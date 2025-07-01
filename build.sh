# switch to main account
login_main

# Normal build steps
. build/envsetup.sh
# RBE
. /tmp/ci/rbe
#export NINJA_REMOTE_NUM_JOBS=150
export RBE_CXX_LINKS_EXEC_STRATEGY=local
export RBE_METALAVA_EXEC_STRATEGY=local
export RBE_LOG_LEVEL=debug
export USE_CCACHE=0
lunch aosp_lavender-userdebug

# export variable here
export TZ=Asia/Kolkata
export SELINUX_IGNORE_NEVERALLOWS=true
export RELAX_USES_LIBRARY_CHECK=true
export TARGET_KERNEL_VERSION=4.19
export PRODUCT_DEFAULT_DEV_CERTIFICATE=vendor/lineage-priv/keys/releasekey
export USE_CCACHE=0

build_gapps=1
# first build vanilla
export WITH_GMS=false
export WITH_GAPPS=false

# second with gms
exp_gapps() {
export USE_GAPPS=true
export WITH_GMS=true
export WITH_GAPPS=true
}

compile_plox () {
make bacon -j16

# KSU bc -_-
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ] && [ $(cat /tmp/rom/out/error.log | grep -o -e 'KernelSU' | head -n 1) ]; then
make bacon -j16
fi

# 5min break for quick fix
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ]; then
push_log
tg "- Push your fix asap...!"
sleep 5m
git -C device/xiaomi/sdm660-common pull -r
git -C device/xiaomi/lavender pull -r
git -C hardware/qcom-caf/sdm660/camera pull -r
#repo sync android_bionic
make bacon -j16
fi

if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ]; then
push_log
tg "- Push your fix asap...!"
sleep 5m
git -C device/xiaomi/sdm660-common pull -r
git -C device/xiaomi/lavender pull -r
git -C hardware/qcom-caf/sdm660/camera pull -r
#repo sync android_bionic
make bacon -j16
fi
}
