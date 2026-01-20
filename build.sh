# Normal build steps

. build/envsetup.sh
# RBE
. /tmp/ci/rbe
#export RBE_METALAVA_EXEC_STRATEGY=local
export RBE_LOG_LEVEL=debug
#export JAVA_OPTS="-Xmx4g"
#export ANDROID_JAVA_OPTIONS="-Xmx4g"
#export _JAVA_OPTIONS="-Xmx4g"
export NINJA_ARGS="-j12"
#env | grep RBE
lunch voltage_lavender-userdebug

build_gapps=0

# export variable here
export TZ=Asia/Kolkata
export SELINUX_IGNORE_NEVERALLOWS=true
export RELAX_USES_LIBRARY_CHECK=true
if [ $K19 == 1 ]; then
export TARGET_KERNEL_VERSION=4.19
elif [ $K19 == 0 ]; then
export TARGET_KERNEL_VERSION=4.4
fi
#export PRODUCT_DEFAULT_DEV_CERTIFICATE=vendor/lineage-priv/keys/releasekey
export WITH_GMS=false

exp_gapps () {
export USE_GAPPS=false
}

login_main

get_system () {
[ ! -e out/target/product/lavender/system.img ] && make systemimage -j16
[ ! -e out/target/product/lavender/system.img ] && tg "System.img buid failed!" && exit 0
echo "System.img Build Succeed!"
echo "- Zipping system"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_system.zip out/target/product/lavender/system.img
upload *_system.zip
}

get_product () {
[ ! -e out/target/product/lavender/product.img ] && make productimage -j16
[ ! -e out/target/product/lavender/product.img ] && tg "Product.img buid failed!" && exit 0
echo "Product.img Build Succeed!"
echo "- Zipping product"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_product.zip out/target/product/lavender/product.img
upload *_product.zip
}

get_system_ext () {
[ ! -e out/target/product/lavender/system_ext.img ] && make systemextimage -j16
[ ! -e out/target/product/lavender/system_ext.img ] && tg "System_ext.img buid failed!" && exit 0
echo "System_ext.img Build Succeed!"
echo "- Zipping system_ext"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_system_ext.zip out/target/product/lavender/system_ext.img
upload *_system_ext.zip
}

get_vendor () {
[ ! -e out/target/product/lavender/vendor.img ] && make vendorimage -j16
[ ! -e out/target/product/lavender/vendor.img ] && tg "Vendor.img buid failed!" && exit 0
echo "Vendor.img Build Succeed!"
echo "- Zipping vendor"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_vendor.zip out/target/product/lavender/vendor.img
upload *_vendor.zip
}

get_odm () {
[ ! -e out/target/product/lavender/odm.img ] && make odmimage -j16
[ ! -e out/target/product/lavender/odm.img ] && tg "odm.img buid failed!" && exit 0
echo "odm.img Build Succeed!"
echo "- Zipping odm"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_odm.zip out/target/product/lavender/odm.img
upload *_odm.zip
}

get_boot () {
[ ! -e out/target/product/lavender/boot.img ] && make bootimage -j16
[ ! -e out/target/product/lavender/boot.img ] && tg "Boot.img buid failed!" && exit 0
echo "Boot.img Build Succeed!"
echo "- Zipping boot"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_boot.zip out/target/product/lavender/boot.img
upload *_boot.zip
}

