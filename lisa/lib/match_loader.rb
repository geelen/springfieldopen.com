class MatchLoader

	def self.get_open_round subreddit
		response = HTTParty.get(self.base_url(subreddit) + ".json?limit=100")
		rounds = response['data']['children'].map { |r| r['data'] }
		rounds.select { |r| r['selftext'] == 'open' }.first
	end

	def self.load_open_matches subreddit
		open_round = self.get_open_round(subreddit)
		puts "Open Round is '#{open_round['title']}'."
		url = base_url(subreddit) + "/comments/#{open_round['id']}.json"
		response = HTTParty.get(url)
		response.last['data']['children'].map { |m| 
			m['data']['replies']['data']['children'].map { |ep| ep['data'] } 
		}
	end

	private

	def self.base_url subreddit
		"http://www.reddit.com/r/#{subreddit}"
	end
end
