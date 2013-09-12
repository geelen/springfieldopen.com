app = angular.module 'homerApp'

app.controller "HomeController", ($scope, $stateParams, $http) ->
  token = $stateParams.token

  $http(
    method: "GET"
    url: "http://localhost:5001/api/v1/me.json",
    headers:
      authorization: "bearer " + token
  ).then (response) ->
    console.log response

