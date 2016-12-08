class MainNode extends Node {
  // reference to the force directed graph
  TwitterGraph graph;

  // look of the central node
  color ringColor = color(255, 131, 0);

  // EDITED
  float nodeDiameter = 16;
  float savedDiameter = nodeDiameter;

  // size of the displayed text
  float textsize = 25;
  // behaviour parameters
  float nodeRadius = 100;
  float nodeStrength = -1;
  float nodeDamping = 0.3;
  int locationID;

  //Flags to control
  boolean labelFlag = true;
  boolean hashtag = false;
  boolean displayed = true;
  boolean isHighlighted = false;
  int numHashtags =0;

  //Node color variable
  color ranCol;

  //REDUNDANT
  int type;

  StringList hashtags;

  Status twitterStatus;

  int numConnections;

  int lifeTime = fadeOutTime;
  int fadeCounter = 0;

  boolean strongConnection = false;
  
  String text;





  // last activation (rollover) time
  int activationTime;
  // is this a node that was clicked on
  boolean wasClicked = false;

  int ID;

  // Initializers
  MainNode(TwitterGraph theGraph) {
    super();
    graph = theGraph;
    //hashtags = new ArrayList<String>();
    this.numConnections = 0;
    init();
  }

  MainNode(TwitterGraph theGraph, float theX, float theY) {
    super(theX, theY);
    this.numConnections = 0;
    //this.fadeCounter = int(f*100);
    graph = theGraph;
    init();
  }

  MainNode(TwitterGraph theGraph, float theX, float theY, color sentiment) {
    super(theX, theY);
    ranCol = sentiment;
    this.numConnections = 0;
    graph = theGraph;
    init();
  }

  MainNode(TwitterGraph theGraph, float theX, float theY, boolean hash) {
    super(theX, theY);
    this.hashtag = true;
    graph = theGraph;
    init();
    this.numConnections = 0;

    if (hash) {
      this.nodeRadius = 200;
    }
  }


  //3D initializer
  /*MainNode(TwitterGraph theGraph, float theX, float theY, float theZ) {
   super(theX, theY, theZ);
   this.numConnections = 0;
   
   
   graph = theGraph;
   init();
   }*/



  MainNode(TwitterGraph theGraph, PVector theVector) {
    super(theVector);
    graph = theGraph;
    this.numConnections = 0;

    init();
  }



  //INITIALIZE PHYSICAL PARAMETERS
  void init() {
    activationTime = millis();
    diameter = nodeDiameter + 6;

    setDamping(nodeDamping);
    setStrength(nodeStrength);

    //Not display radius - used for mouse interaction
    setRadius(nodeRadius);
  }

  //LOAD DATA
  void setID(String theID) {
    super.setID(theID);
  }



  ///
  void draw() {

    //if (ns == i) diameter = 160; else diameter = 16;


    //If the display flag is true.
    if (displayed) {
      pushStyle();
      float d;
      // while loading draw grey ring around node
      d = diameter;

      if (isHighlighted) {
        drawTweetNodeHighlighted();
      } else {
        drawTweetNode();
      }
    }






    //Make 
    ///if (numConnections<=2) {
    if(!isHighlighted){
    lifeTime-=200;
    
    }
    //} else {
    //lifeTime = fadeOutTime; 
    //}
  }


  void drawHashtagNode() {
    //float d = 2;
    float d = (diameter + 10*(numConnections-1)) * map(mouseX, 0, width, 0.1, 0.5);
    float alpha = map(lifeTime, fadeOutTime, 0, 255, 0);
    fill(255, alpha);
    ellipse(x, y, d, d);
  }

  void drawTweetNode() {
    float d = diameter/10;
    float alpha = map(lifeTime, fadeOutTime, 0, 255, 0);

    //fill(ranCol, alpha);
    //ellipse(x, y, d, d);
    stroke(ranCol, alpha);
    strokeWeight(d);
    ellipse(x, y, 4, 4);
  }

  void drawTweetNodeHighlighted() {
    float d = diameter/5;
    float alpha = map(lifeTime, fadeOutTime, 0, 255, 0);

    //fill(ranCol, alpha);
    //ellipse(x, y, d, d);
    stroke(ranCol, alpha);
    strokeWeight(d);
    ellipse(x, y, 15, 15);
  }


  void drawLabel() {

    if (hashtag && labelFlag==true && displayed) {
      // draw text
      textAlign(LEFT);
      rectMode(CORNER);
      float tfactor = 0.5;

      float d = diameter + 5*(numConnections-1);

      activationTime = graph.getMillis();

      float ts = textsize/pow(graph.zoom, 0.5) *tfactor;
      textFont(graph.font, ts);

      float tw = textWidth(id);

      fill(255);

      text(id, x+(d/2+20)*tfactor, y+6*tfactor);
    }
  }

  void setLocationID(int id) {
    this.locationID = id;
  }

  int getLocationID() {
    return this.locationID;
  }

  //void triggerFadeOut() {
  //  displayed = false;

  //  //Node itself
  //  if (fadeCounter > 0) {
  //    float alpha = map(fadeCounter, 1000, 0, 180, 0);
  //    pushStyle();
  //    //colorMode(HSB, 360, 100, 100);
  //    float d;
  //    // while loading draw grey ring around node
  //    d = diameter;

  //    // randomly coloured circle
  //    if (hashtag) {
  //      d = diameter + 10*(numConnections-1);

  //      fill(255, alpha);
  //      ellipse(x, y, d, d);
  //    } else {
  //      fill(ranCol);
  //      ellipse(x, y, d, d);
  //    }

  //    popStyle();

  //    //TEXT LABEL
  //    // draw text fade out.
  //    if (hashtag) {
  //      textAlign(LEFT);
  //      rectMode(CORNER);
  //      float tfactor = 0.5;
  //      activationTime = graph.getMillis();
  //      float ts = textsize/pow(graph.zoom, 0.5) *tfactor;
  //      textFont(graph.font, ts);
  //      pushMatrix();
  //      fill(0, alpha);
  //      text(id, x+(d/2+20)*tfactor, y+6*tfactor);
  //      popMatrix();
  //      fadeCounter-=10;
  //    }
  //  } else {
  //    graph.removeNode(this);
  //  }
  //}

  int getAngle() {
    //translate(width/2, height/2);
    float a = atan2(this.y, this.x);
    int angle = int(degrees(a));
    return angle;
  }
  
  void setText(String text){
   this.text = text; 
  }
}