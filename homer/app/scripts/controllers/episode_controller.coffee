app = angular.module 'homerApp'

app.directive "comment", (RedditApi) ->
  restrict: 'A'
  scope:
    item: '=comment'
  template: """
    <ul>
      <li class='comment-details'>
        {{ item.data.ups }}
        <span class="voting-button" ng-click="downvote(item)" ng-class="{downvoted: item.data.likes === false}">⬇</span>
        <span class="voting-button" ng-click="cancel(item)" ng-class="{nothing: item.data.likes === null}">✖</span>
        {{ item.data.author }}: {{item.data.body}}
      </li>
      <li class='comment-add-reply'>
        <textarea type="text" ng-model="comment_data.new_comment"></textarea>
        <button ng-click="add_comment(comment_data)">Add Comment</button>
      </li>
    </ul>
  """

app.directive "commenttree", ($compile) ->
  restrict: "A"
  replace: true
  scope:
    comment_data: "=commenttree"
  template: """
    <li class='comment-reply' ng-repeat="item in comment_data.children">
      
      <div commenttree="item.data.replies.data"></div>
    </li>
  """
  compile: (tElement, tAttr) ->
    contents = tElement.contents().remove()
    compiledContents = undefined
    (scope, iElement, iAttr) ->
      compiledContents = $compile(contents)  unless compiledContents
      compiledContents scope, (clone, scope) ->
        iElement.append clone

  # controller: ($scope) ->
  #   console.log("CONTROLLER")
  #   console.log($scope)
  #   console.log($scope.comment_data)
  #   console.log($scope.comment_data != undefined)
  #   if (typeof $scope.comment_data != 'undefined')
  #     angular.forEach $scope.comment_data.children, (item) ->
  #       item.data.replies.data.name = item.data.name
  #   $scope.add_comment = (comment_data) ->
  #     console.log(comment_data)
  #     RedditApi.post("/api/comment", api_type: "json", text: comment_data.new_comment, thing_id: comment_data.name).then (response) ->
  #       comment_data.new_comment = ""

app.controller "EpisodeController", ($scope, $stateParams, RedditApi) ->
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
    # console.log($scope.comment_data)

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
    
