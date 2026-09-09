"""Exercise translations from the release ZIP without globally installed catalogs."""
import json
from pathlib import Path
import tempfile
import zipfile

from PySide6.QtCore import QLocale, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlComponent, QQmlEngine

root = Path(__file__).resolve().parents[1]
version = json.loads((root / 'package/metadata.json').read_text())['KPlugin']['Version']
app = QGuiApplication([])
with tempfile.TemporaryDirectory() as temp:
    folder = Path(temp)
    with zipfile.ZipFile(root / 'dist' / f'liquid-glass-tiles-{version}.zip') as bundle:
        bundle.extractall(folder)
    engine = QQmlEngine()
    component = QQmlComponent(engine)
    component.setData(b'''import QtQuick
import "contents/ui/Translations.js" as T
QtObject {
    property string selection: "system"
    property var preferred: Qt.locale().uiLanguages
    property string label: T.text("Wallpaper image:", selection, preferred)
    property string missing: T.text("Unknown future message", selection, preferred)
}''', QUrl.fromLocalFile(str(folder / 'Check.qml')))
    QLocale.setDefault(QLocale('zh_CN'))
    obj = component.create()
    assert obj, [error.toString() for error in component.errors()]
    assert obj.property('label') == '壁纸图片：'
    obj.setProperty('selection', 'en')
    assert obj.property('label') == 'Wallpaper image:'
    obj.setProperty('preferred', ['en-US'])
    obj.setProperty('selection', 'zh_CN')
    assert obj.property('label') == '壁纸图片：'
    obj.setProperty('selection', 'system')
    assert obj.property('label') == 'Wallpaper image:'
    for preferred, expected in [(['zh-Hans-CN'], '壁纸图片：'), (['fr-FR'], 'Wallpaper image:'), (['zh-Hant-TW'], 'Wallpaper image:')]:
        obj.setProperty('preferred', preferred)
        assert obj.property('label') == expected
    assert obj.property('missing') == 'Unknown future message'
print('PASS: packaged QML translations, automatic locale, live override, missing-language/key fallback')
