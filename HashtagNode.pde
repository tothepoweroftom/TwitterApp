class HashtagNode {

  // All the usual stuff
  PVector location;
  PVector velocity;
  PVector acceleration;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed

  float ray;
  float ellipseDiameter;
  String theHashtag;

  float lifetime;
  float life;

  boolean isClicked = false;
  boolean isHighlighted = false;

  //float bloom = 0;
  //PVector blooma = new PVector(0, 0);
  boolean updatepos = true;

  Bloom blooma;

  String text;

  HashtagNode(PVector l, float lf, String th) {
    location = l;
    ray = 40;
    ellipseDiameter = 10;
    maxspeed = 5;
    maxforce = 1;
    acceleration = new PVector(0, 0);
    velocity = new PVector(0, 0);

    lifetime = lf;
    life = lifetime;

    theHashtag = th;
    //this.text = text;
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    PVector dir = PVector.sub(force, acceleration);
    PVector vel = PVector.div(dir, 10);
    acceleration.add(vel);
  }

  void applyBehaviors(ArrayList<HashtagNode> vehicles) {
    if (!isClicked) {
      PVector separateForce = separate(vehicles);
      PVector seekForce = seek();
      separateForce.mult(2);
      seekForce.mult(1);
      applyForce(separateForce);
      applyForce(seekForce);
    } else {
      PVector np = new PVector(20, 100);
      PVector dir = PVector.sub(np, location);
      PVector vel = PVector.div(dir, 7);
      location.add(vel);
    }
  }

  // A method that calculates a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek() {
    PVector target = new PVector(width/2, height/2);
    if (!isClicked) target = new PVector(width/2, height/2); 
    else target = new PVector(30, 140);
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target

    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus velocity
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxforce);  // Limit to maximum steering force

    return steer;
  }

  // Separation
  // Method checks for nearby vehicles and steers away
  PVector separate (ArrayList<HashtagNode> vehicles) {
    float desiredseparation = ray*2;
    PVector sum = new PVector();
    int count = 0;
    // For every boid in the system, check if it's too close
    //for (HashtagNode other : vehicles) {
    //  float d = PVector.dist(location, other.location);
    //  // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
    //  if ((d > 0) && (d < desiredseparation)) {
    //    // Calculate vector pointing away from neighbor
    //    PVector diff = PVector.sub(location, other.location);
    //    diff.normalize();
    //    diff.div(d);        // Weight by distance
    //    sum.add(diff);
    //    count++;            // Keep track of how many
    //  }
    //}

    for (Iterator<HashtagNode> it = vehicles.iterator(); it.hasNext(); ) {
      HashtagNode other = it.next();
      float d = PVector.dist(location, other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      sum.div(count);
      // Our desired vector is the average scaled to maximum speed
      sum.normalize();
      sum.mult(maxspeed);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.sub(velocity);
      sum.limit(maxforce);
    }
    return sum;
  }

  void update(float x, float y) {

    if (isClicked && updatepos) {
      blooma = new Bloom(location);
      //blooma = location;
      updatepos = false;
    }

    /*if (dist(x, y, location.x, location.y) < ellipseDiameter) {
     isHighlighted = true; 
     
     if (mousePressed) {
     isClicked = true;
     
     if (updatepos) {
     blooma = new Bloom(location);
     //blooma = location;
     updatepos = false;
     }
     }
     } else {
     isHighlighted = false;
     }*/

    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);

    // Separate from the center
    if (!isClicked) {
      float desiredseparation = 300;
      PVector sum = new PVector();
      PVector center = new PVector(width/2, height/2);
      float d = PVector.dist(location, center);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location, center);
        diff.normalize();
        diff.div(d);        // Weight by distance
        sum.add(diff);
      }
      sum.normalize();
      sum.mult(maxspeed*10);
      // Implement Reynolds: Steering = Desired - Velocity
      sum.sub(velocity);
      sum.limit(maxforce*2);
      applyForce(sum);
      life -= 20;
    }
  }

  void display() {

    //fill(255, map(life, this.lifetime, 0, 255, 0));
    fill(255, 200);

    noStroke();
    ellipseMode(CENTER);
    if (!isHighlighted) {
      ellipse(location.x-ellipseDiameter/2, location.y, ellipseDiameter, ellipseDiameter);
    } else {
      fill(255, 131, 0);
      ellipse(location.x-ellipseDiameter/2, location.y, ellipseDiameter*4, ellipseDiameter*4);
    }
    fill(255);
    textAlign(LEFT, CENTER);
    pushStyle();
    textFont(font2);

    text("#" + theHashtag, location.x + ellipseDiameter*0.8, location.y);
    popStyle();
    if (blooma != null) {
      blooma.run();
    }
  }

  int getAngle() {
    float a = atan2(location.y-height/2, location.x-width/2);
    int angle = int(degrees(a));
    return angle;
  }
}

class Bloom {

  PVector bl;
  float alpha;

  Bloom(PVector l) {
    bl = l;
    alpha = 0;
  }

  void run() {
    float a = map(alpha, 0, 255, 255, 0);
    //float a = 255.0;
    float nb = 255;
    float db = nb-alpha;
    float vb = db/7;
    alpha += vb;

    stroke(255, a);
    noFill();
    ellipse(bl.x, bl.y, alpha, alpha);
  }
}