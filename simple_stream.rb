
require 'twitter_stream'
stream = %{alberta: @bob "It is remarkable, the character of the pleasure we derive from the best books."
  bob: "They impress us ever with the conviction that one nature wrote and the same reads." /cc @alberta
  alberta: hey @christie. what will we be reading at the book club meeting tonight?
  christie: 'Every day, men and women, conversing, beholding and beholden.' /cc @alberta, @bob
  bob: @duncan, @christie so I see it is Emerson tonight
  duncan: We'll also discuss Emerson's friendship with Walt Whitman /cc @bob
  alberta: @duncan, hope you're bringing those peanut butter chocolate cookies again :D
  emily: Unfortunately, I won't be able to make it this time /cc @duncan
  duncan: @emily, oh what a pity. I'll fill you in next week.
  christie: @emily, "Books are the best of things, well used; abused, among the worst." -- Emerson
  emily: Ain't that the truth ... /cc @christie
  duncan: hey @farid, can you pick up some of those cookies on your way home?
  farid: @duncan, might have to work late tonight, but I'll try and get away if I can}

puts TweetStreamAnalysis.new(stream).to_s