Bundler.require
require File.dirname(__FILE__) + '/../lib/reddit_poster.rb'
require File.dirname(__FILE__) + '/../lib/match_loader.rb'
require File.dirname(__FILE__) + '/../lib/tournament_updater.rb'
Dotenv.load

subreddit = 'SpringfieldOpen'
match_loader = MatchLoader.new(subreddit)
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,subreddit)
tournament_updater = TournamentUpdater.new(match_loader,poster)
tournament_updater.run

