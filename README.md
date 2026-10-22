# bionebicine_pds_2026 board

CircuitPython board definition for Bionebicine's PDS 2026 (ESP32-S3-WROOM-1, N8R8 flash/PSRAM),
forked from `espressif_esp32s3_devkitc_1_n8r8`.

This is **not** an upstream CircuitPython board. It's specific to a single product, so it
doesn't make sense to ask Adafruit's CI to build and maintain it forever for no benefit to
anyone else. Instead, `.github/workflows/build-and-release.yml` builds it ourselves: every
week (and on demand via `workflow_dispatch`), it clones fresh upstream CircuitPython at both
`main` and the latest stable release, copies `boards/bionebicine_pds_2026/` into
`ports/espressif/boards/`, builds, and publishes the firmware as a GitHub Release here if
that version hasn't already been built.

Grab the latest firmware from the [Releases page](../../releases) - `--latest` keeps the
newest build (from either track) marked at the top, with every previous build kept as history.
