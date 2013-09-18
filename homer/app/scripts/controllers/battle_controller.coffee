app = angular.module 'homerApp'

app.filter 'remove_label', () -> (text) ->
  text.replace(/\[(.*?)\]/,"")

app.controller "BattleController", ($scope, $filter, RedditApi) ->
  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/r/SpringfieldOpenTest/.json").then (response) ->
    $scope.episodes = response.data.data.children.map (c) -> c.data
    $scope.battle_eps = $filter('limitTo') ($filter('filter') $scope.episodes, "[Votes]"), 2
    $scope.battle_eps[0].other_item = $scope.battle_eps[1]
    $scope.battle_eps[1].other_item = $scope.battle_eps[0]

  vote = (item,direction) ->
    item.score += if (item.likes == true) then (direction-1) else if (item.likes == false) then (direction+1) else direction
    item.likes = if direction > 0 then true else if direction < 0 then false else null
    RedditApi.post("/api/vote", dir: direction, id: item.name)
    .then -> console.log("Voted on #{item.name} in direction #{direction}")

  $scope.votefor = (item) -> 
    if (item.likes == true)
      vote(item,0)
    else
      vote(item,1)
      vote(item.other_item,0)
