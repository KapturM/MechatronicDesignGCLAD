#pragma once

#include "driver/uart.h"
#include <stdint.h>

#define UART_PORT UART_NUM_0
#define UART_BUF_SIZE 1024

void uart_init(void);
int uart_read_line(char *buffer, int max_len, int timeout_ms);
void uart_send(const char *msg);
