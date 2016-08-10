class TwitterService

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "NQR9RNYRmJ8SSRxAMVZ93HZ8r"
      config.consumer_secret     = "vCMNMYn9MyLJbu0upHateqlDaRomE5FwJZKPiIoVqntsYUFBdK"
      config.access_token        = "265230007-K8r0hKO932KwoGNsNAtC7AC6FaTsgb3gVnfEyP3R"
      config.access_token_secret = "sKDZSXy7vxCZ1JiMJ2GhNsDcwykY44SCjhz1VhJINojLE"
    end
  end


  def calculate_best_tweet_time(username)
    tweet_hash = initialize_hash_for_tweet_count
    user_ids = fetch_follower_ids(username)
    tweets = get_tweets(user_ids)
    populate_hash_for_relevant_tweets(tweet_hash, tweets, Time.zone.now - 7.days, Time.zone.now)
  end

  def populate_hash_for_relevant_tweets(tweet_hash, tweets, from_time, to_time)

    tweets.each do |tweet|
      created_at = Time.parse(tweet.attrs[:created_at])
      if created_at > from_time && created_at <= to_time
        hour = created_at.hour
        day = created_at.wday
        tweet_hash['day'][day] += 1
        tweet_hash['hour'][hour] += 1
      end
    end

    #Rails.logger.info "#{calculate_best_day_to_post(tweet_hash)}  #{calculate_best_time_to_post(tweet_hash)}"
    return calculate_best_day_to_post(tweet_hash), calculate_best_time_to_post(tweet_hash)
  end

  def calculate_best_time_to_post(tweet_hash)
    Date::DAYNAMES[tweet_hash['day'].max_by{|k,v| v}[0]]
  end

  def calculate_best_day_to_post(tweet_hash)
    tweet_hash['hour'].max_by{|k,v| v}[0].to_s + " o'clock"
  end

  def get_tweets(user_ids = [])
    options = {count: 200}
    tweets = []
    user_ids.each do |id|
      begin
        tweets << @client.user_timeline(id, options)
      rescue Twitter::Error::TooManyRequests => error
        Rails.logger.info "Too Many Requests: Failed for user_id: #{id}"
      end
    end
  end

  def fetch_follower_ids(username, count = 10)
    @client.follower_ids(username).to_a[0..count]
  end

  def initialize_hash_for_tweet_count
    tweet_hash = {}
    tweet_hash['day'] = {}
    tweet_hash['hour'] = {}
    (0..23).to_a.each {|i| tweet_hash['hour'][i] = 0 }
    (0..6).to_a.each {|i| tweet_hash['day'][i] = 0 }
    tweet_hash
  end
end
