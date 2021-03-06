class EpisodeLoader

	def self.reddit_hash
		subreddit = "SpringfieldOpenEps"
		url = "http://www.reddit.com/r/#{subreddit}.json"

    response = HTTParty.get(url + "?limit=100")
    puts "Loading Episodes"
    print "."

		full_episode_details = response['data']['children'].map { |child| child['data'] }
		last_id = (full_episode_details.empty?) ? nil : full_episode_details[-1]['name']
		while last_id
			response = HTTParty.get(url + "?limit=100&after=#{last_id}")
      print "."
			new_episode_details = response['data']['children'].map { |child| child['data'] }
			last_id = (new_episode_details.empty?) ? nil : new_episode_details[-1]['name']
			full_episode_details += new_episode_details
    end

    puts
		Hash[full_episode_details.map { |ep|
			season_dot_episode = ep['title'][/\d+\.\d+/]
      [season_dot_episode, ep]
		}]
	end

	def self.episode_keys_by_imdb_ranking
		full_hash = JSON.parse(File.read(File.dirname(__FILE__) + "/../data/episodes.json"))
		full_hash.map { |ep| "#{ep['season']}.#{ep['episode']}" }
	end

end
