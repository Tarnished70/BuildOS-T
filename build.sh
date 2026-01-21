# Normal build steps

. build/envsetup.sh
# RBE
. /tmp/ci/rbe
#export RBE_METALAVA_EXEC_STRATEGY=local

#export RBE_D8_EXEC_STRATEGY=local
#export RBE_R8_EXEC_STRATEGY=remote
export RBE_LOG_LEVEL=debug
export JAVA_OPTS="-Xmx4g"
export ANDROID_JAVA_OPTIONS="-Xmx4g"
export _JAVA_OPTIONS="-Xmx4g"
export RBE_local_resource_fraction=0.1
#export NINJA_ARGS="-j80"
#env | grep RBE
export USE_CCACHE=0
lunch derp_lavender-userdebug
export USE_CCACHE=0

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
export WITH_GMS=true

exp_gapps () {
export USE_GAPPS=false
}

login_main

upload_backup () {
# git upload
gh release create $rom_name --generate-notes --repo $cache_link
gh release upload --clobber $rom_name $1 --repo $cache_link
}

get_system () {
[ ! -e out/target/product/lavender/system.img ] && make systemimage -j80
[ ! -e out/target/product/lavender/system.img ] && tg "System.img buid failed!" && exit 0
tg "System.img Build Succeed!"
echo "- Zipping system"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_system.zip out/target/product/lavender/system.img
upload_backup *_system.zip
}

get_product () {
[ ! -e out/target/product/lavender/product.img ] && make productimage -j80
[ ! -e out/target/product/lavender/product.img ] && tg "Product.img buid failed!" && exit 0
tg "Product.img Build Succeed!"
echo "- Zipping product"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_product.zip out/target/product/lavender/product.img
upload_backup *_product.zip
}

get_system_ext () {
[ ! -e out/target/product/lavender/system_ext.img ] && make systemextimage -j80
[ ! -e out/target/product/lavender/system_ext.img ] && tg "System_ext.img buid failed!" && exit 0
tg "System_ext.img Build Succeed!"
echo "- Zipping system_ext"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_system_ext.zip out/target/product/lavender/system_ext.img
upload_backup *_system_ext.zip
}

get_vendor () {
[ ! -e out/target/product/lavender/vendor.img ] && make vendorimage -j80
[ ! -e out/target/product/lavender/vendor.img ] && tg "Vendor.img buid failed!" && exit 0
tg "Vendor.img Build Succeed!"
echo "- Zipping vendor"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_vendor.zip out/target/product/lavender/vendor.img
upload_backup *_vendor.zip
}

get_odm () {
[ ! -e out/target/product/lavender/odm.img ] && make odmimage -j8
[ ! -e out/target/product/lavender/odm.img ] && tg "odm.img buid failed!" && exit 0
tg "odm.img Build Succeed!"
echo "- Zipping odm"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_odm.zip out/target/product/lavender/odm.img
upload_backup *_odm.zip
}

get_boot () {
[ ! -e out/target/product/lavender/boot.img ] && make bootimage -j8
[ ! -e out/target/product/lavender/boot.img ] && tg "Boot.img buid failed!" && exit 0
tg "Boot.img Build Succeed!"
echo "- Zipping boot"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_boot.zip out/target/product/lavender/boot.img
upload_backup *_boot.zip
}

get_dtbo () {
[ ! -e out/target/product/lavender/dtbo.img ] && make dtboimage -j8
[ ! -e out/target/product/lavender/dtbo.img ] && tg "Dtbo.img buid failed!" && exit 0
tg "Dtbo.img Build Succeed!"
echo "- Zipping dtbo"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_dtbo.zip out/target/product/lavender/dtbo.img
upload_backup *_dtbo.zip
}

prepare_images () {
tg "- Preparing for flashable build!"
[ ! -e out/target/product/lavender/system.img ] && down $cache_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_system.zip && unzip *_system.zip
[ ! -e out/target/product/lavender/product.img ] && down $cache_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_product.zip && unzip *_product.zip
[ ! -e out/target/product/lavender/system_ext.img ] && down $cache_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_system_ext.zip && unzip *_system_ext.zip
[ ! -e out/target/product/lavender/vendor.img ] && down $cache_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_vendor.zip && unzip *_vendor.zip
[ ! -e out/target/product/lavender/odm.img ] && down $cache_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_odm.zip && unzip *_odm.zip
[ ! -e out/target/product/lavender/boot.img ] && down $cache_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_boot.zip && unzip *_boot.zip
[ ! -e out/target/product/lavender/dtbo.img ] && down $cache_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_dtbo.zip && unzip *_dtbo.zip
mv out/target/product/lavender/system.img out/target/product/lavender/product.img out/target/product/lavender/system_ext.img out/target/product/lavender/vendor.img out/target/product/lavender/odm.img out/target/product/lavender/boot.img out/target/product/lavender/dtbo.img /tmp/ci/nex
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
zip -r1v DerpFest-13-Community-Tango-lavender-$(date +"%Y%m%d-%H%S").zip *
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
get_vendor
# fking ksu errors
ls out/target/product/lavender/vendor.img || get_vendor
get_odm
ls out/target/product/lavender/boot.img || get_boot
ls out/target/product/lavender/dtbo.img || get_dtbo
final_zip
#make productimage -j80
#make systemextimage -j80
#make systemimage -j80
#make vendorimage -j80
#export NINJA_ARGS="-j10"
#make derp -j48

# KSU bc -_-
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ] && [ $(cat /tmp/rom/out/error.log | grep -o -e 'KernelSU' -e 'FAILED: ' | head -n 1) ]; then
make derp -j48
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
make derp -j16
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
make derp -j16
fi
}
