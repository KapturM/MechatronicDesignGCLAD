#ifndef STEPPER_H
#define STEPPER_H

#include <stdint.h>
#include <driver/gpio.h>

// Stepper structure
typedef struct {
    gpio_num_t step;  // pin that we will switch ON and OFF to make a step
    gpio_num_t dir;   // if ON we turn clockwise and for OFF we go counterclockwise
    gpio_num_t power; // turn ON and OFF the motor -> depends on the encoder settings 
    int step_size_denominator; // 1(200), 2(400), 4(800), 8(1600), 16(3200), 32(6400)
    int current_position;  
    int switching_delay_ms; 
} stepper_t

void stepper_init(stepper_t *stepper,gpio_num_t step, gpio_num_t dir);
void stepper_init(stepper_t *stepper, gpio_num_t step, int switching_delay_ms, gpio_num_t dir, gpio_num_t power, int step_size_denominator);

void stepper_resert_possition(stepper_t *stepper);

void stepper_set_position(stepper_t *stepper, int go_to_possition);

void stepper_change_stepping_speed(stepper_t *stepper, int new_stepping_speed);
#endif