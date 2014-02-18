Bundler.require
require File.dirname(__FILE__) + '/../lib/reddit_poster.rb'
require File.dirname(__FILE__) + '/../lib/match_loader.rb'
require File.dirname(__FILE__) + '/../lib/tournament_updater.rb'
require File.dirname(__FILE__) + '/../lib/match_creator.rb'
Dotenv.load

subreddit = 'SpringfieldOpen'
match_loader = MatchLoader.new(subreddit)
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,subreddit)
episodes = JSON.parse(File.read("data/staging/episode_lineups.json"))

tournament_updater = TournamentUpdater.new(match_loader,poster)
tournament_updater.run
matches = tournament_updater.new_matches(episodes)
round_name = tournament_updater.upcoming_round_name

match_creator = MatchCreator.new(poster,round_name,matches)
match_creator.run

tournament_updater.start_new_round
