# Photopic

A modern macOS photo-gallery desktop app — a recreation of the original Flash **PhotoPic**, built with Electron.

![icon](app/logo.png)

## Features

- **Albums** — organize photos into named albums (stored as JSON), pick from a launcher.
- **Add photos** — drag-and-drop a folder or individual images, or use the file picker.
- **Contact-sheet gallery** — 5×4 grid, aspect-preserved thumbnails, click-to-fly-open a photo (sharp full-res via decode-then-animate), page navigation.
- **Thumbnail cache** — fast, low-memory grid via cached downscaled thumbnails (generated with `sips`).
- **Reorder** — drag photos within a page, or onto the ◀/▶ arrows to move across pages.
- **Background color** — per-album, applied to the gallery and the expanded/slideshow view.
- **Music** — per-album soundtrack queue with drag-to-reorder; plays in order during slideshows.
- **Slideshow** — full-screen with crossfade + Ken Burns, adjustable speed, shuffle, volume, and a music fade-out on the last slide.
- **Full screen** toggle, **rename**/**delete** albums, **remove** individual photos, missing-file handling.

## Run (development)

```bash
cd app
npm install
npm start
```

## Build (packaged macOS app)

```bash
cd app
npm run build
```

This packages `Photopic.app`, ad-hoc code-signs it, and installs a copy to `/Applications`.

## Regenerate the icon

```bash
cd app
swift make_icon.swift ../art/Designer.png icon_1024.png
# then rebuild the .icns with sips + iconutil (see build notes)
```

## Notes

- Albums store **references** to the original image files (nothing is copied); moved/deleted files are flagged in-app.
- Data lives in a `data/` folder next to the app (dev) or in the fixed workspace path (packaged).
- The app is ad-hoc signed (no Apple Developer ID); on first launch macOS may show a Gatekeeper prompt — right-click → Open once to clear it.
