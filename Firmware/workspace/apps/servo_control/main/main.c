#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "servo.h"

void app_main(void)
{
    // Create two servo objects
    servo_t servo1;
    servo_t servo2;

    // Initialize on different pins/channels
    servo_init(&servo1, LEDC_CHANNEL_0, GPIO_NUM_18);
    servo_init(&servo2, LEDC_CHANNEL_1, GPIO_NUM_19);

    // Configure speed
    servo_set_speed(&servo1, 1, 10);   // 1° step, 10 ms delay
    servo_set_speed(&servo2, 2, 15);   // 2° step, 15 ms delay

    while (1) {
        servo_move_slow(&servo1, 0);
        servo_move_slow(&servo2, 180);

        servo_move_slow(&servo1, 180);
        servo_move_slow(&servo2, 0);

        servo_move_slow(&servo1, 90);
        servo_move_slow(&servo2, 90);

        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}
