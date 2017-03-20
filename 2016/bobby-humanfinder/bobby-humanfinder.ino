/*

code for bobby anspach
written by sam galison, 2016

*/

int photocell = A2;
int reading = 0;

void setup() {

  pinMode(photocell, INPUT);

  Serial.begin(9600);

  Serial.println("hello world! i'm done setting up.");

} // end setup


void loop() {

    reading = analogRead(photocell);

    Serial.print(reading);
    Serial.println();

    delay(10);
    // hang out for 10ms to let the serial buffer catch up

} // end of the loop
