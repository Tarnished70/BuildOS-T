login_main
# Normal build steps
. build/envsetup.sh
# RBE
. /tmp/ci/rbe
# --- BuildBuddy Connection Settings ---
#export RBE_service="nexgang.buildbuddy.io:443"
#export RBE_remote_headers="x-buildbuddy-api-key=0mjw9c0kEWHrzTHaAMTy"
#export RBE_remote_executor="grpcs://nexgang.buildbuddy.io"
#export RBE_remote_cache="grpcs://nexgang.buildbuddy.io"
#export RBE_remote_timeout="10m"

#export RBE_CXX_LINKS_EXEC_STRATEGY=local
export RBE_LOG_LEVEL=debug
export USE_CCACHE=0
export NINJA_ARGS="-j16"
env | grep RBE

lunch lineage_lavender-userdebug

build_gapps=0

# export variable here
export TZ=Asia/Kolkata
export SELINUX_IGNORE_NEVERALLOWS=true
export RELAX_USES_LIBRARY_CHECK=true
export WITH_GMS=false
export USE_CCACHE=0

exp_gapps () {
export USE_GAPPS=false
}

compile_plox () {

m bacon -j80

# KSU bc -_-
if [ -e "/tmp/rom/out/error.log" ] && [ ! -e out/target/product/*/*.zip ] && [ $(cat /tmp/rom/out/error.log | grep -o -e 'KernelSU' -e 'FAILED: ' | head -n 1) ]; then
m bacon -j16
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
repo sync android_bionic
make bacon -j16
fi
}
