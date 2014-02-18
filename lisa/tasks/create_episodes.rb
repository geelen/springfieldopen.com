Bundler.require
require File.dirname(__FILE__) + '/../lib/episode_loader.rb'
require File.dirname(__FILE__) + '/../lib/reddit_poster.rb'
Dotenv.load

subreddit = "SpringfieldOpenEps"
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,subreddit)

existing_eps = EpisodeLoader.reddit_hash.keys
all_episodes = EpisodeLoader.local_imdb_list

episodes = all_episodes - existing_eps

episodes.each do |title|
  response = poster.post(title,{})
  puts JSON.pretty_generate(response)
end
