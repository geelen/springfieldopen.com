class TournamentCreator

	def initialize reddit_poster, episodes
		@reddit_poster = reddit_poster
		@episodes = episodes
		@num_rounds = episodes.first["lineup"].length
	end

	def run
		puts "Clearing subreddit..."
		clear_subreddit
		puts "Creating rounds..."
		create_rounds
		puts "Creating round one matches..."
		create_round_one_matches
	end

	private

	def clear_subreddit
		@reddit_poster.clear_subreddit
	end

	def create_rounds
		1.upto(@num_rounds) { |r|
			if r == 1
				response = @reddit_poster.post("Round #{r} Matches",{status: "open"})
				@round_one_name = response['json']['data']['name']
			else
				@reddit_poster.post("Round #{r} Matches",{status: "pending"})
			end
		}
	end

	def create_round_one_matches
		round_one_matches.each_with_index { |match,i|
			match_name = create_match_comment(i)
			create_episode_comment(match[0],match_name)
			update_episode_selftext(match[0],match_name)
			create_episode_comment(match[1],match_name)
			update_episode_selftext(match[1],match_name)
		}
	end

	def create_match_comment i
		data = {title: "Battle #{i+1}", final_score: "NA"}
		response = @reddit_poster.comment(@round_one_name,data)
		response['json']['data']['things'][0]['data']['name']
	end

	def create_episode_comment episode, match_name
		episode_data = JSON.parse(episode['selftext'])
		title = "#{episode_data['season']}.#{episode_data['episode']} #{episode_data['title']}"
		data = {
			name: episode['name'],
			title: title,
			image: episode_data["images"].first
		}
		@reddit_poster.comment(match_name,data)
	end

	def update_episode_selftext episode, match_name
		episode_data = JSON.parse(episode['selftext'])
		episode_data['battles'] = [match_name]
		@reddit_poster.replace_text(episode['name'],episode_data)
	end

	def round_one_matches
		return @round_one_matches if @round_one_matches
		ep_pairs = @episodes.group_by { |ep| ep["lineup"].first }.values
		@round_one_matches = ep_pairs.map { |pair|
			pair.map { |ep| ep["data"] }
		}
	end
end