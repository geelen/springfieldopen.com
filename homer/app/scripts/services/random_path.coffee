'use strict'
app = angular.module 'homerApp'

app.factory 'RandomPath', ($rootScope, $filter) ->
  RandomPath = $rootScope.$new(true)

  random = (math) -> () ->
    1-math.random()

  RandomPath.next = (array, prev, seed) ->
    math = window.Math
    math.seedrandom(seed)
    randomised_array = $filter('orderBy')(array,random(math))
    console.log(randomised_array)
    nextvalue = undefined
    angular.forEach [0..randomised_array.length-1], (value) ->
      if prev == randomised_array[value]
        if value+1 < randomised_array.length
          nextvalue = randomised_array[value+1]
        else
          nextvalue = randomised_array[0]
    nextvalue

  RandomPath
