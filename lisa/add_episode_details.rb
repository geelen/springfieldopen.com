Bundler.require
require './episode_loader.rb'
require './reddit_poster.rb'
Dotenv.load

subreddit = "SpringfieldOpenEps"
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,subreddit)
episodes = EpisodeLoader.reddit_hash
episode_details = JSON.parse(File.read("data/wikia_episodes.json"))
details_hash = episode_details.group_by { |ep| 
	"#{ep['season']}.#{ep['episode']}" 
}

episodes.keys.each do |title|
	ep_id = title.split(" ")[0]
	if details_hash.has_key?(ep_id)
		details = details_hash[ep_id][0]
		text = details['images'].join(" ")
		text += "\n" + (details['synopsis_needs_attention'] ? "review" : "good")
		text += "\n" + details['synopsis']
	  response = poster.replace_text(episodes[title],text)
	  p response
	  # puts JSON.pretty_generate(response)
	else
		puts ("COULD NOT FIND EPISODE: " + title)
	end
end
