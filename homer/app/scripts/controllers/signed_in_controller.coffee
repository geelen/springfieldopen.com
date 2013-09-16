app = angular.module 'homerApp'

app.controller "SignedInController", ($state, $stateParams, RedditApi) ->
  RedditApi.authToken = $stateParams.token
  RedditApi.refreshToken = $stateParams.refresh
  $state.go('home')
