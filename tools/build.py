"""Compile Shroudfire and prepare an install tree and ZIP. No server files are modified."""
from pathlib import Path
import argparse
import shutil
import subprocess
import zipfile
import bz2
import json
import hashlib

ROOT = Path(__file__).resolve().parents[1]

def build(compiler, includes, fastdl=False, connect_package=None):
    dist = ROOT / 'dist'
    package = dist / 'package'
    if package.exists():
        if package.resolve().parent != dist.resolve():
            raise ValueError('Package directory must remain inside dist')
        shutil.rmtree(package)
    package.mkdir(parents=True, exist_ok=True)
    binary = package / 'addons/sourcemod/plugins/shroudfire.smx'
    binary.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run([str(compiler), str(ROOT / 'addons/sourcemod/scripting/shroudfire.sp'),
                    '-i' + str(ROOT / 'addons/sourcemod/scripting/include'),
                    '-i' + str(includes), '-o' + str(binary), '-E'], check=True)
    for folder in ['addons/sourcemod/scripting', 'cfg']:
        shutil.copytree(ROOT / folder, package / folder, dirs_exist_ok=True)
    shutil.copytree(ROOT / 'game-assets', package, dirs_exist_ok=True)
    if connect_package is not None:
        connect_package = connect_package.resolve()
        extensions = connect_package / 'addons/sourcemod/extensions'
        if not (extensions / 'connect.ext.2.css.so').is_file():
            raise ValueError('Connect package is missing connect.ext.2.css.so')
        if not (connect_package / 'addons/sourcemod/gamedata/connect2.games.txt').is_file():
            raise ValueError('Connect package is missing connect2.games.txt')
        if not (extensions / 'connect.autoload').is_file():
            raise ValueError('Connect package is missing connect.autoload')
        shutil.copytree(connect_package, package, dirs_exist_ok=True)
    for name in ['LICENSE', 'NOTICE', 'README.md', 'COMMANDS.md', 'SOUNDS-LICENSE.md']:
        shutil.copy2(ROOT / name, package / name)
    shutil.copytree(ROOT / 'third-party', package / 'third-party', dirs_exist_ok=True)
    with zipfile.ZipFile(dist / 'shroudfire-css-1.0.0.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
        for file in sorted(package.rglob('*')):
            if file.is_file():
                archive.write(file, file.relative_to(package).as_posix())
    if fastdl:
        fast = dist / 'fastdl'
        if fast.exists():
            if fast.resolve().parent != dist.resolve():
                raise ValueError('FastDL directory must remain inside dist')
            shutil.rmtree(fast)
        for file in sorted((ROOT / 'game-assets').rglob('*')):
            if file.is_file():
                output = fast / file.relative_to(ROOT / 'game-assets')
                output.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(file, output)
                if file.suffix.lower() != '.html':
                    output.with_name(output.name + '.bz2').write_bytes(bz2.compress(file.read_bytes()))
    manifest = {p.relative_to(package).as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                for p in sorted(package.rglob('*')) if p.is_file()}
    (dist / 'SHA256.json').write_text(json.dumps(manifest, indent=2) + '\n', encoding='utf-8')
    print(f'Built {binary}\nInstall archive: {dist / "shroudfire-css-1.0.0.zip"}')

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler', type=Path, required=True)
    parser.add_argument('--include', type=Path, help='SourceMod scripting/include directory')
    parser.add_argument('--fastdl', action='store_true', help='Create uncompressed and bzip2 client assets')
    parser.add_argument('--connect-package', type=Path, help='Optional built Connect install tree to include')
    args = parser.parse_args()
    build(args.compiler.resolve(), (args.include or args.compiler.parent / 'include').resolve(), args.fastdl, args.connect_package)
