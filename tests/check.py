"""Real Qt rendering checks: transparency identity, localized effect, hover and errors."""
import os
from pathlib import Path
import sys
import traceback

os.environ.setdefault('QT_QUICK_CONTROLS_STYLE', 'Fusion')
from PySide6.QtCore import QObject, QPointF, QUrl, QEvent, Qt
from PySide6.QtGui import QGuiApplication, QMouseEvent, QImage, QColor
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQuick import QQuickWindow
from PySide6.QtTest import QTest

root = Path(__file__).resolve().parents[1]
output = root / 'build/test-output'
output.mkdir(parents=True, exist_ok=True)
app = QGuiApplication(sys.argv)
engine = QQmlApplicationEngine()
engine.rootContext().setContextProperty('initialWallpaper', QUrl.fromLocalFile(str(Path(__file__).resolve().parents[1] / 'package/contents/images/demo.svg')))
engine.rootContext().setContextProperty('captureMode', True)
engine.load(QUrl.fromLocalFile(str(root / ('tests/DesktopHarness.qml' if '--desktop-host' in sys.argv else 'tests/Main.qml'))))
assert engine.rootObjects(), 'QML_LOAD_FAILED'
window = engine.rootObjects()[0]
assert isinstance(window, QQuickWindow)
glass = window.findChild(QObject, 'glass')
assert glass is not None

def frame(name):
    result = window.grabWindow()
    assert not result.isNull(), 'EMPTY_FRAME'
    assert result.save(str(output / (name + '.png')))
    return result

def move_mouse(x, y):
    # Deliver a window-local mouse event; Wayland does not permit cursor warping.
    point = QPointF(x, y)
    event = QMouseEvent(QEvent.MouseMove, point, point, Qt.NoButton, Qt.NoButton, Qt.NoModifier)
    QGuiApplication.sendEvent(window, event)

def difference(a, b, x0, y0, x1, y1):
    values = []
    for y in range(int(a.height() * y0), int(a.height() * y1), 6):
        for x in range(int(a.width() * x0), int(a.width() * x1), 6):
            p, q = a.pixelColor(x, y), b.pixelColor(x, y)
            values.append(abs(p.red() - q.red()) + abs(p.green() - q.green()) + abs(p.blue() - q.blue()))
    return sum(values) / len(values)

try:
    QTest.qWait(2200)
    assert glass.property('imageReady'), 'IMAGE_NOT_READY'
    assert glass.property('followDuration') == 0, 'DEFAULT_FOLLOW_DELAY'
    glass.setProperty('idleStrength', 0)
    glass.setProperty('glassOpacity', 0)
    move_mouse(260, 400)
    QTest.qWait(600)
    assert glass.property('presence') > 0.99, 'HOVER_NOT_RECEIVED'
    assert abs(glass.property('pointerX') - 260) < 2, ('HOVER_POSITION_WRONG', glass.property('pointerX'), glass.property('pointerY'), window.width(), window.height())
    baseline = frame('test-original')
    glass.setProperty('glassOpacity', 1)
    QTest.qWait(250)
    left = frame('test-left')
    near = difference(baseline, left, 0.1, 0.3, 0.3, 0.7)
    far = difference(baseline, left, 0.8, 0.3, 0.95, 0.7)
    assert near > 2 and near > far * 5, ('LOCALIZATION_FAILED', near, far)
    move_mouse(1000, 400)
    QTest.qWait(300)
    right = frame('test-right')
    assert abs(glass.property('pointerX') - 1000) < 2, 'MOUSE_FOLLOW_FAILED'
    assert difference(left, right, 0.65, 0.3, 0.85, 0.7) > 2, 'EFFECT_DID_NOT_MOVE'
    overlay = window.findChild(QObject, 'desktopOverlay')
    if overlay is not None:
        for button, name in [(Qt.LeftButton, 'leftClicks'), (Qt.RightButton, 'rightClicks')]:
            point = QPointF(1000, 400)
            QGuiApplication.sendEvent(window, QMouseEvent(QEvent.MouseButtonPress, point, point, button, button, Qt.NoModifier))
            QGuiApplication.sendEvent(window, QMouseEvent(QEvent.MouseButtonRelease, point, point, button, Qt.NoButton, Qt.NoModifier))
            QTest.qWait(50)
            assert overlay.property(name) == 1, ('DESKTOP_CLICK_BLOCKED', name)
    glass.setProperty('glassOpacity', 0)
    QTest.qWait(250)
    transparent = frame('test-transparent')
    assert difference(baseline, transparent, 0, 0, 1, 1) == 0, 'ZERO_OPACITY_CHANGED_IMAGE'
    glass.setProperty('glassOpacity', 1)
    glass.setProperty('motionEnabled', False)
    QTest.qWait(600)
    disabled = frame('test-disabled')
    assert difference(baseline, disabled, 0, 0, 1, 1) == 0, 'DISABLE_FAILED'
    # A dense, deterministic pattern distinguishes true diffusion from tint
    # or a few displaced copies of the sharp original.
    pattern = QImage(1280, 800, QImage.Format_RGB32)
    for y in range(800):
        for x in range(1280):
            pattern.setPixelColor(x, y, QColor('white' if (x // 6 + y // 6) % 2 else 'black'))
    patternPath = output / 'test-frost-pattern.png'
    pattern.save(str(patternPath))
    glass.setProperty('wallpaper', QUrl.fromLocalFile(str(patternPath)))
    glass.setProperty('idleStrength', 1)
    glass.setProperty('refraction', 0)
    glass.setProperty('frost', 0)
    QTest.qWait(700)
    sharp = frame('test-frost-zero')
    glass.setProperty('frost', 1)
    QTest.qWait(700)
    frosted = frame('test-frost-full')
    def contrast(img):
        values = []
        for y in range(150, 650, 7):
            for x in range(150, 1100, 7):
                values.append(abs(img.pixelColor(x, y).red() - img.pixelColor(x + 1, y).red()))
        return sum(values) / len(values)
    sharpContrast, frostContrast = contrast(sharp), contrast(frosted)
    assert sharpContrast > 10 and frostContrast < sharpContrast * 0.35, ('FROST_NOT_DIFFUSING', sharpContrast, frostContrast)
    print(f'FROST_PASS: local contrast {sharpContrast:.2f} -> {frostContrast:.2f}')
    QTest.qWait(250)
    idleFrames = []
    window.frameSwapped.connect(lambda: idleFrames.append(1))
    QTest.qWait(1000)
    assert len(idleFrames) <= 2, ('IDLE_RENDER_LOOP', len(idleFrames))
    print(f'IDLE_PASS: {len(idleFrames)} rendered frames during 1 second at rest')
    glass.setProperty('wallpaper', QUrl.fromLocalFile('/nonexistent/liquid-glass-test.png'))
    QTest.qWait(500)
    assert glass.property('imageFailed'), 'MISSING_IMAGE_NOT_REPORTED'
    print(f'PASS: actual hover, follow, gradient (near={near:.2f}, far={far:.2f}), zero opacity, disable, missing image')
except Exception:
    traceback.print_exc()
    window.close()
    sys.exit(1)
window.close()
