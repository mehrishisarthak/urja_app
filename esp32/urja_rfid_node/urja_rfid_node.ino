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

#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClientSecure.h>
#include <FirebaseClient.h>
#include <SPI.h>
#include <MFRC522.h>

#define RFID_SS_PIN   5
#define RFID_RST_PIN  22

#define WIFI_SSID         "ARBAN"
#define WIFI_PASSWORD     "x87hd4s3"

#define FIREBASE_API_KEY  "AIzaSyB1Srqm2E5KWl5pJCXM4k2dXFqQl8eFfoY"

#define COLONY_CODE       "URJA-JPR-444435"

#define PROJECT_ID  "urjaapp-c0cc6"

#define DOC_PATH \
  "projects/" PROJECT_ID "/databases/(default)/documents/colonies/" COLONY_CODE

// UserAuth with empty email/password → anonymous sign-in (signUp REST endpoint)
DefaultNetwork   network;
UserAuth         user_auth(FIREBASE_API_KEY, "esp32-node-1@urja.internal", "umesh4sharma" );
FirebaseApp      app;
WiFiClientSecure ssl_client;
AsyncClientClass aClient(ssl_client, getNetwork(network));
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
  // 1. FieldTransform: increment totalCoinsEarned by 30
  DocumentTransform::FieldTransform ft;
  ft.fieldPath("totalCoinsEarned");
  ft.increment(Values::IntegerValue(30));

  // 2. Attach transform to the colony document
  DocumentTransform dt;
  dt.document(DOC_PATH);
  dt.fieldTransforms(ft);

  // 3. Wrap in a Write
  Write w;
  w.transform(dt);

  // 4. Build the Writes payload (supports batching; we send one)
  Writes writes;
  writes.writes(w);

  // 5. Fire the commit and wait for result (max 10 s)
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
    if (code == 401)
      Serial.println("  → Fix: enable Anonymous Auth in Firebase console (Auth → Sign-in method)");
    if (code == 403)
      Serial.println("  → Fix: COLONY_CODE doesn't match a Firestore doc, OR run: firebase deploy --only firestore:rules");
  } else {
    Serial.println("[Firestore] HTTP 200 — +30 coins committed (atomic increment)");
  }
}

// ─── Setup ────────────────────────────────────────────────────────────────────
void setup() {
  Serial.begin(115200);
  delay(400);
  Serial.println("\n=== Urja RFID Node ===");

  // SPI with explicit GPIO assignments for ESP32
  SPI.begin(18 /*SCK*/, 19 /*MISO*/, 23 /*MOSI*/, RFID_SS_PIN /*SS*/);
  rfid.PCD_Init();
  Serial.println("RFID ready");

  // WiFi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("WiFi connecting");
  while (WiFi.status() != WL_CONNECTED) {
    delay(300);
    Serial.print(".");
  }
  Serial.printf(" OK  IP: %s\n", WiFi.localIP().toString().c_str());

  // Skip TLS cert verification.
  // For production, set the Firebase root CA instead:
  //   ssl_client.setCACert(FIREBASE_ROOT_CA);
  ssl_client.setInsecure();

  // Init Firebase (anonymous sign-in triggered by empty email/password)
  initializeApp(aClient, app, getAuth(user_auth), onAuthEvent, "authTask");
  app.getApp<Firestore::Documents>(Docs);

  // Block until auth token is ready (max 15 s)
  Serial.print("Signing in anonymously");
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
    Serial.println("Auth failed. Check FIREBASE_API_KEY and that Anonymous Auth is enabled.");
  }
}

// ─── Loop ─────────────────────────────────────────────────────────────────────
void loop() {
  app.loop();  // keeps the anonymous token refreshed automatically

  if (!app.ready()) return;

  // Early-out if no new card is in the field
  if (!rfid.PICC_IsNewCardPresent() || !rfid.PICC_ReadCardSerial()) return;

  printUID();

  // Halt the card so it won't fire again until removed and re-tapped
  rfid.PICC_HaltA();
  rfid.PCD_StopCrypto1();

  commitIncrement();

  // Debounce: ignore new cards for 2 s after a successful tap
  delay(2000);
}
