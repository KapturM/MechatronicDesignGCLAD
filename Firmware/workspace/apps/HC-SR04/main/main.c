#include <stdio.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "driver/gpio.h"
#include "esp_timer.h"
#include "esp_log.h"

#define TAG "HC_SR04"

// GPIO configuration
#define TRIG_GPIO 5
#define ECHO_GPIO 18

#define TRIG_PULSE_US 10
#define MEASURE_INTERVAL_MS 1000
#define TIMEOUT_US 300000  // 300 ms timeout for echo

static void hc_sr04_task(void *arg)
{
    gpio_set_direction(TRIG_GPIO, GPIO_MODE_OUTPUT);
    gpio_set_direction(ECHO_GPIO, GPIO_MODE_INPUT);

    while (1) {
        // Ensure TRIG is low
        gpio_set_level(TRIG_GPIO, 0);
        esp_rom_delay_us(2);

        // Send 10 us pulse
        gpio_set_level(TRIG_GPIO, 1);
        esp_rom_delay_us(TRIG_PULSE_US);
        gpio_set_level(TRIG_GPIO, 0);

        // Wait for ECHO to go high
        int64_t start_time = esp_timer_get_time();
        while (gpio_get_level(ECHO_GPIO) == 0) {
            if (esp_timer_get_time() - start_time > TIMEOUT_US) {
                ESP_LOGW(TAG, "Timeout waiting for echo HIGH");
                goto delay;
            }
        }

        int64_t echo_start = esp_timer_get_time();

        // Wait for ECHO to go low
        while (gpio_get_level(ECHO_GPIO) == 1) {
            if (esp_timer_get_time() - echo_start > TIMEOUT_US) {
                ESP_LOGW(TAG, "Timeout waiting for echo LOW");
                goto delay;
            }
        }

        int64_t echo_end = esp_timer_get_time();
        int64_t echo_time_us = echo_end - echo_start;

        float distance_cm = (echo_time_us * 0.0343f) / 2.0f;

        ESP_LOGI(TAG, "Distance: %.2f cm", distance_cm);

    delay:
        vTaskDelay(pdMS_TO_TICKS(MEASURE_INTERVAL_MS));
    }
}

void app_main(void)
{
    xTaskCreate(
        hc_sr04_task,
        "hc_sr04_task",
        4096,
        NULL,
        5,
        NULL
    );
}
