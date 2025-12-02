#!/usr/bin/env bash
# Transforms Rust target triples into user-friendly platform names.
# Usage: ./get-friendly-target-name.sh <target-triple>
# Outputs the friendly name if mapped, otherwise the original target triple.

set -euo pipefail

declare -A TARGET_MAP=(
  # =============================================================================
  # Linux - glibc
  # =============================================================================
  ["x86_64-unknown-linux-gnu"]="linux-x64"
  ["i686-unknown-linux-gnu"]="linux-x86"
  ["i586-unknown-linux-gnu"]="linux-i586"
  ["aarch64-unknown-linux-gnu"]="linux-arm64"
  ["aarch64_be-unknown-linux-gnu"]="linux-arm64-be"
  ["arm-unknown-linux-gnueabi"]="linux-armv6"
  ["arm-unknown-linux-gnueabihf"]="linux-armv6-hf"
  ["armv5te-unknown-linux-gnueabi"]="linux-armv5te"
  ["armv7-unknown-linux-gnueabi"]="linux-armv7"
  ["armv7-unknown-linux-gnueabihf"]="linux-armv7-hf"
  ["thumbv7neon-unknown-linux-gnueabihf"]="linux-armv7-neon-hf"
  ["loongarch64-unknown-linux-gnu"]="linux-loongarch64"
  ["riscv64gc-unknown-linux-gnu"]="linux-riscv64"
  ["riscv32gc-unknown-linux-gnu"]="linux-riscv32"
  ["powerpc-unknown-linux-gnu"]="linux-ppc"
  ["powerpc64-unknown-linux-gnu"]="linux-ppc64"
  ["powerpc64le-unknown-linux-gnu"]="linux-ppc64le"
  ["s390x-unknown-linux-gnu"]="linux-s390x"
  ["sparc64-unknown-linux-gnu"]="linux-sparc64"
  ["mips-unknown-linux-gnu"]="linux-mips"
  ["mipsel-unknown-linux-gnu"]="linux-mipsel"
  ["mips64-unknown-linux-gnuabi64"]="linux-mips64"
  ["mips64el-unknown-linux-gnuabi64"]="linux-mips64el"

  # =============================================================================
  # Linux - musl
  # =============================================================================
  ["x86_64-unknown-linux-musl"]="linux-x64-musl"
  ["i686-unknown-linux-musl"]="linux-x86-musl"
  ["i586-unknown-linux-musl"]="linux-i586-musl"
  ["aarch64-unknown-linux-musl"]="linux-arm64-musl"
  ["aarch64_be-unknown-linux-musl"]="linux-arm64-be-musl"
  ["arm-unknown-linux-musleabi"]="linux-armv6-musl"
  ["arm-unknown-linux-musleabihf"]="linux-armv6-hf-musl"
  ["armv5te-unknown-linux-musleabi"]="linux-armv5te-musl"
  ["armv7-unknown-linux-musleabi"]="linux-armv7-musl"
  ["armv7-unknown-linux-musleabihf"]="linux-armv7-hf-musl"
  ["loongarch64-unknown-linux-musl"]="linux-loongarch64-musl"
  ["riscv64gc-unknown-linux-musl"]="linux-riscv64-musl"
  ["powerpc64le-unknown-linux-musl"]="linux-ppc64le-musl"
  ["s390x-unknown-linux-musl"]="linux-s390x-musl"
  ["mips-unknown-linux-musl"]="linux-mips-musl"
  ["mipsel-unknown-linux-musl"]="linux-mipsel-musl"
  ["mips64-unknown-linux-muslabi64"]="linux-mips64-musl"
  ["mips64el-unknown-linux-muslabi64"]="linux-mips64el-musl"
  ["hexagon-unknown-linux-musl"]="linux-hexagon-musl"

  # =============================================================================
  # Windows - MSVC
  # =============================================================================
  ["x86_64-pc-windows-msvc"]="windows-x64"
  ["i686-pc-windows-msvc"]="windows-x86"
  ["aarch64-pc-windows-msvc"]="windows-arm64"
  ["arm64ec-pc-windows-msvc"]="windows-arm64ec"
  ["thumbv7a-pc-windows-msvc"]="windows-thumbv7a"

  # =============================================================================
  # Windows - GNU (MinGW)
  # =============================================================================
  ["x86_64-pc-windows-gnu"]="windows-x64-gnu"
  ["i686-pc-windows-gnu"]="windows-x86-gnu"
  ["x86_64-pc-windows-gnullvm"]="windows-x64-gnullvm"
  ["i686-pc-windows-gnullvm"]="windows-x86-gnullvm"
  ["aarch64-pc-windows-gnullvm"]="windows-arm64-gnullvm"

  # =============================================================================
  # macOS / Darwin
  # =============================================================================
  ["x86_64-apple-darwin"]="macos-x64"
  ["aarch64-apple-darwin"]="macos-arm64"
  ["arm64e-apple-darwin"]="macos-arm64e"
  ["i686-apple-darwin"]="macos-x86"
  ["x86_64h-apple-darwin"]="macos-x64-haswell"

  # =============================================================================
  # iOS
  # =============================================================================
  ["aarch64-apple-ios"]="ios-arm64"
  ["aarch64-apple-ios-sim"]="ios-arm64-sim"
  ["aarch64-apple-ios-macabi"]="ios-arm64-catalyst"
  ["arm64e-apple-ios"]="ios-arm64e"
  ["armv7s-apple-ios"]="ios-armv7s"
  ["x86_64-apple-ios"]="ios-x64"
  ["x86_64-apple-ios-macabi"]="ios-x64-catalyst"
  ["i386-apple-ios"]="ios-x86"

  # =============================================================================
  # tvOS
  # =============================================================================
  ["aarch64-apple-tvos"]="tvos-arm64"
  ["aarch64-apple-tvos-sim"]="tvos-arm64-sim"
  ["arm64e-apple-tvos"]="tvos-arm64e"
  ["x86_64-apple-tvos"]="tvos-x64"

  # =============================================================================
  # watchOS
  # =============================================================================
  ["aarch64-apple-watchos"]="watchos-arm64"
  ["aarch64-apple-watchos-sim"]="watchos-arm64-sim"
  ["arm64_32-apple-watchos"]="watchos-arm64_32"
  ["armv7k-apple-watchos"]="watchos-armv7k"
  ["x86_64-apple-watchos-sim"]="watchos-x64-sim"

  # =============================================================================
  # visionOS
  # =============================================================================
  ["aarch64-apple-visionos"]="visionos-arm64"
  ["aarch64-apple-visionos-sim"]="visionos-arm64-sim"

  # =============================================================================
  # Android
  # =============================================================================
  ["aarch64-linux-android"]="android-arm64"
  ["armv7-linux-androideabi"]="android-armv7"
  ["arm-linux-androideabi"]="android-armv6"
  ["thumbv7neon-linux-androideabi"]="android-armv7-neon"
  ["x86_64-linux-android"]="android-x64"
  ["i686-linux-android"]="android-x86"
  ["riscv64-linux-android"]="android-riscv64"

  # =============================================================================
  # Game Consoles
  # =============================================================================
  ["aarch64-nintendo-switch-freestanding"]="switch-arm64"
  ["armv6k-nintendo-3ds"]="3ds-armv6k"
  ["armv7-sony-vita-newlibeabihf"]="psvita-armv7-hf"
  ["mipsel-sony-psp"]="psp-mipsel"
  ["mipsel-sony-psx"]="ps1-mipsel"

  # =============================================================================
  # BSD Family
  # =============================================================================
  ["x86_64-unknown-freebsd"]="freebsd-x64"
  ["i686-unknown-freebsd"]="freebsd-x86"
  ["aarch64-unknown-freebsd"]="freebsd-arm64"
  ["armv6-unknown-freebsd"]="freebsd-armv6"
  ["armv7-unknown-freebsd"]="freebsd-armv7"
  ["powerpc64-unknown-freebsd"]="freebsd-ppc64"
  ["powerpc64le-unknown-freebsd"]="freebsd-ppc64le"
  ["riscv64gc-unknown-freebsd"]="freebsd-riscv64"

  ["x86_64-unknown-netbsd"]="netbsd-x64"
  ["i686-unknown-netbsd"]="netbsd-x86"
  ["aarch64-unknown-netbsd"]="netbsd-arm64"
  ["armv6-unknown-netbsd-eabihf"]="netbsd-armv6-hf"
  ["armv7-unknown-netbsd-eabihf"]="netbsd-armv7-hf"
  ["sparc64-unknown-netbsd"]="netbsd-sparc64"
  ["riscv64gc-unknown-netbsd"]="netbsd-riscv64"
  ["mipsel-unknown-netbsd"]="netbsd-mipsel"
  ["powerpc-unknown-netbsd"]="netbsd-ppc"

  ["x86_64-unknown-openbsd"]="openbsd-x64"
  ["i686-unknown-openbsd"]="openbsd-x86"
  ["aarch64-unknown-openbsd"]="openbsd-arm64"
  ["sparc64-unknown-openbsd"]="openbsd-sparc64"
  ["powerpc64-unknown-openbsd"]="openbsd-ppc64"
  ["riscv64gc-unknown-openbsd"]="openbsd-riscv64"

  ["x86_64-unknown-dragonfly"]="dragonfly-x64"

  # =============================================================================
  # Solaris / illumos
  # =============================================================================
  ["x86_64-pc-solaris"]="solaris-x64"
  ["sparcv9-sun-solaris"]="solaris-sparc64"
  ["x86_64-unknown-illumos"]="illumos-x64"
  ["aarch64-unknown-illumos"]="illumos-arm64"

  # =============================================================================
  # Redox OS
  # =============================================================================
  ["x86_64-unknown-redox"]="redox-x64"
  ["aarch64-unknown-redox"]="redox-arm64"
  ["i586-unknown-redox"]="redox-i586"

  # =============================================================================
  # Fuchsia
  # =============================================================================
  ["x86_64-unknown-fuchsia"]="fuchsia-x64"
  ["aarch64-unknown-fuchsia"]="fuchsia-arm64"
  ["riscv64gc-unknown-fuchsia"]="fuchsia-riscv64"

  # =============================================================================
  # Haiku
  # =============================================================================
  ["x86_64-unknown-haiku"]="haiku-x64"
  ["i686-unknown-haiku"]="haiku-x86"

  # =============================================================================
  # WebAssembly
  # =============================================================================
  ["wasm32-unknown-unknown"]="wasm32"
  ["wasm32-unknown-emscripten"]="wasm32-emscripten"
  ["wasm32-wasip1"]="wasm32-wasip1"
  ["wasm32-wasip1-threads"]="wasm32-wasip1-threads"
  ["wasm32-wasip2"]="wasm32-wasip2"
  ["wasm32-wasip3"]="wasm32-wasip3"
  ["wasm32v1-none"]="wasm32v1"
  ["wasm64-unknown-unknown"]="wasm64"

  # =============================================================================
  # UEFI
  # =============================================================================
  ["x86_64-unknown-uefi"]="uefi-x64"
  ["i686-unknown-uefi"]="uefi-x86"
  ["aarch64-unknown-uefi"]="uefi-arm64"

  # =============================================================================
  # QNX Neutrino RTOS
  # =============================================================================
  ["aarch64-unknown-nto-qnx710"]="qnx710-arm64"
  ["aarch64-unknown-nto-qnx800"]="qnx800-arm64"
  ["x86_64-pc-nto-qnx710"]="qnx710-x64"
  ["x86_64-pc-nto-qnx800"]="qnx800-x64"
  ["i686-pc-nto-qnx700"]="qnx700-x86"

  # =============================================================================
  # VxWorks RTOS
  # =============================================================================
  ["x86_64-wrs-vxworks"]="vxworks-x64"
  ["i686-wrs-vxworks"]="vxworks-x86"
  ["aarch64-wrs-vxworks"]="vxworks-arm64"
  ["armv7-wrs-vxworks-eabihf"]="vxworks-armv7-hf"
  ["powerpc-wrs-vxworks"]="vxworks-ppc"
  ["powerpc64-wrs-vxworks"]="vxworks-ppc64"
  ["riscv32-wrs-vxworks"]="vxworks-riscv32"
  ["riscv64-wrs-vxworks"]="vxworks-riscv64"

  # =============================================================================
  # ESP32 / Xtensa
  # =============================================================================
  ["xtensa-esp32-espidf"]="esp32"
  ["xtensa-esp32-none-elf"]="esp32-baremetal"
  ["xtensa-esp32s2-espidf"]="esp32s2"
  ["xtensa-esp32s2-none-elf"]="esp32s2-baremetal"
  ["xtensa-esp32s3-espidf"]="esp32s3"
  ["xtensa-esp32s3-none-elf"]="esp32s3-baremetal"
  ["riscv32imc-esp-espidf"]="esp32c3"
  ["riscv32imac-esp-espidf"]="esp32c6"

  # =============================================================================
  # NVIDIA GPU (PTX)
  # =============================================================================
  ["nvptx64-nvidia-cuda"]="cuda-ptx64"

  # =============================================================================
  # Hermit Unikernel
  # =============================================================================
  ["x86_64-unknown-hermit"]="hermit-x64"
  ["aarch64-unknown-hermit"]="hermit-arm64"
  ["riscv64gc-unknown-hermit"]="hermit-riscv64"
)

TARGET="${1:-}"
if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <target-triple>" >&2
  exit 1
fi

# Lookup in map, fallback to original if not found
FRIENDLY_NAME="${TARGET_MAP[$TARGET]:-$TARGET}"
echo "$FRIENDLY_NAME"
