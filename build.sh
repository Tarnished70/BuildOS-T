# Normal build steps
. build/envsetup.sh
# RBE
. /tmp/ci/rbe
export RBE_CXX_LINKS_EXEC_STRATEGY=local
export RBE_METALAVA_EXEC_STRATEGY=local
#lunch lavender-userdebug
axion lavender gms pico

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
export WITH_GMS=true

exp_gapps () {
export USE_GAPPS=false
}

get_system () {
[ ! -e out/target/product/lavender/system.img ] && make systemimage -j16
[ ! -e out/target/product/lavender/system.img ] && tg "System.img buid failed!" && exit 0
tg "System.img Build Succeed!"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_system.zip out/target/product/lavender/system.img
upload *_system.zip
}

get_product () {
[ ! -e out/target/product/lavender/product.img ] && make productimage -j12
[ ! -e out/target/product/lavender/product.img ] && tg "Product.img buid failed!" && exit 0
tg "Product.img Build Succeed!"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_product.zip out/target/product/lavender/product.img
upload *_product.zip
}

get_system_ext () {
[ ! -e out/target/product/lavender/system_ext.img ] && make systemextimage -j12
[ ! -e out/target/product/lavender/system_ext.img ] && tg "System_ext.img buid failed!" && exit 0
tg "System_ext.img Build Succeed!"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_system_ext.zip out/target/product/lavender/system_ext.img
upload *_system_ext.zip
}

get_vendor () {
[ ! -e out/target/product/lavender/vendor.img ] && make vendorimage -j12
[ ! -e out/target/product/lavender/vendor.img ] && tg "Vendor.img buid failed!" && exit 0
tg "Vendor.img Build Succeed!"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_vendor.zip out/target/product/lavender/vendor.img
upload *_vendor.zip
}

get_odm () {
[ ! -e out/target/product/lavender/odm.img ] && make odmimage -j12
[ ! -e out/target/product/lavender/odm.img ] && tg "odm.img buid failed!" && exit 0
tg "odm.img Build Succeed!"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_odm.zip out/target/product/lavender/odm.img
upload *_odm.zip
}

get_boot () {
[ ! -e out/target/product/lavender/boot.img ] && make bootimage -j12
[ ! -e out/target/product/lavender/boot.img ] && tg "Boot.img buid failed!" && exit 0
tg "Boot.img Build Succeed!"
7za a -tzip ${rom_name}-${branch_name}-${part_id}_boot.zip out/target/product/lavender/boot.img
upload *_boot.zip
}

prepare_images () {
tg "- Preparing for flashable build!"
[ ! -e out/target/product/lavender/system.img ] && down $upload_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_system.zip && unzip *_system.zip
[ ! -e out/target/product/lavender/product.img ] && down $upload_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_product.zip && unzip *_product.zip
[ ! -e out/target/product/lavender/system_ext.img ] && down $upload_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_system_ext.zip && unzip *_system_ext.zip
[ ! -e out/target/product/lavender/vendor.img ] && down $upload_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_vendor.zip && unzip *_vendor.zip
[ ! -e out/target/product/lavender/odm.img ] && down $upload_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_odm.zip && unzip *_odm.zip
[ ! -e out/target/product/lavender/boot.img ] && down $upload_link/releases/download/${rom_name}/${rom_name}-${branch_name}-${part_id}_boot.zip && unzip *_boot.zip
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
zip -r1v ${rom_name}-${branch_name}-Community-lavender-$(date +"%F-%H%S").zip *
upload *.zip && exit 0
}

compile_plox () {
# part 1
#get_system_ext
#get_product
#get_system
#get_vendor
#get_odm
ax_help
setupPerf
setupSwap
#get_boot
# part2 (choose manual zip or bacon if its not in parts)
#final_zip
#m bacon -j16
#./r* lavender -t user -j8
}
