app = angular.module 'homerApp'

app.controller "EpisodeController", ($scope, $stateParams, RedditApi) ->
  RedditApi.get("/api/v1/me.json").then (response) ->
    $scope.currentUser = response.data

  RedditApi.get("/comments/#{$stateParams.episode_id}.json?limit=0").then (response) ->
    episode = response.data[0].data.children[0].data
    contents = episode.selftext.split("\n")
    $scope.image_url = contents[0]
    $scope.overview = contents[1]



