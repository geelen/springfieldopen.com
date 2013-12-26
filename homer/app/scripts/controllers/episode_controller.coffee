app = angular.module 'homerApp'

app.controller "EpisodeController", ($scope, $stateParams, RedditApi, Utils, $sce, TournamentManager) ->
  $scope.comment_data = 
    children: []
  $scope.ep_details = 
    synopsis: "",
    images: []

  number_of_upcoming_battles = 1
  number_of_episodes = Math.pow(2,number_of_upcoming_battles+1)

  nearby_episodes_map = {}
  nearby_episodes = []
  angular.forEach TournamentManager.battles, (battle) ->
    nearby_episodes.push(battle.ep1)
    nearby_episodes.push(battle.ep2)
    if nearby_episodes.length == number_of_episodes
      angular.forEach nearby_episodes, (episode,i) ->
        ep_list = []
        binary = (i).toString(2)
        while (number_of_upcoming_battles+1) > binary.length
          binary = ("0").concat(binary)
        tree = binary.split("").map (e) -> (e=="1")
        cnt = 0
        angular.forEach tree, (half,j) ->
          n = Math.pow(2,tree.length-j-1)
          k = cnt + (if half then 0 else n)
          ep_list = nearby_episodes.slice(k,k+n).concat(ep_list)
          cnt += (if half then n else 0)
        ep_list.unshift(nearby_episodes[i])
        nearby_episodes_map[episode.ep_name.split("_")[1]] = ep_list
      nearby_episodes = []

  $scope.upcoming = nearby_episodes_map[$stateParams.episode_id]
  console.log($scope.upcoming)

  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data
    $scope.admin_account = ($scope.currentUser.name == "springfieldopen")

  RedditApi.get("/comments/#{$stateParams.episode_id}.json?limit=0").then (response) ->
    $scope.title = response.data[0].data.children[0].data.title
    $scope.reddit_name = response.data[0].data.children[0].data.name
    $scope.ep_details = jsyaml.safeLoad(response.data[0].data.children[0].data.selftext)
    $scope.comment_data = response.data[1].data
    $scope.comment_data.name = $scope.reddit_name
    Utils.collapse_all($scope.comment_data.children)

  $scope.comments = () -> 
    Utils.flatten($scope.comment_data.children)

  $scope.account_str = () ->
    if $scope.admin_account then " (Admin)" else ""

  $scope.first_image = () ->
    if !$scope.ep_details.images
      ""
    else
      $scope.ep_details.images[0]

  $scope.other_images = () ->
    if !$scope.ep_details.images
      []
    else
      $scope.ep_details.images[1..$scope.ep_details.images.length-1]
  
  $scope.select_image = (ind) ->
    if ind < $scope.ep_details.images.length
      selected_image = $scope.ep_details.images[ind+1]
      $scope.ep_details.images[ind+1] = $scope.ep_details.images[0]
      $scope.ep_details.images[0] = selected_image
      $scope.save_changes()
      angular.forEach $scope.ep_details.battles, (value) ->
        new_text = $scope.reddit_name + "\n" + selected_image + "\n" + $scope.title
        RedditApi.post("/api/editusertext", api_type: "json", text: new_text, thing_id: "t1_" + value)

  $scope.save_changes = () ->
    yaml = jsyaml.safeDump($scope.ep_details)
    RedditApi.post("/api/editusertext", api_type: "json", text: yaml, thing_id: $scope.reddit_name)

  $scope.add_comment = (comment_data) ->
    RedditApi.post("/api/comment", api_type: "json", text: comment_data.new_reply, thing_id: comment_data.name).then (response) ->
      comment_data.new_reply = ""
      comment_data.replying = false
      comment_data.collapsed = false
      $scope.retrieve_comments()

  $scope.retrieve_comments = () ->
    RedditApi.get("/comments/#{$stateParams.episode_id}.json?limit=0").then (new_comments) ->
      $scope.update_comment_tree($scope.comment_data.children,new_comments.data[1].data.children)

  $scope.put_links_into_text = (text) ->
    # html = text.replace(/https?:\/\/[^ ]+/g,'<a href="$&">$&</a>')
    html = text.replace(/https?:\/\/[^ ]+/g,'<div><img src="$&"></img></div>')
    $sce.trustAsHtml(html)

  $scope.update_comment_tree = (old_comments,new_comments) ->
    old_comments_map = {}
    angular.forEach old_comments, (value) ->
      old_comments_map[value.data.name] = value
    new_comments_map = {}
    new_comments_to_add = []
    angular.forEach new_comments, (value) ->
      new_comments_map[value.data.name] = value
      if !old_comments_map[value.data.name]
        new_comments_to_add.push(value)
    angular.forEach old_comments, (value) ->
      new_value = new_comments_map[value.data.name]
      if new_value
        value.data.author = new_value.data.author
        value.data.body = new_value.data.body
        value.data.ups = new_value.data.ups
        value.data.downs = new_value.data.downs
        value.data.likes = new_value.data.likes
        if (new_value.data.replies!="")
          if (value.data.replies!="")
            $scope.update_comment_tree(value.data.replies.data.children,new_value.data.replies.data.children)
          else
            value.data.replies = new_value.data.replies
        else
          value.data.replies = ""
    angular.forEach new_comments_to_add, (value) ->
      old_comments.push(value)
    
  $scope.expand = (comment) ->
    comment.data.collapsed = false

  $scope.collapse = (comment) ->
    comment.data.collapsed = true

  $scope.show_expand = (comment) ->
    collapsed = (comment.data.collapsed == true)
    has_children = (comment.data.replies != "")
    return (collapsed && has_children)

  $scope.show_collapse = (comment) ->
    expanded = (comment.data.collapsed != true)
    has_children = (comment.data.replies != "")
    return (expanded && has_children)

  $scope.toggle_reply = (comment,state) ->
    comment.data.replying = state

  $scope.show_reply_box = (comment) ->
    comment.data.replying == true

  $scope.vote_up = (comment) -> 
    if (comment.data.likes == true)
      comment.data.likes = null
      comment.data.ups -= 1
      RedditApi.post("/api/vote", dir: 0, id: comment.data.name)
    else
      if comment.data.likes == false
        comment.data.downs -= 1  
      comment.data.likes = true
      comment.data.ups += 1
      RedditApi.post("/api/vote", dir: 1, id: comment.data.name)

  $scope.vote_down = (comment) -> 
    console.log("voting down")
    if (comment.data.likes == false)
      comment.data.likes = null
      comment.data.downs -= 1
      RedditApi.post("/api/vote", dir: 0, id: comment.data.name)
    else
    if comment.data.likes == true
        comment.data.ups -= 1
      comment.data.likes = false
      comment.data.downs += 1
      RedditApi.post("/api/vote", dir: -1, id: comment.data.name)
    
  $scope.my_comment = (comment) ->
    comment.data.author == $scope.currentUser.name

  $scope.delete_comment = (comment) ->
    RedditApi.post("/api/del", id: comment.data.name).then (response) ->
      $scope.retrieve_comments()

  $scope.show_editing = (comment) ->
    comment.data.editing == true

  $scope.toggle_editing = (comment,state) ->
    if state == false
      RedditApi.post("/api/editusertext", api_type: "json", text: comment.data.body, thing_id: comment.data.name).then (response) ->
        comment.data.editing = false
    else
      comment.data.editing = true
