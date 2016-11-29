class OuterRing {
  int radius;
  int x;
  int y;

  int segments = 14;

  color[] cols = {#f3b700, #faa300, #ff6201, #f63e02, #e57c04, #985F99, #9684A1, #AAACB0, #B6C9BB, #BFEDC1, #71A2B6, #60B2E5, #53F4FF, #E7D7C1, #A78A7F, #735751 };
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