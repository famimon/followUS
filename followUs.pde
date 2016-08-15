// FOLLOW US
// On body video projection visualizing the impact of online social interactions in three epic battles
// Date: 4/12/12
// Concept: Soliman Lopez
// IxD & Code: David Montero
// Credits: Twitter cloud based on code from Jer (blprnt.com)
// PolygonBlob class adapted from Amnon Owed (http://amnonp5.wordpress.com)

// ************ LIBRARIES ****************
import processing.opengl.*; // opengl
import SimpleOpenNI.SimpleOpenNI; // kinect
import blobDetection.*; // blobs
import ddf.minim.*; // Audio player

// this is a regular java import so we can use and extend the polygon class (see PolygonBlob)
import java.awt.Polygon;


// ******** FLAGS & TIMERS *********
// start the sketch
boolean enable;
// intro
boolean intro;
//charge
boolean charge;
// interlude
boolean interlude;

int timer;
int introTimeout =10*60*1000;
int stageTimeout = 5*60*1000;
int interludeTimeout = 5000;

// ************* TWITTER VARIABLES *****
// Thread to query for tweets in the background
tweetQuery queryThread;

// tweetCloud objects for hashtags
tweetCloud hashCloud;
tweetCloud followCloud;

// hashtags terms for the 3 rounds
String[] round1 = {
  "#arte", "#deshaucio", "#amor"
};
String[] round2 = {
  "#performance", "#naciones", "#huelga"
};
String[] round3 = {
  "#contemporaneo", "#casualidad", "#pope"
};
String[] hashtags = new String[3];

// Number of tweets per query (1)
int RPP = 1;

// Maximum age of tweet
float maxAge = 60; // 2 minutes

// dimensions of feeds, stage and stands
int feedWidth, feedHeight;
int stageWidth, stageHeight;
int standWidth, standHeight;

// load tweets every 5 seconds
int queryInterval = 5000;



// ********** VISUALIZATIONS *************
Stage stage;
Kinect k;
Dashboard dashboard;

// Number of hits per round before game over
int NHITS=10;

// Audio handler
Minim minim  = new Minim(this);
// Audio player for ambient sound
AudioPlayer ambientTrack;
AudioPlayer tag1Track;
AudioPlayer tag2Track;
AudioPlayer tag3Track;

//Colours for different hashtags
color tag1Colour, tag2Colour, tag3Colour;

// global variables to influence the movement of all particles
float globalX, globalY;
// the kinect's dimensions to be used later on for calculations
int kinectWidth = 640;
int kinectHeight = 480;



void setup() {
  enable=false;
  intro=true;
  charge=false;
  interlude = false;

  background(0);
  size(1280, 800, OPENGL);
  colorMode(HSB, 360, 100, 100);
  tag1Colour = color(100, 100, 100);
  tag2Colour = color(0, 100, 100);
  tag3Colour = color(60, 100, 100);
  noStroke();
  smooth();

  // Load ambient sound
  ambientTrack = minim.loadFile("audio/follow_us_audio.mp3", 2048);
  ambientTrack.loop();
  tag1Track = minim.loadFile("audio/hash_1.mp3", 2048);
  tag2Track = minim.loadFile("audio/hash_2.mp3", 2048);
  tag3Track = minim.loadFile("audio/hash_3.mp3", 2048);



  //Dimensions of stand
  standWidth = kinectWidth;
  standHeight = height-kinectHeight;

  // Dimensions of twitter feeds
  feedWidth = (width-kinectWidth)/2;
  feedHeight = height-kinectHeight/3;

  // Dimensions of stage 
  stageWidth = kinectWidth;
  stageHeight = kinectHeight;

  // Initialize tweet clouds

  hashCloud = new tweetCloud(feedWidth, feedHeight, maxAge, new PVector(0, kinectHeight/3), 1); // will display with cloud effect (1)
  followCloud = new tweetCloud(feedWidth, feedHeight, maxAge, new PVector(width-feedWidth, kinectHeight/3), 0); // will display with roll credits effect (0)

  // Set up queries for round #1
  hashtags = round1;

  //start Thread to check for new tweets
  queryThread = new tweetQuery(queryInterval, "a", hashtags, RPP);
  queryThread.start();

  // Start Kinect handler
  k = new Kinect(new SimpleOpenNI(this));

  // Initialize health bar
  dashboard = new Dashboard(feedWidth, kinectHeight);

  // Set visualizations for round 1
  stage = new Stage(1);
  timer=millis();
}


void draw() {       
  // Intro performance
  checkTimers();
  if (intro && !charge) {
    dashboard.displaySpotLight();
    // Print tweet clouds
    followCloud.printList();
    hashCloud.printList();
  }
  if (charge && ! enable) {
    followCloud.printList();
    hashCloud.printList();
    dashboard.displayHealthbar();
  }    
  if (interlude) {
    stage.clearStage();
    dashboard.displayInterlude();
  }
  if (enable) {    
    // print the stage
    if (!stage.gameOver) {  
      stage.display();
      // Display healh bar
      dashboard.displayHealthbar();
    }
    else {
      stage.clearStage();
      dashboard.displayGameOver();
    }
  }
}

void checkTimers() {
  //==========>>remove this line
// if (charge) dashboard.health++;

  if (millis()-timer > introTimeout && intro) {
    charge=true;
    intro=false;
    dashboard.health = 0;
    timer=millis();
  }
  if (charge && dashboard.health >= 100) {
    enable=true;
    charge=false;
    timer=millis();
  }
  if (millis()-timer > stageTimeout && enable) {
    dashboard.health=0;
    interlude = true;
    enable = false;
    timer = millis();
  }
  if (millis()-timer > interludeTimeout && interlude) {
    interlude = false;
    enable = true;
    changeRound();
    timer=millis();
  }
}

void changeRound() {
  dashboard.health=100;
  stage.clearStage();
  if (stage.id == 1) {
    stage = new Stage(2);
    hashtags = round2;
  }
  else if (stage.id == 2) {
    background(0);
    stage = new Stage(3);
    hashtags = round3;
  }else{
    interlude=false;
    enable=false;
    fill(0);
    rect(0,0,width,height);
    dashboard.displayEnd();
   hashCloud.displayCredits();
   followCloud.displayCredits();
  }
}

color selectColour(int type) {
  color colour = tag1Colour;
  switch(type) {
  case 1:
    colour = tag1Colour;
    break;
  case 2:
    colour = tag2Colour;
    break;
  case 3:
    colour = tag3Colour;
    break;
  }
  return colour;
}

void playSound(int type) {
  switch(type) {
  case 1:
    tag1Track.rewind();
    tag1Track.play();
    break;
  case 2:
    tag2Track.rewind();
    tag2Track.play();
    break;
  case 3:
    tag3Track.rewind();
    tag3Track.play();
    break;
  }
}

boolean sketchFullScreen() {
  return true;
}

