app = angular.module 'homerApp'

app.controller "EpisodeController", ($scope, $stateParams, RedditApi, Utils) ->
  $scope.comment_data = 
    children: []

  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data
    $scope.admin_account = ($scope.currentUser.name == "springfieldopen")

  RedditApi.get("/comments/#{$stateParams.episode_id}.json?limit=0").then (response) ->
    $scope.title = response.data[0].data.children[0].data.title
    $scope.reddit_name = response.data[0].data.children[0].data.name
    ep_details = response.data[0].data.children[0].data.selftext.split("\n")
    $scope.all_images = ep_details[0].split(" ")
    $scope.overview = ep_details[2..-1].join("\n")
    $scope.comment_data = response.data[1].data
    $scope.comment_data.name = $scope.reddit_name
    console.log($scope.comments())

  $scope.comments = () -> 
    Utils.flatten($scope.comment_data.children)

  $scope.account_str = () ->
    if $scope.admin_account then " (Admin)" else ""

  $scope.images = () ->
    if !$scope.all_images
      []
    else if $scope.admin_account
      $scope.all_images
    else
      $scope.all_images[0..0]
  
  $scope.select_image = (ind) ->
    if ind < $scope.all_images.length
      selected_image = $scope.all_images[ind]
      $scope.all_images[ind] = $scope.all_images[0]
      $scope.all_images[0] = selected_image

  $scope.save_changes = () ->
    image_str = $scope.all_images.join(" ")
    ep_details = image_str + "\ngood\n" + $scope.overview
    RedditApi.post("/api/editusertext", api_type: "json", text: ep_details, thing_id: $scope.reddit_name)

  $scope.add_comment = (comment_data) ->
    RedditApi.post("/api/comment", api_type: "json", text: comment_data.new_reply, thing_id: comment_data.name).then (response) ->
      comment_data.new_reply = ""
      RedditApi.get("/comments/#{$stateParams.episode_id}.json?limit=0").then (new_comments) ->
        $scope.comment_data = new_comments.data[1].data
        $scope.comment_data.name = $scope.reddit_name
    
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
    console.log($scope.show_reply_box(comment))

  $scope.show_reply_box = (comment) ->
    comment.data.replying == true

