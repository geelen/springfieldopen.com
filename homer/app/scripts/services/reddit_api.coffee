'use strict'
app = angular.module 'homerApp'

app.factory 'RedditApi', ($rootScope, $http) ->
  apiHost = "http://localhost:5002"

  RedditApi = $rootScope.$new(true)

  RedditApi.authToken = localStorage.RedditApi_authToken
  RedditApi.refreshToken = localStorage.RedditApi_refreshToken
  RedditApi.$watch 'authToken', (newVal) ->
    console.log(newVal)
    localStorage.RedditApi_authToken = newVal
  RedditApi.$watch 'refreshToken', (newVal) ->
    console.log(newVal)
    localStorage.RedditApi_refreshToken = newVal

  RedditApi.get = (url) ->
    $http
      headers:
        authorization: "bearer " + RedditApi.authToken
      method: "GET"
      url: apiHost + url

  RedditApi.post = (url, data) ->
    $http
      headers:
        authorization: "bearer " + token
        'Content-Type': 'application/x-www-form-urlencoded'
      method: "POST"
      url: apiHost + url
      data: ("#{k}=#{v}" for k,v of data).join("&")

  RedditApi
