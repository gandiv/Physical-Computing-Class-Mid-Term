//Text To Speech

// the text to speech class
import java.io.IOException;

static class TextToSpeech extends Object {

  // Store the voices, makes for nice auto-complete in Eclipse

  // male voices
  static final String ALEX = "Alex";
  static final String BRUCE = "Bruce";
  static final String FRED = "Fred";
  static final String JUNIOR = "Junior";
  static final String RALPH = "Ralph";

  // female voices
  static final String AGNES = "Agnes";
  static final String KATHY = "Kathy";
  static final String PRINCESS = "Princess";
  static final String VICKI = "Vicki";
  static final String VICTORIA = "Victoria";

  // novelty voices
  static final String ALBERT = "Albert";
  static final String BAD_NEWS = "Bad News";
  static final String BAHH = "Bahh";
  static final String BELLS = "Bells";
  static final String BOING = "Boing";
  static final String BUBBLES = "Bubbles";
  static final String CELLOS = "Cellos";
  static final String DERANGED = "Deranged";
  static final String GOOD_NEWS = "Good News";
  static final String HYSTERICAL = "Hysterical";
  static final String PIPE_ORGAN = "Pipe Organ";
  static final String TRINOIDS = "Trinoids";
  static final String WHISPER = "Whisper";
  static final String ZARVOX = "Zarvox";

  // throw them in an array so we can iterate over them / pick at random
  static String[] voices = {
    ALEX, BRUCE, FRED, JUNIOR, RALPH, AGNES, KATHY,
    PRINCESS, VICKI, VICTORIA, ALBERT, BAD_NEWS, BAHH,
    BELLS, BOING, BUBBLES, CELLOS, DERANGED, GOOD_NEWS,
    HYSTERICAL, PIPE_ORGAN, TRINOIDS, WHISPER, ZARVOX
  };

  // this sends the "say" command to the terminal with the appropriate args
  static void say(String script, String voice, int speed) {
    try {
      Runtime.getRuntime().exec(new String[] {"say", "-v", voice, "[[rate " + speed + "]]" + script});
    }
    catch (IOException e) {
      System.err.println("IOException");
    }
  }

  // Overload the say method so we can call it with fewer arguments and basic defaults
  static void say(String script) {
    // 200 seems like a resonable default speed
    say(script, ALEX, 200);
  }

}
// Program starts
/*
This program is written by Parth Soni & Mudassir Mohammed
*/
import processing.serial.*;
Serial myPort;

int[] values; //incoming values

// Phrases the hat speaks
String[] script = {
  "Hey! WEAR ME!!!, Let's, Play, a, Game! EH, HEHHH, HEH, HEEEH.", 
  "...Hey Human!......... Wear the glove,......... and play rock paper and scissors with me!......PUT ON THE GLOVE.....EH HEH HEH EH", 
  ".........Did you, put the, glove on?, make a fist, with your glove, and see how it feels!", 
  "...... Strike, Rock..., Paper or... Scissors...,... on, Go!", 
  "...Rock, Paper, Scissors, GO!"
};

int numOfSensors = 2; // Change this depending on incoming Values
int gameStart; // Start The Damn Game!
int indexFinger; // Index Finger Value
int ringFinger; // Ring Finger Value
int closedFist = 990; // The bent sensor Value
boolean hatDecision = false;  //Capturing the Hat value
int RPS; // The hat decision value
int userAction_1; // The user decision value
int userAction_2; // The user deicion value
int userChoice;

int voiceIndex = 11; // Currently the narrator is Bad News
int voiceSpeed = 250; // Speed of the narrator

boolean timerReset = false; // Reset Time

// all dialogues
boolean dialogue1 = false; // Used to start the first dialogue (normally true) 
int dialogue1Duration = 25000; //Length of the first dialogue, Change this with narrator and speed

boolean dialogue2 = false; // Used to start the second dialogue

boolean dialogue3 = false; // Used to start the third dialogue
int clenchFistDuration = 15000; //Third dialogue duration
boolean clenchSuccess = false; // Check if the user is wearing the glove or not
boolean hatFinishClench = false; // Hat finishes the third dialogue

boolean dialogue4 = false; // used to start the fourth dialogue
int dialogue4Duration =10000; // fourth dialogue duration

boolean dialogue5 = true; // used to start the fifth dialogue

//Timer to check for things
int savedTime = 0;

void setup () {
  size (1280, 720);
  myPort = new Serial (this, Serial.list()[5], 9600);
  myPort.bufferUntil('\n'); // Read until the End of Line
  background(0);
}

