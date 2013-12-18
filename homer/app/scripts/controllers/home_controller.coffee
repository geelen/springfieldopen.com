app = angular.module 'homerApp'

app.controller "DummyHomeController", ($scope) ->

app.controller "HomeController", ($scope, $filter, RedditApi, RandomPath) ->

  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/r/SpringfieldOpen.json").then (response) ->
<<<<<<< HEAD
    rounds = response.data.data.children
    open_round = (rounds.filter (c) -> c.data.selftext == "open")[0]
    round_post = open_round.data.id
    RedditApi.get("/comments/#{round_post}.json").then (response) ->
      $scope.battles = response.data[1].data.children.map (c) -> 
        $scope.load_battle(c.data.replies.data.children)
      console.log($scope.battles)

  $scope.load_battle = (comments) ->
    battle = {}
    battle.ep1 = $scope.load_battle_episode(comments[0].data)
    battle.ep2 = $scope.load_battle_episode(comments[1].data)
    battle.ep1.other_item = battle.ep2
    battle.ep2.other_item = battle.ep1
    battle

  $scope.load_battle_episode = (comment) ->
    battle_ep = comment
    ep_details = comment.body.split("\n")
    battle_ep.ep_name = ep_details[0]
    battle_ep.ep_image_url = ep_details[1]
    title_pieces = ep_details[2].split(" ")
    battle_ep.ep_num = title_pieces[0]
    battle_ep.ep_title = title_pieces[1..title_pieces.length-1].join(" ")
    battle_ep
  
  $scope.short_name = (long_name) ->
    long_name.split("_")[1]

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
