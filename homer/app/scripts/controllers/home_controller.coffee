app = angular.module 'homerApp'

app.controller "HomeController", ($scope, RedditApi) ->
  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/r/SpringfieldOpen.json").then (response) ->
    $scope.battles = response.data.data.children.map (c) -> c.data

  $scope.get_episodes_after = (name) ->
    RedditApi.get("/r/SpringfieldOpenEps.json?limit=100&after=#{name}").then (response) ->
      $scope.get_episodes_after_helper(response)

  $scope.get_episodes_after_helper = (response) ->
    eps = response.data.data.children.map (c) -> c.data
    $scope.episodes = $scope.episodes.concat(eps)
    console.log($scope.episodes.length)
    if eps.length > 0
      $scope.get_episodes_after(eps[eps.length-1].name)

  $scope.get_episodes = () ->
    RedditApi.get("/r/SpringfieldOpenEps.json?limit=100").then (response) ->
      $scope.get_episodes_after_helper(response)
      
  $scope.episodes = []
  $scope.get_episodes()
  
  $scope.short_name = (item) ->
    item.name.split("_")[1]

  # vote = (direction) -> (item) ->
  #   item.likes = if direction > 0 then true else if direction < 0 then false else null
  #   RedditApi.post("/api/vote", dir: direction, id: item.name)
  #   .then -> console.log("Voted on #{item.name} in direction #{direction}")

  # $scope.upvote = vote(1)
  # $scope.downvote = vote(-1)
  # $scope.cancel = vote(0)
