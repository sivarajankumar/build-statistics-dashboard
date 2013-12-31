'use strict';


 
var softwareRelasesServices = angular.module('softwareRelasesServices', ['ngResource']);


softwareRelasesServices.factory('Mockdata', ['$resource',
  function($resource){
    return $resource('mockdata/:filename.json', {}, {
      query: {method:'GET', params: { filename: 'releases-list' }, isArray:true}
    });
  }]);

softwareRelasesServices.factory('Translator', [ function(){

	return {
		errors: function (errorKeys) {
			var texts = [];

			if ( !errorKeys ) return texts;

			for(var i = 0; i < errorKeys.length; i++) {
				var key = errorKeys[i];
				if (key == 'error-no-permission') 
					texts.push("No permission for requested operation.");
				else 
					texts.push("Key: " + key);
					
			}
			return texts;
		},

		success: function() {
			return 'Data processed successfully';
		}
	}

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
softwareRelasesServices.factory('ReleaseService', [ 'Mockdata', 
function(Mockdata) {
	var ReleaseService = {
		query: function() {
			var r = Mockdata.query({ filename: 'releases-list' });
			return r;
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
			return ['Shop', 'Admintool'];
		},

		queryDistinctSystems: function() {
			return ['Western Europe Production', 'Eastern Europe Production'];
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
