# Normal build steps
. build/envsetup.sh
lunch qassa_lavender-user

build_gapps=0

# export variable here
export TZ=Asia/Kolkata
export SELINUX_IGNORE_NEVERALLOWS=true
export USE_GAPPS=false
export WITH_GAPPS=false

exp_gapps () {
export USE_GAPPS=true
export WITH_GAPPS=true
}

compile_plox () {
mka qassa -j16
#make Settings -j16
#upload out/target/product/lavender/system/product/priv-app/Settings/Settings.apk
}
