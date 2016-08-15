class Stage {
  // Stage ID, identifies the round number
  int id;
  boolean gameOver;
  int healthStep;

  //*******VARIABLES FOR ROUND#1 ******

  // Heartbeat audio player
  AudioPlayer heartbeat; 
  // followus tag audio player
  AudioPlayer followSound; 

  // Defines the player colour
  float inc = 1;
  float h= 0;
  float s= 0;
  float b=100;

  // min and max values for saturation, we move in ranges of white at the beginning
  float minS = 0; 
  float maxS = 40;

  // List and size of shots 
  ArrayList <Shot> shots = new ArrayList();
  int r=150;

  //*********VARIABLES FOR ROUND#2 *******
  // three color palettes (artifact from me storing many interesting color palettes as strings in an external data file ;-)
  String[] palettes = {
    "-1117720,-13683658,-8410437,-9998215,-1849945,-5517090,-4250587,-14178341,-5804972,-3498634", 
    "-67879,-9633503,-8858441,-144382,-4996094,-16604779,-588031", 
    "-16711663,-13888933,-9029017,-5213092,-1787063,-11375744,-2167516,-15713402,-5389468,-2064585"
  };

  int nParticles = 4000;
  ArrayList <Particle> flow = new ArrayList();
  // number of particles to be killed per strike
  int toKill = 400;
  // thickness of particles
  float thickness = 5;

  //**********VARIABLES FOR ROUND#3
  float shadowScale;

  Stage(int n) {
    id =n ;
    gameOver = false;
    followSound = minim.loadFile("audio/hashtag_follow.mp3", 2048);    
    healthStep = 100/NHITS;
    // Initialization of variables based on round number
    switch (id) {
    case 1:      
      // start up Minim
      heartbeat = minim.loadFile("audio/heart_beat.mp3", 2048);
      s = minS; // initialize saturation to the minimum value
      break;
    case 2:
      hashCloud = new tweetCloud(feedWidth, feedHeight, maxAge, new PVector(0, kinectHeight/3), 0); // will display with cloud effect (1)
      setupFlowfield();
      break;
    case 3:
      hashCloud = new tweetCloud(feedWidth, feedHeight, maxAge, new PVector(0, kinectHeight/3), 1); // will display with cloud effect (1)
      shadowScale = 0;
      break;
    }
  }

  void display() {
    k.update();
    switch(id) {
    case 1:
      updateSaturation();
      k.playerColour=color(h, s, b);
      pushMatrix();
      translate(feedWidth+(stageWidth-kinectWidth)/2, (stageHeight-kinectHeight)/2);
      k.displayPlayerImage();
      for (int i = 0; i < shots.size();i++) {
        if (shots.get(i).destroy) {
          shots.remove(i);
        }
        else {
          shots.get(i).drawShot();
        }
      }
      popMatrix();
      break;
    case 2:
      pushMatrix();
      translate(feedWidth+(stageWidth-kinectWidth)/2, (stageHeight-kinectHeight)/2);
      background(0);
      drawFlowfield();
      popMatrix();    
      break;
    case 3:
      k.playerColour=color(0, 0, 100);
      pushMatrix();
      translate(feedWidth+(stageWidth-kinectWidth)/2, (stageHeight-kinectHeight)/2);
      k.displayPlayerImage();
      translate((kinectWidth-kinectWidth*shadowScale)/2, (kinectHeight-kinectHeight*shadowScale)/2);//(stageWidth-kinectWidth*shadowScale)/2, (stageHeight-kinectHeight*shadowScale)/2);
      scale(shadowScale);
      k.displayPlayerPolygon(0);
      popMatrix();
      break;
    }
  }

  void hit(int type) {
    println("HIT!! -->"+type);
    dashboard.health-=healthStep;
    playSound(type);
    if (dashboard.health <= 0) gameOver=true;
    switch(id) {
    case 1:
      if (k.poly.npoints>0) {
        Shot s = new Shot(r, type);
        if (!shots.contains(s)) {
          shots.add(s);
        }
        minS = (minS+10>maxS-20)?minS:minS+10;
        maxS = (maxS+10>100)?100:maxS+10;
      }
      break;
    case 2:
      k.playerColour=selectColour(type);
      pushMatrix();
      translate((stageWidth-kinectWidth)/2, (stageHeight-kinectHeight)/2);
      k.displayPlayerImage();
      popMatrix();
      if (toKill > flow.size()) {
        toKill=flow.size()/2;
      }
      for (int i=0; i<toKill && i<flow.size(); i++) {
        flow.remove(i);
      }
      // set the colors randomly 
      setRandomColors(1);
      break;
    case 3:
      if (shadowScale<=1)
      { 
        shadowScale += .1;
      }
      break;
    }
  }

  void recover() {
    println("RECOVER!!");
    followSound.rewind();
    followSound.play();
    dashboard.health+=healthStep;
    switch(id) {
    case 1:
      minS = (minS-10<0)?0:minS-10;
      maxS = (maxS-10<minS+40)?maxS:maxS-10;
      break;
    case 2:
      for (int i=0; i<400; i++) {
        flow.add(new Particle(i/10000.0));
      }
      toKill=400;
      break;
    case 3:
      if (shadowScale>0)  
        shadowScale -= .1;    
      break;
    }
  }

  void updateSaturation() {
    if (s > maxS || s < minS) { 
      inc*=-1;
      if (s<minS) {
        heartbeat.rewind();
        heartbeat.play();
      }
    }
    s+= inc;
  }

  void setupFlowfield() {
    // set stroke weight (for particle display) to 2.5
    strokeWeight(thickness);
    // initialize all particles in the flow
    for (int i=0; i<nParticles; i++) {
      flow.add(new Particle(i/10000.0));
    }
    // set all colors randomly now
    setRandomColors(1);
  }

  void drawFlowfield() {
    // set global variables that influence the particle flow's movement
    globalX = noise(frameCount * 0.01) * width/2 + width/4;
    globalY = noise(frameCount * 0.005 + 5) * height;
    // update and display all particles in the flow
    for (int i=0;i<flow.size();i++) {
      flow.get(i).updateAndDisplay();
    }
  }

  // sets the colors every nth frame
  void setRandomColors(int nthFrame) {
    if (frameCount % nthFrame == 0) {
      // turn a palette into a series of strings
      String[] paletteStrings = split(palettes[int(random(palettes.length))], ",");
      // turn strings into colors
      color[] colorPalette = new color[paletteStrings.length];
      for (int i=0; i<paletteStrings.length; i++) {
        colorPalette[i] = int(paletteStrings[i]);
      }
      // set all particle colors randomly to color from palette (excluding first aka background color)
      for (int i=0; i<flow.size(); i++) {
        flow.get(i).col = colorPalette[int(random(1, colorPalette.length))];
      }
    }
  }

  void clearStage() {    
    fill(0);
    noStroke();
    rect(feedWidth, 0, stageWidth, stageHeight);
  }
}

