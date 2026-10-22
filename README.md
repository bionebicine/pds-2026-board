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

## Local development

`scripts/build.sh` is the one place that knows how to build this board - both CI and local
builds call it, so they can't drift apart from each other. To build it yourself:

```bash
scripts/build.sh <path-to-a-circuitpython-checkout>
```

The checkout can be any clone of `adafruit/circuitpython`, on whatever ref you want to build
against - the script never touches which ref is checked out, and never commits anything into
it. It just copies `boards/bionebicine_pds_2026/` in fresh (overwriting any previous copy),
then builds. That means the checkout can be a long-lived local cache you `git fetch`/reset
over time, the same checkout you already use for other CircuitPython work; it never needs its
own branch or commit for this board. The resulting firmware lands at
`<checkout>/ports/espressif/build-bionebicine_pds_2026/firmware.bin` (and `.uf2`).

Editing the board files themselves (`board.c`, `mpconfigboard.h`, `mpconfigboard.mk`,
`pins.c`, `sdkconfig`)? Edit them directly under `boards/bionebicine_pds_2026/` in this repo -
that's their one canonical home. There's no second copy anywhere else to keep in sync with.

Standard ESP-IDF build prerequisites apply (a C compiler, `cmake`, `ninja`, Python 3.10+) -
see [ESP-IDF's own prerequisites docs](https://docs.espressif.com/projects/esp-idf/en/latest/esp32/get-started/index.html#installation)
for your platform if `install.sh` can't find something it needs.
