#include <string.h>
#include "command.h"

CommandType check_for_commands(const char *input)
{
    if (strcmp(input, "LED ON") == 0)
        return CMD_LED_ON;

    if (strcmp(input, "LED OFF") == 0)
        return CMD_LED_OFF;

    return CMD_UNKNOWN;
}
