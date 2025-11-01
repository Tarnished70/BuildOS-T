#!/usr/bin/env bash
set -e -o pipefail

# =============================
# Basic Configuration
# =============================
KERNEL_DIR="$(pwd)"
CHAT_ID="-1001537211587"
TOKEN="7911765578:AAFN90U-GMGmzf5TINpbZKG8C0SuiKmRi_I"
COMPILER="llvm"   # llvm or default (aosp)
DEFCONFIG="lavender_defconfig"
IMAGE=${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb
VERBOSE=0         # Set to 1 for verbose build

exports() {
DEVICE="lavender"
VERSION=v1.0
KERNELNAME="whynot"
TANGGAL=$(date +"%Y%m%d-%H%M")
ZIPNAME="${KERNELNAME}${TYPE}-${DEVICE}-${TANGGAL}.zip"
}

# Dynamic Partition
if [ "$1" = "--Legacy" ]; then
TYPE="-Legacy"
git apply drop_rdp.p
elif [ "$1" = "--ORDP" ]; then
TYPE="-Dynamic-OLD"
git apply -R drop_rdp.p
else
TYPE="-Dynamic"
git apply drop_old_rdp.p
fi

# =============================
# Telegram Upload Function
# =============================
telegram_push() {
  curl --progress-bar -F document=@"$1" \
    "https://api.telegram.org/bot${TOKEN}/sendDocument" \
    -F chat_id="${CHAT_ID}" \
    -F "disable_web_page_preview=true" \
    -F "parse_mode=Markdown" \
    -F caption="$2"
}

# =============================
# Compiler Setup
# =============================
if [ "$COMPILER" = "llvm" -a ! -d clang ]; then
  echo -e "\e[32mCompiler Set As LLVM Clang\e[0m"
  mkdir -p clang
  wget -qO- https://www.kernel.org/pub/tools/llvm/files/llvm-21.1.4-x86_64.tar.gz | tar --strip-components=1 -xz -C clang
  rm -rf llvm-*.tar.gz
  export PATH="${KERNEL_DIR}/clang/bin:$PATH"
fi

# =============================
# Clone AnyKernel3
# =============================
if [ ! -d AnyKernel3 ]; then
git clone https://github.com/ImSpiDy/AnyKernel3 --depth=1
fi

# =============================
# Build Environment
# =============================
export KBUILD_BUILD_USER="RoHaNRaJ"
export KBUILD_BUILD_HOST="ArchLinux"
PROCS=$(nproc --all)

# =============================
# Build Function
# =============================
compile() {
  START=$(date +"%s")

  make O=out ARCH=arm64 "${DEFCONFIG}" LLVM=1
  make -kj"${PROCS}" O=out ARCH=arm64 LLVM=1 V="${VERBOSE}" 2>&1 | tee error.log || true

  END=$(date +"%s")
  DIFF=$((END - START))

  if [ ! -f "${IMAGE}" ]; then
    telegram_push "error.log" "**Build Failed**"
    exit 1
  fi
}

# =============================
# Zipping Function
# =============================
zipping() {
  mv "${IMAGE}" AnyKernel3/

  cd AnyKernel3 || exit 1
  zip -r9 "${ZIPNAME}" ./* -x .git README.md
  cd "${KERNEL_DIR}" || exit 1
}

# =============================
# Upload Function
# =============================
upload() {
  telegram_push "AnyKernel3/${ZIPNAME}" \
    "Build took : $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s)"
  rm -rf "AnyKernel3/${ZIPNAME}"
}

# =============================
# Main Execution Flow
# =============================
exports
compile
zipping
upload
