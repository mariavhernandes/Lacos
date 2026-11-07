#include "esp_camera.h"
#include <WiFi.h>
#include <HTTPClient.h>

// --- AJUSTE AQUI ---
const char* ssid = "A54 de Maria Victória";
const char* password = "mariavictoria";
const char* serverUrl = "http://10.145.140.207:3000/api/upload.php";

#define BUTTON_PIN 21

// Pinos Câmera Freenove ESP32-S3
#define PWDN_GPIO_NUM -1
#define RESET_GPIO_NUM -1
#define XCLK_GPIO_NUM 15
#define SIOD_GPIO_NUM 4
#define SIOC_GPIO_NUM 5
#define Y9_GPIO_NUM 16
#define Y8_GPIO_NUM 17
#define Y7_GPIO_NUM 18
#define Y6_GPIO_NUM 12
#define Y5_GPIO_NUM 10
#define Y4_GPIO_NUM 8
#define Y3_GPIO_NUM 9
#define Y2_GPIO_NUM 11
#define VSYNC_GPIO_NUM 6
#define HREF_GPIO_NUM 7
#define PCLK_GPIO_NUM 13

void sendPhoto() {
  // ------------------------------------------------------------------
  // 1. SOLUÇÃO DO ATRASO: Descarrega o frame antigo parado no buffer
  // ------------------------------------------------------------------
  camera_fb_t * fb_old = esp_camera_fb_get();
  if (fb_old) {
    esp_camera_fb_return(fb_old); // Limpa a foto antiga da memória RAM
  }

  // ------------------------------------------------------------------
  // 2. Captura a foto REAL no momento exato do clique
  // ------------------------------------------------------------------
  camera_fb_t * fb = esp_camera_fb_get();
  if (!fb) {
    Serial.println("Erro na câmera!");
    return;
  }

  HTTPClient http;
  http.begin(serverUrl);

  String boundary = "----ESP32Boundary";
  
  // Nome dinâmico para evitar cache de nome fixo
  String filename = "esp32_" + String(millis()) + ".jpg";

  String head = "--" + boundary + "\r\nContent-Disposition: form-data; name=\"imageFile\"; filename=\"" + filename + "\"\r\nContent-Type: image/jpeg\r\n\r\n";
  String tail = "\r\n--" + boundary + "--\r\n";

  uint32_t totalLen = head.length() + fb->len + tail.length();
  http.addHeader("Content-Type", "multipart/form-data; boundary=" + boundary);

  uint8_t *buffer = (uint8_t *)malloc(totalLen);
  if (buffer) {
    memcpy(buffer, head.c_str(), head.length());
    memcpy(buffer + head.length(), fb->buf, fb->len);
    memcpy(buffer + head.length() + fb->len, tail.c_str(), tail.length());

    int httpCode = http.POST(buffer, totalLen);
    Serial.printf("Envio HTTP: %d\n", httpCode);
    free(buffer);
  } else {
    Serial.println("Erro ao alocar memória para o buffer!");
  }

  http.end();
  esp_camera_fb_return(fb); // Libera o buffer da câmara para o próximo clique
}

void setup() {
  Serial.begin(115200);
  pinMode(BUTTON_PIN, INPUT_PULLDOWN);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) { 
    delay(500); 
    Serial.print("."); 
  }
  Serial.println("\nWi-Fi Conectado!");

  camera_config_t config;
  config.ledc_channel = LEDC_CHANNEL_0;
  config.ledc_timer = LEDC_TIMER_0;
  config.pin_d0 = Y2_GPIO_NUM; config.pin_d1 = Y3_GPIO_NUM;
  config.pin_d2 = Y4_GPIO_NUM; config.pin_d3 = Y5_GPIO_NUM;
  config.pin_d4 = Y6_GPIO_NUM; config.pin_d5 = Y7_GPIO_NUM;
  config.pin_d6 = Y8_GPIO_NUM; config.pin_d7 = Y9_GPIO_NUM;
  config.pin_xclk = XCLK_GPIO_NUM; config.pin_pclk = PCLK_GPIO_NUM;
  config.pin_vsync = VSYNC_GPIO_NUM; config.pin_href = HREF_GPIO_NUM;
  config.pin_sccb_sda = SIOD_GPIO_NUM; config.pin_sccb_scl = SIOC_GPIO_NUM;
  config.pin_pwdn = PWDN_GPIO_NUM; config.pin_reset = RESET_GPIO_NUM;
  config.xclk_freq_hz = 10000000;
  config.pixel_format = PIXFORMAT_JPEG;
  config.frame_size = FRAMESIZE_VGA;
  config.jpeg_quality = 12;
  config.fb_count = 1;

  esp_camera_init(&config);
  Serial.println("Pronto! Aperte o botão.");
}

void loop() {
  if (digitalRead(BUTTON_PIN) == HIGH) {
    Serial.println("Enviando foto...");
    sendPhoto();
    delay(2000); // Debounce do botão
  }
  delay(50);
}