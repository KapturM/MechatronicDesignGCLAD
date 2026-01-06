#include "stepper.h"

typedef struct {
    int target;
} stepper_cmd_t;

// ================= INTERNAL FUNCTIONS ==========================

static void stepper_task(void *arg)
{
    stepper_t *m = (stepper_t *)arg;
    stepper_cmd_t cmd;

    while (1) {
        if (xQueueReceive(m->command_queue, &cmd, portMAX_DELAY)) {

            m->target_position = cmd.target;

            int diff = m->target_position - m->current_position;
            int dir = (diff > 0) ? 1 : -1;
            gpio_set_level(m->dir_pin, dir > 0);

            int total_steps = abs(diff) * m->microsteps;

            int accel = m->accel_steps;
            int steps = total_steps;

            for (int i = 0; i < steps; i++) {

                if (m->stop_requested) {
                    break;
                }

                int delay;

                if (i < accel) {
                    // Acceleration phase
                    delay = m->max_delay_us -
                            (m->max_delay_us - m->min_delay_us) * i / accel;
                }
                else if (i > steps - accel) {
                    // Deceleration phase
                    int d = steps - i;
                    delay = m->max_delay_us -
                            (m->max_delay_us - m->min_delay_us) * d / accel;
                }
                else {
                    // Cruise
                    delay = m->min_delay_us;
                }

                gpio_set_level(m->step_pin, 1);
                esp_rom_delay_us(delay);
                gpio_set_level(m->step_pin, 0);
                esp_rom_delay_us(delay);

                m->current_position += dir;
            }

            m->stop_requested = false;
            m->target_position = m->current_position;

        }
    }
}

// ============ PUBLIC API =======================================

void stepper_init(stepper_t *m,
                  gpio_num_t step,
                  gpio_num_t dir,
                  gpio_num_t enable,
                  int min_delay_us,
                  float microsteps)
{
    m->step_pin = step;
    m->dir_pin = dir;
    m->enable_pin = enable;
    m->min_delay_us = min_delay_us;
    m->microsteps = microsteps;

    m->accel_steps = 50;  // default ramp length               
    m->max_delay_us = min_delay_us * 25; // default start/stop speed

    m->current_position = 0;
    m->target_position = 0;

    // Init GPIO
    gpio_config_t io = {
        .mode = GPIO_MODE_OUTPUT,
        .intr_type = GPIO_INTR_DISABLE,
        .pull_down_en = false,
        .pull_up_en = false,
        .pin_bit_mask = (1ULL << step) |
                        (1ULL << dir) |
                        (1ULL << enable)
    };
    gpio_config(&io);

    gpio_set_level(enable, 0);  // enable driver

    // Create command queue
    m->command_queue = xQueueCreate(4, sizeof(stepper_cmd_t));

    // Create task
    xTaskCreate(stepper_task, "stepper_task", 2048, m, 5, &m->task_handle);
}

void stepper_enable(stepper_t *m) {
    gpio_set_level(m->enable_pin, 0);
}

void stepper_disable(stepper_t *m) {
    gpio_set_level(m->enable_pin, 1);
}

void stepper_set_home(stepper_t *m, int pos) {
    m->current_position = pos;
}

void stepper_move_to(stepper_t *m, int target_position)
{
    stepper_cmd_t cmd = { .target = target_position };
    xQueueSend(m->command_queue, &cmd, 0);   // non-blocking
}

bool stepper_is_busy(stepper_t *m)
{
    return !m->stop_requested &&
           (m->current_position != m->target_position);
}

void stepper_stop(stepper_t *m)
{
    m->stop_requested = true;
}
