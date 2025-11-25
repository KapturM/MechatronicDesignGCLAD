# Useful commands

```
idf.py set-target esp32
idf.py build
```

```
venv\Scripts\activate
```

Flash command (Szymon)
```
python -m esptool --port COM4 --chip auto --baud 921600 --before default_reset --after hard_reset write_flash --flash_mode dio --flash_freq 40m --flash_size detect 0x1000 .\build\bootloader\bootloader.bin 0x8000 .\build\partition_table\partition-table.bin 0x10000 .\build\app.bin
```


# Container based on:
https://github.com/ShawnHymel/course-iot-with-esp-idf/?tab=readme-ov-file