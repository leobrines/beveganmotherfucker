# beveganmotherfucker

Static site served by nginx and deployed with Kamal.

## Footage

The original videos come from this public Google Drive folder:
https://drive.google.com/drive/u/0/folders/1rFPC-OMn-GLbJxFCFtPRZP7-jTPttsjs

The site plays a compressed copy at `assets/animal_explotaition_footage.mp4`. To regenerate it,
download the original from the folder above and run (requires `ffmpeg`):

```sh
scripts/compress-video.sh ~/Downloads/<downloaded file>.mp4
```

The original is moved to `~/Videos/beveganmotherfucker/` (not committed). Later runs can omit the
argument. `TARGET_MB` (default 95, GitHub rejects files over 100 MB), `HEIGHT` (default 720) and
`LOGLEVEL` (ffmpeg `-loglevel`, default `info`) can be set as environment variables.
