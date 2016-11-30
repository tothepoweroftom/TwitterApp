class Tweet {
  color sentiment;
  String user;
  String text;

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
        wr.write("txt=hello and what happens if I put a full tweet? great if it works!"); //ezm is my JSON object containing the api commands
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
        println("The server response is " + response);
        String resp = response.toString();
        if (resp.contains("Positive")) {
          result = color(0, 255, 0);
        }
        if (resp.contains("Negative")) {
          result = color(255, 0, 0);
        }
        if (resp.contains("Neutral")) {
          result = color(255);
        }
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
}