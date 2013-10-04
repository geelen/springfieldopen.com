Bundler.require

class EpisodeLoader

	def self.reddit_hash
		subreddit = "SpringfieldOpenEps"
		url = "http://www.reddit.com/r/#{subreddit}.json"
		response = HTTParty.get(url + "?limit=100")
		full_episode_details = response['data']['children'].map { |child| child['data'] }
		last_id = (full_episode_details.empty?) ? nil : full_episode_details[-1]['name']
		while last_id
			response = HTTParty.get(url + "?limit=100&after=#{last_id}")
			new_episode_details = response['data']['children'].map { |child| child['data'] }
			last_id = (new_episode_details.empty?) ? nil : new_episode_details[-1]['name']
			full_episode_details += new_episode_details
		end
		Hash[full_episode_details.map { |ep| [ep['title'].gsub("&amp;","&"), ep['name']] }]
	end

	def self.local_imdb_list
		full_hash = JSON.parse(File.read("data/episodes.json"))
		full_hash.map { |ep| "#{ep['season']}.#{ep['episode']} #{ep['title']}" } 
	end

end