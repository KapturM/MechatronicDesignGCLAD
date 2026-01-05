#include "command.h"
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

Command parse_command(const char *input)
{
    Command cmd = { CMD_UNKNOWN, 0, 0, 0};

    // --- LED Commands ---
    if (strcmp(input, "LED ON") == 0) {
        cmd.type = CMD_LED_ON;
        return cmd;
    }

    if (strcmp(input, "LED OFF") == 0) {
        cmd.type = CMD_LED_OFF;
        return cmd;
    }

    // --- SERVO MOVE: id, angle ---
    if (strncmp(input, "SERVO MOVE:", 11) == 0) {

        // Example input: "SERVO MOVE: 1, 180"
        int id = 0;
        int angle = 0;

        // Parse integers from the string
        // %d reads integers and skips spaces
        if (sscanf(input + 11, "%d , %d", &id, &angle) == 2) {
            cmd.type = CMD_SERVO_MOVE;
            cmd.p1 = id;
            cmd.p2 = angle;
            return cmd;
        }

        // Parsing failed
        cmd.type = CMD_UNKNOWN;
        return cmd;
    }


    // --- SERVO SET SPEED: id, step_deg, delay ---
    if (strncmp(input, "SERVO SET SPEED:", 16) == 0) {

        int id = 0;
        int step = 0;
        int delay = 0;

        // Parse pattern:
        // SERVO SET SPEED: 1, 3, 20
        if (sscanf(input + 16, "%d , %d , %d", &id, &step, &delay) == 3) {
            cmd.type = CMD_SERVO_SET_SPEED;
            cmd.p1 = id;
            cmd.p2 = step;
            cmd.p3 = delay;
            return cmd;
        }

        cmd.type = CMD_UNKNOWN;
        return cmd;
    }

    // --- SEND TRIGGER ---
    if (strcmp(input, "TRIGGER ON") == 0) {
        cmd.type = CMD_SEND_TRIGGER_ON;
        return cmd;
    }

    if (strcmp(input, "TRIGGER OFF") == 0) {
        cmd.type = CMD_SEND_TRIGGER_OFF;
        return cmd;
    }


    // No match
    return cmd;
}
