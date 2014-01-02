'use strict';


/* Controllers */

var softwareRelasesControllers = angular.module('softwareRelasesControllers', []);

softwareRelasesControllers.controller('SoftwareReleaseListCtrl', ['$scope', 'ReleaseService',
  function($scope, ReleaseService) {
	ReleaseService.query().success(function(data) { $scope.releases = data; });
	$scope.orderProp = 'created';
	
	$scope.removeRelease = function(id) {
		$('#' + id).remove();
	};
  }]);

softwareRelasesControllers.controller('ReleaseStepsListCtrl', ['$scope', '$routeParams', 'ReleaseService', 'ReleaseStepService',
  function($scope, $routeParams, ReleaseService, ReleaseStepService) {
	ReleaseService.get($routeParams.releaseId).success(function(data) { $scope.release = data; });
	
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
	CommentService.query($routeParams.stepId).success(function(data) { $scope.step = data });

	$scope.formData = {};
	$scope.processForm = function() {
		CommentService.create($routeParams.stepId, $scope.formData).success(
			function(result) {
				$scope.step = result.step;
				Helpers.evalFormResult(result, $scope);
			}
		);
	};
  }]);
  
softwareRelasesControllers.controller('ReleaseMetricsListCtrl', ['$scope', '$routeParams', 'ReleaseService', 'MetricService',
  function($scope, $routeParams, ReleaseService, MetricService) {

	ReleaseService.get($routeParams.releaseId).success(function(data) { $scope.release = data; });
	MetricService.queryHistory($routeParams.releaseId).success(function(data) { $scope.metrics = data; });

	$scope.updateMetric = function(metric) {

		var inputField = $('#metric_value_' + metric.id);
		
		var value = parseFloat(metric.value);
		if(isNaN(value)) {
			inputField.removeClass('info');
			inputField.addClass('error');
			return;
		}

		MetricService.saveValue({ 
			releaseId: $routeParams.releaseId, 
			metric: { 
				id: metric.id,
				value: metric.value
			}
		}).success(function(result) {
		
			if (result.success) {
				inputField.removeClass('error');
				inputField.addClass('info');
			}
			else {
				inputField.removeClass('info');
				inputField.addClass('error');
			}

		});

		
	};
  }]);
  
softwareRelasesControllers.controller('SoftwareReleaseCreateCtrl', ['$scope', 'ReleaseService',
  function($scope, ReleaseService) {
	$scope.formData = {};
	ReleaseService.queryDistinctSystems().success(function(data) { $scope.targetSystems = data });
	ReleaseService.queryDistinctNames().success(function(data) { $scope.applicationNames = data; });

	$scope.processForm = function() {
		ReleaseService.createNew($scope.formData).success(function(result) {
			$scope.release = result.release;
			Helpers.evalFormResult(result, $scope);
		});

	}

  }]);  
  
softwareRelasesControllers.controller('SoftwareReleaseRateCtrl', ['$scope', '$routeParams', 'ReleaseService', 
  function($scope, $routeParams, ReleaseService) {

	$scope.formData = [];
	ReleaseService.get($routeParams.releaseId).success(function(data) { $scope.release = data; });

	$scope.processForm = function(form) {
	ReleaseService.rate($routeParams.releaseId, form)
		.success(function(result) {
			$scope.release = result.release;
			Helpers.evalFormResult(result, $scope);
		});
	};

	$scope.updateFormData = function(metric,form) {
		form[metric.id] = metric.value;
	}
  }]);


