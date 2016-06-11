angular.module \awesome-g0v, <[]>
  ..controller \awesome-g0v-viewer, <[$scope $http]> ++ ($scope, $http) ->
    $http do
      url: \registry.json
      method: \GET
    .success (d) -> $scope.registry = d
