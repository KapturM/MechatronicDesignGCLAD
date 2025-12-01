#include <string.h>
#include <math.h>
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "esp_log.h"
#include "driver/rmt_tx.h"

#include <stdio.h>
#include "driver/uart.h"
#include "driver/gpio.h"

#define UART_PORT UART_NUM_0
#define BUF_SIZE 1024

#define FRAME_DURATION_MS   20

static const gpio_num_t led_pin = GPIO_NUM_2; // GPIO pin for the LED

static const char *TAG = "UART_APP";


void app_main(void)
{
     // Configure UART
    uart_config_t uart_config = {
        .baud_rate = 115200,
        .data_bits = UART_DATA_8_BITS,
        .parity = UART_PARITY_DISABLE,
        .stop_bits = UART_STOP_BITS_1,
        .flow_ctrl = UART_HW_FLOWCTRL_DISABLE,
    };

    uart_param_config(UART_PORT, &uart_config);
    uart_driver_install(UART_PORT, BUF_SIZE, BUF_SIZE, 0, NULL, 0);

    char data[BUF_SIZE];

    uart_write_bytes(UART_PORT, "ESP32 Ready\r\n", 13);


    gpio_reset_pin(led_pin);
    // Configure the GPIO pin for the LED
    gpio_config_t io_conf = {
        .pin_bit_mask = (1ULL << led_pin), // Bit mask for the LED pin
        .mode = GPIO_MODE_OUTPUT,          // Set as output mode
        .pull_up_en = GPIO_PULLUP_DISABLE, // Disable pull-up
        .pull_down_en = GPIO_PULLDOWN_DISABLE, // Disable pull-down
        .intr_type = GPIO_INTR_DISABLE     // Disable interrupts
    };
    gpio_config(&io_conf);
    
    while (1) {
        int len = uart_read_bytes(UART_PORT, (uint8_t *)data, BUF_SIZE - 1, pdMS_TO_TICKS(100));
        
        if (len > 0) {
            data[len] = 0;   // Null-terminate
            ESP_LOGI(TAG, "Received: %s", data);

            // Strip newline
            for (int i = 0; i < len; i++) {
                if (data[i] == '\r' || data[i] == '\n') data[i] = 0;
            }

            // Command handling
            if (strcmp(data, "LED ON") == 0) {
                // Turn the LED on
                gpio_set_level(led_pin, 1);
                printf("Hello, Blinky! LED ON\n");
   
            } else if (strcmp(data, "LED OFF") == 0) {
                // Turn the LED off
                gpio_set_level(led_pin, 0);
                printf("Hello, Blinky! LED OFF\n");

            } else {
                uart_write_bytes(UART_PORT, "Unknown command\r\n", 18);
            }
        }
        vTaskDelay(pdMS_TO_TICKS(FRAME_DURATION_MS));
    }
}
