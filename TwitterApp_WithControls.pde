import generativedesign.*;
import processing.data.XML;
import processing.pdf.*;
import java.net.*;
import java.io.UnsupportedEncodingException;
import java.util.Calendar;
import java.util.Date;
import java.util.Iterator;
import java.util.regex.Pattern;
import java.util.regex.Matcher;
import java.io.*;
import java.net.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;
import controlP5.*;
import processing.data.*;

import org.processing.wiki.triangulate.*;

//Spacebrew - Implementation
import spacebrew.*;
String server="localhost";
String name="TwitterApp1";
String description ="Twitter data visualization";


Spacebrew sb;
PVector slider;

//Global control values
int slider1 = 180;
int slider2 = 180;
int linearSlider = 0;
boolean centerButton = false;
String filter = "technology";
boolean slider1Active = false;
boolean slider2Active = false;

PApplet root = this;

ControlP5 cp5;
Textfield txtfld; // EDITED
String textValue = "";

TwitterGraph myTwitterGraph;
float nodeDiameter = 25;

//Global node reference
MainNode global;

//Default keyword array
String keywords[] = {
  "technology"
};  
String hashtags[];

public PVector interaction = new PVector(0, 0);



int CANVAS_WIDTH = 1280;
float zoom = 0.2;

int fadeOutTime = 100000;


//Global Counters
int hashCount = 0;
int tweetCount =0;

//To attach springs
Node dummyCenterNode;


//Twitter drawing code;

//DRAWING CODE
int clr [] = {255, 0};
int min = 5, max = 18;
int limit = 180;
PFont font;
PFont font2;

float c = 1;
String[] symmb;
boolean twitFlag = false;
PImage userImage;
String userImageURL;
PImage maskImage;

//Internet stuff
TwitterStream twitterStream;

//Sentiment Analysis
HttpURLConnection conn = null;
StringBuilder response = new StringBuilder();
processing.data.JSONObject ezm = new processing.data.JSONObject();


// Background particle system
ParticleSystem ps;

ArrayList<HashtagNode> thcnodes = new ArrayList<HashtagNode>();
ArrayList<HashtagNode> closestNodes = new ArrayList<HashtagNode>();
boolean resetNodes = false;

color averageSentiment;
ArrayList<Color> averageColor = new ArrayList<Color>();
ArrayList<Integer> avg = new ArrayList<Integer>();
ArrayList<MainNode> selectedNodes = new ArrayList<MainNode>();

static class Util {
  public static String streamToString(InputStream is) throws IOException {
    StringBuilder sb = new StringBuilder();
    BufferedReader rd = new BufferedReader(new InputStreamReader(is));
    String line;
    while ((line = rd.readLine()) != null) {
      sb.append(line);
    }
    return sb.toString();
  }
}

PApplet thisPApplet = this;

void setup() {
  // fullScreen(P3D);
  size(1200, 800, P3D);
  background(255);
  noStroke();
  dummyCenterNode = new Node(0, 0);
  myTwitterGraph = new TwitterGraph();
  maskImage = loadImage("mask.jpg");
  //Global array for storage - probably unnecessarily big
  symmb = new String[180];
  hashtags = new String[100];

  font = createFont("blanch_condensed.ttf", 22);
    font2 = createFont("futura.ttc", 22);

  //font = loadFont("SourceCodePro-Light-22.vlw");

  //Begin Streaming from twitter
  openTwitterStream();
  //  URL url = null;


  //Add controls
  cp5 = new ControlP5(this);

  //txtfld = cp5.addTextfield("input")
  //  .setPosition(20, 20)
  //  .setSize(200, 40)
  //  .setFont(font)
  //  .setFocus(true)
  //  .setColorBackground(color(0))
  //  .setColor(color(255))
  //  //.setLabel("Filter:   " + keywords[0])
  //  .setLabel("Filter:   " + keywords[0])
  //  ;


  //Spacebrew setup
  // instantiate the spacebrewConnection variable
  sb = new Spacebrew( this );
  slider = new PVector(0, 0);
  // declare your publishers
  sb.addPublish( "local_slider", "range", slider1 ); 

  // declare your subscribers
  sb.addSubscribe( "slider1", "range" );
  sb.addSubscribe( "slider2", "range" );
  sb.addSubscribe( "centralButton", "boolean" );
  sb.addSubscribe( "slider1Active", "boolean" );
  sb.addSubscribe( "slider2Active", "boolean" );

  sb.addSubscribe( "linearSlider", "range" );
  sb.addSubscribe( "filter", "string" );

  sb.connect(server, name, description );

  ps = new ParticleSystem();
}


