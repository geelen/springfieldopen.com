app = angular.module 'homerApp'

app.controller "DummyHomeController", ($scope) ->

app.controller "HomeController", ($scope, $filter, RedditApi, RandomPath) ->

  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/r/SpringfieldOpen.json").then (response) ->
    $scope.battles = response.data.data.children.map (c) ->
      $scope.load_battle(c.data)

  $scope.load_battle = (battle) ->
    RedditApi.get("/comments/#{$scope.short_name(battle.name)}.json?limit=2&sort=old").then (response) ->
      battle_eps = $filter('limitTo') (response.data[1].data.children.map (c) -> c.data), 2
      battle.ep1_score = $filter('positive') (battle_eps[0].ups - battle_eps[0].downs)
      battle.ep2_score = $filter('positive') (battle_eps[1].ups - battle_eps[1].downs)
    battle_details = battle.selftext.split("\n")
    battle.round = battle_details[0]
    battle.number = battle_details[1]
    split_title = battle_details[2].split(" ")
    battle.ep1_title = split_title[1..split_title.length-1].join(" ")
    battle.ep1_num = split_title[0]
    battle.ep1_name = battle_details[3]
    split_title = battle_details[4].split(" ")
    battle.ep2_title = split_title[1..split_title.length-1].join(" ")
    battle.ep2_num = split_title[0]
    battle.ep2_name = battle_details[5]
    battle.description = "\"#{battle.ep1_title}\" VS \"#{battle.ep2_title}\""
    # console.log(battle)
    battle

  $scope.get_episodes_after = (name) ->
    RedditApi.get("/r/SpringfieldOpenEps.json?limit=100&after=#{name}").then (response) ->
      $scope.get_episodes_after_helper(response)

  $scope.get_episodes_after_helper = (response) ->
    eps = response.data.data.children.map (c) -> c.data
    $scope.episodes = $scope.episodes.concat(eps)
    # console.log($scope.episodes.length)
    if eps.length > 0
      $scope.get_episodes_after(eps[eps.length-1].name)

  $scope.get_episodes = () ->
    RedditApi.get("/r/SpringfieldOpenEps.json?limit=100").then (response) ->
      $scope.get_episodes_after_helper(response)

  $scope.episodes = []
  # $scope.get_episodes()

  $scope.short_name = (long_name) ->
    long_name.split("_")[1]

  # vote = (direction) -> (item) ->
  #   item.likes = if direction > 0 then true else if direction < 0 then false else null
  #   RedditApi.post("/api/vote", dir: direction, id: item.name)
  #   .then -> console.log("Voted on #{item.name} in direction #{direction}")

  # $scope.upvote = vote(1)
  # $scope.downvote = vote(-1)
  # $scope.cancel = vote(0)
