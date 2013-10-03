Bundler.require
Dotenv.load

subreddit = "SpringfieldOpenEps"
existing_eps = begin
	response = HTTParty.get("http://www.reddit.com/r/#{subreddit}.json")
	response['data']['children'].map { |child| child['data']['title'] }
end

all_episodes = begin
	full_hash = JSON.parse(File.read("data/episodes.json"))
	full_hash.map { |ep| "#{ep['season']}.#{ep['episode']} #{ep['title']}" }
end

episodes = all_episodes - existing_eps

auth_token = begin
	response = HTTParty.get("http://mr-burns-springfieldopen.herokuapp.com/refresh.json?refresh_token=#{ENV["REDDIT_REFRESH_TOKEN"]}")
	response["access_token"]
end

ep = episodes.first

options = { 
	headers: {
		"authorization" => "bearer " + auth_token,
		'Content-Type' => 'application/x-www-form-urlencoded'
	}, 
	body: {
		api_type: 'json',
		kind: 'self',
		save: 'true',
		title: ep,
		text: "This is a test",
		iden: "HGm5fjOEq9V406eISkLpzhCb68E8dPi4",
		captcha: "yyhnnx",
		sr: subreddit
	}.map { |k,v| "#{k}=#{v}" }.join("&")
}
response = HTTParty.post('https://oauth.reddit.com/api/submit.json', options)

# RedditApi.post = (url, data) -> checkAuth ->
#     $http
#       headers:
#         authorization: "bearer " + RedditApi.authToken
#         'Content-Type': 'application/x-www-form-urlencoded'
#       method: "POST"
#       url: apiHost + url
#       data: ("#{k}=#{v}" for k,v of data).join("&")

binding.pry

