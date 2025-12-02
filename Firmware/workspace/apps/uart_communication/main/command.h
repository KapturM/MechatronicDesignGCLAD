#pragma once

typedef enum {
    CMD_NONE = 0,
    CMD_LED_ON,
    CMD_LED_OFF,
    CMD_UNKNOWN
} CommandType;

CommandType check_for_commands(const char *input);
