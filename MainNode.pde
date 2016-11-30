class MainNode extends Node {
  // reference to the force directed graph
  TwitterGraph graph;


  // look of the node
  color nodeColor;
  color ringColor = color(255, 131, 0);
  float nodeDiameter = 15;
  // size of the displayed text
  float textsize = 22;
  // behaviour parameters
  float nodeRadius = 50;
  float nodeStrength = -10;
  float nodeDamping = 0.2;
  int locationID;
  
  
  boolean labelFlag = true;
  boolean hashtag = false;
  int numHashtags =0;
  
  color ranCol;

  int type;

  StringList hashtags;

  Status twitterStatus;

  int numConnections;
  
  int lifeTime = 100000;
  
  boolean strongConnection = false;
  
  



  // last activation (rollover) time
  int activationTime;
  // is this a node that was clicked on
  boolean wasClicked = false;

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
  }

  MainNode(TwitterGraph theGraph, float theX, float theY, float theZ) {
    super(theX, theY, theZ);
    this.numConnections = 0;


    graph = theGraph;
    init();
  }



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

    //Not display radius
    setRadius(nodeRadius);
  }

  //LOAD DATA
  void setID(String theID) {
    super.setID(theID);
  }



  ///
  void draw() {
    
    
    pushStyle();
    //colorMode(HSB, 360, 100, 100);
    float d;
    // while loading draw grey ring around node
    d = diameter;

    // randomly coloured circle
    if (hashtag) {
      d = diameter + 10*(numConnections-1);

      fill(255, 180);
      ellipse(x, y, d, d);
    } else {
      fill(ranCol);
      ellipse(x, y, d, d);
    }

    popStyle();
    
    if(numConnections<=2){
    lifeTime-=100;
    }
  }


  void drawLabel() {

    if (hashtag && labelFlag==true) {
      // draw text
      textAlign(LEFT);
      rectMode(CORNER);
      float tfactor = 0.5;

      float d = diameter + 5*(numConnections-1);

      activationTime = graph.getMillis();

      float ts = textsize/pow(graph.zoom, 0.5) *tfactor;
      textFont(graph.font, ts);

      float tw = textWidth(id);
      // fill(255, 10);
      pushMatrix();

      // rect(x+(diameter/2+4), y-(ts/2), (tw+3), (ts+3));
      // if (graph.isRollover(this) && graph.showRolloverText) {
      fill(0);
      // }
      //rotate(getTheta());
      // translate(x,y);
      text(id, x+(d/2+20)*tfactor, y+6*tfactor);

      popMatrix();
    }
  }

  void setLocationID(int id) {
    this.locationID = id;
  }

  int getLocationID() {
    return this.locationID;
  }

  float getTheta() {

    return GenerativeDesign.cartesianToPolar(this.x, this.y)[1];
  }
}