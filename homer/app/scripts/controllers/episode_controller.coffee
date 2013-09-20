app = angular.module 'homerApp'

app.factory 'RecursionHelper', ['$compile', ($compile) ->
  RecursionHelper = {
    compile: ($element) ->
      contents = $element.contents().remove()
      compiledContents = null
      ($scope, $element) ->
        if (!compiledContents)
          compiledContents = $compile(contents)
        compiledContents $scope, (clone) ->
          $element.append(clone)
    RecursionHelper
  }
]

app.directive 'markdown', () ->  
  restrict: 'E',
  controller: ($scope) ->
    $scope.converter = new Showdown.converter()
  link: ($scope, $element, $attrs) ->
    $element.html($scope.converter.makeHtml($element.text()))

app.directive 'commenttree', (RecursionHelper) ->
  restrict: 'A',
  scope: {comments: '=commenttree'},
  controller: ($scope) ->
    $scope.replies = (item) -> 
      if item.replies then item.replies.data.children.map (c) -> c.data else []
  template: 
    '<li ng-repeat="item in comments">' + 
      '<div>{{ item.ups }}' + 
      '<span class="voting-button" ng-click="upvote(item)" ng-class="{upvoted: item.likes === true}">⬆</span>' + 
      '<span class="voting-button" ng-click="downvote(item)" ng-class="{downvoted: item.likes === false}">⬇</span>' +
      '<span class="voting-button" ng-click="cancel(item)" ng-class="{nothing: item.likes === null}">✖</span>' + 
      # '{{ item.author }}: <span ng-html-bind-unsafe="item.body_html"></span></div><ul commenttree="replies(item)"></ul>' + 
      '{{ item.author }}: {{item.body}}</div><ul commenttree="replies(item)"></ul>' + 
    '</li>'
  compile: ($element) ->
    RecursionHelper.compile($element)

app.controller "EpisodeController", ($scope, $stateParams, RedditApi) ->
  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/comments/#{$stateParams.episode_id}.json?limit=0").then (response) ->
    ep_details = response.data[0].data.children[0].data.selftext.split("\n")
    $scope.image_url = ep_details[0]
    $scope.overview = ep_details[1]
    $scope.comments = response.data[1].data.children.map (c) -> c.data
    console.log($scope.comments)


