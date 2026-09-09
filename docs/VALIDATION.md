# Release-candidate validation — 2026-09-08

- Shader compilation passed with Qt Shader Baker 6.11.1 and `--qsbversion 64` (QSB container version 6).
- All QML files passed syntax/type lint. Warnings concern the documented Plasma-provided context names `i18nd` and `parentLayout`; standalone preview globals are also supplied at runtime.
- GPU render suite passed with PySide6/Qt 6.10.2 and the desktop input overlay: hover/follow, near/far gradient, original-image identity at opacity zero, disable, left/right click pass-through, invalid-image handling.
- Frost pattern local contrast: 41.27 -> 4.80. Idle observation: zero extra rendered frames in one second after settling.
- ZIP installed, metadata resolved, upgraded from a temporary older-version fixture, and uninstalled under isolated XDG directories. The actual user desktop was not changed by the package test.
- Designer name and both supplied links are checked in the packaged UI and credits. Runtime ZIP is scanned for development paths, email addresses and original-scene data.
- Demo PNG/MP4 are rendered from the included original SVG; no personal wallpaper or author mail is distributed. The video is a deterministic renderer demonstration, not a performance benchmark.
- The earlier desktop input implementation was accepted by the owner on Plasma 6.7.3 / Qt 6.11.1 / Wayland. The final material was visually accepted in preview. Native activation of this newly namespaced package, multilingual UI visual review, other GPUs, X11 and mixed-DPI multi-monitor testing remain community acceptance work.
- No GitHub repository, KDE Store listing or community post has been published by these tools.

## 0.2.1 localization fix

- Release ZIP translation regression passed in a clean temporary directory: Chinese system language, manual English/Chinese, live updates, fallback.
- Isolated KPackage installation, upgrade and removal passed.
- Native KDE settings visual acceptance remains pending. The Python preview cannot load this distribution’s Kirigami due to Qt private ABI differences.

## 0.3.0

- Actual hover leave event retains position and presence; click pass-through, frost, transparency and idle-frame regressions pass.
- Real Qt decoder tests cover PNG/JPG/WebP, Unicode and reserved path characters, timed/sequential/random transitions, missing files, invalid JSON, empty and single lists, and disabling playback.
- Settings component loaded using system Qt 6.9.1 and Kirigami on the second test machine; Chinese slideshow labels and configuration values checked.
- Community image-selection report cannot be considered reproduced or resolved without the affected file/system details. Absolute local paths are now normalized; file URLs are preserved.

## 0.3.1

- GPU rendering regression confirms intermediate red/blue pixels during crossfade, correct final image and unchanged pointer coordinates.
- Frost, hover leave, click pass-through, opacity, idle rendering and missing-image regression checks pass.
- User confirmed 0.3.0 slideshow persistence, Chinese UI and pointer retention after Plasma restart.