prepare_images () {
tg "- Preparing for flashable build!"
[ ! -e out/target/product/lavender/system.img ] && gh release download -R $upload_link ${rom_name} -p '*_system.zip' && unzip *_system.zip
[ ! -e out/target/product/lavender/product.img ] && gh release download -R $upload_link ${rom_name} -p '*_product.zip' && unzip *_product.zip
[ ! -e out/target/product/lavender/system_ext.img ] && gh release download -R $upload_link ${rom_name} -p '*_system_ext.zip' && unzip *_system_ext.zip
[ ! -e out/target/product/lavender/vendor.img ] && gh release download -R $upload_link ${rom_name} -p '*_vendor.zip' && unzip *_vendor.zip
[ ! -e out/target/product/lavender/odm.img ] && gh release download -R $upload_link ${rom_name} -p '*_odm.zip' && unzip *_odm.zip
[ ! -e out/target/product/lavender/boot.img ] && gh release download -R $upload_link ${rom_name} -p '*_boot.zip' && unzip *_boot.zip
mv out/target/product/lavender/system.img out/target/product/lavender/product.img out/target/product/lavender/system_ext.img out/target/product/lavender/vendor.img out/target/product/lavender/odm.img out/target/product/lavender/boot.img /tmp/ci/nex
cd /tmp/ci/nex
echo "- Convert sparse images to raw images"
simg2img system.img system.img.raw
simg2img vendor.img vendor.img.raw
simg2img product.img product.img.raw
simg2img odm.img odm.img.raw
simg2img system_ext.img system_ext.img.raw
echo "- Map dynamic partition"
echo "resize system $(du -sb $PWD/system.img.raw  | cut -d - -f 1 | cut -d / -f 1)" >> dynamic_partitions_op_list
echo "resize vendor $(du -sb $PWD/vendor.img.raw  | cut -d - -f 1 | cut -d / -f 1)" >> dynamic_partitions_op_list
echo "resize product $(du -sb $PWD/product.img.raw  | cut -d - -f 1 | cut -d / -f 1)" >> dynamic_partitions_op_list
echo "resize odm $(du -sb $PWD/odm.img.raw  | cut -d - -f 1 | cut -d / -f 1)" >> dynamic_partitions_op_list
echo "resize system_ext $(du -sb $PWD/system_ext.img.raw  | cut -d - -f 1 | cut -d / -f 1)" >> dynamic_partitions_op_list
echo "- Print dynamic_partitions_op_list"
cat dynamic_partitions_op_list
echo "- Cleanup raw images after collecting sizes for dynamic partition"
rm -rf *.img.raw
}

convert_dat () {
tg "- Repack *.new.dat"
bin=/tmp/ci/bin/linux
python3 $bin/img2sdat.py system.img -o /tmp/ci/nex -v 4 && rm -rf system.img
python3 $bin/img2sdat.py vendor.img -o /tmp/ci/nex -v 4 -p vendor && rm -rf vendor.img
python3 $bin/img2sdat.py product.img -o /tmp/ci/nex -v 4 -p product && rm -rf product.img
python3 $bin/img2sdat.py odm.img -o /tmp/ci/nex -v 4 -p odm && rm -rf odm.img
python3 $bin/img2sdat.py system_ext.img -o /tmp/ci/nex -v 4 -p system_ext && rm -rf system_ext.img
}

convert_br () {
tg "- Repack *.dat.br"
ls /tmp/ci/nex
brotli -6 -jv system.new.dat -o system.new.dat.br
brotli -6 -jv vendor.new.dat -o vendor.new.dat.br
brotli -6 -jv product.new.dat -o product.new.dat.br
brotli -6 -jv odm.new.dat -o odm.new.dat.br
brotli -6 -jv system_ext.new.dat -o system_ext.new.dat.br
}

final_zip () {
prepare_images
convert_dat
convert_br
tg "- Zipping OTA Package"
zip -r1v VoltageOS-13-Community-lavender-$(date +"%Y%m%d-%H%S").zip *
mkdir -p /tmp/rom/out/target/product/lavender
mv *.zip /tmp/rom/out/target/product/lavender
cd /tmp/rom && ls /tmp/rom/out/target/product/lavender/*.zip
}

split_build () {
case "$build_type" in
		 c|C|s|S)
		 # part 1
		 get_product
		 get_system_ext
		 get_system
		 ;;
		 *)
		 # part 2
		 get_vendor
		 # fking ksu errors
		 ls out/target/product/lavender/vendor.img || get_vendor
		 get_odm
		 get_boot
esac
}

compile_plox () {
#split_build

#get_product
#get_system_ext
#get_system
#get_vendor
# fking ksu errors
#ls out/target/product/lavender/vendor.img || get_vendor
#get_odm
#ls out/target/product/lavender/boot.img || get_boot
#final_zip
#m productimage
#m systemextimage
#m systemimage
m bacon -j80

# KSU bc -_-
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ] && [ $(cat /tmp/rom/out/error.log | grep -o -e 'KernelSU' -e 'FAILED: ' | head -n 1) ]; then
m bacon -j16
fi
# 5min break for quick fix
login_main
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ]; then
push_log
tg "- Push your fix asap...!"
sleep 5m
git -C device/xiaomi/sdm660-common pull -r
git -C device/xiaomi/lavender pull -r
git -C hardware/qcom-caf/sdm660/media pull -r
#repo sync android_bionic
make bacon -j16
fi
# another 5m break
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ]; then
push_log
tg "- Push your fix asap...!"
sleep 5m
git -C device/xiaomi/sdm660-common pull -r
git -C device/xiaomi/lavender pull -r
git -C hardware/qcom-caf/sdm660/media pull -r
#repo sync android_bionic
make bacon -j16
fi
}
