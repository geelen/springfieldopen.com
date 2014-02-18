Bundler.require
# require File.dirname(__FILE__) + '/../lib/reddit_poster.rb'
require File.dirname(__FILE__) + '/../lib/match_loader.rb'
Dotenv.load

subreddit = 'SpringfieldOpen'
match_loader = MatchLoader.new(subreddit)

# close round
p match_loader.open_round['title']

# store final scores in body of each match comment...
# ...and select winner of each match
matches = match_loader.open_matches
p matches.map { |match|
	eps = match.map { |ep| 
		{ body: ep['body'].split("\n").last, score: ep['ups']-ep['downs'] }
	}
	p eps
	if eps[0][:score] > eps[1][:score]
		eps[0]
	elsif eps[0][:score] < eps[1][:score]
		eps[1]
	else
		nil
	end
}

# open next round
p match_loader.upcoming_round['title']

# post comments for new matches

