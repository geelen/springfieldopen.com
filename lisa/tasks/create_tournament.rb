Bundler.require
require File.dirname(__FILE__) + '/../lib/reddit_poster.rb'
require File.dirname(__FILE__) + '/../lib/tournament_creator.rb'
require File.dirname(__FILE__) + '/../lib/match_creator.rb'
Dotenv.load

subreddit = "SpringfieldOpen"
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,subreddit)
episodes = JSON.parse(File.read("data/staging/episode_lineups.json"))

tournament_creator = TournamentCreator.new(poster,episodes)
tournament_creator.run
matches = tournament_creator.round_one_matches
round_name = tournament_creator.round_one_name

match_creator = MatchCreator.new(poster,round_name,matches)
match_creator.run

