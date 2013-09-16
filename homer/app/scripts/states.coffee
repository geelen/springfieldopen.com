app = angular.module 'homerApp'

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'

  $stateProvider
    .state 'signed-out',
      url: '/'
      templateUrl: 'views/signed_out.html'
      controller: 'SignedOutController'
    .state 'home',
      url: '/access_token/:token/refresh_token/:refresh'
      templateUrl: 'views/home.html'
      controller: 'HomeController'
    .state 'battle',
      url: '/battle'
      templateUrl: 'views/battle.html'
