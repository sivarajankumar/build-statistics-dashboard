'use strict';

/* App Module */

var phonecatApp = angular.module('softwareRelasesApp', [
  'ngRoute'
  ,'softwareRelasesControllers'
  ,'softwareRelasesFilters'
  ,'softwareRelasesServices'
  ,'softwareRelasesDirectives'
]);

phonecatApp.config(['$routeProvider',
  function($routeProvider) {
    $routeProvider.
      when('/releases', {
        templateUrl: 'partials/releases-list.html',
        controller: 'SoftwareReleaseListCtrl'
      }).
      when('/releases/delete/:releaseId', {
        templateUrl: 'partials/releases-list.html',
        controller: 'SoftwareReleaseListCtrl'
      }).	  
      when('/release/:releaseId/steps', {
        templateUrl: 'partials/steps-list.html',
        controller: 'ReleaseStepsListCtrl'
      }).
      when('/release/:releaseId/step/:stepId/comments', {
        templateUrl: 'partials/comments-list.html',
        controller: 'CommentsListCtrl'
      }).	  
	  when('/release/:releaseId/metrics', {
        templateUrl: 'partials/metrics-list.html',
        controller: 'ReleaseMetricsListCtrl'
      }).
	  when('/release/create-new', {
        templateUrl: 'partials/release-create-new.html',
        controller: 'SoftwareReleaseCreateCtrl'
      }).
	  when('/release/:releaseId/rate', {
        templateUrl: 'partials/release-rate.html',
        controller: 'SoftwareReleaseRateCtrl'
      }).	  
      otherwise({
        redirectTo: '/releases'
      });
  }]);
