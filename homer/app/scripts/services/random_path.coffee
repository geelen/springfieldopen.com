'use strict'
app = angular.module 'homerApp'

app.factory 'RandomPath', ($rootScope, $filter, RedditApi) ->
  RandomPath = $rootScope.$new(true)
  math = window.Math
  next_prev_lookup = {}
  RandomPath.next = (current) ->
    pair = next_prev_lookup[current]
    if pair then pair[0] else ""
  RandomPath.prev = (current) ->
    pair = next_prev_lookup[current]
    if pair then pair[1] else ""
  random = () ->
    1-math.random()
      
  RedditApi.get("/api/v1/me.json").then (response) ->
    math.seedrandom(response.data.name)
    RedditApi.get("/r/SpringfieldOpen.json").then (response) ->
      names = response.data.data.children.map (c) -> 
        c.data.name.split("_")[1]
      array = $filter('orderBy')(names,random)
      angular.forEach [0..array.length-1], (value) ->
        if (value+1 < array.length) && (value > 0)
          pair = [array[value+1],array[value-1]]
        else if (value > 0)
          pair = [array[0],array[value-1]]
        else
          pair = [array[value+1],array[array.length-1]]
        next_prev_lookup[array[value]] = pair

  RandomPath
