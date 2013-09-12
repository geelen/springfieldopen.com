app = angular.module 'homerApp'

app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/'

  $stateProvider
    .state 'signed-out',
      url: '/'
      templateUrl: 'views/signed_out.html'
    .state 'home',
      url: '/access_token/:token'
      templateUrl: 'views/home.html'
