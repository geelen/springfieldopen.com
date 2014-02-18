Bundler.require
require 'cgi'

class RedditPoster

	def initialize refresh_token, subreddit
		@headers = {
	    "authorization" => "bearer " + get_auth_token(refresh_token),
	    'Content-Type' => 'application/x-www-form-urlencoded'
	  }
	  @subreddit = subreddit
	end

	def get_user
		body_hash = {
      api_type: 'json'
    }
		options = {
	    headers: @headers,
	    body: hash_to_body(body_hash)
	  }
	  HTTParty.get('https://oauth.reddit.com/api/v1/me.json', options)
	end

	def post title, data
		body_hash = {
      api_type: 'json',
      kind: 'self',
      save: 'true',
      title: CGI.escape(title),
      text: CGI.escape(data_to_json(data)),
      sr: @subreddit
    }
		options = {
	    headers: @headers,
	    body: hash_to_body(body_hash)
	  }
	  HTTParty.post('https://oauth.reddit.com/api/submit.json', options)
	end

	def delete thingname
		body_hash = {
      id: thingname
    }
		options = {
	    headers: @headers,
	    body: hash_to_body(body_hash)
	  }
	  HTTParty.post('https://oauth.reddit.com/api/del', options)
	end

	def clear_subreddit
		url = "http://www.reddit.com/r/#{@subreddit}.json"
		response = HTTParty.get(url)
		while response['data']['children'].length > 0
			response['data']['children'].each { |post|
				response = delete(post['data']['name'])
			}
			response = HTTParty.get(url)
		end
	end

	def replace_text thingname, data
		text = JSON.pretty_generate(data).gsub(/^/,"    ")
		body_hash = {
      api_type: 'json',
      thing_id: thingname,
      text: CGI.escape(data_to_json(data))
    }
		options = {
	    headers: @headers,
	    body: hash_to_body(body_hash)
	  }
	  HTTParty.post('https://oauth.reddit.com/api/editusertext.json', options)
	end

	def comment thingname, data
		body_hash = {
      api_type: 'json',
      thing_id: thingname,
      text: CGI.escape(data_to_json(data))
    }
		options = {
	    headers: @headers,
	    body: hash_to_body(body_hash)
	  }
	  HTTParty.post('https://oauth.reddit.com/api/comment.json', options)
	end

	private

	def get_auth_token refresh_token
		mr_burns = "http://mr-burns-springfieldopen.herokuapp.com"
		response = HTTParty.get(mr_burns + "/refresh.json?refresh_token=#{refresh_token}")
		response["access_token"]
	end

	def hash_to_body hash
    hash.map { |k,v| "#{k}=#{v}" }.join("&")
  end

  def data_to_json data
  	JSON.pretty_generate(data).gsub(/^/,"    ")
  end
end