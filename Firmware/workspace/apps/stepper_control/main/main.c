#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "stepper.h"

stepper_t motor;

void app_main(void)
{
    stepper_init(&motor, GPIO_NUM_18, GPIO_NUM_19, GPIO_NUM_15,
                 20,     // ms between HIGH and LOW pulse
                 1);    // microsteps

    stepper_move_to(&motor, 100);

    while (stepper_is_busy(&motor)) {
        vTaskDelay(pdMS_TO_TICKS(10));
    }

    stepper_move_to(&motor, -50);
}
