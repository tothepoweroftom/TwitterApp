import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import generativedesign.*; 
import processing.data.XML; 
import processing.pdf.*; 
import java.net.*; 
import java.io.UnsupportedEncodingException; 
import java.util.Calendar; 
import java.util.Iterator; 
import java.util.Map; 
import ddf.minim.*; 

import twitter4j.*; 
import twitter4j.api.*; 
import twitter4j.auth.*; 
import twitter4j.conf.*; 
import twitter4j.json.*; 
import twitter4j.management.*; 
import twitter4j.util.*; 
import twitter4j.util.function.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class TwitterApp extends PApplet {












Minim minim;
AudioSample[] note;



TwitterGraph myTwitterGraph;

PApplet root = this;

float zoom = 0.2f;

float nodeDiameter = 50;

int CANVAS_WIDTH = 1280;


Node dummyCenterNode;


//Twitter drawing code;

//DRAWING CODE
int clr [] = {255, 0};
int min = 5, max = 18;
int limit = 180;
PFont font;
float c = 1;
String[] symmb;
boolean twitFlag = false;

CircleText nvCirc;
CircleText nvCirc2;


TwitterStream twitterStream;



//mouseInteraction
//boolean dragging = false;
//float offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, clickOffsetX = 0, clickOffsetY = 0;
//int lastMouseButton = 0;

PApplet thisPApplet = this;

public void setup() {
  
  background(255);
  noStroke();
  dummyCenterNode = new Node(0, 0);

  myTwitterGraph = new TwitterGraph();

  minim = new Minim(this);

  //  println(myTwitterGraph.toString());
  symmb = new String[180];

  font = createFont("blanch_condensed.ttf", 22);

  openTwitterStream();
  frameRate(15);

  note = new AudioSample[6];
  for (int i=0; i<note.length; i++) {
    note[i] = minim.loadSample(str(i+1)+".wav");
  }
}


public void draw() {

  background(255);
  textFont(font, 30);

  // ------ update and draw graph ------
  myTwitterGraph.update();
  myTwitterGraph.draw();

  if (twitFlag) {
    if (symmb.length != 0) {
      pushStyle();
      fill(0);
      //nvCirc.drawSymbolsByRadius(symmb[1], 500);
      //nvCirc2.drawSymbolsByRadius(symmb[0], 800);
      popStyle();
      //println(symmb[1]);
      pushStyle();
      fill(0);
      text(symmb[0], width/10, height/4, 200, 400);
      fill(255, 131, 0);
      text(symmb[1], width - width/6, height/4, 200, 400);

      popStyle();
    }
  }
}

public void keyPressed() {

  if (keyCode == UP) zoom *= 1.05f;
  if (keyCode == DOWN) zoom /= 1.05f;
  zoom = constrain(zoom, 0.05f, 1);
  if (key == 'a' || key == 'A') {
    myTwitterGraph.addNode(str(random(1000)), random(10, 20), random(10, 20));
  }

  if (key == 't' || key == 'T') {
    twitFlag = !twitFlag;
  }

  println(zoom);
}


// Stream it
public void openTwitterStream() {  

  ConfigurationBuilder cb = new ConfigurationBuilder();  
  cb.setOAuthConsumerKey("d1AVCc0m033ZvweC2lOp5VFFW");
  cb.setOAuthConsumerSecret("U1DzbrWbp4LzcyIQPCu5UvSVyO5uzAOMEDYyACbwmH8WIaefoe");
  cb.setOAuthAccessToken("3569010795-OA5ceBBzRYGToSPlsdyx7lyBqEMMOkagGmDSD7j");
  cb.setOAuthAccessTokenSecret("wCliIo5iPESSlfUt9gIqZXkzqoVFWghVa7dhmDTngP67I");

  TwitterStream twitterStream = new TwitterStreamFactory(cb.build()).getInstance();

  FilterQuery filtered = new FilterQuery();

  // if you enter words it will use them to filter, otherwise it will sample
  String keywords[] = {
    "Energy"
  };

  filtered.track(keywords);

  twitterStream.addListener(listener);

  if (keywords.length==0) {
    // sample() method internally creates a thread which manipulates TwitterStream 
    twitterStream.sample(); // and calls these adequate listener methods continuously.
  } else { 
    twitterStream.filter(filtered);
  }
  println("connected");
} 


// Implementing StatusListener interface
StatusListener listener = new StatusListener() {

  //@Override
  public void onStatus(Status status) {
    //System.out.println("@" + status.getUser().getScreenName() + " - " + status.getText());

    String name = status.getUser().getScreenName();
    String text = status.getText();
  int m = millis();
  int s = second();

    myTwitterGraph.addNode(name + str(s) + str(m), random(-5, 5), random(-5, 5));

    int ran = PApplet.parseInt(random(note.length));

    note[ran].trigger();


    if (symmb != null) {
      symmb[0] = text;
      symmb[1] = name;
      twitFlag = true;
      // println(symmb[0] + " " + symmb[1]);
    }
  }

  //@Override
  public void onDeletionNotice(StatusDeletionNotice statusDeletionNotice) {
    System.out.println("Got a status deletion notice id:" + statusDeletionNotice.getStatusId());
  }

  //@Override
  public void onTrackLimitationNotice(int numberOfLimitedStatuses) {
    System.out.println("Got track limitation notice:" + numberOfLimitedStatuses);
  }

  //@Override
  public void onScrubGeo(long userId, long upToStatusId) {
    System.out.println("Got scrub_geo event userId:" + userId + " upToStatusId:" + upToStatusId);
  }

  //@Override
  public void onStallWarning(StallWarning warning) {
    System.out.println("Got stall warning:" + warning);
  }

  //@Override
  public void onException(Exception ex) {
    ex.printStackTrace();
  }
};

public void stop(){
 minim.stop();
 twitterStream.shutdown();
}

// quick helper class by Manoylov AC
// drawing text on circle with different modes
// not perfect. WIP.
// correctly works with textAlign(CENTER);

class CircleText {
  String inText = "Grymziki want to eat ";
  float xPos, yPos;
  float ang = 0;
  float radius = 100;
  private float startAngle = 0; // for future using
  private float crclStrWidth;

  CircleText (float in_posX, float in_posY, String in_txt) {
    setXY(in_posX, in_posY);
    setText(in_txt);
  }

  public void setText(String in_txt) {
    this.inText = in_txt;
  }

  public void setXY(float in_posX, float in_posY) {
    this.xPos = in_posX;
    this.yPos = in_posY;
  }

  public void shiftXY(float in_posX, float in_posY) {
    this.xPos += in_posX;
    this.yPos += in_posY;
  }

  //////////////////////////////////////////////////////////////////////////////////////////////

  // we set string and then method calculates size of the radius
  public void drawTextRing(String in_txt) {
    setText(in_txt);
    drawTextOnRingBase(ang);
  }

  public void drawTextRing(float in_posX, float in_posY, String in_txt) {
    setXY(in_posX, in_posY);
    drawTextRing(in_txt);
  }

  public void drawTextRing() {
    drawTextOnRingBase(ang);
  }
  //////////////////////////////////////////////////////////////////////////////////////////////

  // we set string and radius and then method calculates size of the font
  public void drawTextSizeForRadTxt(String in_txt, float in_diam) {
    this.inText = in_txt;
    textSize(10);
    textSize((TWO_PI * in_diam/2) / (widthOfString(in_txt)/10));
    drawTextOnRingBase(ang);
  }

  public void drawTextSizeForRadTxt(float in_posX, float in_posY, String in_txt, float in_diam) {
    setXY(in_posX, in_posY);
    drawTextSizeForRadTxt(in_txt, in_diam);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////

  // we set symbol and radius and then method counts amount of the symbols for repetitions
  // if string contains more than 1 symbol then radius will be changed
  public void drawSymbolsByRadius(String in_txt, float in_diam) {
    this.radius = in_diam/2;
    resetStrBySymbNum(in_txt, 0);
    calcRadLenFromStirng();
    drawTextOnRingBase(ang);
  }  

  public void drawSymbolsByRadius(float in_posX, float in_posY, String in_txt, float in_diam) {
    setXY(in_posX, in_posY);
    drawSymbolsByRadius(in_txt, in_diam);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////  

  // we set string and count of repetitions and then method calculates size of the radius
  public void drawStringRepetition(String in_txt, int in_countRepetition) {
    resetStrBySymbNum(in_txt, in_countRepetition);
    calcRadLenFromStirng();
    drawTextOnRingBase(ang);
  }

  public void drawStringRepetition(float in_posX, float in_posY, String in_txt, int in_countRepetition) {
    setXY(in_posX, in_posY);
    drawStringRepetition(in_txt, in_countRepetition);
    drawTextOnRingBase(ang);
  }

  //////////////////////////////////////////////////////////////////////////////////////////////
  // helper methods

  // method create a new string that repeats itself as many times as necessary for existing radius
  private void resetStrBySymbNum(String in_txt, int count) {
    if (count == 0) {
      count = PApplet.parseInt(TWO_PI*radius/ (widthOfString(in_txt)));
    }
    this.inText = "";
    while (count>0) {
      this.inText += in_txt;
      count--;
    }
  }

  // method of calculating the string width and the corresponding radius   
  private void calcRadLenFromStirng() {
    this.crclStrWidth = widthOfString(this.inText); 
    this.radius = crclStrWidth / TWO_PI;
  }

  // widthOfString("String width") != textWidth("String width")
  public float widthOfString(String in_str) {
    int cnt = 0;
    float totalWidth = 0;
    while (cnt < in_str.length () ) {
      totalWidth += textWidth(in_str.charAt(cnt));
      ++cnt;
    }
    return totalWidth;
  }

  //////////////////////////////////////////////////////////////////////////////////////////////

  public void draw() {
    drawTextOnRingBase(ang);
    ang++;
  }

  private void drawTextOnRingBase(float ang) {
    calcRadLenFromStirng();
    textAlign(CENTER);

    int count = 0;
    float arcLength = 0;
    float totalAngle = crclStrWidth/radius;
    float angle;

    while (count < inText.length () ) {
      float wdthTChar = textWidth(inText.charAt(count));
      arcLength += wdthTChar/2;
      angle = PI + arcLength / radius  - totalAngle;  
      float xx = cos(angle + startAngle) * radius + xPos;
      float yy = sin(angle + startAngle) * radius + yPos;

      pushMatrix();
      translate(xx, yy);
      rotate(angle + PI/2 +ang);
      text(inText.charAt(count++), 0, 0);
      popMatrix();
      arcLength += wdthTChar/2;
    }
    //    ellipse(xPos, yPos, radius*2, radius*2);
  }
}
class MainNode extends Node {
  // reference to the force directed graph
  TwitterGraph graph;


  // look of the node
  int nodeColor = color(random(255));
  int ringColor = color(255, 131, 0);
  float nodeDiameter = 50;
  // size of the displayed text
  float textsize = 22;
  // behaviour parameters
  float nodeRadius = 200;
  float nodeStrength = -10;
  float nodeDamping = 0.06f;

  int ranCol;

  int type;



  // last activation (rollover) time
  int activationTime;
  // is this a node that was clicked on
  boolean wasClicked = false;

// Initializers
  MainNode(TwitterGraph theGraph) {
    super();
    ranCol = color(random(255), random(255), random(255));
    graph = theGraph;
    init();
  }

  MainNode(TwitterGraph theGraph, float theX, float theY) {
    super(theX, theY);
    ranCol = color(random(255), random(255), random(255));

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
  public void init() {
    activationTime = millis();
    diameter = nodeDiameter + 6;

    setDamping(nodeDamping);
    setStrength(nodeStrength);
    
    //Not display radius
    setRadius(nodeRadius);
  }

  //LOAD DATA
  public void setID(String theID) {
    super.setID(theID);
  }



  ///
  public void draw() {


      float d;
      // while loading draw grey ring around node
      d = diameter-30;

      pushStyle();
      // randomly coloured circle
      fill(ranCol);
      ellipse(x, y, d, d);

      popStyle();
   
  }


  public void drawLabel() {
    // draw text
    textAlign(LEFT);
    rectMode(CORNER);
    float tfactor = 1;

    // draw text for rolloverNode
    if (graph.showText) {
      if (wasClicked || (graph.isRollover(this) && graph.showRolloverText)) {
        activationTime = graph.getMillis();

        float ts = textsize/pow(graph.zoom, 0.5f) *tfactor;
        textFont(graph.font, ts);

        float tw = textWidth(id);
        fill(255, 80);
        rect(x+ (diameter/2+4)*tfactor, y-(ts/2)*tfactor, (tw+3)*tfactor, (ts+3)*tfactor);
        fill(80);
        if (graph.isRollover(this) && graph.showRolloverText) {
          fill(0);
        }
        text(id, x+(diameter/2+5)*tfactor, y+6*tfactor);
      } else {
        // draw text for all nodes that are linked to the rollover node
        if (wasClicked || graph.showRolloverNeighbours) {
          if (graph.isRolloverNeighbour(this)) {
            activationTime = graph.getMillis();
          }
        }

        int dt = graph.getMillis() - activationTime;
        if (dt < 10000) {
          float ts = textsize/pow(graph.zoom, 0.5f)*tfactor;
          textFont(graph.font, ts);

          float tw = textWidth(id);
          float a = min(3*(1-dt/10000.0f), 1) * 100;
          fill(255, a*0.8f);
          rect(x+(diameter/2+4)*tfactor, y-(ts/2)*tfactor, (tw+3)*tfactor, (ts+3)*tfactor);
          fill(80, a);
          text(id, x+(diameter/2+5)*tfactor, y+6*tfactor);
        }
      }
    }
  }
}


//TwitterGraph controls everything the nodes need and their relationships to each other.
class TwitterGraph {

  // we use a HashMap to store the nodes, because we frequently have to find them by their id,
  // which is easy to do with a HashMap
  HashMap nodeMap = new HashMap();

  // we use an ArrayList because it is faster to append with new springs
  ArrayList springs = new ArrayList();

  // hovered node
  Node rolloverNode = null;
  // node that is dragged with the mouse
  Node selectedNode = null;
  // node for which loading is in progress
  Node loadingNode = null;





  // default parameters
  int resultCount = 10;

  float springLength = 10;
  float springStiffness = 0.1f;
  float springDamping = 0.010f;

  PFont font;
  float textsize;
  float lineWeight = 1;
  float lineAlpha = 100;
  int linkColor = color(160);

  boolean showText = false;
  boolean showRolloverText = false;
  boolean showRolloverNeighbours = false;


  //Graph SIZE
  float minX = 0;
  float minY = 0;
  float maxX = width;
  float maxY = height;

  //CONTROLLING ZOOM
  float zoom = 1;
  float targetZoom = 1;
  PVector offset = new PVector();
  PVector targetOffset = new PVector();

  // helpers
  int pMillis = millis();
  // for pdf output we need to freeze time to 
  // prevent text from disappearing
  boolean freezeTime = false;


  // ------ constructor ------

  TwitterGraph() {
    font = createFont("Miso", 12);
  }


  // ------ methods ------


  //-------------MAIN NODE ADD & REMOVE----------------
  public Node addNode(String theID, float theX, float theY) {
    // check if the node is already there
    Node findNode = (Node) nodeMap.get(theID);

    //IF it isn't add it
    if (findNode == null) {
      Node newNode = new MainNode(this, theX, theY);
      newNode.setID(theID);
      //Add Node Details to HashMap
      nodeMap.put(theID, newNode);
      addSpringToCenter(theID);
      return newNode;
    } else {
      return null;
    }
  }
  




  public Spring addSpring(String fromID, String toID) {
    MainNode fromNode, toNode; 
    fromNode = (MainNode) nodeMap.get(fromID);
    toNode = (MainNode) nodeMap.get(toID);

    // if one of the nodes do not exist, stop creating spring
    if (fromNode==null) return null;
    if (toNode==null) return null;

    if (getSpring(fromNode, toNode) == null) {
      // create a new spring
      Spring newSpring = new Spring(fromNode, toNode, springLength, springStiffness, 0.9f);
      springs.add(newSpring);
      return newSpring;
    }

    return null;
  }
  
  public Spring addSpringToCenter(String id){
    MainNode node;
    node = (MainNode) nodeMap.get(id);
    
    if(node==null) return null;
    
    if(getSpring(node, dummyCenterNode) ==null){
     Spring newSpring = new Spring(node, dummyCenterNode, springLength, springStiffness, 0.9f);
     springs.add(newSpring);
     return newSpring;
    }
    
    return null;
  }
      
  
  

  ///REMOVE NODE

  public void removeNode(Node theNode, int type) {
    int i;
    // remove springs from/to theNode
    for (i = springs.size()-1; i >= 0; i--) {
      Spring s = (Spring) springs.get(i);
      if (s.fromNode == theNode || s.toNode == theNode) {
        springs.remove(i);
      }
    }

    // remove theNode from the HASHMAP
    nodeMap.remove(theNode.id);

    // remove single nodes
    Iterator iter = nodeMap.entrySet().iterator();

    while (iter.hasNext ()) {
      Map.Entry me = (Map.Entry) iter.next();
      MainNode node = (MainNode) me.getValue();
      if (getSpringIndexByNode(node) < 0) {
        iter.remove();
      }
    }
  }

  public Node getNodeByID(String theID) {
    Node node = (Node) nodeMap.get(theID); 
    return node;
  }



  ////FOR CLICK I THINK
  //  Node getNodeByScreenPos(float theX, float theY) {
  //    float mx = (theX-width/2)/zoom-offset.x;
  //    float my = (theY-height/2)/zoom-offset.y;

  //    return getNodeByPos(mx, my);
  //  }


  //Node getNodeByPos(float theX, float theY) {
  //  Node selectedNode = null;
  //  Iterator i = nodeMap.entrySet().iterator();
  //  while (i.hasNext ()) {
  //    Map.Entry me = (Map.Entry) i.next();
  //    TwitterNode checkNode = (TwitterNode) me.getValue();

  //    float d = dist(theX, theY, checkNode.x, checkNode.y);
  //    if (d < max(checkNode.diameter/2, minClickDiameter)) {
  //      selectedNode = (Node) checkNode;
  //    }
  //  }
  //  return selectedNode;
  //}

  public int getSpringIndexByNode(Node theNode) {
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s.fromNode == theNode || s.toNode == theNode) {
        return i;
      }
    }
    return -1;
  }

  public Spring getSpring(Node theFromNode, Node theToNode) {
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s.fromNode == theFromNode && s.toNode == theToNode) {
        return s;
      }
    }
    return null;
  }


  public float getZoom() {
    return targetZoom;
  }
  public void setZoom(float theZoom) {
    targetZoom = theZoom;
  }

  public PVector getOffset() {
    return new PVector(offset.x, offset.y);
  }

  public void setOffset(float theOffsetX, float theOffsetY) {
    offset.x = theOffsetX; 
    offset.y = theOffsetY; 
    targetOffset.x = offset.x; 
    targetOffset.y = offset.y;
  }

  public Node getLoadingNode() {
    return loadingNode;
  }
  public void setLoadingNode(Node theNode) {
    loadingNode = theNode;
  }
  public boolean isLoading(Node theNode) {
    if (theNode == loadingNode) return true;
    return false;
  }

  public boolean isRollover(Node theNode) {
    if (theNode == rolloverNode) return true;
    return false;
  }
  public boolean isRolloverNeighbour(Node theNode) {
    if (getSpring(theNode, rolloverNode) != null) return true;
    if (getSpring(rolloverNode, theNode) != null) return true;
    return false;
  }

  public boolean isSelected(Node theNode) {
    if (theNode == selectedNode) return true;
    return false;
  }

  public int getMillis() {
    if (freezeTime) {
      return pMillis;
    }
    return millis();
  }



  public PVector screenPos(PVector thePos) {
    return new PVector(thePos.x, thePos.y, 1);
  }

  public PVector localToGlobal(float theX, float theY) {
    float mx = (theX+offset.x)*zoom+width/2;
    float my = (theY+offset.y)*zoom+height/2;

    return new PVector(mx, my);
  }

  public PVector globalToLocal(float theX, float theY) {
    float mx = (theX-width/2)/zoom-offset.x;
    float my = (theY-height/2)/zoom-offset.y;

    return new PVector(mx, my);
  }



  public String toString() {
    String s = "";

    Iterator i = nodeMap.entrySet().iterator();
    while (i.hasNext ()) {
      Map.Entry me = (Map.Entry) i.next();
      Node node = (Node) me.getValue();
      s += node.toString() + "\n";
    }
    return (s);
  }

  //-------------------------------------------
  public void update() {
    // use this function also to get actual width and heigth of the graph
    minX = Float.MAX_VALUE; 
    minY = Float.MAX_VALUE;
    maxX = -Float.MAX_VALUE; 
    maxY = -Float.MAX_VALUE;

    // make an Array out of the values in nodeMap
    Node[] nodes = (Node[]) nodeMap.values().toArray(new Node[0]);


    //Apply forces
    for (int i = 0; i < nodes.length; i++) {
      nodes[i].attract(nodes);
    }

    //Add springs
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s == null) break;
      s.update();
    }

    //Call the update method on individual nodes
    for (int i = 0; i < nodes.length; i++) {
      nodes[i].update();

      minX = min(nodes[i].x, minX);
      maxX = max(nodes[i].x, maxX);
      minY = min(nodes[i].y, minY);
      maxY = max(nodes[i].y, maxY);
    }


        if (selectedNode != null) {
          // when dragging a node
          selectedNode.x = (mouseX - width/2)/zoom - offset.x;
          selectedNode.y = (mouseY - height/2)/zoom - offset.y;
        }
  }


  public void draw() {
    int dt = 0;
    if (!freezeTime) {
      int m = millis();
      dt = m - pMillis;    
      pMillis = m;
    }

    // smooth movement of canvas
    PVector d = new PVector();

    float accomplishPerSecond = 0.95f;
    float f = pow(1/(1-accomplishPerSecond), -dt/1000.0f);

    d = PVector.sub(targetOffset, offset);
    d.mult(f);
    offset = PVector.sub(targetOffset, d);

    zoom = targetZoom - ((targetZoom - zoom) * f);


    pushStyle();

    pushMatrix();
    translate(width/2, height/2);
    scale(zoom);
    translate(offset.x, offset.y);


    //THIS LOADS THE DATA IN THE ORIGINAL
    Iterator iter = nodeMap.entrySet().iterator();
    while (iter.hasNext ()) {
      Map.Entry me = (Map.Entry) iter.next();
      //MainNode node = (MainNode) me.getValue();
      //node.loaderLoop();
    }


    // draw springs
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s == null) break;
      stroke(0);
      strokeWeight(lineWeight);
      //drawArrow((MainNode) s.fromNode,  s.toNode);
      line(s.getFromNode().x, s.getFromNode().y, s.getToNode().x, s.getToNode().y);
      noStroke();
    }

    // draw nodes
    colorMode(RGB, 255, 255, 255, 100);

    iter = nodeMap.entrySet().iterator();
    while (iter.hasNext ()) {
      Map.Entry me = (Map.Entry) iter.next();

      MainNode node = (MainNode) me.getValue();
      node.draw();
     // removeNode(node);
    }

    // draw node labels 
    iter = nodeMap.entrySet().iterator();
    while (iter.hasNext ()) {
      Map.Entry me = (Map.Entry) iter.next();
      MainNode node = (MainNode) me.getValue();
      node.drawLabel();
    }

    popMatrix();

    popStyle();
    
    //DRAW THE CENTRE NODE
     drawCenter();
  }

  public void drawCenter(){
       
      float d;
      // while loading draw grey ring around node
      d = nodeDiameter;


      // white ring between center circle and link ring

      fill(255, 131, 0);
      ellipse(width/2, height/2, d, d);

      // main dot
      d = (nodeDiameter - 10);
      pushStyle();
      fill(255);
      ellipse(width/2, height/2, d, d);
      popStyle(); 
  }
  public void drawArrow(MainNode n1, MainNode n2) {

    PVector d = new PVector(n2.x - n1.x, n2.y - n1.y);
    float margin1 = n1.diameter/2.0f + 3 + lineWeight/2;
    float margin2 = n2.diameter/2.0f + 3 + lineWeight/2;

    if (d.mag() > margin1+margin2) {
      d.normalize();
      line(n1.x+d.x*margin1, n1.y+d.y*margin1, n2.x-d.x*margin2, n2.y-d.y*margin2);

      float a = atan2(d.y, d.x);
      pushMatrix();
      translate(n2.x-d.x*margin2, n2.y-d.y*margin2);
      rotate(a);
      float l = 1 + lineWeight;
      line(0, 0, -l, -l);
      line(0, 0, -l, l);
      popMatrix();
    }
  }


  public float getWidth() {
    return 1;
  }

  public String encodeURL(String name) {
    StringBuffer sb = new StringBuffer();
    byte[] utf8 = name.getBytes();
    for (int i = 0; i < utf8.length; i++) {
      int value = utf8[i] & 0xff;
      if (value < 33 || value > 126) {
        sb.append('%');
        sb.append(hex(value, 2));
      } else {
        sb.append((char) value);
      }
    }
    return sb.toString();
  }
}
  public void settings() {  size(1280, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#FFFCFC", "--stop-color=#cccccc", "TwitterApp" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
