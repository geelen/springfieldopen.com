require 'sinatra'
require "sinatra/reloader" if development?
require 'httparty'
require 'json'
require 'sinatra/cross_origin'
require 'newrelic_rpm'

get "/" do
  erb :index
end

get "/sign_in" do
  base_url = "https://ssl.reddit.com/api/v1/authorize"
  params = {
    state: "signing_in",
    duration: "permanent",
    response_type: "code",
    scope: "identity,submit,vote,read",
    client_id: ENV['REDDIT_CLIENT'],
    redirect_uri: ENV['REDDIT_REDIRECT_URL']
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
      scope: 'identity,submit,vote,read',
      client_id: ENV['REDDIT_CLIENT'],
      redirect_uri: ENV['REDDIT_REDIRECT_URL'],
      code: params[:code],
      grant_type: 'authorization_code'
    },
    body: {}
  )

  auth_json = JSON.parse(auth_post.body)
  params_str = auth_json.map { |k,v| "#{k}=#{v}" }.join("&")
  redirect "http://localhost:9000/#/access_token/#{auth_json['access_token']}/refresh_token/#{auth_json['refresh_token']}"
end

get "/refresh.json" do
  cross_origin
  content_type :json

  auth_post = RedditApi.post('/api/v1/access_token',
    query: {
      state: 'signing_in',
      scope: 'identity,submit,vote,read',
      client_id: ENV['REDDIT_CLIENT'],
      redirect_uri: ENV['REDDIT_REDIRECT_URL'],
      refresh_token: params[:refresh_token],
      grant_type: 'refresh_token'
    },
    body: {}
  )

  auth_post.body
end

# get "/api/*" do
#   RedditApi.get(...)
# end

# post "/api/*" do
#   RedditApi.post(...)
# end


