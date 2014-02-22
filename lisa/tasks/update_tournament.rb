require 'bundler'
Bundler.require
require_relative '../lib/reddit_poster'
require_relative '../lib/tournament_manager'
require_relative '../lib/lisa_config'
Dotenv.load

config = LisaConfig.from_argv(ARGV)
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,config.subreddit)
manager = TournamentManager.new(config,poster)
manager.perform_update_if_its_time
manager.close_log
