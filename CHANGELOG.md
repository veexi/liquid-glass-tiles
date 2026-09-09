# Changelog

## 0.3.1

- Crossfade prepared wallpaper images over 500 ms while keeping glass position stable.
- Release the previous image after the transition.
- Document logout/login after updates to refresh cached QML and configuration schemas.

## 0.3.0

- Keep glass at the last pointer position when leaving the desktop.
- Add mixed-format slideshow, configurable interval, list/random order and per-image removal.
- Skip unreadable images with bounded retries and retain a working fallback.
- Normalize absolute image paths with spaces, Unicode and reserved URL characters.
- Include the 0.2.1 bundled translation fix and language selection.

## 0.2.1

- Fix packaged Chinese translations not loading in wallpaper settings.
- Add system / Simplified Chinese / English language selection.
- Use bundled PO-derived catalogs without requiring global locale installation.

## 0.2.0 — First community preview

- Native Plasma 6 wallpaper package with a self-contained demo image.
- Pointer-local glass tiles with Gaussian frost, curved refraction and directional highlights.
- Immediate pointer tracking by default; optional deliberate smoothing.
- Passive top-level pointer observation that preserves desktop left/right click handling.
- English and Simplified Chinese settings.
- Original-designer attribution in the settings, documentation and release copy.
- Installable ZIP, source ZIP, checksums and isolated package lifecycle tests.
