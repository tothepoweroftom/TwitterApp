
import generativedesign.*;
import processing.data.XML;
import processing.pdf.*;
import java.net.*;
import java.io.UnsupportedEncodingException;
import java.util.Calendar;
import java.util.Iterator;
import java.util.Map;
import ddf.minim.*;

Minim minim;
AudioSample[] note;



TwitterGraph myTwitterGraph;

PApplet root = this;

float zoom = 0.2;

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

void setup() {
  size(1280, 800);
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


void draw() {

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

    int ran = int(random(note.length));

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

void stop(){
 minim.stop();
 twitterStream.shutdown();
}