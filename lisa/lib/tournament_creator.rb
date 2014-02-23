class TournamentCreator

	def initialize reddit_poster, episodes
		@reddit_poster = reddit_poster
		@episodes = episodes
		@num_rounds = episodes.first["lineup"].length
	end

	def round_one_matches
		return @round_one_matches if @round_one_matches
		ep_pairs = @episodes.group_by { |ep| ep["lineup"].first }.values
		@round_one_matches = ep_pairs.map { |pair|
			pair.map { |ep| ep["data"] }
		}
	end

	def round_one_name
		return @round_one_name if @round_one_name
		run
		@round_one_name
	end

	def clear_subreddit
		@reddit_poster.clear_subreddit
	end

	def create_rounds tournament_start, round_duration, round_gap
		1.upto(@num_rounds) { |r|
			start_time = tournament_start + round_duration*(r-1)
			end_time = start_time + round_duration - round_gap
			if r == 1
				data = {status: "open", start_time: start_time, end_time: end_time}
				response = @reddit_poster.post("Round #{r} Matches", data)
				@round_one_name = response['json']['data']['name']
			else
				data = {status: "pending", start_time: start_time, end_time: end_time}
				@reddit_poster.post("Round #{r} Matches", data)
			end
		}
	end

	def clear_episode_matches
		@episodes.each { |episode| 
			episode_data = JSON.parse(episode['data']['selftext'])
			episode_data.delete('battles')
			episode_data['matches'] = []
			@reddit_poster.replace_text(episode['data']['name'],episode_data)
		}
	end

end