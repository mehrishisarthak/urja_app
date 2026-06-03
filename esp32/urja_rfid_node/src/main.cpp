/**
 * Urja RFID Node -- ESP32 -> Firestore atomic increment
 * -------------------------------------------------------
 * Library : mobizt/FirebaseClient
 * Board   : ESP32
 * RFID    : MFRC522
 *
 * Wiring:
 *   MFRC522 SDA  -> GPIO  5  (SS)
 *   MFRC522 SCK  -> GPIO 18
 *   MFRC522 MOSI -> GPIO 23
 *   MFRC522 MISO -> GPIO 19
 *   MFRC522 RST  -> GPIO 22
 *   MFRC522 3.3V -> 3.3V
 *   MFRC522 GND  -> GND
 */

#define ENABLE_USER_AUTH
#define ENABLE_FIRESTORE

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>
#include "ExampleFunctions.h"
#include <SPI.h>
#include <MFRC522.h>

// ---- Pin config -------------------------------------------------------------
#define RFID_SS_PIN  5
#define RFID_RST_PIN 22

// ---- Credentials ------------------------------------------------------------
#define WIFI_SSID              "ARBAN"
#define WIFI_PASSWORD          "x87hd4s3"

#define FIREBASE_API_KEY       "AIzaSyB1Srqm2E5KWl5pJCXM4k2dXFqQl8eFfoY"
#define FIREBASE_USER_EMAIL    "esp32-node-1@urja.internal"
#define FIREBASE_USER_PASSWORD "umesh4sharma"

#define COLONY_CODE "URJA-JPR-444435"
#define PROJECT_ID  "urjaapp-c0cc6"

// Relative document path -- Docs.commit() + Firestore::Parent prepend the
// full "projects/.../databases/(default)/documents/" prefix automatically.
// Passing the full path here causes Firestore to see a doubled path -> 400.
#define DOC_REL_PATH "colonies/" COLONY_CODE

// ---- Firebase objects -------------------------------------------------------
UserAuth             user_auth(FIREBASE_API_KEY, FIREBASE_USER_EMAIL, FIREBASE_USER_PASSWORD);
FirebaseApp          app;
SSL_CLIENT           ssl_client;
AsyncClientClass     aClient(ssl_client);
Firestore::Documents Docs;

// ---- RFID -------------------------------------------------------------------
MFRC522 rfid(RFID_SS_PIN, RFID_RST_PIN);

// ---- Forward declarations ---------------------------------------------------
void onAuthEvent(AsyncResult &r);
void printUID();
void commitIncrement();

// ---- Auth event callback ----------------------------------------------------
void onAuthEvent(AsyncResult &r) {
    if (r.isError())
        Serial.printf("[Auth] Error %d: %s\n",
                      r.error().code(), r.error().message().c_str());
}

// ---- Print RFID UID to Serial -----------------------------------------------
void printUID() {
    Serial.print("Card UID: ");
    for (byte i = 0; i < rfid.uid.size; i++) {
        if (i) Serial.print(":");
        if (rfid.uid.uidByte[i] < 0x10) Serial.print("0");
        Serial.print(rfid.uid.uidByte[i], HEX);
    }
    Serial.println();
}

// ---- Atomic Firestore increment (+30 totalCoinsEarned) ----------------------
void commitIncrement() {
    FieldTransform::Increment incr(Values::IntegerValue(30));
    FieldTransform::FieldTransform fieldTransforms("totalCoinsEarned", incr);

    // Use the RELATIVE path here. Firestore::Parent(PROJECT_ID) supplies the
    // "projects/.../databases/(default)/documents/" prefix automatically.
    DocumentTransform transform(DOC_REL_PATH, fieldTransforms);
    Writes writes(Write(transform, Precondition()));

    AsyncResult result;
    Docs.commit(aClient, Firestore::Parent(PROJECT_ID), writes, result);

    unsigned long t0 = millis();
    while (!result.available() && millis() - t0 < 10000) {
        app.loop();
        delay(10);
    }

    if (!result.available()) {
        Serial.println("[Firestore] Commit timed out");
        return;
    }

    if (result.isError()) {
        int code = result.error().code();
        Serial.printf("[Firestore] HTTP %d - %s\n",
                      code, result.error().message().c_str());
        if (code == 400)
            Serial.println("  -> INVALID_ARGUMENT: check DOC_REL_PATH and field name");
        if (code == 401)
            Serial.println("  -> enable Email/Password auth in Firebase console");
        if (code == 403)
            Serial.println("  -> deploy firestore.rules: firebase deploy --only firestore:rules");
    } else {
        Serial.println("[Firestore] HTTP 200 - +30 coins committed");
    }
}

// ---- Setup ------------------------------------------------------------------
void setup() {
    Serial.begin(115200);
    delay(400);
    Serial.println("\n=== Urja RFID Node ===");

    SPI.begin(18, 19, 23, RFID_SS_PIN);
    rfid.PCD_Init();
    Serial.println("RFID ready");

    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
    Serial.print("WiFi connecting");
    while (WiFi.status() != WL_CONNECTED) {
        delay(300);
        Serial.print(".");
    }
    Serial.printf(" OK  IP: %s\n", WiFi.localIP().toString().c_str());

    set_ssl_client_insecure_and_buffer(ssl_client);

    initializeApp(aClient, app, getAuth(user_auth), onAuthEvent, "authTask");
    app.getApp<Firestore::Documents>(Docs);

    Serial.print("Signing in");
    unsigned long t0 = millis();
    while (!app.ready() && millis() - t0 < 15000) {
        app.loop();
        delay(100);
        Serial.print(".");
    }
    Serial.println();

    if (app.ready()) {
        Serial.println("Auth OK -> tap a card to add +30 coins");
    } else {
        Serial.println("Auth failed. Check FIREBASE_API_KEY and Email/Password auth settings.");
    }
}

// ---- Loop -------------------------------------------------------------------
void loop() {
    app.loop();

    if (!app.ready()) return;
    if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) return;

    printUID();
    rfid.PICC_HaltA();
    rfid.PCD_StopCrypto1();

    commitIncrement();

    delay(2000);
}
