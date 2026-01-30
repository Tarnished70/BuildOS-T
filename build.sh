login_main
# Normal build steps
. build/envsetup.sh
# RBE
. /tmp/ci/rbe
#export NINJA_REMOTE_NUM_JOBS=150
#export RBE_CXX_LINKS_EXEC_STRATEGY=local
#export RBE_METALAVA_EXEC_STRATEGY=local
export RBE_LOG_LEVEL=debug
export RBE_local_resource_fraction=0.4
#export USE_CCACHE=0
env | grep RBE
lunch lineage_miatoll-userdebug

build_gapps=0

# export variable here
export TZ=Asia/Kolkata
export SELINUX_IGNORE_NEVERALLOWS=true
export RELAX_USES_LIBRARY_CHECK=true
export WITH_GMS=false
#export USE_CCACHE=0

exp_gapps () {
export USE_GAPPS=false
}

compile_plox () {

m bacon -j80

# KSU bc -_-
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ] && [ $(cat /tmp/rom/out/error.log | grep -o -e 'KernelSU' -e 'FAILED: ' | head -n 1) ]; then
m bacon -j80
fi

# 5min break for quick fix
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ]; then
push_log
tg "- Push your fix asap...!"
sleep 5m
git -C device/xiaomi/sm6250-common pull -r
#repo sync android_bionic
make bacon -j16
fi
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ]; then
push_log
tg "- Push your fix asap...!"
sleep 5m
git -C device/xiaomi/sm6250-common pull -r
repo sync android_bionic
make bacon -j16
fi
}
