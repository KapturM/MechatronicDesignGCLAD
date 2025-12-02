#pragma once

typedef enum {
    CMD_NONE = 0,
    CMD_LED_ON,
    CMD_LED_OFF,
    CMD_SERVO_MOVE,
    CMD_UNKNOWN
} CommandType;

typedef struct {
    CommandType type;
    int p1;
    int p2;
} Command;

Command parse_command(const char *input);
