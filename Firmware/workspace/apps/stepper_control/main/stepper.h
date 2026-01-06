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

    int microsteps;
    int step_delay_us;

    volatile int current_position;
    volatile int target_position;

    QueueHandle_t command_queue;
    TaskHandle_t task_handle;
} stepper_t;

void stepper_init(stepper_t *motor,
                  gpio_num_t step,
                  gpio_num_t dir,
                  gpio_num_t enable,
                  int step_delay_us,
                  int microsteps);

void stepper_enable(stepper_t *motor);
void stepper_disable(stepper_t *motor);

void stepper_set_home(stepper_t *motor, int position);
void stepper_move_to(stepper_t *motor, int target_position);
bool stepper_is_busy(stepper_t *motor);

#endif
