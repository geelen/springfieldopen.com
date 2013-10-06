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

  RedditApi.get("/comments/#{$stateParams.episode_id}.json?limit=0").then (response) ->
    $scope.title = response.data[0].data.children[0].data.title
    ep_details = response.data[0].data.children[0].data.selftext.split("\n")
    $scope.image_url = ep_details[0].split(" ")[0]
    $scope.overview = ep_details[2..-1].join("\n")
    $scope.comments = response.data[1].data.children

