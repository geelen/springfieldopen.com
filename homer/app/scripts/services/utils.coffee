'use strict'
app = angular.module 'homerApp'

app.factory 'Utils', () ->
  twoWayLocalStorageBind: (scope, prop, storageName) ->
    scope[prop] = localStorage[storageName]
    scope.$watch prop, (newVal) -> localStorage[storageName] = newVal if newVal?
