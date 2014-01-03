'use strict';


function toUrl(path) {
	return '/' + path;
}

var softwareRelasesServices = angular.module('softwareRelasesServices', ['ngResource']);


softwareRelasesServices.factory('Mockdata', ['$http',
  function($http){
	return  {
		query: function(data) { return $http.get('mockdata/' + data.filename + '.json'); },
		get: function(data) { return $http.get('mockdata/' + data.filename + '.json'); },
	};
  }]);

softwareRelasesServices.factory('ReleaseStepService', [ '$http', function($http) {
	var service = {
		delete: function(releaseId, stepId) {
			var promise = $http.delete(toUrl('release/' + releaseId + '/step/' + stepId + '.json'));
			return promise;
		},

		saveNewStatus: function(releaseId, stepId, newStatus) {
			var promise = $http.post(toUrl('release/' + releaseId + '/step/' + stepId + '.json?status=' + newStatus));
			return promise;
		},

		get: function(releaseId, stepId) {
			var promise = $http.get(toUrl('release/' + releaseId + '/step/' + stepId + '.json'));
			return promise;
		},

	};
	return service;
  }]);
softwareRelasesServices.factory('ReleaseService', [ 'Mockdata', '$http',
function(Mockdata, $http) {
	var ReleaseService = {
		query: function() {
			var promise = $http.get(toUrl('releases.json'));
			return promise;
		},

		createNew: function(releaseData) {
			var name = releaseData.name;
			var version = releaseData.version;
			var system = releaseData.system;
			
			var promise = $http.post(toUrl('release.json?name=' + name + '&version=' + version + '&system=' + system));
			return promise;
		},
		
		get: function(releaseId) {
			var promise = $http.get(toUrl('release/' + releaseId + '.json'));
			return promise;
		},

		queryDistinctNames: function() {
			var promise = $http.get(toUrl('releases/names.json'));
			return promise;
		},

		queryDistinctSystems: function() {
			var promise = $http.get(toUrl('releases/systems.json'));
			return promise;
		},
		
		delete: function(id) {
			var promise = $http.delete(toUrl('release/' + id + '.json'));
			return promise;
		}
	};
	return ReleaseService;
}]);

softwareRelasesServices.factory('PermissionService', [ 'Mockdata', function(Mockdata) {
	var service = {
		userPermissions: function() {
			return [ 'save-status', 'create-comment', 'view-releases' ];
		}
	};
	return service;
}]);


softwareRelasesServices.factory('CommentService', [ '$http', 
function($http) {
	var service = {
		create: function(releaseId, stepId, data) {
			var url = toUrl('release/' + releaseId + '/step/' + stepId + '/comment.json');
			var xsrf = $.param({ author: data.author, text: data.text }); // make it a string
			var promise = $http({
				method: 'POST',
				url: url,
				data: xsrf,
				headers: {'Content-Type': 'application/x-www-form-urlencoded'}
			});
			return promise;
		},

		query: function(releaseId, stepId) {
			var promise = $http.get(toUrl('release/' + releaseId + '/step/' + stepId + '.json'));
			return promise;
		}
	};
	return service;
}]);

softwareRelasesServices.factory('MetricService', [ '$http', function($http) {
	var service = {
		queryHistory: function(releaseId) {
			var url= toUrl('release/' + releaseId + '/metrics-default-history.json');
			return $http.get(url);
		},

		remove: function(metricId) {
			return $http.delete(toUrl('metric/' + metricId + '.json'));
		},

		saveValue: function(metricId, value) {
			return $http.post(
				toUrl('metric/' + metricId + '.json?value=' 
				+ value));
		}
	};
	return service;
}]);

