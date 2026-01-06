#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "stepper.h"

stepper_t motor;

#define FULL_ROTATION_STEPS 200   // change to your motor steps

void app_main(void)
{
    stepper_init(&motor, GPIO_NUM_22, GPIO_NUM_23, GPIO_NUM_19,
                 200,   // min_delay_us
                 1);   // microsteps

    while (1) {

        // FULL ROTATION LEFT
        stepper_move_to(&motor, FULL_ROTATION_STEPS);

        while (stepper_is_busy(&motor)) {
            vTaskDelay(pdMS_TO_TICKS(10));
        }

        vTaskDelay(pdMS_TO_TICKS(300)); // small pause


        // FULL ROTATION RIGHT
        stepper_move_to(&motor, -FULL_ROTATION_STEPS);

        while (stepper_is_busy(&motor)) {
            vTaskDelay(pdMS_TO_TICKS(10));
        }

        vTaskDelay(pdMS_TO_TICKS(300)); // small pause
    }
}