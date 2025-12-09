#include "stepper.h"
#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

void stepper_init(stepper_t *stepper,
                  gpio_num_t step,
                  gpio_num_t dir,
                  gpio_num_t power,
                  int switching_delay_ms)
{
    stepper->current_position = 0;
    stepper->step = step;
    stepper->dir = dir;
    stepper->power = power;
    stepper->switching_delay_ms = switching_delay_ms;
    stepper->step_size_denominator = 1;

    // Configure pins
    gpio_config_t io_conf = {
        .mode = GPIO_MODE_OUTPUT,
        .intr_type = GPIO_INTR_DISABLE,
        .pull_down_en = false,
        .pull_up_en = false,
        .pin_bit_mask = (1ULL << step) | (1ULL << dir) | (1ULL << power),
    };
    gpio_config(&io_conf);

    gpio_set_level(step, 0);
    gpio_set_level(dir, 0);
    gpio_set_level(power, 1);   // enable driver
}

void stepper_reset_position(stepper_t *stepper)
{
    stepper->current_position = 0;
}

void stepper_set_direction(stepper_t *stepper, int dir)
{
    gpio_set_level(stepper->dir, dir ? 1 : 0);
    stepper->direction = dir ? 1 : -1;
}

void stepper_step(stepper_t *stepper)
{
    // Rising edge
    gpio_set_level(stepper->step, 1);
    vTaskDelay(pdMS_TO_TICKS(stepper->switching_delay_ms));

    // Falling edge
    gpio_set_level(stepper->step, 0);
    vTaskDelay(pdMS_TO_TICKS(stepper->switching_delay_ms));
}

void stepper_set_position(stepper_t *stepper, int target_position)
{
    int diff = target_position - stepper->current_position;

    if (diff == 0) return;

    if (diff > 0)
        stepper_set_direction(stepper, 1);
    else
        stepper_set_direction(stepper, 0);

    int steps = abs(diff) * stepper->step_size_denominator;

    for (int i = 0; i < steps; i++) {
        stepper_step(stepper);
        stepper->current_position += stepper->direction * (1.0 / stepper->step_size_denominator);
    }
}
