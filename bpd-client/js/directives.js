'use strict';

var softwareRelasesDirectives = angular.module('softwareRelasesDirectives', []);

softwareRelasesDirectives.directive('renderMetric', function() {

	function createEmptyData(label) {
		return	{
			data : [[0,null]],
			label : label,
			pie: { explode: 8 } 
		};
	}

	function labelFormatter(total, value) {
		if(value === null) {
			return null;
		}
		if (value > 10000) {
			var v = value/1000;
			return v.toFixed(0) + 'K';
		}
		if (value > 1000) {
			var v = value/1000;
			return v.toFixed(2) + 'K';
		}
		else {
			return value.toFixed(2);
		}		
	}

	function createWidgetDefinition(metric) {

		var data = [
			{ data : [[0,metric.value]], label : 'This build' }
		];

		var avgLast5Builds = createEmptyData('Average last 5 builds');
		var avgBuild6to50 = createEmptyData('Average of build 6 to 50');

		for(var i = 0; i < metric.comparisonValues.length; i++) {
			var v = metric.comparisonValues[i];
			if (v.type == 'avg-last-5-builds') {
				avgLast5Builds.data = [[0, v.value]];
			}
			if (v.type == 'avg-last-6-builds') {
				avgBuild6to50.data = [[0, v.value]];
			}
		}

		data.push(avgLast5Builds);
		data.push(avgBuild6to50);


		var def = {
			data: data,
			options: {
				HtmlText : false,
				colors: ['#FF3333', '#C9C9DF', '#CB4B4B', '#4DA74D', '#9440ED'],
				grid : {
				  verticalLines : false,
				  horizontalLines : false,
				  outlineWidth: 0,
				},
				xaxis : { showLabels : false },
				yaxis : { showLabels : false },
				pie : {
				  show : true, 
				  explode : 3,
				  labelFormatter: labelFormatter
				},
				mouse : { track : true },
				legend : {
				  position : 'se',
				  show: false,
				  backgroundColor : '#D2E8FF'
				}			
			}
		};
		
		return def;
	}

	function link(scope, element, attr) {
	
		var metric = scope.metric;
		
		if(attr.type == 'pie-chart') {
			var def = createWidgetDefinition(metric);
			var domTargetElement = element.parent()[0];
			Flotr.draw(domTargetElement, def.data, def.options);
		}
		else {
			element.text('unsupported type: ' + attr.type + ', types are: pie-chart');
		}
		
	}
	
	var r = {
		restrict: 'E',
		link: link,
		scope: {
			metric: "=data"
		}
	};	
	return r;
});
