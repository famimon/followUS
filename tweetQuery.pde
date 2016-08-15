class tweetQuery extends Thread {
  // Twitter handler
  Twitter twitter; 
  boolean running;           // Is the thread running?  Yes or no?
  int wait;                  // How many milliseconds should we wait in between executions?
  String id;                 // Thread name
  String[] hashtags;
  int rpp;                    // Number of tweets per query
  
  // Constructor, create the thread
  // It is not running by default
  tweetQuery (int w, String s, String[] h, int r) {
    //Credentials
    ConfigurationBuilder cb = new ConfigurationBuilder();
    cb.setOAuthConsumerKey("QKsoFYpGIt5nwf0cUkJiA");
    cb.setOAuthConsumerSecret("bK9tOUJp0PzajnJlPiv6ePOXo5c6hZ2Zxqnq9Luw");
    cb.setOAuthAccessToken("419039639-BmkFda7iarnvJ6ZHVhOBJgNcukaXZ7CykiX8BZpB");
    cb.setOAuthAccessTokenSecret("t7hLGtRFeTjhHlXNmDE9mHgwPsTYsJXvIoDQHKao");

    //Make the twitter object and prepare the queries, 3 queries per "round"
    twitter = new TwitterFactory(cb.build()).getInstance();
    
    wait = w;
    running = false;
    id = s;
    hashtags = h;
    rpp=r;
  }

  // Overriding "start()"
  void start () {
    // Set running equal to true
    running = true;
    // Print messages
    println("Starting thread (will execute every " + wait + " milliseconds.)"); 
    // Do whatever start does in Thread, don't forget this!
    super.start();
  }


  // We must implement run, this gets triggered by start()
  void run () {
    while (running) {
      for (int i=0; i<3; i++) {
        doQuery(hashtags[i], hashCloud,i+1);
        }  
        doQuery("#followus", followCloud,0);
      // Ok, let's wait for however long we should wait
      try {
        sleep((long)(wait));
      } 
      catch (Exception e) {
      }
    }
    System.out.println(id + " thread is done!");  // The thread is done when we get to the end of run()
  }

  void doQuery(String h, tweetCloud tc, int type) {
    Query query = new Query(h);
    query.setRpp(rpp);
    
      for (int i=0; i<rpp && i<getQuery(query).size();i++)
        tc.updateTweets((Tweet) getQuery(query).get(i),type);
    
  }

  // Our method that quits the thread
  void quit() {
    System.out.println("Quitting."); 
    running = false;  // Setting running to false ends the loop in run()
    // IUn case the thread is waiting. . .
    interrupt();
  }
  
  
  ArrayList getQuery(Query q) {
    ArrayList tweets = new ArrayList();
    //Try making the query request.
    try {
      QueryResult result = twitter.search(q);
      tweets = (ArrayList) result.getTweets();
    } 
    catch (TwitterException te) {
      println("Couldn't connect: " + te);
    };
    return tweets;
  }
  
}

