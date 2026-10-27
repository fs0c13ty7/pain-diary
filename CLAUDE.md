# Pain Diary

Offline web app hosted on GitHub Pages. This repository is PUBLIC.

## Privacy rule (non-negotiable)
- No personal data may ever be committed: no pain logs, no backup files, no names, emails or health details.
- The app stores entries only in the browser on the user's iPhone (localStorage). Never add analytics, external fonts, CDNs, trackers or any network calls that send data anywhere.
- Before EVERY commit and push, run `bash tools/privacy-check.sh` and only continue if it passes.
- Commit with a GitHub noreply author email, never a personal address.

## Files
- `index.html`: the whole app (calendar, logging sheets, report, backup/restore)
- `sw.js`: offline cache of app files only; bump `CACHE` when shipping changes
- `manifest.webmanifest`, `icons/`: Home Screen install
