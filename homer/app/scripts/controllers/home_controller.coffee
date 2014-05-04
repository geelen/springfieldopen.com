app = angular.module 'homerApp'

app.controller "DummyHomeController", ($scope) ->

app.controller "HomeController", ($scope, $filter, RedditApi, TournamentManager, $timeout) ->
  $scope.tournament = TournamentManager
  current_time = 0

  update_current_time = () ->
    current_time = Math.floor(Date.now()/1000)
    if TournamentManager.time_of_next_event && current_time
      new_time = 1000*(TournamentManager.time_of_next_event - current_time)
    else
      new_time = 0
    $scope.time_until_next_event = new_time
    $timeout(update_current_time, 100)
  update_current_time()

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
