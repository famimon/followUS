// Class containing the shot animation
class Shot {
  int shotStep = 5;
  int radius;
  int frame =0;
  float px, py;
  int colour;

  boolean destroy = false;
  
  Shot(int r, int type) {
    radius = r;
    px= random(k.playerImage.width);
    py = random(k.playerImage.height);
    while (!k.poly.contains (px, py)) {
      px= random(k.playerImage.width);
      py = random(k.playerImage.height);
    }
    colour = selectColour(type);
  }


  void drawShot() {
    frame += shotStep;

    fill(colour, 155);

    for (int i = 0; i < radius; i++) {
      float t = (frame+1 + i) % radius;
      if (t==1) {  
        ellipse(px, py, i/2, i/2);
        ellipse(px, py, i/4, i/4);
        ellipse(px, py, i/8, i/8);
        ellipse(px, py, i/10, i/10);
      }
    }
    if (frame > radius) destroy=true;
  }
  
}