void draw() {

  //println(frameRate);

  background(0);

  dataFetching();

  averagingColor();

  ps.run();

  textFont(font, 30);

  // ------ update and draw graph ------
  myTwitterGraph.update();
  myTwitterGraph.draw();

  for (int i = 0; i < thcnodes.size(); i++) {
    HashtagNode thc = thcnodes.get(i);

    thc.applyBehaviors(thcnodes);
    thc.update(mouseX, mouseY);
    thc.display();

    //println("angle: " + thc.getAngle());

    float a = atan2(mouseY-height/2, mouseX-width/2);
    int angle = int(degrees(a));


    if (slider2Active) {
      //Outer Slider Selector
      if (abs(thc.getAngle() - slider2) < 10) {
        //thc.isHighlighted = true;
        //println(slider1);
        closestNodes.add(thc);
        if (mousePressed) {
          thc.isClicked = true;
        }
      } else {
        thc.isHighlighted = false;
      }
      if (closestNodes.isEmpty() ==false) {
        findClosestNode();
      }
    }

    if (slider1Active) {
      //Inner slider selector
      selectedNodes =  myTwitterGraph.checkAngles(slider1);
    }

    PVector txtpv = new PVector(20, 100);
    if (thc.location.dist(txtpv) < 30) {
      resetNodes = true;
      keywords[0] = "#" + thc.theHashtag;
      background(255);
    }

    if (resetNodes) {
      thcnodes.clear();
      myTwitterGraph = new TwitterGraph();
      resetNodes = false;
    }
  }




  if (twitFlag) {
    if (symmb.length != 0) {
      drawText();
    }
  }
}

void findClosestNode() {
  //Check list of closest node for the closest then empty.
  int index = 0;
  for (HashtagNode node : closestNodes) {
    int min=10;
    if (node.getAngle()<min) {
      min = node.getAngle();
      index = closestNodes.indexOf(node); // get the index nr of the node
      println("Index: " + index);
    }
  }
  closestNodes.get(index).isHighlighted = true; 
  closestNodes.clear();
}


//Keyboard controls
void keyPressed() {

  if (keyCode == UP) zoom *= 1.05;
  if (keyCode == DOWN) zoom /= 1.05;
  zoom = constrain(zoom, 0.05, 1);

  if (keyCode == RIGHT) myTwitterGraph.nodeSelector++;
  if (keyCode == LEFT) myTwitterGraph.nodeSelector--;


  if (key == 't' || key == 'T') {
    twitFlag = !twitFlag;
  }

  if (key == 'c' || key == 'C') {
    myTwitterGraph.removeNodes();
    hashCount = 0;
    tweetCount = 0;
  }

  if (key == 'l' || key == 'L') {
    myTwitterGraph.displayLabels();
  }

  //println(zoom);
}

void drawText() {
  pushStyle();
  fill(255);
  popStyle();
  pushStyle();
  fill(255, 180);
  textAlign(LEFT, TOP);
  text("Filter: " + keywords[0], 20, 20, 200, 200);
  if (!selectedNodes.isEmpty()) {
        textFont(font2, 18);

    text(selectedNodes.get(0).text, 20, height/4, 200, 400);
  }
          textFont(font, 30);

  textSize(28);
  fill(255, 200);
  text("#Tweets", 20, height/2+height/8, 200, 400);
  textSize(30);
  fill(255, 180);
  text(str(tweetCount), 20, height/2+height/8 + 30, 200, 400);
  text("#Hashtags", 20, height/2+height/4, 200, 400);
  text("Happiness %:", 20, height/2 + height*0.35);
  text(str(averageSentiment), 20, height/2 + height*0.38);
  textSize(20);
  fill(255, 180);
  text(str(hashCount), 20, height/2+height/4 + 30, 200, 400);
  fill(255, 131, 0, 180);

  text(symmb[1], width - 150, height/6, 100, 400);
  fill(180, 180);
  if (symmb[2]!=null) {
    text(symmb[2], width-150, height/6+30, 100, 400);
  }

  if (userImage != null) {
    userImage.filter(GRAY);
    image(userImage, width-150, height/6 +100, 100, 100);
  }
  popStyle();
}


