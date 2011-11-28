class Profile
  PROFILE_REGEXP = /@?([a-z_]*)/

   @@instances = []

  attr_reader :name
  attr_accessor :tweets


  def self.find_or_create(profile_string)
    @@instances.each do |instance|
      if instance.name == profile_string.match(PROFILE_REGEXP)[1]
        return instance
      end
    end 
    Profile.new(profile_string)
  end

  def store!
    @@instances << self unless @@instances.include?(self)
  end


  def eql? other
    other.kind_of?(self.class) && self.name == other.name
  end

  def hash
    self.name.hash
  end

  def ==(profile)
    self.name == profile.name
  end

  def <=>(profile)
    self.name <=> profile.name
  end

  def tweets
    @tweets ||= 0
  end

  def reciters
    @reciters  ||= []
  end

  def mentions
    @mentions ||= []
  end


  def recited_by!(reciter)
    self.reciters << reciter unless self.reciters.any? { |profile| profile == reciter }
    self.friends = (mentions & reciters)
  end

  def mention!(target)
    self.mentions << target unless self.mentions.any? { |profile| profile == target }
    self.friends = (mentions & reciters)
  end

  def friends=(friends)
    @friends = friends
  end


  def friends
    @friends ||= []
  end


  private 

  def initialize(profile)
    @name = profile.match(PROFILE_REGEXP)[1]
    self.store!
  end

end

class TweetStreamAnalysis

  def tweets
    @tweets ||= []
  end

  def initialize(stream)
    stream.each_line do |tweet|
      tweet = TweetParser.parse!(tweet.strip)
      tweets << tweet
    end
    retrieve_all_profiles!
  end

  def profiles
    @profiles ||= []
  end
  def profiles=(profiles)
    @profiles = [profiles].flatten
  end

  def active_profiles
    profiles.reject { |profile| profile.tweets == 0 }
  end

  def build_friend_degrees_for(profile)
    friend_degree_list = []
    parent_list = [profile]
    begin
      friend_list = parent_list.collect(&:friends).flatten.uniq.reject { |f| parent_list.include?(f) }
      friend_degree_list.push([friend_list.sort { |a,b| a <=> b }])
      parent_list = (parent_list + friend_list).flatten
    end while !friend_list.empty?
    friend_degree_list
  end

  def to_s
    output = ""
    active_profiles.each do |profile|
      output << "#{profile.name}\n"
      friend_degrees_list = build_friend_degrees_for(profile)
      friend_degrees_list.each do |friend_list|
        unless friend_list.flatten.empty?
          output << "#{friend_list.flatten!.collect(&:name).join(', ')}\n" 
        end
      end
      output << "\n" unless profile == active_profiles.last
    end
    output
  end

  private

  def retrieve_all_profiles!
    profiles = []
    tweets.each do |tweet|
      profiles.push(tweet.source) unless profiles.any? { |profile| profile == tweet.source }
      tweet.mentions.each do |profile|
        profiles.push(profile) unless profiles.any? { |prof| prof == profile }
      end
    end
    profiles.sort! { |a,b| a <=> b }
    self.profiles = profiles
  end

  
end

class TweetParser

  class InvalidTweetFormat < StandardError; end

  attr_reader :mentions, :source, :tweet

  MENTION_REGEXP = /@[a-z_]*/
  SOURCE_REGEXP = /^([a-z_]*):/

  def mentions
    @mentions ||= []
  end


  def self.parse!(tweet)
    source = tweet.match(SOURCE_REGEXP)[1] rescue (raise InvalidTweetFormat, "It must be on the format: 'source_profile: message'")
    source = Profile.find_or_create(source)

    mentions = tweet.scan(MENTION_REGEXP)
    mentions.map! { |profile| Profile.find_or_create(profile) }
    new(source,mentions, tweet)
  end

  def initialize(source,mentions, tweet)
    @source = source
    @source.tweets += 1
    @mentions = mentions
    @mentions.each do |profile|
      @source.mention!(profile)
      profile.recited_by!(source)
    end
  end

end


