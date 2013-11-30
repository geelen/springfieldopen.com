'use strict'
app = angular.module 'homerApp'

app.factory 'Utils', () ->
  Utils =
    twoWayLocalStorageBind: (scope, prop, storageName) ->
      scope[prop] = localStorage[storageName]
      scope.$watch prop, (newVal) -> localStorage[storageName] = newVal if newVal?
    flatten: (nested, depth=0) ->
      array = []
      angular.forEach nested, (value) ->
        value.data.depth = depth
        array.push value
        if (value.data.replies!="" && value.data.collapsed != true)
          array = array.concat(Utils.flatten(value.data.replies.data.children,depth+1))
      array
