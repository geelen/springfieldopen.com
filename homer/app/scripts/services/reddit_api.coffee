'use strict'
app = angular.module 'homerApp'

app.config ($httpProvider) ->
  $httpProvider.responseInterceptors.push ($q, $injector) ->
    success = (response) -> response
    error = (response) ->
      if response.status == 401
        $http = $injector.get('$http')
        RedditApi = $injector.get('RedditApi')
        $http.get("http://mr-burns-springfieldopen.herokuapp.com/refresh.json?refresh_token=#{RedditApi.refreshToken}")
          .then (refreshResponse) ->
            RedditApi.authToken = refreshResponse.data.access_token
            RedditApi.refreshToken = refreshResponse.data.refresh_token
            response.config.headers.authorization = "bearer " + RedditApi.authToken
            $http(response.config)
      else
        $q.reject(response)
    (promise) -> promise.then(success, error)

app.factory 'RedditApi', ($rootScope, $http, Utils, $q) ->
#  apiHost = "http://localhost:5002"
  apiHost = "http://brockman-springfieldopen.herokuapp.com"

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
