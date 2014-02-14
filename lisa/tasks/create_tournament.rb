Bundler.require
require File.dirname(__FILE__) + '/../lib/reddit_poster.rb'
Dotenv.load

def get_battles episodes
	battles = episodes.group_by { |ep| ep[1][0] }.values
	battles.map { |battle|
		battle.length == 2 ? [battle[0][0],battle[1][0]] : nil
	}.compact
end

subreddit = "SpringfieldOpen"
refresh_token = ENV["REDDIT_REFRESH_TOKEN"]
poster = RedditPoster.new(refresh_token,subreddit)
episodes = JSON.parse(File.read("data/episode_lineups.json"))

# Clear subreddit
poster.clear_subreddit(subreddit)

# Add round posts
rounds = 8
round1_post_name = ""
1.upto(rounds) { |r|
	if r == 1
		response = poster.post("Round #{r} Matches","open")
		round1_post_name = response['json']['data']['name']
	else
		response = poster.post("Round #{r} Matches","pending")
	end
	puts JSON.pretty_generate(response)
}

# Add battles to round 1
get_battles(episodes).each_with_index do |battle,i|
	# Create battle comment
	response = poster.comment(round1_post_name,"Battle #{i+1}")
	puts JSON.pretty_generate(response)
	battle_comment_name = response['json']['data']['things'][0]['data']['name']
	# Create ep1 comment for battle
	battle1 = battle[0].flatten
	response = poster.comment(battle_comment_name,battle1[1] + "\n" + battle1[2] + "\n" + battle1[0])
	battle1_id = response['json']['data']['things'][0]['data']['id']
	puts JSON.pretty_generate(response)
	# Create ep1 comment for battle
	battle2 = battle[1].flatten
	response = poster.comment(battle_comment_name,battle2[1] + "\n" + battle2[2] + "\n" + battle2[0])
	battle2_id = response['json']['data']['things'][0]['data']['id']
	puts JSON.pretty_generate(response)
	# Update ep1 selftext
	response = HTTParty.get("http://www.reddit.com/r/SpringfieldOpenEps/comments/#{battle1[1].split("_")[1]}.json")
	ep_details = YAML.load(response[0]['data']['children'][0]['data']['selftext'])
	ep_details['battles'] = [battle1_id]
	response = poster.replace_text(battle1[1],ep_details.to_yaml)
	puts JSON.pretty_generate(response)
	# Update ep2 selftext
	response = HTTParty.get("http://www.reddit.com/r/SpringfieldOpenEps/comments/#{battle2[1].split("_")[1]}.json")
	ep_details = YAML.load(response[0]['data']['children'][0]['data']['selftext'])
	ep_details['battles'] = [battle2_id]
	response = poster.replace_text(battle2[1],ep_details.to_yaml)
	puts JSON.pretty_generate(response)
end

