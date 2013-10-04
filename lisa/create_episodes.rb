Bundler.require
require './episode_loader.rb'
require 'cgi'
Dotenv.load

subreddit = "SpringfieldOpenEps"

existing_eps = EpisodeLoader.reddit_hash.keys
all_episodes = EpisodeLoader.local_imdb_list

episodes = all_episodes - existing_eps

auth_token = begin
	response = HTTParty.get("http://mr-burns-springfieldopen.herokuapp.com/refresh.json?refresh_token=#{ENV["REDDIT_REFRESH_TOKEN"]}")
	response["access_token"]
end

episodes.each do |ep|

  options = {
    headers: {
      "authorization" => "bearer " + auth_token,
      'Content-Type' => 'application/x-www-form-urlencoded'
    },
    body: {
      api_type: 'json',
      kind: 'self',
      save: 'true',
      title: CGI.escape(ep),
      text: "This is a test",
      sr: subreddit
    }.map { |k,v| "#{k}=#{v}" }.join("&")
  }
  response = HTTParty.post('https://oauth.reddit.com/api/submit.json', options)

  puts JSON.pretty_generate(response)

end
