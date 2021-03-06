app = angular.module 'homerApp'

app.filter 'remove_label', () -> (text) ->
  text.replace(/\[(.*?)\]/,"")
  
app.filter 'positive', () -> (score) ->
  if score >= 0 then score else 0

app.controller "BattleController", ($scope, $filter, $stateParams, RedditApi, RandomPath) ->
  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  $scope.next = () ->
    RandomPath.next($stateParams.battle_id)

  $scope.previous = () ->
    RandomPath.prev($stateParams.battle_id)

  RedditApi.get("/comments/#{$stateParams.battle_id}.json?limit=2&sort=old").then (response) ->
    $scope.episodes = $filter('limitTo') (response.data[1].data.children.map (c) -> c.data), 2
    $scope.parse_text($scope.episodes[0])
    $scope.parse_text($scope.episodes[1])
    $scope.episodes[0].other_item = $scope.episodes[1]
    $scope.episodes[1].other_item = $scope.episodes[0]

  $scope.parse_text = (item) ->
    item.short_name = $scope.ep_short_name(item)
    item.title = $scope.ep_title(item)

  $scope.ep_short_name = (item) ->
    item.body.split("\n")[1].split("_")[1]

  $scope.ep_title = (item) ->
    item.body.split("\n")[0]

  $scope.score = (item) ->
    $filter('positive') (item.ups - item.downs)

  vote = (item,direction) ->
    if direction > 0
      if item.likes == false
        item.ups += 1
        item.downs -= 1
      else if item.likes == null
        item.ups += 1
      item.likes = true
    else if direction < 0
      if item.likes == true
        item.ups -= 1
        item.downs += 1
      else if item.likes == null
        item.downs += 1
      item.likes = false
    else
      if item.likes == true
        item.ups -= 1
      else if item.likes == false
        item.downs -= 1
      item.likes = null
    RedditApi.post("/api/vote", dir: direction, id: item.name)

  $scope.votefor = (item) -> 
    if (item.likes == true)
      vote(item,0)
    else
      vote(item,1)
      vote(item.other_item,0)
