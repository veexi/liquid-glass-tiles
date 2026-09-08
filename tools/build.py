"""Bake portable Qt shaders and create deterministic installation/source archives."""
from pathlib import Path
import hashlib
import json
import os
import shutil
import subprocess
import zipfile

ROOT = Path(__file__).resolve().parents[1]
PACKAGE = ROOT / 'package'
metadata = json.loads((PACKAGE / 'metadata.json').read_text())['KPlugin']
version = metadata['Version']
qsb = os.environ.get('QSB') or shutil.which('qsb')
if not qsb:
    qsb = next((str(p) for p in [Path('/usr/lib64/qt6/bin/qsb'), Path('/usr/lib/qt6/bin/qsb')] if p.is_file()), None)
if not qsb:
    raise SystemExit('qsb not found: install Qt 6 Shader Tools or set QSB=/path/to/qsb')
for shader in sorted((PACKAGE / 'contents/shaders').glob('*.frag')):
    relative = shader.relative_to(ROOT)
    # Bake the older container format instead of requiring the builder's Qt minor version.
    subprocess.run([qsb, '--qt6', '--qsbversion', '64', '-o', str(relative) + '.qsb', str(relative)], cwd=ROOT, check=True)
domain = 'plasma_wallpaper_' + metadata['Id']
for po in sorted((ROOT / 'translations').glob('*.po')):
    destination = PACKAGE / 'contents/locale' / po.stem / 'LC_MESSAGES' / (domain + '.mo')
    destination.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(['msgfmt', '--check', '-o', str(destination), str(po)], check=True)
for name in ('LICENSE', 'CREDITS.md'):
    shutil.copyfile(ROOT / name, PACKAGE / name)
dist = ROOT / 'dist'
dist.mkdir(exist_ok=True)

def archive(target, entries):
    with zipfile.ZipFile(target, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as output:
        for path, name in sorted(entries, key=lambda pair: pair[1]):
            info = zipfile.ZipInfo(name, date_time=(2026, 1, 1, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            output.writestr(info, path.read_bytes())

runtime = [(p, p.relative_to(PACKAGE).as_posix()) for p in PACKAGE.rglob('*')
           if p.is_file() and p.name != 'component.contract.json']
archive(dist / f'liquid-glass-tiles-{version}.zip', runtime)
public_roots = ['package', 'tools', 'tests', 'translations', 'docs']
source = []
for directory in public_roots:
    for p in (ROOT / directory).rglob('*'):
        if p.is_file() and '__pycache__' not in p.parts and p.name != 'component.contract.json':
            source.append((p, f'liquid-glass-tiles-{version}/' + p.relative_to(ROOT).as_posix()))
for name in ['README.md', 'README.zh-CN.md', 'LICENSE', 'CREDITS.md', 'CHANGELOG.md', '.gitignore']:
    source.append((ROOT / name, f'liquid-glass-tiles-{version}/{name}'))
archive(dist / f'liquid-glass-tiles-{version}-source.zip', source)
hashes = [(p.name, hashlib.sha256(p.read_bytes()).hexdigest()) for p in sorted(dist.glob(f'*{version}*.zip'))]
(dist / 'SHA256SUMS').write_text(''.join(f'{digest}  {name}\n' for name, digest in hashes))
for name, digest in hashes:
    print(name, digest)
