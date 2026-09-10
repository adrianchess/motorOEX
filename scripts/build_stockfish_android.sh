#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd "$(dirname "$0")/.." && pwd)"
output_dir="${1:-$project_dir/build/stockfish-19}"
ndk_dir="${ANDROID_NDK_HOME:?Set ANDROID_NDK_HOME to Android NDK 28.2.13676358}"
case "$(uname -s)" in
  Darwin) host_tag=darwin-x86_64 ;;
  Linux) host_tag=linux-x86_64 ;;
  *) printf 'Unsupported build host\n' >&2; exit 1 ;;
esac
export PATH="$ndk_dir/toolchains/llvm/prebuilt/$host_tag/bin:$PATH"
command -v aarch64-linux-android24-clang++ >/dev/null
command -v llvm-readelf >/dev/null
command -v shasum >/dev/null

mkdir -p "$output_dir"
output_dir="$(cd "$output_dir" && pwd)"
work_dir="$(mktemp -d "${TMPDIR:-/tmp}/stockfish-19.XXXXXX")"
trap 'rm -rf "$work_dir"' EXIT
curl -fL --retry 2 --max-time 120 \
  https://github.com/official-stockfish/Stockfish/archive/refs/tags/sf_19.tar.gz \
  -o "$work_dir/source.tar.gz"
source_hash="$(shasum -a 256 "$work_dir/source.tar.gz" | awk '{print $1}')"
[[ "$source_hash" == 519b653d0d1ffb96531d982ccbe5c6a19425e8388e0e3c2f70f34b424ab32d76 ]]
tar -xzf "$work_dir/source.tar.gz" -C "$work_dir"
cd "$work_dir/Stockfish-sf_19/src"
network="$(awk '/^#define EvalFileDefaultName / {gsub(/"/, "", $3); print $3}' evaluate.h)"
[[ "$network" =~ ^nn-[0-9a-f]{12}\.nnue$ ]]
curl -fL --retry 2 --max-time 300 \
  "https://tests.stockfishchess.org/api/nn/$network" -o "$network" || \
  curl -fL --retry 2 --max-time 300 \
    "https://raw.githubusercontent.com/official-stockfish/networks/master/$network" \
    -o "$network"
network_hash="$(shasum -a 256 "$network" | awk '{print $1}')"
[[ "$network" == "nn-${network_hash:0:12}.nnue" ]]

make -j "${JOBS:-4}" build ARCH=armv8 COMP=ndk \
  COMPCXX=aarch64-linux-android24-clang++ \
  EXTRALDFLAGS='-Wl,-z,max-page-size=16384'
llvm-strip stockfish
elf_report="$(llvm-readelf -h -l -d stockfish)"
grep -q 'Machine:.*AArch64' <<< "$elf_report"
grep -q '/system/bin/linker64' <<< "$elf_report"
awk '/ LOAD / {count++; if ($NF != "0x4000") invalid=1} END {exit (!count || invalid)}' <<< "$elf_report"
if grep -q 'libc++_shared.so' <<< "$elf_report"; then
  printf 'Unexpected shared C++ runtime dependency\n' >&2
  exit 1
fi
cp stockfish "$output_dir/libstockfish.so"
cp "$work_dir/source.tar.gz" "$output_dir/Stockfish-sf_19.tar.gz"
cp "$network" "$output_dir/$network"
cp ../Copying.txt "$output_dir/Copying.txt"
shasum -a 256 "$output_dir/libstockfish.so" "$output_dir/Stockfish-sf_19.tar.gz" "$output_dir/$network"
printf 'Built Stockfish 19: %s/libstockfish.so\n' "$output_dir"