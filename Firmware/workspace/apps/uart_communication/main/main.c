#include "connection.h"
#include "command.h"

#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <string.h>
#include <stdio.h>

#define LED_PIN GPIO_NUM_2
#define FRAME_DURATION_MS 20

void app_main(void)
{
    // Initialize UART (from connection.c)
    uart_init();

    // Configure LED
    gpio_config_t io_conf = {
        .pin_bit_mask = 1ULL << LED_PIN,
        .mode = GPIO_MODE_OUTPUT,
        .pull_up_en = 0,
        .pull_down_en = 0,
        .intr_type = GPIO_INTR_DISABLE
    };
    gpio_config(&io_conf);

    char rx_buffer[UART_BUF_SIZE];

    while (1) {

        int len = uart_read_line(rx_buffer, UART_BUF_SIZE, FRAME_DURATION_MS);

        if (len > 0) {
            CommandType cmd = check_for_commands(rx_buffer);

            switch (cmd) {

            case CMD_LED_ON:
                gpio_set_level(LED_PIN, 1);
                uart_send("LED=1\n");
                break;

            case CMD_LED_OFF:
                gpio_set_level(LED_PIN, 0);
                uart_send("LED=0\n");
                break;

            default:
                uart_send("UNKNOWN\n");
                break;
            }
        }
    }
}
