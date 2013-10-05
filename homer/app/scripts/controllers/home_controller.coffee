app = angular.module 'homerApp'

app.controller "HomeController", ($scope, RedditApi) ->
  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/r/SpringfieldOpen.json").then (response) ->
    $scope.battles = response.data.data.children.map (c) -> c.data

  $scope.battle_short_name = (item) ->
    item.name.split("_")[1]

  # vote = (direction) -> (item) ->
  #   item.likes = if direction > 0 then true else if direction < 0 then false else null
  #   RedditApi.post("/api/vote", dir: direction, id: item.name)
  #   .then -> console.log("Voted on #{item.name} in direction #{direction}")

  # $scope.upvote = vote(1)
  # $scope.downvote = vote(-1)
  # $scope.cancel = vote(0)
