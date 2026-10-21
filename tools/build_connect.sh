#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
DEPS="${CONNECT_DEPS_ROOT:-${ROOT}/deps/connect}"
PYTHON="${PYTHON:-python3}"
if [[ "$(uname -s)" != "Linux" ]]; then
  echo "Connect's query-cache build requires Linux with an x86 C++ toolchain." >&2
  exit 1
fi
mkdir -p "${DEPS}" "${ROOT}/build/connect" "${ROOT}/dist/connect"

clone_dependency() {
  local url="$1" destination="$2" branch="${3:-}"
  if [[ -d "${destination}/.git" ]]; then return; fi
  if [[ -n "${branch}" ]]; then
    git clone --depth 1 --recursive --shallow-submodules --branch "${branch}" "${url}" "${destination}"
  else
    git clone --depth 1 --recursive --shallow-submodules "${url}" "${destination}"
  fi
}

clone_dependency https://github.com/alliedmodders/ambuild.git "${DEPS}/ambuild"
clone_dependency https://github.com/alliedmodders/hl2sdk.git "${DEPS}/hl2sdk-css" css
clone_dependency https://github.com/alliedmodders/hl2sdk-manifests.git "${DEPS}/hl2sdk-manifests"
clone_dependency https://github.com/alliedmodders/sourcemod.git "${DEPS}/sourcemod" 1.12-dev
clone_dependency https://github.com/alliedmodders/metamod-source.git "${DEPS}/metamod-source" 1.12-dev

# Preserve the SDK's encoding and line endings while making its global delete
# definitions agree with GCC's standard exception specification.
"${PYTHON}" - "${DEPS}/sourcemod/public/smsdk_ext.cpp" <<'PY'
from pathlib import Path
import re, sys
path = Path(sys.argv[1])
raw = path.read_bytes()
pattern = rb'(?m)^([ \t]*void operator delete(?:\[\])?\(void[ \t]+\*[ \t]*ptr\))(?:[ \t]+noexcept)?([ \t]*\r?)$'
updated, count = re.subn(pattern, rb'\1 noexcept\2', raw)
if count != 2:
    raise SystemExit(f'Expected the SDK scalar/array delete definitions; found {count}')
path.write_bytes(updated)
PY

"${PYTHON}" -m venv "${DEPS}/venv"
"${DEPS}/venv/bin/python" -m pip install --disable-pip-version-check "${DEPS}/ambuild"
pushd "${ROOT}/build/connect" >/dev/null
CC=gcc CXX=g++ "${DEPS}/venv/bin/python" "${ROOT}/connect/configure.py" \
  --enable-optimize --sdks=css --targets=x86 \
  --hl2sdk-root="${DEPS}" \
  --hl2sdk-manifest-path="${DEPS}/hl2sdk-manifests" \
  --sm-path="${DEPS}/sourcemod" --mms-path="${DEPS}/metamod-source"
"${DEPS}/venv/bin/ambuild"
popd >/dev/null

BINARY="${ROOT}/build/connect/package/addons/sourcemod/extensions/connect.ext.2.css.so"
test -f "${BINARY}"
"${PYTHON}" - "${BINARY}" <<'PY'
from pathlib import Path
import sys
data = Path(sys.argv[1]).read_bytes()
if data[:5] != b'\x7fELF\x01' or int.from_bytes(data[18:20], 'little') != 3:
    raise SystemExit('Expected an ELF x86 32-bit extension')
if b'sv_gamedesc_override' not in data:
    raise SystemExit('The built extension is missing its game-description cvar')
PY
if nm -D --undefined-only "${BINARY}" | grep -Eq 'Plat_localtime|Con(Color)?Msg|Error$|Warning$'; then
  echo "The Connect build still has unresolved CSS runtime helpers." >&2
  exit 1
fi
"${PYTHON}" - "${ROOT}" <<'PY'
from pathlib import Path
import shutil, sys, zipfile
root = Path(sys.argv[1])
package = root / 'dist/connect/package'
if package.exists():
    if package.resolve().parent != (root / 'dist/connect').resolve():
        raise SystemExit('Unexpected Connect package path')
    shutil.rmtree(package)
shutil.copytree(root / 'build/connect/package', package)
with zipfile.ZipFile(root / 'dist/shroudfire-connect-linux-x86.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
    for file in sorted(package.rglob('*')):
        if file.is_file(): archive.write(file, file.relative_to(package).as_posix())
print('Connect install tree:', package)
print('Connect ZIP:', root / 'dist/shroudfire-connect-linux-x86.zip')
PY
