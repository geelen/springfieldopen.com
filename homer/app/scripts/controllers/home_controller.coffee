app = angular.module 'homerApp'

app.controller "HomeController", ($scope, RedditApi) ->
  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/.json").then (response) ->
    $scope.homepage = response.data.data.children.map (c) -> c.data
    console.log($scope.homepage)

  vote = (direction) -> (item) ->
    item.likes = if direction > 0 then true else if direction < 0 then false else null
    RedditApi.post("/api/vote", dir: direction, id: item.name)
    .then -> console.log("Voted on #{item.name} in direction #{direction}")

  $scope.upvote = vote(1)
  $scope.downvote = vote(-1)
  $scope.cancel = vote(0)
