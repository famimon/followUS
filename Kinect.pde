// Kinect sensor handler
class Kinect {  
  // ******* KINECT AND OPENNI **********
  // declare SimpleOpenNI object
  SimpleOpenNI context;

  // declare BlobDetection object
  BlobDetection theBlobDetection;

  // declare custom PolygonBlob object (see class for more info)
  PolygonBlob poly = new PolygonBlob();

  // PImage to hold incoming imagery and smaller one for blob detection
  PImage playerImage, blobs;

 
  // this will store data about the scene (bg pixels will be 0, and if there are any users, they will have the value of the user id
  // e.g. if there are no users, the array will be filled with zeros, if there is one user, some array entries will be equal to 1, etc. 
  // the size of the array is the same as the number of pixels in scene image, so it's easy to use with the pixels[] of a PImage
  int[] sceneMap;

  // to center and rescale from 640x480 to higher custom resolutions
  float reScale;

  // Variables for blobs
  int numBlobs = 5;

  // Threshold blob creation (range 0:1), the lower the value the more detailed but more risk of false positives
  float blobThreshold=.2;

  // The lower the value the more distance we can cover but the resulting polygon can get distorted 
  float polyDistance = 5;

  // The colour for the player's silhouette
  int playerColour;
  
  Kinect(SimpleOpenNI c) {
    // initialize SimpleOpenNI object
    context = c;
    playerColour = color(0, 0, 100);
    if (!context.enableScene()) { 
      // if context.enableScene() returns false
      // then the Kinect is not working correctly
      // make sure the green light is blinking
      println("Kinect not connected!"); 
      exit();
    } 
    else {
      kinectHeight = context.sceneHeight();
      kinectWidth = context.sceneWidth();

      //set scene map array
      sceneMap = new int[kinectHeight*kinectWidth];
      //create the image to draw the user into, by default it will be filled black
      playerImage = new PImage(kinectWidth, kinectHeight);

      // calculate the reScale value
      // currently it's rescaled to fill the complete width (cuts top and bottom)
       reScale = (float) stageWidth / kinectWidth;
      // currently it's rescaled to fill the complete height (leaves empty sides)
      //reScale = (float) stageHeight / kinectHeight;
      // create a smaller blob image for speed and efficiency
      blobs = new PImage(kinectWidth/3, kinectHeight/3);
      // initialize blob detection object to the blob image dimensions
      theBlobDetection = new BlobDetection(blobs.width, blobs.height);
      theBlobDetection.setThreshold(blobThreshold);
    }
  }

  void update() {
    context.update();
    // put the player into a PImage
    playerImage = context.sceneImage().get();
    // Update player's silhouette with playerColour
    updatePlayerImage();
    // create the Blobs ploygon
    updateBlobs();
  }

  void displayPlayerImage() {
//    pushMatrix();
//    translate(feedWidth+(stageWidth-kinectWidth*reScale)/2, (stageHeight-kinectHeight*reScale)/2);
//      scale(reScale);
    image(playerImage, 0, 0);
//    popMatrix();
  }

  void displayPlayerPolygon(color c) {
    noStroke();
    fill(c);
    poly.drawPolygon();
  }

  void updatePlayerImage() {
    // gives you a label map, 0 = no person, 0+n = person n - tell OpenNI to update the numbers in the array
    context.sceneMap(sceneMap);
    playerImage.loadPixels();
    //clear playerImage - fill everything with black
    Arrays.fill(playerImage.pixels, color(0));
    for (int i = 0 ; i < playerImage.pixels.length; i++) {
      //check if there is a user for the current pixel, if so, use our custom colour for the pixel at this index
      if (sceneMap[i] > 0){ 
        playerImage.pixels[i] = playerColour;
      }
    }
    playerImage.updatePixels();
  }

  void updateBlobs() {
    // cop.y the image into the smaller blob image
    blobs.copy(playerImage, 0, 0, playerImage.width, playerImage.height, 0, 0, blobs.width, blobs.height);
    // blur the blob image
    blobs.filter(BLUR);
    // detect the blobs
    theBlobDetection.computeBlobs(blobs.pixels);
    // clear the polygon (original functionality)
    poly.reset();
    // create the polygon from the blobs (custom functionality, see class)
    poly.createPolygon(polyDistance);
  }
}

