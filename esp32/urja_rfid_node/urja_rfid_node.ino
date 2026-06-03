/**
 * Urja RFID Node — ESP32 → Firestore atomic increment
 * ─────────────────────────────────────────────────────
 * Library : mobizt/FirebaseClient  (Arduino Library Manager)
 * Board   : ESP32
 * RFID    : MFRC522
 *
 * Wiring:
 *   MFRC522 SDA  → GPIO  5  (SS)
 *   MFRC522 SCK  → GPIO 18
 *   MFRC522 MOSI → GPIO 23
 *   MFRC522 MISO → GPIO 19
 *   MFRC522 RST  → GPIO 22
 *   MFRC522 3.3V → 3.3V
 *   MFRC522 GND  → GND
 */

// These must come before FirebaseClient.h to enable the right modules
#define ENABLE_USER_AUTH
#define ENABLE_FIRESTORE

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>
#include <SPI.h>
#include <MFRC522.h>

// ─── Pin config ───────────────────────────────────────────────────────────────
#define RFID_SS_PIN  5
#define RFID_RST_PIN 22

// ─── Credentials ──────────────────────────────────────────────────────────────
#define WIFI_SSID             "ARBAN"
#define WIFI_PASSWORD         "x87hd4s3"

#define FIREBASE_API_KEY      "AIzaSyB1Srqm2E5KWl5pJCXM4k2dXFqQl8eFfoY"
#define FIREBASE_USER_EMAIL   "esp32-node-1@urja.internal"
#define FIREBASE_USER_PASSWORD "umesh4sharma"

#define COLONY_CODE  "URJA-JPR-444435"
#define PROJECT_ID   "urjaapp-c0cc6"

// Full Firestore document resource name used by DocumentTransform
#define DOC_PATH \
  "projects/" PROJECT_ID "/databases/(default)/documents/colonies/" COLONY_CODE

// ─── Firebase objects ─────────────────────────────────────────────────────────
DefaultNetwork      network;
UserAuth            user_auth(FIREBASE_API_KEY, FIREBASE_USER_EMAIL, FIREBASE_USER_PASSWORD);
FirebaseApp         app;
WiFiClientSecure    ssl_client;
AsyncClientClass    aClient(ssl_client, getNetwork(network));
Firestore::Documents Docs;

// ─── RFID ─────────────────────────────────────────────────────────────────────
MFRC522 rfid(RFID_SS_PIN, RFID_RST_PIN);

// ─── Auth event callback ──────────────────────────────────────────────────────
void onAuthEvent(AsyncResult &r) {
  if (r.isError())
    Serial.printf("[Auth] Error %d: %s\n",
                  r.error().code(), r.error().message().c_str());
}

// ─── Print RFID UID to Serial ─────────────────────────────────────────────────
void printUID() {
  Serial.print("Card UID: ");
  for (byte i = 0; i < rfid.uid.size; i++) {
    if (i) Serial.print(":");
    if (rfid.uid.uidByte[i] < 0x10) Serial.print("0");
    Serial.print(rfid.uid.uidByte[i], HEX);
  }
  Serial.println();
}

// ─── Atomic Firestore increment (+30 totalCoinsEarned) ───────────────────────
void commitIncrement() {
  // FieldTransform: server-side atomic increment
  DocumentTransform::FieldTransform ft;
  ft.fieldPath("totalCoinsEarned");
  ft.increment(Values::IntegerValue(30));

  // Combined update (empty body) + updateTransforms so that
  // request.resource.data in Firestore security rules contains the full
  // document, not just the transformed field.
  Document<Values::StringValue> emptyDoc(DOC_PATH);
  Write w;
  w.update(emptyDoc);
  w.updateTransforms(ft);
  Writes writes;
  writes.writes(w);

  // 4. Commit and wait (max 10 s)
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
    Serial.printf("[Firestore] HTTP %d — %s\n",
                  code, result.error().message().c_str());
    if (code == 400)
      Serial.println("  → Fix: colony document does not exist yet — create colonies/" COLONY_CODE " in Firebase console with totalCoinsEarned: 0");
    if (code == 401)
      Serial.println("  → Fix: enable Email/Password auth in Firebase console");
    if (code == 403)
      Serial.println("  → Fix: COLONY_CODE mismatch, or deploy firestore.rules");
  } else {
    Serial.println("[Firestore] HTTP 200 — +30 coins committed");
  }
}

// ─── Setup ────────────────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  delay(400);
  Serial.println("\n=== Urja RFID Node ===");

  SPI.begin(18 /*SCK*/, 19 /*MISO*/, 23 /*MOSI*/, RFID_SS_PIN);
  rfid.PCD_Init();
  Serial.println("RFID ready");

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("WiFi connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.printf(" OK  IP: %s\n", WiFi.localIP().toString().c_str());

  // Skip TLS cert verification (fine for a local IoT node).
  // For production: ssl_client.setCACert(FIREBASE_ROOT_CA);
  ssl_client.setInsecure();

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
    Serial.println("Auth OK  →  tap a card to add +30 coins");
  } else {
    Serial.println("Auth failed. Check FIREBASE_API_KEY and Email/Password auth settings.");
  }
}

// ─── Loop ─────────────────────────────────────────────────────────────────────
void loop() {
  app.loop();  // keeps auth token refreshed

  if (!app.ready()) return;
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) return;

  printUID();
  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();

  commitIncrement();

  delay(2000);  // debounce: ignore re-taps for 2 s
}
