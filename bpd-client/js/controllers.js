'use strict';

/* Controllers */

var softwareRelasesControllers = angular.module('softwareRelasesControllers', []);

softwareRelasesControllers.controller('SoftwareReleaseListCtrl', ['$scope', 'ReleaseService',
  function($scope, ReleaseService) {
    $scope.releases = ReleaseService.query();
    $scope.orderProp = 'created';
	
	$scope.removeRelease = function(id) {
		$('#' + id).remove();
	};
  }]);

softwareRelasesControllers.controller('ReleaseStepsListCtrl', ['$scope', '$routeParams', 'ReleaseService', 'ReleaseStepService',
  function($scope, $routeParams, ReleaseService, ReleaseStepService) {
	$scope.release = ReleaseService.get($routeParams.releaseId);
	
	$scope.removeStep = function(stepId) {
		ReleaseStepService.delete(stepId);
		$('#' + stepId).remove();
	};
	
	$scope.updateStatus = function(newStatus, stepId) {
		var div = $('#' + stepId + ' div.step-data');
		var allClasses = div.attr('class');
		var array = allClasses.split(" ");
		
		var clazzAlreadySet = false;
		
		for(var i = 0; i < array.length; i++) {
			var clazz = array[i];
			if (clazz.indexOf('status-') == 0) { // starts with
				if(clazz != 'status-' + newStatus) {
					div.removeClass(clazz);
				}
				else {
					clazzAlreadySet = true;
				}
				
			}
		}
		
		if(!clazzAlreadySet) {
			div.addClass('status-' + newStatus);
			ReleaseStepService.saveNewStatus(newStatus);

			if(newStatus == 'passed') {
				alert("Step passed. Server scripts will start as configured");
			}
		}
		else {
			alert("Status already set. Will not set it twice.");
		}
	};
  }]);

softwareRelasesControllers.controller('CommentsListCtrl', [ '$scope', '$routeParams', 'CommentService', 
  function($scope, $routeParams, CommentService) {
	$scope.step = CommentService.query($routeParams.stepId);
	$scope.formData = {};
	$scope.processForm = function() {
		$scope.step = CommentService.create($routeParams.stepId, $scope.formData);
	};
  }]);
  
softwareRelasesControllers.controller('ReleaseMetricsListCtrl', ['$scope', '$routeParams', 'ReleaseService',
  function($scope, $routeParams, ReleaseService) {
	$scope.release = ReleaseService.get($routeParams.releaseId);
  }]);
  
softwareRelasesControllers.controller('SoftwareReleaseCreateCtrl', ['$scope', 'ReleaseService',
  function($scope, ReleaseService) {
	$scope.formData = {};
	$scope.targetSystems = ReleaseService.queryDistinctSystems();
	$scope.applicationNames = ReleaseService.queryDistinctNames();

	$scope.processForm = function() {
		$scope.release = ReleaseService.createNew($scope.formData);
	}

  }]);  
  
softwareRelasesControllers.controller('SoftwareReleaseRateCtrl', ['$scope', '$routeParams', 'ReleaseService',
  function($scope, $routeParams, ReleaseService) {

	$scope.release = ReleaseService.get($routeParams.releaseId);
	$scope.processForm = function() {
		$scope.release = ReleaseService.rate(
			$routeParams.releaseId, 
			$scope.formData);
	},

	$scope.findMetricByName = function(metricName) {
		// Mockdata
		return 5;
	}

	$scope.formData = {
		numOfServerRestarts: $scope.findMetricByName('num-server-restarts'),
		numOfSupportRequests: $scope.findMetricByName('num-support-requests')
	};

  }]);
