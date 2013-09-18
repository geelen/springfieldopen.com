app = angular.module 'homerApp'

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'

  $stateProvider
    .state 'signed_in',
      url: '/access_token/:token/refresh_token/:refresh'
      controller: 'SignedInController'
    .state 'home',
      url: '/'
      templateUrl: 'views/home.html'
      controller: 'HomeController'
    .state 'test_battle',
      url: '/test_battle'
      templateUrl: 'views/test_battle.html'
      controller: 'BattleController'
    .state 'battle',
      url: '/battle'
      templateUrl: 'views/battle.html'
    
