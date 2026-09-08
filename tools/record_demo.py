"""Render promotional media using only the included original artwork."""
from pathlib import Path
import math
import os
import subprocess
import sys

os.environ.setdefault('QT_QUICK_CONTROLS_STYLE', 'Fusion')
from PySide6.QtCore import QObject, QPointF, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickWindow
from PySide6.QtTest import QTest

root = Path(__file__).resolve().parents[1]
frames = root / 'build/demo-frames'
frames.mkdir(parents=True, exist_ok=True)
app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.load(QUrl.fromLocalFile(str(root / 'tests/Showcase.qml')))
assert engine.rootObjects(), 'SHOWCASE_LOAD_FAILED'
window = engine.rootObjects()[0]
assert isinstance(window, QQuickWindow)
glass = window.findChild(QObject, 'glass')
QTest.qWait(1600)
assert glass.property('imageReady'), 'DEMO_IMAGE_NOT_READY'
assert window.grabWindow().save(str(root / 'docs/preview.png'))
for index in range(144):
    phase = 2 * math.pi * index / 144
    x = 640 + 310 * math.sin(phase)
    y = 430 + 170 * math.sin(phase * 2 + 0.6)
    glass.setProperty('testPosition', QPointF(x, y))
    QTest.qWait(20)
    assert window.grabWindow().save(str(frames / f'{index:04}.png'))
window.close()
subprocess.run(['ffmpeg', '-hide_banner', '-loglevel', 'error', '-y', '-framerate', '24',
                '-i', str(frames / '%04d.png'), '-frames:v', '144', '-c:v', 'libx264',
                '-crf', '20', '-pix_fmt', 'yuv420p', '-movflags', '+faststart',
                str(root / 'docs/demo.mp4')], check=True)
print('MEDIA_OK: docs/preview.png and docs/demo.mp4 (6 seconds, 24 fps)')
