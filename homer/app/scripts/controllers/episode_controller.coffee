app = angular.module 'homerApp'

app.directive "commenttree", ($compile) ->
  restrict: "A"
  scope:
    comments: "=commenttree"
  template: """
    <ul>
      <li ng-repeat="item in comments">
        {{ item.data.ups }}
        <span class="voting-button" ng-click="downvote(item)" ng-class="{downvoted: item.data.likes === false}">⬇</span>
        <span class="voting-button" ng-click="cancel(item)" ng-class="{nothing: item.data.likes === null}">✖</span>
        {{ item.data.author }}: {{item.data.body}}
        <div commenttree="item.data.replies.data.children"></div>
      </li>
    </ul>
  """
  compile: (tElement, tAttr) ->
    contents = tElement.contents().remove()
    compiledContents = undefined
    (scope, iElement, iAttr) ->
      compiledContents = $compile(contents)  unless compiledContents
      compiledContents scope, (clone, scope) ->
        iElement.append clone

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
    $scope.comments = response.data[1].data.children

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
    console.log(ep_details)
    RedditApi.post("/api/editusertext", api_type: "json", text: ep_details, thing_id: $scope.reddit_name)
    
