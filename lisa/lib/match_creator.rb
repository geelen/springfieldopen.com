class MatchCreator

	def initialize reddit_poster, round_name, ep_subreddit
		@reddit_poster = reddit_poster
		@round_name = round_name
		@ep_url = "http://www.reddit.com/r/#{ep_subreddit}/"
	end

	def create_matches matches
		matches.each_with_index { |match,i|
			match_name = create_match_comment(i)
			create_episode_comment(match[0],match_name)
			update_episode_selftext(match[0],match_name)
			create_episode_comment(match[1],match_name)
			update_episode_selftext(match[1],match_name)
		}
	end

	private

	def create_match_comment i
		data = {title: "Battle #{i+1}", final_score: "NA"}
		response = @reddit_poster.comment(@round_name,data)
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
		response = HTTParty.get(@ep_url + "/comments/#{episode['id']}.json")
		fresh_episode = response[0]['data']['children'][0]['data']
		episode_data = JSON.parse(fresh_episode['selftext'])
		episode_data['matches'] << match_name
		@reddit_poster.replace_text(episode['name'],episode_data)
	end
end