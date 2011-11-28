require 'twitter_stream'

describe TweetParser do

  it "should extract the informations about source of a tweet" do
    tweet = "guilherme: hello @alvares, how are you?" 
    TweetParser.parse!(tweet).source.name.should == "guilherme"
  end
  it "should extract the informations about mentions of a tweet" do
    tweet = "guilherme: hello @alvares, do you know @fmorais?" 
    TweetParser.parse!(tweet).mentions.map { |m| m.name }.should == ["alvares","fmorais"]
  end

end

describe Profile do

  context "initialization" do
    it "should have one instance of profile characterized by name" do
      profile = Profile.find_or_create("guilherme")
      Profile.find_or_create("guilherme").should == profile
    end
    it "should initialize from a string containing his name" do
      Profile.find_or_create("guilherme").name.should == "guilherme"
    end
    it "should initialize from a string containing his name, if @ is present remove it" do
      Profile.find_or_create("@guilherme").name.should == "guilherme"
    end
  end


end


describe TweetStreamAnalysis do

  it "should analyze a stream of tweets and retrieve the profiles involved on alphabetic order"  do
    tweet = "guilherme: hello @fmorais, how are you?\n" 
    tweet2 = "alvares: @jonas, fine and you?" 
    stream = "#{tweet}#{tweet2}"
    @analysis = TweetStreamAnalysis.new(stream)
    @analysis.active_profiles.collect(&:name).should == ["alvares","guilherme"]
  end

  it "should analyze a stream of tweets and print the ouput with networks"  do
    tweet = "guilherme: hello @alvares, how are you?\n" 
    tweet2 = "alvares: @guilherme, fine and you?\n" 
    stream = "#{tweet}#{tweet2}"
    @analysis = TweetStreamAnalysis.new(stream)
    Profile.find_or_create("alvares").friends.should == [Profile.find_or_create("guilherme")]
  end

end
