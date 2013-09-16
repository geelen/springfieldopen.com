'use strict'
app = angular.module 'homerApp'

app.factory 'RedditApi', ($rootScope, $http, Utils, $q) ->
  apiHost = "http://localhost:5002"

  RedditApi = $rootScope.$new(true)

  Utils.twoWayLocalStorageBind RedditApi, 'authToken', 'RedditApi_authToken'
  Utils.twoWayLocalStorageBind RedditApi, 'refreshToken', 'RedditApi_refreshToken'

  checkAuth = (ifAuthedDo) ->
    if RedditApi.authToken?
      ifAuthedDo()
    else
      $rootScope.loginNeeded = true
      $q.defer().promise

  RedditApi.get = (url) -> checkAuth ->
    $http
      headers:
        authorization: "bearer " + RedditApi.authToken
      method: "GET"
      url: apiHost + url

  RedditApi.post = (url, data) -> checkAuth ->
    $http
      headers:
        authorization: "bearer " + RedditApi.authToken
        'Content-Type': 'application/x-www-form-urlencoded'
      method: "POST"
      url: apiHost + url
      data: ("#{k}=#{v}" for k,v of data).join("&")

  RedditApi
