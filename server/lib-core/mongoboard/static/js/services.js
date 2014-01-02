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

softwareRelasesServices.factory('ReleaseStepService', [ 'Mockdata', function(Mockdata) {
	var service = {
		delete: function(stepId) {

		},

		saveNewStatus: function(stepId, newStatus) {

		},

		get: function(stepId) {
			return Mockdata.get({ filename: 'steps-details' });
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
			var system = releaseData.version;
			var data = Mockdata.get({ filename: 'release-details' });

			return {
				success: true,
				errors: undefined,
				release: data
			};
		},
		
		get: function(releaseId) {
			return Mockdata.get({ filename: 'release-details' });
		},

		queryDistinctNames: function() {
			var promise = $http.get(toUrl('releases/names.json'));
			return promise;
		},

		queryDistinctSystems: function() {
			var promise = $http.get(toUrl('releases/systems.json'));
			return promise;
		},
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


softwareRelasesServices.factory('CommentService', [ 'Mockdata', 
function(Mockdata) {
	var service = {
		create: function(stepId, data) {
			var data = Mockdata.get({ filename: 'steps-details' });	
			return {
				success: false,
				errors: ['error-no-permission'],
				step: data
			};
		},
		query: function(stepId) {
			return Mockdata.get({ filename: 'steps-details' });	
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

