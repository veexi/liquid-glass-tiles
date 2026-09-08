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
