app = angular.module 'homerApp'

app.filter 'remove_label', () -> (text) ->
  text.replace(/\[(.*?)\]/,"")
  
app.filter 'positive', () -> (score) ->
  if score >= 0 then score else 0

app.controller "BattleController", ($scope, $filter, $stateParams, RedditApi) ->
  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/comments/#{$stateParams.battle_id}.json?limit=2&sort=old").then (response) ->
    $scope.episodes = $filter('limitTo') (response.data[1].data.children.map (c) -> c.data), 2
    $scope.episodes.map (ep) -> 
    $scope.get_title($scope.episodes[0])
    $scope.get_title($scope.episodes[1])
    $scope.episodes[0].other_item = $scope.episodes[1]
    $scope.episodes[1].other_item = $scope.episodes[0]
    console.log($scope.episodes[0])

  $scope.get_title = (item) ->
    item.short_name = $scope.ep_short_name(item)
    RedditApi.get("/#{item.short_name}.json").then (response) ->
      item.title = response['data'][0]['data']['children'][0]['data']['title']

  $scope.score = (item) ->
    $filter('positive') (item.ups - item.downs)

  $scope.ep_short_name = (item) ->
    item.body.split("_")[1]

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
