#include <Arduino.h>
#include <HardwareSerial.h>
#include <BLEDevice.h>
#include <BLEServer.h>
#include <BLEUtils.h>
#include <BLE2902.h>

// UART
HardwareSerial Serial2(1);  // UART1
#define UART_RX 20
#define UART_TX 21
#define UART_BAUDRATE 115200

// BLE
BLECharacteristic *pCharacteristic;
bool deviceConnected = false;

#define SERVICE_UUID        "2E18CC93-EFBE-4927-AC92-0D229C122383"
#define CHARACTERISTIC_UUID "13909B07-0859-452F-AB6E-E5A4BC8D9DF4"  // Notify

class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer* pServer) {
    deviceConnected = true;
  }
  void onDisconnect(BLEServer* pServer) {
    deviceConnected = false;
  }
};

void setup() {
  Serial.begin(115200);
  Serial2.begin(UART_BAUDRATE, SERIAL_8N1, UART_RX, UART_TX);  // RX ← Pico TX

  // BLE Init
  BLEDevice::init("ESP32-EMG");
  BLEServer *pServer = BLEDevice::createServer();
  pServer->setCallbacks(new MyServerCallbacks());

  BLEService *pService = pServer->createService(SERVICE_UUID);
  pCharacteristic = pService->createCharacteristic(
                      CHARACTERISTIC_UUID,
                      BLECharacteristic::PROPERTY_NOTIFY
                    );
  pCharacteristic->addDescriptor(new BLE2902());

  pService->start();
  pServer->getAdvertising()->start();

  Serial.println("BLE UART Bridge Ready");
}

void loop() {
  if (Serial2.available()) {
    String received = Serial2.readStringUntil('\n');
    Serial.println("Recibido desde Pico: " + received);

    if (deviceConnected) {
      pCharacteristic->setValue(received.c_str());
      pCharacteristic->notify();
      Serial.println("Dato enviado por BLE");
    }
  }

  delay(10); // pequeña pausa para estabilidad
}
