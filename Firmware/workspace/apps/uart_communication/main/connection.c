#include "connection.h"
#include "driver/uart.h"
#include "esp_log.h"
#include <string.h>

void uart_init(void)
{
    uart_config_t config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    };

    uart_param_config(UART_PORT, &config);
    uart_driver_install(UART_PORT, UART_BUF_SIZE, UART_BUF_SIZE, 0, NULL, 0);

    uart_write_bytes(UART_PORT, "ESP32 Ready\n", 12);
}

int uart_read_line(char *buffer, int max_len, int timeout_ms)
{
    int len = uart_read_bytes(UART_PORT, (uint8_t *)buffer, max_len - 1, pdMS_TO_TICKS(timeout_ms));

    if (len > 0) {
        buffer[len] = 0;
        // Remove CR/LF
        for (int i = 0; i < len; i++) {
            if (buffer[i] == '\r' || buffer[i] == '\n') {
                buffer[i] = 0;
                break;
            }
        }
    }
    return len;
}

void uart_send(const char *msg)
{
   printf(msg);
}
