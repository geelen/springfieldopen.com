app = angular.module 'homerApp'

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'

  $stateProvider
    .state 'signed_in',
      url: '/access_token/:token/refresh_token/:refresh'
      controller: 'SignedInController'
#    .state 'home',
#      url: '/'
#      templateUrl: 'views/home.html'
#      controller: 'HomeController'
    .state 'home',
      url: '/'
      templateUrl: 'views/home2.html'
      controller: 'DummyHomeController'
    .state 'battle',
      url: '/battle/:battle_id'
      templateUrl: 'views/battle.html'
      controller: 'BattleController'
    .state 'episode',
      url: '/episode/:episode_id'
      templateUrl: 'views/episode.html'
      controller: 'EpisodeController'
    .state 'test_battle',
      url: '/test_battle'
      templateUrl: 'views/test_battle.html'

