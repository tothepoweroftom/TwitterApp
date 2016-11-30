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

PApplet root = this;


ControlP5 cp5;
String textValue = "";

TwitterGraph myTwitterGraph;
float nodeDiameter = 25;

//Global node reference
MainNode global;

//Default keyword array
String keywords[] = {
  "Technology"
};  
String hashtags[];





int CANVAS_WIDTH = 1280;
float zoom = 0.2;


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
float c = 1;
String[] symmb;
boolean twitFlag = false;


//Internet stuff
TwitterStream twitterStream;

//Sentiment Analysis
HttpURLConnection conn = null;
StringBuilder response = new StringBuilder();
processing.data.JSONObject ezm = new processing.data.JSONObject();

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
  fullScreen();
  //size(1200,800);
  background(255);
  noStroke();
  dummyCenterNode = new Node(0, 0);
  myTwitterGraph = new TwitterGraph();

  //Global array for storage - probably unnecessarily big
  symmb = new String[180];
  hashtags = new String[100];

  
  font = createFont("blanch_condensed.ttf", 22);

  //Begin Streaming from twitter
  openTwitterStream();
//  URL url = null;


//Add controls
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
        drawText();
    }
  }

}


//Keyboard controls
void keyPressed() {

  if (keyCode == UP) zoom *= 1.05;
  if (keyCode == DOWN) zoom /= 1.05;
  zoom = constrain(zoom, 0.05, 1);


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

void drawText(){
       pushStyle();
      fill(0);
      popStyle();
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


// Stream it
void openTwitterStream() {  

  ConfigurationBuilder cb = new ConfigurationBuilder();  
  cb.setOAuthConsumerKey("d1AVCc0m033ZvweC2lOp5VFFW");
  cb.setOAuthConsumerSecret("U1DzbrWbp4LzcyIQPCu5UvSVyO5uzAOMEDYyACbwmH8WIaefoe");
  cb.setOAuthAccessToken("3569010795-OA5ceBBzRYGToSPlsdyx7lyBqEMMOkagGmDSD7j");
  cb.setOAuthAccessTokenSecret("wCliIo5iPESSlfUt9gIqZXkzqoVFWghVa7dhmDTngP67I");

  TwitterStream twitterStream = new TwitterStreamFactory(cb.build()).getInstance();

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
     
    //Add a new tweet node, temporarily storing it in the global node
    global =(MainNode) myTwitterGraph.addNode(name, random(-5, 5), random(-5, 5));
    parseHashtag(text, global);

    String tzone = status.getUser().getTimeZone();
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


//Take input from the textfield
public void input(String theText) {
  // automatically receives results from controller input
  println("a textfield event for controller 'input' : "+theText);
  keywords[0]=theText;
  openTwitterStream();
  myTwitterGraph.removeNodes();
}


//Parse the tweet to extract the hashtags.
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

  }
}