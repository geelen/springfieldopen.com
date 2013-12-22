Bundler.require
require './episode_loader.rb'
require './reddit_poster.rb'
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
details_hash = episode_details.group_by { |ep| 
	"#{ep['season']}.#{ep['episode']}" 
}

# ["12.18 Trilogy of Error"].each do |title|
episodes.keys.each do |title|
	ep_id = title.split(" ")[0]
	if details_hash.has_key?(ep_id)
		details = details_hash[ep_id][0]
		# p details.to_yaml
		response = poster.replace_text(episodes[title][0],details.to_yaml)
		p response
	  # puts JSON.pretty_generate(response)
	else
		puts ("COULD NOT FIND EPISODE: " + title)
	end
end
