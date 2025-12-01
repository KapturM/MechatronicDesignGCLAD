#include "servo.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"

// ----- CONSTANTS -----
#define SERVO_MIN_US 500
#define SERVO_MAX_US 2500
#define SERVO_PERIOD_US 20000      // 20ms for 50Hz
#define SERVO_FREQ 50
#define SERVO_TIMER LEDC_TIMER_0
#define SERVO_MODE LEDC_LOW_SPEED_MODE
#define SERVO_RES LEDC_TIMER_16_BIT

// Convert µs → LEDC duty
static inline uint32_t servo_us_to_duty(uint32_t us)
{
    return (uint32_t)((((uint64_t)us) * ((1 << 16) - 1)) / SERVO_PERIOD_US);
}

void servo_init(servo_t *servo, ledc_channel_t channel, gpio_num_t gpio)
{
    servo->channel = channel;
    servo->gpio = gpio;
    servo->current_angle = 0;
    servo->step_deg = 1;
    servo->step_delay_ms = 10;

    static bool timer_initialized = false;

    // Initialize timer once for all servos
    if (!timer_initialized) {
        ledc_timer_config_t timer_conf = {
            .duty_resolution = SERVO_RES,
            .freq_hz = SERVO_FREQ,
            .speed_mode = SERVO_MODE,
            .timer_num = SERVO_TIMER,
            .clk_cfg = LEDC_AUTO_CLK
        };
        ledc_timer_config(&timer_conf);
        timer_initialized = true;
    }

    // Channel config
    ledc_channel_config_t ch_conf = {
        .channel    = channel,
        .duty       = 0,
        .gpio_num   = gpio,
        .speed_mode = SERVO_MODE,
        .hpoint     = 0,
        .timer_sel  = SERVO_TIMER
    };
    ledc_channel_config(&ch_conf);

    vTaskDelay(pdMS_TO_TICKS(20));
    printf("Servo %d ready!", servo->channel);
}

// ----- Speed configuration -----
void servo_set_speed(servo_t *servo, uint32_t step_deg, uint32_t delay_ms)
{
    if (step_deg == 0) step_deg = 1;
    servo->step_deg = step_deg;
    servo->step_delay_ms = delay_ms;
    printf("Servo %d speed set: %ld deg/step, %ld ms delay",servo->channel, step_deg, delay_ms);
    printf("Servo %d speed configured!", servo->channel);
}

// ----- Instant movement -----
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

// ----- Speed controlled movement -----
void servo_move_slow(servo_t *servo, uint32_t target_angle)
{
    printf("Servo %d start movement.",servo->channel);
    if (target_angle > 180) target_angle = 180;

    int current = servo->current_angle;

    while (current != target_angle) {
        if (current < target_angle) {
            current += servo->step_deg;
            if (current > target_angle)
                current = target_angle;
        } else {
            current -= servo->step_deg;
            if (current < target_angle)
                current = target_angle;
        }

        servo_set_angle(servo, current);
        vTaskDelay(pdMS_TO_TICKS(servo->step_delay_ms));
    }
    printf("Servo %d finished movement.",servo->channel);
}
