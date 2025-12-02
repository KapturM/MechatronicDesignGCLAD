#include "connection.h"
#include "command.h"
#include "servo.h"

#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include <string.h>
#include <stdio.h>

#define LED_PIN GPIO_NUM_2
#define FRAME_DURATION_MS 20

void app_main(void)
{
    // Create two servo objects (from servo.c)
    servo_t servo1;
    servo_t servo2;

    // Initialize on different pins/channels
    servo_init(&servo1, LEDC_CHANNEL_0, GPIO_NUM_18);
    servo_init(&servo2, LEDC_CHANNEL_1, GPIO_NUM_19);


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
                uart_send("LED TURNED OFF\n");
                break;

            case CMD_LED_OFF:
                gpio_set_level(LED_PIN, 0);
                uart_send("LED TUNRED ON\n");
                break;

            case CMD_SERVO_MOVE:
                // cmd.p1 = servo ID
                // cmd.p2 = angle
                printf("MOVING SERVO %d TO %d deg\n", cmd.p1, cmd.p2);
                if (cmd.p1 == 1){
                    // Move to angle with speed control
                    servo_move_slow(&servo1, cmd.p2);
                    uart_send("OK SERVO MOVED\n");
                }else if (cmd.p1 == 2){
                    // Move to angle with speed control
                    servo_move_slow(&servo2, cmd.p2);
                    uart_send("OK SERVO MOVED\n");
                }else{
                    printf("Unknown servo ID!\n");
                }
                break;

            case CMD_SERVO_SET_SPEED:
                // cmd.p1 = servo ID
                // cmd.p2 = step_deg
                // cmd.p3 = step_delay_ms
                printf("Set servo %d speed: step=%d deg, delay=%d ms\n", cmd.p1, cmd.p2, cmd.p3);
                if (cmd.p1 == 1){
                    // Configure speed (degrees per step, delay between steps)
                    servo_set_speed(&servo1, cmd.p2, cmd.p3);
                    uart_send("OK SERVO SPEED\n");
                }else if (cmd.p1 == 2){
                    // Configure speed (degrees per step, delay between steps)
                    servo_set_speed(&servo2, cmd.p2, cmd.p3);
                    uart_send("OK SERVO SPEED\n");
                }else{
                    printf("Unknown servo ID!\n");
                }
                break;
                
            default:
                uart_send("UNKNOWN\n");
                break;
            }
        }
    }
}
