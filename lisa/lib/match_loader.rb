class MatchLoader

	def initialize subreddit
		@base_url = "http://www.reddit.com/r/#{subreddit}" 
		reload_rounds
	end

	def reload_rounds
		response = HTTParty.get(@base_url + "/new.json")
		@rounds = response['data']['children'].map { |r| r['data'] }
	end

	def open_round
		@rounds[index_of_open_round]
	end

	def upcoming_round
		(index_of_open_round > 0) ? @rounds[index_of_open_round-1] : nil
	end

	def open_matches
		puts "Open Round is '#{open_round['title']}'."
		url = @base_url + "/comments/#{open_round['id']}.json"
		response = HTTParty.get(url)
		response.last['data']['children'].map { |m| 
			m['data']['replies']['data']['children'].map { |ep| ep['data'] } 
		}
	end

	private

	def index_of_open_round 
		@rounds.find_index { |round| round['selftext'] == 'open' }
	end

end
