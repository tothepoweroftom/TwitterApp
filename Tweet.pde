class Tweet {
  color sentiment;
  String user;
  String text;
  int count = 0;
  Tweet (String userName, String tweetText) {
    sentiment = getColor();
    user = userName;
    text = tweetText;
  }

  color getColor () {
    color result = color(255);
    //put code to retrieve sentiment

    URL url = null;
    try
    {
      url = new URL("http://sentiment.vivekn.com/api/text/");
    }
    catch (MalformedURLException ex)
    {
      println("Url fejler");
    }
    if (url == null)
    {
      print("url øv");
    }

    try {
      conn = (HttpURLConnection) url.openConnection();
      try {
        conn.setRequestMethod("POST"); //use post method
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setRequestProperty("Accept", "application/json");
        conn.setDoOutput(true); //we will send stuff

        OutputStreamWriter wr = new OutputStreamWriter(conn.getOutputStream());
        wr.write("txt=" + text); //ezm is my JSON object containing the api commands
        wr.flush();
        wr.close();
      } 
      catch (ProtocolException e) {
        println("æv");
      }

      // Open a stream which can read the server response*********************************

      InputStream in = conn.getInputStream();

      BufferedReader rd = null;

      try {

        rd = new BufferedReader(new InputStreamReader(in));
        String responseSingle = null;

        while ((responseSingle = rd.readLine()) != null) {
          response.append(responseSingle);
        }
        //println("The server response is " + response);
        String resp = response.toString();
        if (resp.contains("Positive")) {
          pushMatrix();
          result = this.positive();
          popMatrix();
        }
        if (resp.contains("Negative")) {
          pushMatrix();
          result = this.negative();
          popMatrix();
        }
        if (resp.contains("Neutral")) {
          pushMatrix();
          result = this.neutral();
          popMatrix();
        }
        response.setLength(0);
      }
      catch (IOException e) {
        println("hm");
      }
      finally {  //in this case, we are ensured to close the input stream
        if (in != null)
          in.close();
      }
    }
    catch (IOException e) {
    } 
    finally {  //in this case, we are ensured to close the connection itself
    }

    return result;
  }

  color positive() {
    float hue, sat, bright;
    colorMode(HSB, 255);

    //for positive tweets
    hue = random(90, 110);
    sat = random(100, 200);
    bright = 50 + hue;

    return color(hue, sat, bright);
  } 

  color negative() {
    float hue, sat, bright;
    colorMode(HSB, 255);
    //for negative tweets
    hue = random(-18, 20);
    bright = 200 + abs(hue);
    sat = random(100, 255);
    if (hue<0) { 
      hue = 255 + hue;
    };
    return color(hue, sat, bright);
  }

  color neutral() {
    float hue, sat, bright;
    colorMode(HSB, 255);
    //for neutral tweets
    hue = random(20, 120);
    sat = random(0, 70);
    bright = 200;
    return color(hue, sat, bright);
  }
}