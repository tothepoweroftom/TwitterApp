//TwitterGraph controls everything the nodes need and their relationships to each other.
class TwitterGraph {

  // we use a HashMap to store the nodes, because we frequently have to find them by their id,
  // which is easy to do with a HashMap
  ConcurrentHashMap nodeMap = new ConcurrentHashMap();

  // we use an ArrayList because it is faster to append with new springs
  ArrayList springs = new ArrayList();

  // hovered node
  Node rolloverNode = null;
  // node that is dragged with the mouse
  Node selectedNode = null;
  // node for which loading is in progress
  Node loadingNode = null;


  ArrayList anchors = new ArrayList(); 


  // default parameters
  int resultCount = 10;

  float springLength = 10;
  float springStiffness = 0.21;
  float springDamping = 0.10;

  PFont font;
  float textsize;
  float lineWeight =1;
  float lineAlpha = 200;
  color linkColor = color(160);

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
  Node addNode(String theID, float theX, float theY) {
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
  
    //-------------MAIN NODE ADD & REMOVE----------------
  Node addNode(String theID, float theX, float theY, color sentiment) {
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
  
    //-------------MAIN NODE ADD & REMOVE----------------
  Node addHashtagNode(String hashtag, float theR, float theAngle) {
    // check if the node is already there
    MainNode findNode = (MainNode) nodeMap.get(hashtag);
    float[] points = GenerativeDesign.polarToCartesian(theR, theAngle);
    //IF it isn't add it
    if (findNode == null) {
      MainNode newNode = new MainNode(this, points[0], points[1], true);
      newNode.setID(hashtag);
      newNode.numConnections++;
      //Add Node Details to HashMap
      nodeMap.put(hashtag, newNode);
     // addSpringToCircle(hashtag, points[0], points[1]);
      return newNode;
    } else {
      findNode.numConnections++;
      findNode.nodeStrength--;
      return null;
    }
  }





  Spring addSpring(String fromID, String toID) {
    MainNode fromNode, toNode; 
    fromNode = (MainNode) nodeMap.get(fromID);
    toNode = (MainNode) nodeMap.get(toID);

    // if one of the nodes do not exist, stop creating spring
    if (fromNode==null) return null;
    if (toNode==null) return null;

    if (getSpring(fromNode, toNode) == null) {
      // create a new spring
      Spring newSpring = new Spring(fromNode, toNode, springLength, springStiffness, 0.9);
      springs.add(newSpring);
      return newSpring;
    }

    return null;
  }
  
    Spring addWeakSpring(String fromID, String toID) {
    MainNode fromNode, toNode; 
    fromNode = (MainNode) nodeMap.get(fromID);
    toNode = (MainNode) nodeMap.get(toID);

    // if one of the nodes do not exist, stop creating spring
    if (fromNode==null) return null;
    if (toNode==null) return null;

    if (getSpring(fromNode, toNode) == null) {
      // create a new spring
      Spring newSpring = new Spring(fromNode, toNode, springLength, 0, 0.9);
      springs.add(newSpring);
      return newSpring;
    }

    return null;
  }



  Spring addSpringToCenter(String id) {
    MainNode node;
    node = (MainNode) nodeMap.get(id);

    if (node==null) return null;

    if (getSpring(node, dummyCenterNode) ==null) {
      Spring newSpring = new Spring(node, dummyCenterNode, springLength, springStiffness, 0.9);
      springs.add(newSpring);
      return newSpring;
    }

    return null;
  }
  
   Spring addSpringToCircle(String id, float rad, float theta) {
    MainNode node;
    node = (MainNode) nodeMap.get(id);
    PVector polar = new PVector(rad, theta);
    PVector carte = GenerativeDesign.polarToCartesian(polar);
    Node anchor = new Node(carte);
    if (node==null) return null;

    if (getSpring(node, anchor) ==null) {
      Spring newSpring = new Spring(node, anchor, rad, springStiffness, 0.9);
      springs.add(newSpring);
      return newSpring;
    }

    return null;
  }




  ///REMOVE NODE

  void removeNode(Node theNode) {
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

  Node getNodeByID(String theID) {
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

  int getSpringIndexByNode(Node theNode) {
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s.fromNode == theNode || s.toNode == theNode) {
        return i;
      }
    }
    return -1;
  }

  Spring getSpring(Node theFromNode, Node theToNode) {
    for (int i = 0; i < springs.size(); i++) {
      Spring s = (Spring) springs.get(i);
      if (s.fromNode == theFromNode && s.toNode == theToNode) {
        return s;
      }
    }
    return null;
  }


  float getZoom() {
    return targetZoom;
  }
  void setZoom(float theZoom) {
    targetZoom = theZoom;
  }

  PVector getOffset() {
    return new PVector(offset.x, offset.y);
  }

  void setOffset(float theOffsetX, float theOffsetY) {
    offset.x = theOffsetX; 
    offset.y = theOffsetY; 
    targetOffset.x = offset.x; 
    targetOffset.y = offset.y;
  }

  Node getLoadingNode() {
    return loadingNode;
  }
  void setLoadingNode(Node theNode) {
    loadingNode = theNode;
  }
  boolean isLoading(Node theNode) {
    if (theNode == loadingNode) return true;
    return false;
  }

  boolean isRollover(Node theNode) {
    if (theNode == rolloverNode) return true;
    return false;
  }
  boolean isRolloverNeighbour(Node theNode) {
    if (getSpring(theNode, rolloverNode) != null) return true;
    if (getSpring(rolloverNode, theNode) != null) return true;
    return false;
  }

  boolean isSelected(Node theNode) {
    if (theNode == selectedNode) return true;
    return false;
  }

  int getMillis() {
    if (freezeTime) {
      return pMillis;
    }
    return millis();
  }



  PVector screenPos(PVector thePos) {
    return new PVector(thePos.x, thePos.y, 1);
  }

  PVector localToGlobal(float theX, float theY) {
    float mx = (theX+offset.x)*zoom+width/2;
    float my = (theY+offset.y)*zoom+height/2;

    return new PVector(mx, my);
  }

  PVector globalToLocal(float theX, float theY) {
    float mx = (theX-width/2)/zoom-offset.x;
    float my = (theY-height/2)/zoom-offset.y;

    return new PVector(mx, my);
  }



  String toString() {
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
  void update() {
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


  void draw() {
    int dt = 0;
    if (!freezeTime) {
      int m = millis();
      dt = m - pMillis;    
      pMillis = m;
    }

    // smooth movement of canvas
    PVector d = new PVector();

    float accomplishPerSecond = 0.95;
    float f = pow(1/(1-accomplishPerSecond), -dt/1000.0);

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
      MainNode from = (MainNode) s.getFromNode();
      stroke(from.ranCol);
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
      node.drawLabel();
      
      if(node.lifeTime==0){node.triggerFadeOut();}
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

  void removeNodes() {
    Iterator iter = nodeMap.entrySet().iterator();

    iter = nodeMap.entrySet().iterator();
    while (iter.hasNext ()) {
      Map.Entry me = (Map.Entry) iter.next();

      MainNode node = (MainNode) me.getValue();
      removeNode(node);
    }
  }

  void displayLabels() {
    Iterator iter = nodeMap.entrySet().iterator();

    iter = nodeMap.entrySet().iterator();
    while (iter.hasNext ()) {
      Map.Entry me = (Map.Entry) iter.next();

      MainNode node = (MainNode) me.getValue();
      node.labelFlag = !node.labelFlag;
    }
  }

  void drawCenter() {

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
  
  void drawArrow(MainNode n1, MainNode n2) {

    PVector d = new PVector(n2.x - n1.x, n2.y - n1.y);
    float margin1 = n1.diameter/2.0 + 3 + lineWeight/2;
    float margin2 = n2.diameter/2.0 + 3 + lineWeight/2;

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


  float getWidth() {
    return 1;
  }
}