#include <stdio.h>
#include "driver/ledc.h"
#include "esp_err.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

// ------ SERVO CONSTANTS ------
#define SERVO_FREQUENCY 50
#define SERVO_TIMER LEDC_TIMER_0
#define SERVO_MODE LEDC_LOW_SPEED_MODE
#define SERVO_RES LEDC_TIMER_16_BIT

#define SERVO_MIN_US 500
#define SERVO_MAX_US 2500
#define SERVO_PERIOD_US 20000

// Convert pulse width (us) → duty
static inline uint32_t servo_us_to_duty(uint32_t us)
{
    return (uint32_t)((((uint64_t)us) * ((1 << 16) - 1)) / SERVO_PERIOD_US);
}

// ------ SERVO STRUCT ------
typedef struct {
    ledc_channel_t channel;
    gpio_num_t gpio;
    uint32_t current_angle;  // tracked angle
} servo_t;

// ------ INITIALIZE SERVO ------
void servo_init(servo_t *servo)
{
    ledc_channel_config_t ch_conf = {
        .channel    = servo->channel,
        .duty       = 0,
        .gpio_num   = servo->gpio,
        .speed_mode = SERVO_MODE,
        .hpoint     = 0,
        .timer_sel  = SERVO_TIMER
    };
    ledc_channel_config(&ch_conf);

    servo->current_angle = 0;
}

// Set servo instantly to angle
void servo_set_angle(servo_t *servo, uint32_t angle)
{
    if (angle > 180) angle = 180;

    uint32_t pulse = SERVO_MIN_US +
                     (angle * (SERVO_MAX_US - SERVO_MIN_US) / 180);

    uint32_t duty = servo_us_to_duty(pulse);

    ledc_set_duty(SERVO_MODE, servo->channel, duty);
    ledc_update_duty(SERVO_MODE, servo->channel);

    servo->current_angle = angle;
}

// ------ SPEED CONTROLLED MOVEMENT ------
// speed_delay_ms = time between angle steps
// step_size_deg  = degrees to move per step (smaller = smoother)
void servo_move_slow(servo_t *servo, uint32_t target_angle, uint32_t step_size_deg, uint32_t speed_delay_ms)
{
    if (target_angle > 180) target_angle = 180;

    int current = servo->current_angle;

    while (current != target_angle) {
        if (current < target_angle) {
            current += step_size_deg;
            if (current > target_angle) current = target_angle;
        } else {
            current -= step_size_deg;
            if (current < target_angle) current = target_angle;
        }

        servo_set_angle(servo, current);
        vTaskDelay(pdMS_TO_TICKS(speed_delay_ms));
    }
}

void app_main(void)
{
    // Configure LEDC timer (shared by both servos)
    ledc_timer_config_t timer_conf = {
        .duty_resolution = SERVO_RES,
        .freq_hz = SERVO_FREQUENCY,
        .speed_mode = SERVO_MODE,
        .timer_num = SERVO_TIMER,
        .clk_cfg = LEDC_AUTO_CLK
    };
    ledc_timer_config(&timer_conf);

    // Create 2 servos
    servo_t servo1 = {
        .channel = LEDC_CHANNEL_0,
        .gpio = GPIO_NUM_18
    };

    servo_t servo2 = {
        .channel = LEDC_CHANNEL_1,
        .gpio = GPIO_NUM_19
    };

    servo_init(&servo1);
    servo_init(&servo2);

    while (1) {

        // Move both slowly in different patterns
        servo_move_slow(&servo1, 0,   1, 10);   // (target, step size, delay)
        servo_move_slow(&servo2, 180, 2, 15);

        servo_move_slow(&servo1, 180, 1, 10);
        servo_move_slow(&servo2, 0,   2, 15);

        servo_move_slow(&servo1, 90,  1, 20);
        servo_move_slow(&servo2, 90,  1, 20);

        vTaskDelay(pdMS_TO_TICKS(1000));
    }
}
