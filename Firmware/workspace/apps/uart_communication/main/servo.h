#ifndef SERVO_H
#define SERVO_H

#include <stdint.h>
#include "driver/ledc.h"
#include "driver/gpio.h"

// Servo structure
typedef struct {
    ledc_channel_t channel;
    gpio_num_t gpio;
    uint32_t current_angle;
    uint32_t step_deg;       // speed step
    uint32_t step_delay_ms;  // speed delay
} servo_t;

// Initialize a servo on a given channel + pin
void servo_init(servo_t *servo, ledc_channel_t channel, gpio_num_t gpio);

// Sets angle instantly (0–180)
void servo_set_angle(servo_t *servo, uint32_t angle);

// Configure speed (degrees per step, delay between steps)
void servo_set_speed(servo_t *servo, uint32_t step_deg, uint32_t delay_ms);

// Move to angle with speed control
void servo_move_slow(servo_t *servo, uint32_t target_angle);

#endif
