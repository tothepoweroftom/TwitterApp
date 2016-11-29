class MainNode extends Node {
  // reference to the force directed graph
  TwitterGraph graph;


  // look of the node
  color nodeColor;
  color ringColor = color(255, 131, 0);
  float nodeDiameter = 20;
  // size of the displayed text
  float textsize = 22;
  // behaviour parameters
  float nodeRadius = 50;
  float nodeStrength = -1;
  float nodeDamping = 0.2;
  int locationID;

  boolean hashtag = false;

  color ranCol;

  int type;

  ArrayList<String> hashtags;



  // last activation (rollover) time
  int activationTime;
  // is this a node that was clicked on
  boolean wasClicked = false;

  // Initializers
  MainNode(TwitterGraph theGraph) {
    super();
    graph = theGraph;
    hashtags = new ArrayList<String>();
    init();
  }

  MainNode(TwitterGraph theGraph, float theX, float theY) {
    super(theX, theY);
    ranCol = color(random(255), random(255), random(255));
    hashtags = new ArrayList<String>();

    graph = theGraph;
    init();
  }

  MainNode(TwitterGraph theGraph, float theX, float theY, boolean hash) {
    super(theX, theY);
    ranCol = color(random(255), random(255), random(255));
    hashtags = new ArrayList<String>();
    this.hashtag = true;
    graph = theGraph;
    init();
  }

  MainNode(TwitterGraph theGraph, float theX, float theY, float theZ) {
    super(theX, theY, theZ);
    ranCol = color(random(255), random(255), random(255));
    hashtags = new ArrayList<String>();

    graph = theGraph;
    init();
  }



  MainNode(TwitterGraph theGraph, PVector theVector) {
    super(theVector);
    graph = theGraph;
    ranCol = color(random(255), random(255), random(255));

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
    fill(100, 100, 100);
    ellipse(x, y, d, d);

    popStyle();
  }


  void drawLabel() {

    if (hashtag) {
      // draw text
      textAlign(LEFT);
      rectMode(CORNER);
      float tfactor = 0.5;


      activationTime = graph.getMillis();

      float ts = textsize/pow(graph.zoom, 0.5) *tfactor;
      textFont(graph.font, ts);

      float tw = textWidth(id);
      fill(230, 80);
      rect(x+(diameter/2+4), y-(ts/2), (tw+3), (ts+3));
      // if (graph.isRollover(this) && graph.showRolloverText) {
      fill(0);
      // }
      text(id, x+(diameter/2+20)*tfactor, y+6*tfactor);
      // draw text for rolloverNode
      //if (graph.showText) {
      //  if (wasClicked || (graph.isRollover(this) && graph.showRolloverText)) {
      //    activationTime = graph.getMillis();

      //    float ts = textsize/pow(graph.zoom, 0.5) *tfactor;
      //    textFont(graph.font, ts);

      //    float tw = textWidth(id);
      //    fill(255, 80);
      //    rect(x+ (diameter/2+4)*tfactor, y-(ts/2)*tfactor, (tw+3)*tfactor, (ts+3)*tfactor);
      //    fill(80);
      //    if (graph.isRollover(this) && graph.showRolloverText) {
      //      fill(0);
      //    }
      //    text(id, x+(diameter/2+5)*tfactor, y+6*tfactor);
      //  } else {
      //    // draw text for all nodes that are linked to the rollover node
      //    if (wasClicked || graph.showRolloverNeighbours) {
      //      if (graph.isRolloverNeighbour(this)) {
      //        activationTime = graph.getMillis();
      //      }
      //    }

      //    int dt = graph.getMillis() - activationTime;
      //    if (dt < 10000) {
      //      float ts = textsize/pow(graph.zoom, 0.5)*tfactor;
      //      textFont(graph.font, ts);

      //      float tw = textWidth(id);
      //      float a = min(3*(1-dt/10000.0), 1) * 100;
      //      fill(255, a*0.8);
      //      rect(x+(diameter/2+4)*tfactor, y-(ts/2)*tfactor, (tw+3)*tfactor, (ts+3)*tfactor);
      //      fill(80, a);
      //      text(id, x+(diameter/2+5)*tfactor, y+6*tfactor);
      //    }
      //  }
      //}
    }
  }

  void setLocationID(int id) {
    this.locationID = id;
  }

  int getLocationID() {
    return this.locationID;
  }
}