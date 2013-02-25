/*
 * MicBlink
 */
 
#define LED_PORT 13

#define PERIOD     5000
#define LOW_PERIOD 1500

void setup() {                
  pinMode(LED_PORT, OUTPUT);     
}

void loop() {
  digitalWrite(LED_PORT, HIGH);
  delay(PERIOD - LOW_PERIOD);
  digitalWrite(LED_PORT, LOW);
  delay(LOW_PERIOD);
}
