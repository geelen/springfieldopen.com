Bundler.require
require './reddit_poster.rb'
Dotenv.load

def get_battles episodes
	battles = episodes.group_by { |ep| ep[1][0] }.values
	battles.map { |battle|
		battle.length == 2 ? [battle[0][0],battle[1][0]] : nil
	}.compact
end

subreddit = "SpringfieldOpen"
round = 0
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,subreddit)
episodes = JSON.parse(File.read("data/episode_lineups#{round}.json"))

get_battles(episodes).each_with_index do |battle,i|
	response = poster.post("Battle #{round+1}-#{i+1}","Test battle.")
	puts JSON.pretty_generate(response)
	post_name = response['json']['data']['name']
	response = poster.comment(post_name,battle[0][0] + "\n" + battle[0][1])
	puts JSON.pretty_generate(response)
	response = poster.comment(post_name,battle[1][0] + "\n" + battle[1][1])
	puts JSON.pretty_generate(response)
end

