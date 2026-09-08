"""Launch the same QML renderer used in Plasma; optionally capture a test frame."""
import argparse
import os
from pathlib import Path
import sys

from PySide6.QtCore import QObject, QPointF, QTimer, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickWindow

parser = argparse.ArgumentParser()
parser.add_argument('--image', default=str(Path(__file__).resolve().parents[1] / 'package/contents/images/demo.svg'))
parser.add_argument('--capture')
parser.add_argument('--x', type=float, default=480)
parser.add_argument('--y', type=float, default=400)
parser.add_argument('--opacity', type=float, default=0.85)
parser.add_argument('--frost', type=float, default=0.35)
args = parser.parse_args()
os.environ.setdefault('QT_QUICK_CONTROLS_STYLE', 'Fusion')
app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty('initialWallpaper', QUrl.fromLocalFile(str(Path(args.image).resolve())))
engine.rootContext().setContextProperty('captureMode', bool(args.capture))
engine.load(QUrl.fromLocalFile(str(Path(__file__).with_name('Main.qml'))))
if not engine.rootObjects():
    raise SystemExit('QML_LOAD_FAILED')
window = engine.rootObjects()[0]
assert isinstance(window, QQuickWindow)
if args.capture:
    QTimer.singleShot(15000, lambda: app.exit(4))
    glass = window.findChild(QObject, 'glass')
    glass.setProperty('testPointer', True)
    glass.setProperty('testPosition', QPointF(args.x, args.y))
    glass.setProperty('glassOpacity', max(0, min(1, args.opacity)))
    glass.setProperty('frost', max(0, min(1, args.frost)))
    def capture():
        if not glass.property('imageReady'):
            print('IMAGE_NOT_READY', file=sys.stderr)
            app.exit(2)
            return
        ok = window.grabWindow().save(args.capture)
        print('CAPTURE_OK' if ok else 'CAPTURE_FAILED', args.capture)
        app.exit(0 if ok else 3)
    QTimer.singleShot(2000, capture)
sys.exit(app.exec())
