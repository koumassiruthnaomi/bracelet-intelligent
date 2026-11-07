#include <WiFi.h>
#include <PubSubClient.h>
#include <DHT.h>

// Wi-Fi Wokwi
const char* ssid = "Wokwi-GUEST";
const char* password = "";

// Broker MQTT
const char* mqtt_server = "test.mosquitto.org";

// DHT22
#define DHTPIN 14
#define DHTTYPE DHT22

// Bouton et LED
#define BUTTON_PIN 16
#define LED_PIN 5

DHT dht(DHTPIN, DHTTYPE);

WiFiClient espClient;
PubSubClient client(espClient);

void reconnect() {
  while (!client.connected()) {
    Serial.print("Connexion au broker MQTT...");

    String clientId = "ESP32-";
    clientId += String(random(0xffff), HEX);

    if (client.connect(clientId.c_str())) {
      Serial.println("Connecté !");
    } else {
      Serial.print("Erreur : ");
      Serial.println(client.state());
      delay(2000);
    }
  }
}

void setup() {
  Serial.begin(115200);

  dht.begin();

  pinMode(BUTTON_PIN, INPUT_PULLUP);
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  WiFi.begin(ssid, password);
  Serial.print("Connexion au Wi-Fi");

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("\nWi-Fi connecté !");
  client.setServer(mqtt_server, 1883);
}

void loop() {

  if (!client.connected()) {
    reconnect();
  }

  client.loop();

  // Lecture du DHT22
  float temperature = dht.readTemperature();
  float humidity = dht.readHumidity();

  if (!isnan(temperature) && !isnan(humidity)) {

    String temp = "La température est de " + String(temperature, 2) + " °C";
    String hum = "L'humidité est de " + String(humidity, 2) + " %";

    client.publish("ruth/iot/temperature", temp.c_str());
    client.publish("ruth/iot/humidity", hum.c_str());

    Serial.println(temp);
    Serial.println(hum);
  }

  // Tentative de retrait du bracelet
  if (digitalRead(BUTTON_PIN) == LOW) {

    digitalWrite(LED_PIN, HIGH);

    String alerte = "ALERTE : Tentative de retrait du bracelet !";
    String camera = "ESP32-CAM : Photo capturée.";
    String gps = "Position GPS envoyée aux parents.";

    client.publish("ruth/iot/alerte", alerte.c_str());
    client.publish("ruth/iot/camera", camera.c_str());
    client.publish("ruth/iot/gps", gps.c_str());

    Serial.println(alerte);
    Serial.println(camera);
    Serial.println(gps);

    delay(2000);

  } else {

    digitalWrite(LED_PIN, LOW);

  }

  delay(5000);
}