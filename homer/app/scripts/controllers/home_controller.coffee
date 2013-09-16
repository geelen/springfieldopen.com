app = angular.module 'homerApp'

app.controller "HomeController", ($scope, $stateParams, $http) ->
  token = $stateParams.token

  reddit = (url, opts) ->
    $http(angular.extend({
      method: "GET"
      url: "http://localhost:5002" + url
#      url: "http://brockman-springfieldopen.herokuapp.com" + url
      headers:
        authorization: "bearer " + token
    }, opts))

  reddit("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  reddit("/.json").success (response) ->
    $scope.homepage = response.data.children.map (c) -> c.data
    console.log($scope.homepage)

  vote = (direction) -> (item) ->
    item.likes = if direction > 0 then true else if direction < 0 then false else null
    reddit "/api/vote",
      method: "POST"
      headers:
        'Content-Type': 'application/x-www-form-urlencoded'
        authorization: "bearer " + token
      data: "dir=#{direction}&id=#{item.name}"
    .success -> console.log("Voted on #{item.name} in direction #{direction}")

  $scope.upvote = vote(1)
  $scope.downvote = vote(-1)
  $scope.cancel = vote(0)
