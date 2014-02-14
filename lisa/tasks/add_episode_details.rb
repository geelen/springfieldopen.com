Bundler.require

require_relative '../lib/episode_loader'
require_relative '../lib/reddit_poster'
require 'yaml'
Dotenv.load

subreddit = "SpringfieldOpenEps"
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,subreddit)
# response = poster.get_user
# p response
# puts JSON.pretty_generate(response)
episodes = EpisodeLoader.reddit_hash
episode_details = JSON.parse(File.read("data/wikia_episodes.json"))
details_hash = Hash[episode_details.map { |ep|
	["#{ep['season']}.#{ep['episode']}", ep]
}]

# ["12.18 Trilogy of Error"].each do |title|
episodes.keys.each do |ep_id|
	if details_hash.has_key?(ep_id)
		details = details_hash[ep_id]
    #puts episodes[ep_id]['name']
    #puts JSON.pretty_generate(details).gsub(/^/,"    ")
    response = poster.replace_text(episodes[ep_id]['name'], JSON.pretty_generate(details).gsub(/^/,"    "))
		#p response
    puts JSON.pretty_generate(response)
	else
		puts ("COULD NOT FIND EPISODE: " + title)
	end
end
