require 'sinatra'
require "sinatra/reloader" if development?
require 'httparty'
require 'json'

get "/" do
  erb :index
end

get "/sign_in" do
  base_url = "https://ssl.reddit.com/api/v1/authorize"
  params = {
    state: "signing_in",
    duration: "permanent",
    response_type: "code",
    scope: "identity",
    client_id: ENV['REDDIT_CLIENT'],
    redirect_uri: "http://localhost:5000/redirect"
  }
  params_str = params.map { |k,v| "#{k}=#{v}" }.join("&")
  redirect "#{base_url}?#{params_str}"
end

class RedditApi
  include HTTParty
  base_uri 'https://ssl.reddit.com'
  basic_auth ENV['REDDIT_CLIENT'], ENV['REDDIT_SECRET']
end

get "/redirect" do
  auth_post = RedditApi.post('/api/v1/access_token',
    query: {
      state: params[:state],
      scope: 'identity',
      client_id: ENV['REDDIT_CLIENT'],
      redirect_uri: "http://localhost:5000/redirect",
      code: params[:code],
      grant_type: 'authorization_code'
    },
    body: {}
  )

  auth_json = JSON.parse(auth_post.body)
  params_str = auth_json.map { |k,v| "#{k}=#{v}" }.join("&")
  redirect "/?#{params_str}"
end

# get "/api/*" do
#   RedditApi.get(...)
# end

# post "/api/*" do
#   RedditApi.post(...)
# end


