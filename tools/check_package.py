"""Validate the actual release ZIP and exercise installation in an isolated root."""
from pathlib import Path, PurePosixPath
import json
import os
import re
import shutil
import subprocess
import tempfile
import zipfile

root = Path(__file__).resolve().parents[1]
metadata = json.loads((root / 'package/metadata.json').read_text())['KPlugin']
archive = root / 'dist' / f'liquid-glass-tiles-{metadata["Version"]}.zip'
with zipfile.ZipFile(archive) as bundle:
    names = bundle.namelist()
    assert len(names) == len(set(names)), 'Duplicate archive entries'
    required = ['metadata.json', 'contents/ui/main.qml', 'contents/ui/config.qml',
                'contents/ui/Glass.qml', 'contents/ui/FadingImage.qml', 'contents/ui/Slideshow.qml', 'contents/ui/Playlist.js', 'contents/ui/Translations.js', 'contents/ui/Catalogs.js', 'contents/config/main.xml',
                'contents/shaders/glass.frag.qsb', 'contents/shaders/blur.frag.qsb',
                'contents/images/demo.svg', 'LICENSE', 'CREDITS.md']
    assert all(name in names for name in required), 'Missing runtime files'
    for name in names:
        p = PurePosixPath(name)
        assert not p.is_absolute() and '..' not in p.parts, 'Unsafe archive path'
        assert not name.endswith('.py') and 'legacy/' not in name and 'test-' not in name
        data = bundle.read(name)
        assert not re.search(rb'/(?:var/)?home/[A-Za-z0-9_.-]+/', data), ('Personal path', name)
        for secret in [b'@gmail.com', b'app.start(', b'121.html']:
            assert secret not in data, ('Private development content in package', name)
    config = bundle.read('contents/ui/config.qml').decode()
    for link in ['https://avely.me/designgabor', 'https://x.com/DesignGabor']:
        assert link in config and link in bundle.read('CREDITS.md').decode()
    assert 'Gábor Molnár' in config

with tempfile.TemporaryDirectory(prefix='liquid-glass-package-check-') as temporary:
    folder = Path(temporary)
    environment = dict(os.environ)
    environment['XDG_DATA_HOME'] = str(folder / 'data')
    environment['XDG_CONFIG_HOME'] = str(folder / 'config')
    environment['XDG_CACHE_HOME'] = str(folder / 'cache')
    packages = folder / 'data/plasma/wallpapers'
    packages.mkdir(parents=True)
    command = ['kpackagetool6', '--type', 'Plasma/Wallpaper']
    subprocess.run(command + ['--install', str(archive)], check=True, env=environment)
    installed = packages / metadata['Id']
    assert (installed / 'contents/shaders/blur.frag.qsb').is_file()
    subprocess.run(command + ['--show', metadata['Id']], check=True, env=environment)
    # Use an older version only in the temporary fixture, then test the real upgrade.
    path = installed / 'metadata.json'
    older = json.loads(path.read_text()); older['KPlugin']['Version'] = '0.1.0'
    path.write_text(json.dumps(older))
    subprocess.run(command + ['--upgrade', str(archive)], check=True, env=environment)
    assert json.loads(path.read_text())['KPlugin']['Version'] == metadata['Version']
    subprocess.run(command + ['--remove', metadata['Id']], check=True, env=environment)
    assert not installed.exists()
print('PASS: release layout, credits, private-content scan, isolated install / upgrade / uninstall')
