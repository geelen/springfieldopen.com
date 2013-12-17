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
response = poster.post("Round #{round+1} Matches","")
puts JSON.pretty_generate(response)
round_post_name = response['json']['data']['name']

get_battles(episodes).each_with_index do |battle,i|
	text = "Battle #{i+1}"
	response = poster.comment(round_post_name,text)
	puts JSON.pretty_generate(response)
	battle_comment_name = response['json']['data']['things'][0]['data']['name']
	battle1 = battle[0].flatten
	response = poster.comment(battle_comment_name,battle1[1] + "\n" + battle1[2] + "\n" + battle1[0])
	puts JSON.pretty_generate(response)
	battle2 = battle[1].flatten
	response = poster.comment(battle_comment_name,battle2[1] + "\n" + battle2[2] + "\n" + battle2[0])
	puts JSON.pretty_generate(response)
end

