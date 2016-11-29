class OuterRing {
  int radius;
  int x;
  int y;

  int segments = 14;

  OuterRing(int radius, int x, int y) {
    this.radius = radius; 
    this.x = x;
    this.y = y;
  }


  void display() {
    pushStyle();
    noFill();
    if (segments<=cols.length) {
      for (int i=0; i<this.segments; i++) {
        strokeWeight(10);
        stroke(cols[i]);
        float angle = 2*PI/segments;
        // println(angle*i);
        arc(this.x, this.y, this.radius, this.radius, i*angle, i*angle+angle);
      }
    }
    popStyle();
  }
}