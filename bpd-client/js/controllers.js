'use strict';

var Helpers = {
	evalFormResult: function(result, $scope, Translator) {
		if (result.success) {
			$scope.messages = [ Translator.success() ];
			$scope.messageClass = 'info';
		}
		else {
			$scope.messages = Translator.errors(result.errors);
			$scope.messageClass = 'error';
		}
	}
}
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

softwareRelasesControllers.controller('CommentsListCtrl', [ '$scope', '$routeParams', 'CommentService', 'Translator',
  function($scope, $routeParams, CommentService, Translator) {
	$scope.step = CommentService.query($routeParams.stepId);
	$scope.formData = {};
	$scope.processForm = function() {
		var result = CommentService.create($routeParams.stepId, $scope.formData);

		$scope.step = result.step;
		Helpers.evalFormResult(result, $scope, Translator);
	};
  }]);
  
softwareRelasesControllers.controller('ReleaseMetricsListCtrl', ['$scope', '$routeParams', 'ReleaseService',
  function($scope, $routeParams, ReleaseService) {
	$scope.release = ReleaseService.get($routeParams.releaseId);
  }]);
  
softwareRelasesControllers.controller('SoftwareReleaseCreateCtrl', ['$scope', 'ReleaseService', 'Translator',
  function($scope, ReleaseService, Translator) {
	$scope.formData = {};
	$scope.targetSystems = ReleaseService.queryDistinctSystems();
	$scope.applicationNames = ReleaseService.queryDistinctNames();

	$scope.processForm = function() {
		var result = ReleaseService.createNew($scope.formData);
	
		$scope.release = result.release;

		Helpers.evalFormResult(result, $scope, Translator);
	}

  }]);  
  
softwareRelasesControllers.controller('SoftwareReleaseRateCtrl', ['$scope', '$routeParams', 'ReleaseService', 'Translator',
  function($scope, $routeParams, ReleaseService, Translator) {

	$scope.formData = [];
	$scope.release = ReleaseService.get($routeParams.releaseId);

	$scope.processForm = function(form) {
		var result = ReleaseService.rate(
			$routeParams.releaseId, 
			form);
		$scope.release = result.release;

		Helpers.evalFormResult(result, $scope, Translator);
	};


	$scope.updateFormData = function(metric,form) {
		form[metric.id] = metric.value;
	}
  }]);


