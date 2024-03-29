'use strict';


/* Controllers */

var softwareRelasesControllers = angular.module('softwareRelasesControllers', []);

softwareRelasesControllers.controller('SoftwareReleaseListCtrl', ['$scope', 'ReleaseService',
  function($scope, ReleaseService) {
	ReleaseService.query().success(function(data) { $scope.releases = data; });
	$scope.orderProp = 'created';
	
	$scope.removeRelease = function(id) {
		ReleaseService.delete(id);
		$('#' + id).remove();
	};
  }]);

softwareRelasesControllers.controller('ReleaseStepsListCtrl', ['$scope', '$routeParams', 'ReleaseService', 'ReleaseStepService',
  function($scope, $routeParams, ReleaseService, ReleaseStepService) {
	ReleaseService.get($routeParams.releaseId).success(function(data) { $scope.release = data; });
	
	$scope.removeStep = function(releaseId, stepId) {
		ReleaseStepService.delete(releaseId, stepId).success(function() {
			$('#' + stepId).remove();
		});
	};
	
	$scope.updateStatus = function(newStatus, stepId, releaseId) {
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
			ReleaseStepService.saveNewStatus(releaseId, stepId, newStatus).then(function() {
				div.addClass('status-' + newStatus);
				if(newStatus == 'passed') {
					alert("Step passed. Server scripts will start as configured");
				}
			}, function() {
				alert("Server responded an error");
			});

		}
		else {
			alert("Status already set. Will not set it twice.");
		}
	};
  }]);

softwareRelasesControllers.controller('CommentsListCtrl', [ '$scope', '$routeParams', 'CommentService', 
  function($scope, $routeParams, CommentService) {
	CommentService.query($routeParams.releaseId, $routeParams.stepId)
		.success(function(data) { $scope.step = data });

	$scope.formData = {};
	$scope.processForm = function() {
		CommentService.create($routeParams.releaseId, $routeParams.stepId, $scope.formData)
			.success(function(result) {
				$scope.step = result;
				Helpers.evalFormResultSuccess($scope);
			}
		);
	};
  }]);
  
softwareRelasesControllers.controller('ReleaseMetricsListCtrl', ['$scope', '$routeParams', 'ReleaseService', 'MetricService',
  function($scope, $routeParams, ReleaseService, MetricService) {

	MetricService.queryHistory($routeParams.releaseId).success(function(data) { 
		$scope.release = data.release; 
		$scope.metrics = data.metrics; 
	});

	$scope.updateMetric = function(metric) {

		var inputField = $('#metric_value_' + metric._id);
		
		var value = parseFloat(metric.value);
		if(isNaN(value)) {
			inputField.removeClass('info');
			inputField.addClass('error');
			return;
		}

		MetricService.saveValue(metric._id, metric.value).then(function(r) {
			inputField.removeClass('error');
			inputField.addClass('info');
			inputField.val(r.data.value);
		}, function() {
			inputField.removeClass('info');
			inputField.addClass('error');
		});

		
	};
  }]);
  
softwareRelasesControllers.controller('SoftwareReleaseCreateCtrl', ['$scope', 'ReleaseService',
  function($scope, ReleaseService) {
	$scope.formData = {};
	ReleaseService.queryDistinctSystems().success(function(data) { $scope.targetSystems = data });
	ReleaseService.queryDistinctNames().success(function(data) { $scope.applicationNames = data; });

	$scope.processForm = function() {
		ReleaseService.createNew($scope.formData)
		.then(function(result) {
			$scope.release = result;
			Helpers.evalFormResultSuccess($scope);
		}, function(result) {
			Helpers.evalFormResultError(result, $scope);
		});

	}

  }]);  
  
