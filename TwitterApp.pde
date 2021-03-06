
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

import java.util.concurrent.ConcurrentHashMap;

import java.util.Map;

import controlP5.*;

ControlP5 cp5;

String textValue = "";

TwitterGraph myTwitterGraph;

PApplet root = this;

Node global;

OuterRing oR;

String keywords[] = {
  "Innovation"
};  

String hashtags[];

float zoom = 0.2;

float nodeDiameter = 20;

int CANVAS_WIDTH = 1280;
int hashCount = 0;
int tweetCount =0;


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

//GLOBAL COLOR PALETTE
color[] cols = {#f3b700, #faa300, #ff6201, #f63e02, #e57c04, #985F99, #9684A1, #AAACB0, #B6C9BB, #BFEDC1, #71A2B6, #60B2E5, #53F4FF, #E7D7C1, #A78A7F, #735751 };


TwitterStream twitterStream;



//mouseInteraction
//boolean dragging = false;
//float offsetX = 0, offsetY = 0, clickX = 0, clickY = 0, clickOffsetX = 0, clickOffsetY = 0;
//int lastMouseButton = 0;

PApplet thisPApplet = this;

void setup() {
  fullScreen();
  //size(1200,800);
  background(255);
  noStroke();
  dummyCenterNode = new Node(0, 0);

  myTwitterGraph = new TwitterGraph();
  oR = new OuterRing(height-height/20, width/2, height/2);


  //  println(myTwitterGraph.toString());
  symmb = new String[180];

  hashtags = new String[100];

  font = createFont("blanch_condensed.ttf", 22);

  openTwitterStream();



  cp5 = new ControlP5(this);

  cp5.addTextfield("input")
    .setPosition(20, 100)
    .setSize(200, 40)
    .setFont(font)
    .setFocus(true)
    .setColorBackground(color(220))
    .setColor(color(0))
    .setLabel("Filter")

    ;
}


void draw() {

  background(220);
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
      fill(0, 180);
      text(symmb[0], 20, height/4, 200, 400);
      textSize(34);
      fill(0, 200);
      text("#Tweets", 20, height/2+height/8, 200, 400);
      textSize(30);
      fill(0, 180);
      text(str(tweetCount), 20, height/2+height/8 + 30, 200, 400);
      text("#Hashtags", 20, height/2+height/4, 200, 400);
      textSize(30);
      fill(0, 180);
      text(str(hashCount), 20, height/2+height/4 + 30, 200, 400);
      fill(255, 131, 0, 180);
      text(symmb[1], width - width/6, height/4, 200, 400);
      fill(180, 180);
      if (symmb[2]!=null) {
        text(symmb[2], width-width/6, height/6, 200, 400);
      }
      popStyle();
    }
  }

  oR.display();
}

void keyPressed() {

  if (keyCode == UP) zoom *= 1.05;
  if (keyCode == DOWN) zoom /= 1.05;
  zoom = constrain(zoom, 0.05, 1);
  if (key == 'a' || key == 'A') {
    myTwitterGraph.addNode(str(random(1000)), random(10, 20), random(10, 20));
  }

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

  println(zoom);
}


// Stream it
void openTwitterStream() {  

  ConfigurationBuilder cb = new ConfigurationBuilder();  
  cb.setOAuthConsumerKey("d1AVCc0m033ZvweC2lOp5VFFW");
  cb.setOAuthConsumerSecret("U1DzbrWbp4LzcyIQPCu5UvSVyO5uzAOMEDYyACbwmH8WIaefoe");
  cb.setOAuthAccessToken("3569010795-OA5ceBBzRYGToSPlsdyx7lyBqEMMOkagGmDSD7j");
  cb.setOAuthAccessTokenSecret("wCliIo5iPESSlfUt9gIqZXkzqoVFWghVa7dhmDTngP67I");

  TwitterStream twitterStream = new TwitterStreamFactory(cb.build()).getInstance();

  FilterQuery filtered = new FilterQuery();



  filtered.track(keywords[0]);

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

    int favourite = status.getFavoriteCount();
    int retweet = status.getRetweetCount();

    int total = favourite+retweet;
    println(total);

    global = myTwitterGraph.addNode(name, random(-5, 5), random(-5, 5));
    parseHashtag(text, global);
    String loc = status.getUser().getLocation();
    // println("Hashmap size:" + myTwitterGraph

    if (loc !=null) {
      // println(loc);
    }

    String tzone = status.getUser().getTimeZone();
    //println(tzone);
    tweetCount++;




    if (symmb != null) {
      symmb[0] = text;
      symmb[1] = name;
      symmb[2] = tzone;
      twitFlag = true;
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

void stop() {
  twitterStream.shutdown();
}

public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
  keywords[0]=theText;
  openTwitterStream();
  myTwitterGraph.removeNodes();
}

void parseHashtag(String tweetText, Node callingNode) {
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
    MainNode node =(MainNode) myTwitterGraph.addHashtagNode("#"+search, 280, random(360));
    myTwitterGraph.addWeakSpring("#"+search, global.id);
    //node.numConnections++;
    hashCount++;

    //String searchHTML="<a href='http://search.twitter.com/search?q=" + search + "'>" + result + "</a>"
    //tweetText = tweetText.replace(result, searchHTML);
  }
}