class Dashboard {
  int health;
  color c;
  int sat;
  float incS;
  int posX, posY;
  PFont console;
  int cx, cy;

  Dashboard(int px, int py) {  
    incS=1;
    sat=100;
    health=100;
    posX = px;
    posY = py;
    cx=posX+standWidth/2;
    cy =posY+standHeight/2;

    console =   createFont("Monospaced", 24);
  }

  void  displayHealthbar() {
    fill(0);
    noStroke();
    rect(posX, posY, standWidth, standHeight);
    if (health<50) {
      if (sat<60 || sat>100) incS*=-1;
      sat+=incS;
    }
    else {
      sat=100;
    }
    for (int i=0;i<health;i++) {
      c = color(i, sat, 100);
      fill(c);
      noStroke();
      rect(posX+(standWidth-200)/2+i*2, posY+standHeight/3, 2, 30);
    }
  }

  void displaySpotLight() {
    fill(0, 0, 100);
    int txt =30;
    noStroke();
    ellipse(cx, cy, standHeight, standHeight);
    textSize(txt);
    textAlign(CENTER);
    fill(0, 150);
    text("#FOLLOW US", cx, cy-txt);
    textSize(20);
    text("Interactúa con tus contenidos\na través de Twitter.", cx, cy);
  }

  void displayInterlude() {
    clear();
    textFont(console);
    noStroke();
    fill(120, 100, 100);
    textAlign(CENTER);
    text("Loading ", posX+(standWidth)/2, posY+standHeight/3);
    if (second()%2==0) {
      fill(120, 100, 100);
    }
    else {
      fill(0, 0, 0);
    }
    rect(posX+(standWidth/2)+60, posY+standHeight/3-20, 12, 24);
  }

  void displayGameOver() {
    clear();
    textFont(console);
    noStroke();
    fill(120, 100, 100);
    textAlign(CENTER);
    text("You Lose ", posX+(standWidth)/2, posY+standHeight/3);
    if (second()%2==0) {
      fill(120, 100, 100);
    }
    else {
      fill(0, 0, 0);
    }
    rect(posX+(standWidth/2)+60, posY+standHeight/3-20, 12, 24);
  }

void displayEnd() {
    clear();
    textFont(console);
    noStroke();
    fill(120, 100, 100);
    textAlign(CENTER);
    text("#followus", posX+(standWidth)/2, posY+standHeight/3);
    if (second()%2==0) {
      fill(120, 100, 100);
    }
    else {
      fill(0, 0, 0);
    }
    rect(posX+(standWidth/2)+60, posY+standHeight/3-20, 12, 24);
  }
  
  void clear() {
    fill(0);
    noStroke();
    rect(posX, posY, standWidth, standHeight);
  }
}