// Stream it
void openTwitterStream() {  

  ConfigurationBuilder cb = new ConfigurationBuilder();  
  cb.setOAuthConsumerKey("oXA0fTQIjsiDf5EtsV8f75Em0");
  cb.setOAuthConsumerSecret("USy7v0OTU85qcxoQc4Hq4NZUkRJ7Zo8T5eBEukhZzl3rF1rG0n");
  cb.setOAuthAccessToken("1250112156-JH2OMApcksqCLXTKhfMZlC3JqCo4glASaAPKCSQ");
  cb.setOAuthAccessTokenSecret("YupymuIFIZKCt6x7IAg2mpt0NwqWRJd9MVZPdbTS0iUuA");

  twitterStream = new TwitterStreamFactory(cb.build()).getInstance();

  FilterQuery filtered = new FilterQuery();



  filtered.track(keywords);
  //filtered.language("English");

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

    //Access tweet and user
    String name = status.getUser().getScreenName();
    String text = status.getText();
    int m = millis();
    int s = second();

    userImageURL = status.getUser().getOriginalProfileImageURL();
    userImage = loadImage(userImageURL);

    //Number of followers
    int followers = status.getUser().getFollowersCount()*10;

    //Add a new tweet node, temporarily storing it in the global node
    global =(MainNode) myTwitterGraph.addNode(name, random(-7, 7), random(-7, 7));
    global.fadeCounter = followers;
    global.setText(text);
    //println("f: " + followers + " | g: " + global.fadeCounter);
    parseHashtag(followers, text, global);

    //println(myTwitterGraph.springs.size());

    String tzone = status.getUser().getLocation();
    //println(tzone);
    tweetCount++;

    //Temporarily store the data for global access
    if (symmb != null) {
      symmb[0] = text;
      symmb[1] = name;
      symmb[2] = tzone;
      twitFlag = true;
    }

    //Access sentiment server - assign color based on sentiment
    Tweet newTweet = new Tweet(name, text);
    color sentiment = newTweet.getColor();
    //averageSentiment = lerpColor(averageSentiment, sentiment, 0.5);
    averageColor.add(new Color(sentiment));
    avg.add(new Integer(newTweet.percentageSentiment));
    global.ranCol = sentiment;
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

//Shut the stream when done
void stop() {
  twitterStream.shutdown();
}


////Take input from the textfield
//public void input(String theText) {
//  // automatically receives results from controller input
//  println("a textfield event for controller 'input' : "+theText);
//  keywords[0]=theText;
//  openTwitterStream();
//  myTwitterGraph.removeNodes();
//  txtfld.setLabel("Filter:   " + keywords[0]);
//}


//Parse the tweet to extract the hashtags.
void parseHashtag(float lf, String tweetText, Node callingNode) {
  String patternStr = "(?:\\s|\\A)[##]+([A-Za-z0-9-_]+)";
  Pattern pattern = Pattern.compile(patternStr);
  Matcher matcher = pattern.matcher(tweetText);
  String result = "";

  // Search for Hashtags
  while (matcher.find()) {
    result = matcher.group();
    result = result.replace(" ", "");
    String search = result.replace("#", "");
    // println(search);
    //Add hashtag node to circle

    // EDITED
    boolean addHashtag = true;
    boolean looksArraylist = true;
    for (int i = 0; i < thcnodes.size(); i++) {
      if (looksArraylist) {
        HashtagNode thc = thcnodes.get(i);
        if (search.equals(thc.theHashtag)) {
          thc.ellipseDiameter += 10;
          //looksArraylist = false;
          addHashtag = false;
        }

        // float l = map(thc.life, thc.lifetime, 0, 255, 0);

        if (thc.life<50) {
          thcnodes.remove(i);
        }
      }
    }

    if (addHashtag) {
      float a = random(TWO_PI);
      PVector p = new PVector(width/2 + (cos(a)*300), height/2 + (sin(a)*300));
      HashtagNode h = new HashtagNode(p, lf, search.toLowerCase());
      thcnodes.add(h);
    }

    //MainNode node =(MainNode) myTwitterGraph.addHashtagNode("#"+search, 280, random(360));
    //myTwitterGraph.addWeakSpring("#"+search, global.id);
    //node.numConnections++;
    hashCount++;
  }
}

class Color {

  color c;

  Color(color cc) {
    c = cc;
  }

  color col() {
    return c;
  }
}

void averagingColor() {
  if (averageColor.size() > 1) {
    for (int i = 1; i < averageColor.size(); i++) {
      Color c = averageColor.get(i);
      Color cc = averageColor.get(i-1);
      averageSentiment = lerpColor(c.col(), cc.col(), 0.5);
    }
  }

  int sum = 0;
  for (Integer n : avg) {
    sum += n;
  }

  averageSentiment = constrain(sum, 0, 100);
}

void dataFetching() {

  colorMode(RGB, 255);

  for (int x = width/86; x < width; x += width/86) {
    for (int y = height/50; y < height; y += height/50) {
      stroke(255, 175);
      strokeWeight(1);
      point(x, y);
    }
  }

  if (random(1) > 0.5) {
    for (int x = width/100; x < width; x += width/100) {
      for (int y = height/50; y < height; y += height/50) {
        float r = random(1);
        stroke(255, 125);
        strokeWeight(1);
        if (r > 0.99) {
          line(x, y, x+width/100, y);
        }
      }
    }
  }

  stroke(255, 100);
  line(width*0.2, height*0.5, width*0.4, height*0.5);
  line(width-(width*0.2), height*0.5, width-width*0.4, height*0.5);
  line(width*0.5, height*0.2, width*0.5, height*0.4);
  line(width*0.5, height-height*0.2, width*0.5, height-height*0.4);
}

void resetGraph() {
  //Reset counters
  hashCount = 0;
  tweetCount = 0;
  // twitFlag = false;
  myTwitterGraph.removeNodes();
  for (int i = thcnodes.size() - 1; i >= 0; i--) {
    thcnodes.remove(i);
  }
  println("Graph reset");
  // twitFlag = true;
}



//Spacebrew methods
void onRangeMessage( String name, int value ) {
  println("got range message " + name + " : " + value);

  if ( name.equals("slider1")) {
    //  println("got range message " + name + " : " + value);

    slider1 = value-180;
    slider.x = 200*sin(value);
    slider.y =200*cos(value);
  } else if ( name.equals("slider2")) {

    slider2 = value-180;
  } else if (name.equals("linearSlider")) {
    linearSlider = value;
  }
}

void onBooleanMessage(String name, boolean value) {
  println("got boolean message " + name + " : " + value);

  if (name.equals("centralButton")) {
    if (value == true) {
      resetGraph();
    }
  }
  if (name.equals("slider1Active")) {
    slider1Active = value;
  }
  if (name.equals("slider2Active")) {
    slider2Active = value;
  }
}

void onStringMessage(String name, String value) {
  println("got boolean message " + name + " : " + value);
  if (name.equals("filter")) {
    keywords[0] = value;
    resetGraph();
    twitterStream.clearListeners();
    FilterQuery filtered = new FilterQuery();
    filtered.track(keywords);
    twitterStream.addListener(listener);

    if (keywords.length==0) {
      // sample() method internally creates a thread which manipulates TwitterStream 
      twitterStream.sample(); // and calls these adequate listener methods continuously.
    } else { 
      twitterStream.filter(filtered);
    }
  }
}