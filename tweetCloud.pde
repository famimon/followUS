class tweetCloud {
  //Build an ArrayList to hold all tweets that we get from the queried hashtags, and another one to keep their coordinates in the screen
  ArrayList <Tweet> tweets = new ArrayList();
  ArrayList <PVector> positions = new ArrayList();
  // List for the Cloud effect, flags when a tweet has been printed 
  ArrayList <Boolean> printed = new ArrayList();

  // Boxes containing twitter feeds
  PGraphics pg;

  // Speed of fade in depth
  float DEPTH_STEP = 4;

  // Maximum age of tweet
  float maxAge;
  // dimensions of feeds
  int feedWidth, feedHeight;

  // Position in screen to display
  PVector anchor;

  // effect to display the cloud 0=roll 1=cloud
  int effect;

  int txtSize;


  tweetCloud(int w, int h, float age, PVector a, int e) {
    feedWidth = w;
    feedHeight = h;
    maxAge = age;
    anchor = a;
    effect =e;
    txtSize = feedWidth/20;
    pg = (effect==0)?createGraphics(feedWidth, feedHeight, P3D):createGraphics(feedWidth, feedHeight);
  }


  void updateTweets(Tweet t, int type) {
    float age = getTweetAge(t);        
    if (age < maxAge && !tweets.contains(t)) { 
      PVector coordinate = new PVector(random(feedWidth-30*feedWidth/40), random(feedHeight-5*feedWidth/40), 0-age);
      tweets.add(t);      
      int i =tweets.indexOf(t);
      positions.add(i, coordinate);
      printed.add(i, false);    
      if (stage!=null && (enable||charge)) {
        if (type==0) {
          stage.recover();
        }
        else if (enable)
          stage.hit(type);
      }  
      //println(i+": ADDED at "+coordinate);
    }
  }

void displayCredits() {
   PFont console =   createFont("Monospaced", 24);
    textFont(console);
    noStroke();
    fill(120, 100, 100);
    textAlign(LEFT);
    if(effect==1){
    text("Concepto artistico\n y performance\n @solimanlopez", anchor.x, anchor.y+standHeight/3);
    }else{
      text("Interacción\n y código\n @monteractive", anchor.x, anchor.y+standHeight/3);
    }
      if (second()%2==0) {
      fill(120, 100, 100);
    }
    else {
      fill(0, 0, 0);
    }
    rect(anchor.x+60, anchor.y+standHeight/3, 12, 24);
  }

  void printList() {
    if (tweets.size() > 0 && positions.size()>0) {
      //Draw a tweet from the list of tweets that we've built
      for (int i = 0; i<tweets.size(); i++) {
        // get tweet
        Tweet t = (Tweet) tweets.get(i);
        float age = getTweetAge(t);
        //        println(i+": "+age);
        if (age > maxAge) {
          // Remove the tweet from the list when size reaches zero
          positions.remove(i);
          printed.remove(i);
          tweets.remove(i);
          // println(i+": REMOVED");
        } 
        else {
          // create string
          String user = t.getFromUser();
          String msg = "@" + user + ": " + t.getText();
          // move the position in depth
          if (effect==0) {
            printRoll(msg, positions.get(i), age);
          }
          else {
            if (!printed.get(i)) {
              printCloud(msg, positions.get(i));            
              printed.remove(i);
              printed.add(i, true);
            }
          }
          positions.get(i).z-=DEPTH_STEP;
        }
      }
    }
  }

  void printRoll(String m, PVector p, float age) {
    int i = (30 < m.length())? 30: m.length()-1;
    while (i < m.length () && m.charAt (i)!=' ') i++;
    String ss1 = m.substring(0, i);

    int j = (i+30 < m.length())? i+30:m.length()-1;
    while (j < m.length () && m.charAt (j)!=' ') j++;
    String ss2 = m.substring(i, j);

    i = (j+30 < m.length())? j+30:m.length()-1;
    while (i < m.length () && m.charAt (i)!=' ') i++;
    String ss3 = m.substring(j, i);

    j = (i+30 < m.length())? i+30:m.length()-1;
    while (j < m.length () && m.charAt (j)!=' ') j++;
    String ss4 = m.substring(i, j);
    String ss5 = m.substring(j);

    pg.beginDraw();
    pg.smooth();
    pg.background(0);
    pg.fill(255, 250-age*2);// Get darker with time
    pg.textSize(txtSize);
    pg.text(ss1, p.x, p.y, p.z);
    pg.text(ss2, p.x, p.y+txtSize, p.z);
    pg.text(ss3, p.x, p.y+2*txtSize, p.z);
    pg.text(ss4, p.x, p.y+3*txtSize, p.z);
    pg.text(ss5, p.x, p.y+4*txtSize, p.z);
    pg.endDraw();
    image(pg, anchor.x, anchor.y);
  }

  void printCloud(String m, PVector p) {
    float txt = random(6, 18);
    int i = (30 < m.length())? 30: m.length()-1;
    while (i < m.length () && m.charAt (i)!=' ') i++;
    String ss1 = m.substring(0, i);

    int j = (i+30 < m.length())? i+30:m.length()-1;
    while (j < m.length () && m.charAt (j)!=' ') j++;
    String ss2 = m.substring(i, j);

    i = (j+30 < m.length())? j+30:m.length()-1;
    while (i < m.length () && m.charAt (i)!=' ') i++;
    String ss3 = m.substring(j, i);

    j = (i+30 < m.length())? i+30:m.length()-1;
    while (j < m.length () && m.charAt (j)!=' ') j++;
    String ss4 = m.substring(i, j);
    String ss5 = m.substring(j);

    pg.beginDraw();
    pg.smooth();
    pg.fill(255, random(100, 250));
    pg.textSize(txt);
    pg.text(ss1, p.x, p.y, p.z);
    pg.text(ss2, p.x, p.y+txt, p.z);
    pg.text(ss3, p.x, p.y+2*txt, p.z);
    pg.text(ss4, p.x, p.y+3*txt, p.z);
    pg.text(ss5, p.x, p.y+4*txt, p.z);
    pg.fill(0, 50);  
    pg.rect(0, 0, feedWidth, feedHeight);
    pg.endDraw();
    image(pg, anchor.x, anchor.y);
  }

  float getTweetAge(Tweet t) {
    /// create timestamp
    Date tweetDate = t.getCreatedAt();
    // System date to calculate the age of the tweets
    Date d = new Date();
    // age of the tweet in seconds
    return (d.getTime()-tweetDate.getTime())/1000;
  }
}