void draw () {
  background (0);

  //Check if the switch has been pressed
  if (gameStart==1) {
    // To Reset the timer when game starts
    if (!timerReset) {
      savedTime = millis();
      timerReset = true;
    }

    int passedTime = millis() - savedTime; // Passed time in the Timer
//    println(passedTime);

    //First Dialogue
    if (dialogue1 == true) {
      TextToSpeech.say(script[1], TextToSpeech.voices[voiceIndex], voiceSpeed);
      dialogue1 = false;
      dialogue2 = true;
      myPort.write('0'); //send a 0 to arduino for first talk
    } // End of Dialogue 1

    //Second Dialogue
    if (dialogue2) {
      if (passedTime > dialogue1Duration) {
        savedTime = millis();
        dialogue2 = false; // So it never returns to the Second dialogue unless on reset
        TextToSpeech.say(script[2], TextToSpeech.voices[voiceIndex], voiceSpeed);
        myPort.write('1'); //send a 0 to arduino for first talk
        dialogue3 = true; // Start to check if the user is clenching the glove
      }
    } // End of Dialogue 2

    // Third Dialogue (Mostly just to check fist clenching)
    if (dialogue3) {
      // If the user clenched their fist and hat finished talking, then go to next dialogue
      if (indexFinger >= closedFist) {
        clenchSuccess = true;
      } // This is seperated from the timer, so just incase if the user clenches it before the hat finishes talking
      if (passedTime > clenchFistDuration ) {
        hatFinishClench = true;
      }

      // Once the hat finishes talking and the glove is clenched, then go to next dialogue
      if (clenchSuccess && hatFinishClench) {
        dialogue4 = true;
        dialogue3 = false;
        savedTime = millis();
      }
    } // End of Dialogue 3

    // Fourth Dialogue
    if (dialogue4) {
      TextToSpeech.say(script[3], TextToSpeech.voices[voiceIndex], voiceSpeed);
      myPort.write('2'); //send a 0 to arduino for first talk
      savedTime = millis();
      dialogue4 = false;
      dialogue5= true;
      delay (7000); // For some reaosn the timers stopped working so had to use this :( THE EVIL DELAY
    } // End of Fourth dialogue
    
    if (dialogue5) {
      TextToSpeech.say(script[4], TextToSpeech.voices[voiceIndex], voiceSpeed);
      dialogue5 = false;
      myPort.write('3');
      delay(2700);
      rockPaperScissors(); // Start The Game!
    }
    
  } else {

    gameReset(); // If the switch is off the game will reset it self
  }
}
// The Game Starts
void rockPaperScissors() {
  
  // Get The hat's decision
  if (!hatDecision) {
  RPS = int(random(3));
  userAction_1 = indexFinger;
//  userAction_2 = ringFinger;
 if (RPS == 0) {
 myPort.write('4'); // This is Rock
 }
  if (RPS == 1) {
 myPort.write('5'); // This is Paper
 } 
 if (RPS == 2) {
 myPort.write('6'); // This is Scissors
 }
 println(RPS);
  hatDecision = true; // Lock the Choice
}

checkUserChoice (); // Check What the user picked first before comparing

declareWinner(); // Compare those Values to Decide a Winner
}


void checkUserChoice () {
  // THis is Rock 
if (userAction_1 > closedFist && userAction_2 > closedFist){
  userChoice = 0;
}
//This is Paper
if (userAction_1 < closedFist && userAction_2 < closedFist){
    userChoice = 1;

}
// This is Scissors
if (userAction_1 < closedFist && userAction_2 > closedFist){
    userChoice = 2;
}

}

void decalreWinner () {
 // Insert Different Phrases here!
  if (RPS == 0 && userChoice == 0){
  // It's a draw! Rock can't beat rock!
  }
  if (RPS == 1 && userChoice == 1){
  // Paper Draw!
  }  
  if (RPS == 2 && userChoice == 2){
  // Scissors Draw!
  }
  
  if (RPS == 0 && userChoice == 1){
  // The Player wins! Paper Beats Rock!
  }  
    if (RPS == 0 && userChoice == 2){
  // The Hat wins! Rock Beats Scissors!
  }  
  
  if (RPS == 1 && userChoice == 0){
  // The hat wins! Paper Beats Rock!
  }
  if (RPS == 1 && userChoice == 2){
  // The User wins! Scissors Cut paper!
  }
  
   if (RPS == 2 && userChoice == 0){
  // The Player wins! Rock Beats Scissors!
  }
     if (RPS == 2 && userChoice == 1){
  // The Hat wins! Scissors beat Paper!
  }
// Hat gets grumpy and tells you to shut it down!
  
}

void gameReset() {

  timerReset = false;
  dialogue1 = true; // This should be true
  dialogue2 = false;
  dialogue3 = false;
  dialogue4 = false;
  dialogue5 = false; 
  hatDecision = false;
  clenchSuccess = false;
  hatFinishClench = false;
}

void serialEvent(Serial myPort) {
  // get the string from arduino
  String inString = myPort.readStringUntil('\n'); 
  //    println(inString);
  if (inString != null) {
    // trim off any whitespace 
    inString = trim(inString);
    // split the string
    values = int(split(inString, ","));

    if (values.length >= numOfSensors) {
      
      gameStart = values[0]; // Once the switch has been flipped
      indexFinger = values[1];
//      ringFinger = values[2];
    }
  }
}
