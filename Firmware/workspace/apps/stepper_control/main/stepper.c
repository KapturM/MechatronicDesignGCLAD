#include "stepper.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"


void stepper_init(stepper_t *stepper,gpio_num_t step, gpio_num_t dir){
    stepper->current_position = 0;
    stepper->step_size_denominator = 1;
    stepper->switching_delay_ms = 500;
    stepper->step = step
    stepper->dir = dir
    stepper->power = 15;
}

