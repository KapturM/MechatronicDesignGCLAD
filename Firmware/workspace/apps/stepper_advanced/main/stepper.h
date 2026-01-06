#ifndef STEPPER_H
#define STEPPER_H

#include "driver/gpio.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "freertos/queue.h"

typedef struct {
    gpio_num_t step_pin;
    gpio_num_t dir_pin;
    gpio_num_t enable_pin;

    int current_position;
    int target_position;

    int microsteps;

    volatile bool stop_requested;

    // Motion profile
    int min_delay_us;     // max speed
    int max_delay_us;     // start/stop speed
    int accel_steps;      // ramp length

    QueueHandle_t command_queue;
    TaskHandle_t task_handle;
} stepper_t;

void stepper_init(stepper_t *motor,
                  gpio_num_t step,
                  gpio_num_t dir,
                  gpio_num_t enable,
                  int step_delay_us,
                  float microsteps);

void stepper_enable(stepper_t *motor);
void stepper_disable(stepper_t *motor);

void stepper_stop(stepper_t *m);

void stepper_set_home(stepper_t *motor, int position);
void stepper_move_to(stepper_t *motor, int target_position);
bool stepper_is_busy(stepper_t *motor);

#endif
