#pragma once

typedef enum {
    CMD_NONE = 0,
    CMD_LED_ON,
    CMD_LED_OFF,
    CMD_SERVO_MOVE,
    CMD_SERVO_SET_SPEED,
    CMD_UNKNOWN
} CommandType;

typedef struct {
    CommandType type;
    int p1; // servo id
    int p2; // angle OR step_deg
    int p3; // step_delay_ms
} Command;

Command parse_command(const char *input);
