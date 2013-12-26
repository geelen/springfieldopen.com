app = angular.module 'homerApp'

app.controller "DummyHomeController", ($scope) ->

app.controller "HomeController", ($scope, $filter, RedditApi, TournamentManager) ->

  $scope.short_name = (long_name) ->
    long_name.split("_")[1]

  $scope.escape_image_url = (url) ->
    url.replace("'","\\'")

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

  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  $scope.tournament = TournamentManager
  $scope.tournament.update_battles() # do this every 10 seconds or something?

