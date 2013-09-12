'use strict'

app = angular.module 'homerApp', ['ui.router']


app.config ($stateProvider, $urlRouterProvider) ->
  $urlRouterProvider.otherwise '/route1'

  $stateProvider
    .state 'route1',
      url: '/route1'
      templateUrl: 'views/route1.html'
    .state 'route1.list',
      url: '/list'
      templateUrl: 'views/route1-list.html'
    .state 'route2',
      url: '/route2'
      templateUrl: 'views/route2.html'
