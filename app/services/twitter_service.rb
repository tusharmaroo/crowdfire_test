class TwitterService

  def initialize
    @client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ""
      config.consumer_secret     = ""
      config.access_token        = ""
      config.access_token_secret = ""
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
    # Fallback included if nothing is found
    Date::DAYNAMES[tweet_hash['day'].max_by{|k,v| v}[0] || Time.zone.now.wday]
  end

  def calculate_best_day_to_post(tweet_hash)
    # Fallback included if nothing is found
    (tweet_hash['hour'].max_by{|k,v| v}[0] || Time.zone.now.hour).to_s + " o'clock"
  end

  def get_tweets(user_ids = [])
    options = {count: 200}
    tweets = []
    user_ids.each do |id|
      begin
        @client.user_timeline(id, options).each { |tweet| tweets << tweet }
      rescue Twitter::Error::TooManyRequests => error
        Rails.logger.info "Too Many Requests: Failed for user_id: #{id}"
      end
    end
    return tweets
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
