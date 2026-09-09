"""Real Qt decoder / timer checks for mixed formats and broken playlist entries."""
import json
from pathlib import Path
import tempfile
from PySide6.QtCore import QUrl
from PySide6.QtGui import QGuiApplication, QImage, QColor
from PySide6.QtQml import QQmlComponent, QQmlEngine
from PySide6.QtTest import QTest

app = QGuiApplication([])
engine = QQmlEngine()
root = Path(__file__).resolve().parents[1]
component = QQmlComponent(engine, QUrl.fromLocalFile(str(root/'package/contents/ui/Slideshow.qml')))
slide = component.create()
assert slide, [e.toString() for e in component.errors()]
def wait_for(predicate, message, timeout=3000):
    for _ in range(timeout // 20):
        if predicate(): return
        QTest.qWait(20)
    assert predicate(), message
with tempfile.TemporaryDirectory() as temp:
    directory = Path(temp)
    urls = []
    for name, color in [('中文 # 图.png', 'red'), ('second.jpg', 'green'), ('third.webp', 'blue')]:
        p = directory / name
        image = QImage(30,30,QImage.Format_RGB32); image.fill(QColor(color))
        assert image.save(str(p)), ('Decoder unavailable', name)
        urls.append(QUrl.fromLocalFile(str(p)).toString())
    bad = QUrl.fromLocalFile(str(directory/'missing.png')).toString()
    slide.setProperty('fallback', QUrl(urls[0]))
    slide.setProperty('images', json.dumps([urls[0],bad,urls[1],urls[2]]))
    slide.setProperty('enabled',True)
    wait_for(lambda: slide.property('currentSource')==QUrl(urls[0]),'First image')
    QTest.qWait(200)
    slide.advance()
    wait_for(lambda: slide.property('currentSource')==QUrl(urls[1]),'Skip invalid image')
    slide.advance()
    wait_for(lambda: slide.property('currentSource')==QUrl(urls[2]),'Mixed WebP')
    slide.advance()
    wait_for(lambda: slide.property('currentSource')==QUrl(urls[0]),'Wrap list')
    slide.setProperty('images',json.dumps(urls))
    QTest.qWait(200)
    slide.setProperty('intervalSeconds',1)
    wait_for(lambda: slide.property('currentSource')==QUrl(urls[1]),'Timer advance',2000)
    slide.setProperty('intervalSeconds',300)
    slide.setProperty('randomOrder',True)
    for _ in range(8):
        previous=slide.property('currentSource')
        slide.advance()
        wait_for(lambda: slide.property('currentSource')!=previous,'Random immediate repeat')
    slide.setProperty('images',json.dumps([bad]))
    QTest.qWait(400)
    assert slide.property('attempts')==1 and not slide.property('loading')
    assert slide.property('currentSource')==QUrl(urls[0])
    slide.setProperty('images','invalid json')
    QTest.qWait(50)
    assert slide.property('currentSource')==QUrl(urls[0])
    slide.setProperty('images',json.dumps([urls[1]]))
    wait_for(lambda: slide.property('currentSource')==QUrl(urls[1]),'Single image')
    slide.setProperty('enabled',False)
    assert slide.property('currentSource')==QUrl(urls[0])
print('PASS: PNG/JPG/WebP, Unicode/#/spaces, timer, sequence wrap, random no repeat, bad/empty/single lists, disable')
