/*

 Mid Term
 Mudassir Mohammed, Parth Soni
 DIGF 2B03 Physical Computing S01
 OCAD University
 Created on [Feb. 8th 2015]
 
 Based on:
 a touch of imagination and lots of Googling! 

*/
#include <Servo.h> 

Servo lips;  // create servo object to control a servo 
const int total_pos = 150; // Total Space in the Hat Talk Servo! Have mroe than needed for testing and safety
const int pos_1 =125; // Number of used position in the first dialogue
const int pos_2 = 110; // NUmber of servo movements in second dialogue
const int pos_3 = 25; // Number of Servo Movements in the third dialogue
const int maxRot = 179; //Maximum Servo Rotation
const int minRot = 130; // Minimum Servo Rotation
int servoPos [total_pos]  ;

char val ; // Values recieed from Processing
int indexFingerPin =A0;//The Index finger movement of the Glove
int ringFingerPin =A1; // the Ring Finger Movement of the Glove
int gameStartPin = 7; // Switch to turn on the Game
int speakerPin = 10; //to indicate Rock, Paper and Scissors

int rockLED = 11; // Rock LED
int paperLED = 12; // Paper LED
int scissorsLED = 13; // Scissors LED

int gameStart = 0; // Start game
int indexFinger; // Index Finger Sensor Vals
int ringFinger; // Ring Finger Sensor Vals

boolean firstMovement = false; // This is the First Movement of mouth
boolean secondMovement = false;  // This is the Second Movement of the mouth
boolean thirdMovement = false; // This is the Third Movement of the mouth
int ringMap;
void setup(){
  
Serial.begin (9600);
lips.attach (9);//Servo Attach
pinMode (gameStartPin, INPUT); // POT Switch
pinMode (speakerPin, OUTPUT); // Speaker
pinMode (rockLED,OUTPUT); // Rock LED
pinMode (paperLED,OUTPUT); // Paper LED
pinMode (scissorsLED,OUTPUT); // Scissors LED

lips.write(180); // Initial Mouth Position (Keep it closed, just incase flies sneak in)
}

void loop() {
  
   gameStart = digitalRead (gameStartPin) ; // To see if the user has started the game
//  println(gameStart);
  // The Game Starts
  if (gameStart == HIGH) {
    val = Serial.read();
    
    talkingPart(); // Move the Servo
    indexFinger = analogRead(indexFingerPin); // Checks for index finger bend
  ringFinger = analogRead(ringFingerPin);
  ringMap = map(ringFinger,726,822,980,1008);
    parsingSerial(); // Send the sensor Value data
    delay (125); // Have some Sensor Value Delay
    
  }
  else {
    parsingSerial(); // Send sensor data
    lips.write (180); // If the game is off, move the lips to a close position
   // Keep the LEDS off
    digitalWrite(paperLED,LOW); 
    digitalWrite(rockLED,LOW);
    digitalWrite(scissorsLED,LOW);
  }


}

void talkingPart () {
  
    // First Talking Part
    if (val == '0'){
      firstMovement = true;
    }
    // If the value has been recieved Start Talking!
    if (firstMovement){
      for (int i = 0; i < pos_1; i++){
       int randomNumber = random (minRot,maxRot);
       servoPos[i] = randomNumber;
       lips.write(servoPos[i]);
       delay(125);
      }
      firstMovement = false;
    }
    
    
    // Second Talking Part
    if (val == '1'){
      secondMovement = true;
    }
    // If the value has been recieved Start Talking!
    if (secondMovement){
      for (int i = 0; i < pos_2; i++){
       int randomNumber = random (minRot,maxRot);
       servoPos[i] = randomNumber;
       lips.write(servoPos[i]);
       delay(100);
      }
      secondMovement = false;
    }
    
    //Third Talking Part
        if (val == '2'){
      thirdMovement = true;
    }
    // If the value has been recieved Start Talking!
    if (thirdMovement){
      for (int i = 0; i < pos_3; i++){
       int randomNumber = random (minRot,maxRot);
       servoPos[i] = randomNumber;
       lips.write(servoPos[i]);
       delay(200);
      }
      thirdMovement = false;
    }
    
    // The game starts!
    if(val=='3'){
         digitalWrite(scissorsLED,LOW); 
        digitalWrite(paperLED,LOW);
        digitalWrite(rockLED,LOW);
        delay(100);
       lips.write(160);
      digitalWrite(rockLED, HIGH);
       lips.write(180);
      tone (speakerPin, 261, 900);
      delay (900);
      digitalWrite(paperLED, HIGH);
      tone (speakerPin, 461, 900);
       lips.write(180);
      delay (900);
        lips.write(150);
      digitalWrite(scissorsLED, HIGH);
      tone (speakerPin, 661, 900);
      delay (900);

    }   
   // This is to check if th hat has picked, Rock, Paper or Scissors
    if (val == '4'){
        digitalWrite(rockLED,HIGH);
        digitalWrite(paperLED,LOW);
        digitalWrite(scissorsLED,LOW);
    }
       if (val == '5'){
        digitalWrite(paperLED,HIGH);
        digitalWrite(rockLED,LOW);
        digitalWrite(scissorsLED,LOW);
    }
       if (val == '6'){
        digitalWrite(scissorsLED,HIGH); 
        digitalWrite(paperLED,LOW);
        digitalWrite(rockLED,LOW);
   
    }

}

void parsingSerial () {
  // Pass all of the beautiful data to processing
    Serial.print(gameStart);
    Serial.print(",");
    Serial.print (indexFinger);
    Serial.print(",");
    Serial.println (ringMap);

}
