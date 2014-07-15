(function(){
	var sa = angular.module('somewhatabstract', [] );
	
	sa.config(['$httpProvider', function($httpProvider) {
		$httpProvider.interceptors.push('saHttpActivityInterceptor');
	}]);

	sa.factory('saNavigationGuard', ['$window', '$rootScope', function($window, $rootScope) {
		var guardians = [];

		var onBeforeUnloadHandler = function($event) {
			var message = getGuardMessage();
			if (message) {
				($event || $window.event).returnValue = message;
				return message;
			} else {
				return undefined;
			}
		};

		var locationChangeStartHandler = function($event) {
			var message = getGuardMessage();
			if (message && !$window.confirm(message))
			{
				if ($event.stopPropagation) $event.stopPropagation();
				if ($event.preventDefault) $event.preventDefault();
				$event.cancelBubble = true;
				$event.returnValue = false;
			}
		};

		var getGuardMessage = function () {
		    var message = undefined;
		    _.any(guardians, function(guardian) { return !!(message = guardian()); });
		    return message;
		};

		var registerGuardian = function(guardianCallback) {
			guardians.unshift(guardianCallback);
			return function() {
				var index = guardians.indexOf(guardianCallback);
				if (index >= 0) {
					guardians.splice(index, 1);
				}
			};
		};

		if ($window.addEventListener) {
			$window.addEventListener('beforeunload', onBeforeUnloadHandler);
		} else {
			$window.onbeforeunload = onBeforeUnloadHandler;
		}

		$rootScope.$on('$locationChangeStart', locationChangeStartHandler);

		return {
			registerGuardian: registerGuardian
		};
	}]);

	sa.factory('saHttpActivityInterceptor', ['$q', 'saNavigationGuard', function($q, saNavigationGuard) {
		var pendingRequestsCounter = 0;

		var updateCounter = function(method, delta) {
			if (method != 'POST' && method != 'PUT' && method != 'DELETE') {
			    return false;
			}
			pendingRequestsCounter += delta;
			return true;
		};

		saNavigationGuard.registerGuardian(function() {
			return pendingRequestsCounter > 0 ? 'There are changes pending.' : undefined;
		});

		return {
			request: function(request) {
				request.saTrackedActivity = updateCounter(request.method, 1);
				return request;
			},

			response: function(response) {
				if (response.config && response.config.saTrackedActivity) {
					updateCounter(response.config.method, -1);
				}
				return response;
			},

			responseError: function(rejection) {
				if (rejection.config && rejection.config.saTrackedActivity) {
					updateCounter(response.config.method, -1);
				}
				return $q.reject(rejection);
			}
		};
	}]);
    
    sa.directive('saEditableField', function () {
        return {
        	restrict: 'E',
			require: 'ngModel',
            template: '<label>{{fieldName}}</label><input type="text" ng-model="fieldValue" /><button ng-click="showField()">Alert!</button>',
            scope: {
                fieldName: '@saFieldName',
                fieldValue: '=ngModel'
            },
            controller: 'saFieldController'
        };
    });

	sa.controller('saFieldController', ['$scope', '$window', function($scope, $window) {
		$scope.showField = function() {
			$window.alert("Your " + $scope.fieldName + " is " + $scope.fieldValue);
		};
	}]);
})();