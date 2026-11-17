# USB_VID/USB_PID are borrowed from this board's fork parent rather than a pair registered to
# us: this board's USB is never exposed externally once shipped, so these values are only ever
# seen by internal tooling, not an end user's machine.
USB_VID = 0x303A
USB_PID = 0x7003
USB_PRODUCT = "Bionebicine PDS 2026"
USB_MANUFACTURER = "Bionebicine"

IDF_TARGET = esp32s3

CIRCUITPY_ESP_FLASH_SIZE = 8MB
CIRCUITPY_ESP_FLASH_MODE = qio
CIRCUITPY_ESP_FLASH_FREQ = 80m

CIRCUITPY_ESP_PSRAM_SIZE = 8MB
CIRCUITPY_ESP_PSRAM_MODE = opi
CIRCUITPY_ESP_PSRAM_FREQ = 80m

# Independent of CIRCUITPY_DUALBANK: only *defaults* to its value, so this keeps OTA working
# while eliminating the "storage extended" state.
CIRCUITPY_STORAGE_EXTEND = 0

# Trimmed from the fork parent's full-feature build down to the modules this board uses.
# CIRCUITPY_WIFI stays on: this chip's BT controller links against esp_coex/esp_phy
# unconditionally, and CircuitPython's Makefile only pulls those in when CIRCUITPY_WIFI
# is nonzero, so disabling it breaks the BLE link on this chip. The WiFi radio itself is
# left off at runtime instead.
#
# CIRCUITPY_WEB_WORKFLOW is a separate variable that otherwise defaults to
# CIRCUITPY_NETWORK's value (which in turn defaults to CIRCUITPY_WIFI's) - explicitly
# turned off here rather than inherited, since this project doesn't use networking at all
# and the supervisor's own web-workflow startup activity runs before boot.py/code.py ever
# get a chance to run (so mcu/app/main.py's wifi.radio.enabled = False can't prevent it).
# Hardware-confirmed (2026-11-17, speed branch) via host-timestamped UART capture across a
# real manual-Off deep-sleep wake: ~5.2s of the ~6.3s spent before code.py's first line
# even runs sits in two gaps immediately around a native "Wi-Fi: No IP" status update -
# see docs/boot_timing_report.md in fed_pds_nebulizer for the full before/after.
CIRCUITPY_WEB_WORKFLOW = 0
#
# Skips supervisor/shared/safe_mode.c's wait_for_safe_mode_reset() - a hardcoded 1000ms
# wait on every normal boot (skipped only for brownout/watchdog/rescue-debug resets) to
# give a window for a double-reset-to-force-safe-mode gesture. Redundant for this board:
# no native RST button exists on the bare WROOM-1 module (Mike/Kent, 2026-11-17), and
# there's no bench need to force safe mode this way - this project's own
# persist.overlay_store.check_and_recover() crash-loop rollback handles bad-firmware
# recovery independently of this native mechanism.
CIRCUITPY_SKIP_SAFE_MODE_WAIT = 1
CIRCUITPY_AUDIOPWMIO = 0
CIRCUITPY_AUDIOBUSIO = 0
CIRCUITPY_AUDIOI2SIN = 0
CIRCUITPY_CANIO = 0
CIRCUITPY_PS2IO = 0
CIRCUITPY_SDIOIO = 0
CIRCUITPY_SDCARDIO = 0
CIRCUITPY_MAX3421E = 0
CIRCUITPY_ROTARYIO = 0
CIRCUITPY_COUNTIO = 0
CIRCUITPY_FREQUENCYIO = 0
CIRCUITPY_ANALOGBUFIO = 0
CIRCUITPY_ONEWIREIO = 0
CIRCUITPY_AESIO = 0
CIRCUITPY_ESPCAMERA = 0
CIRCUITPY_MEMORYMAP = 0
CIRCUITPY_NEOPIXEL_WRITE = 0
CIRCUITPY_PULSEIO = 0
CIRCUITPY_RAINBOWIO = 0
CIRCUITPY_RGBMATRIX = 0
CIRCUITPY__EVE = 0
CIRCUITPY_PARALLELDISPLAYBUS = 0
CIRCUITPY_FRAMEBUFFERIO = 0
CIRCUITPY_VECTORIO = 0
CIRCUITPY_GIFIO = 0
CIRCUITPY_BITMAPTOOLS = 0
CIRCUITPY_JPEGIO = 0
CIRCUITPY_BITMAPFILTER = 0
CIRCUITPY_ULAB = 0
CIRCUITPY_KEYPAD = 0
CIRCUITPY_KEYPAD_DEMUX = 0
CIRCUITPY_USB_HID = 0
CIRCUITPY_USB_MIDI = 0
CIRCUITPY_BLE_FILE_SERVICE = 0
CIRCUITPY_BLE_SERIAL_SERVICE = 0
