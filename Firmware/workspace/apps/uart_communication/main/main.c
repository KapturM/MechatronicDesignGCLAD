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

        int len = uart_read_line(rx_buffer, UART_BUF_SIZE, 50);
        if (len > 0) {

            Command cmd = parse_command(rx_buffer);

            switch(cmd.type) {

            case CMD_LED_ON:
                gpio_set_level(LED_PIN, 1);
                uart_send("LED=1\n");
                break;

            case CMD_LED_OFF:
                gpio_set_level(LED_PIN, 0);
                uart_send("LED=0\n");
                break;

            case CMD_SERVO_MOVE:
                // cmd.p1 = servo ID
                // cmd.p2 = angle
                printf("MOVING SERVO %d TO %d deg\n", cmd.p1, cmd.p2);

                // TODO: Call your servo driver
                // servo_move(cmd.p1, cmd.p2);

                break;

            default:
                uart_send("UNKNOWN\n");
                break;
            }
        }
    }
}
