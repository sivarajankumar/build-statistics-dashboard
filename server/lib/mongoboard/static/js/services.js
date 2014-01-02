'use strict';


function toUrl(path) {
	return '/'+path;
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
		delete: function(stepId) {
			var promise = $http.delete(toUrl('release/step/' + stepId + '.json'));
			return promise;
		},

		saveNewStatus: function(stepId, newStatus) {
			var promise = $http.post(toUrl('release/step/' + stepId + '.json?status=' + newStatus));
			return promise;
		},

		get: function(stepId) {
			var promise = $http.get(toUrl('release/step/' + stepId + '.json'));
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

		rate: function(releaseId, data) {
			var data = Mockdata.get({ filename: 'release-details' });
			return {
				success: true,
				errors: undefined,
				release: data
			}
		},

		createNew: function(releaseData) {
			var name = releaseData.name;
			var version = releaseData.version;
			var system = releaseData.system;
			
			var promise = $http.post(toUrl('create-release?name=' + name + '&version=' + version + '&system=' + system));
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


softwareRelasesServices.factory('CommentService', [ '$http', 'Mockdata', 
function($http, Mockdata) {
	var service = {
		create: function(releaseId, stepId, data) {
			var data = Mockdata.get({ filename: 'steps-details' });	
			return data;
		},
		query: function(releaseId, stepId) {
			var promise = $http.get(toUrl('release/' + releaseId + '/step/' + stepId + '.json'));
			return promise;
		}
	};
	return service;
}]);

softwareRelasesServices.factory('MetricService', [ 'Mockdata', function(Mockdata) {
	var service = {
		queryHistory: function() {
			return Mockdata.query({ filename: 'metrics-list' });	
		},
		saveValue: function(data) {
			var releaseId = data.releaseId;
			var metricId = data.metric.id;
			var metricValue = data.metric.value; // make it a number

			var result = {
				success: true,
				value: metricValue
			};
			
			// Mockdata to show color changes on gui
			if (metricValue <= 0) {
				result.success = false;
			}

			return result;
		}
	};
	return service;
}]);

