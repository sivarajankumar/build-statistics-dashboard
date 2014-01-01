'use strict';

var softwareRelasesDirectives = angular.module('softwareRelasesDirectives', []);

softwareRelasesDirectives.directive('ngKeypressEnter', function() {
	var r = {
		restrict: 'A',
		link: function (scope, element, attrs) {
			element.bind("keydown keypress", function (event) {
				if(event.which === 13) {
					scope.$apply(function (){
						scope.$eval(attrs.ngKeypressEnter);
					});
			                event.preventDefault();
				}
        		});
		}
	};
	return r
});
softwareRelasesDirectives.directive('renderMetric', function() {

	function labelFormatter(total, value) {
		if(value === null || value === undefined) {
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

	function createWidgetData(metric) {
		var history = metric.history;
		var data = [];
		var record;
		var i = 0;

		if (history != undefined) {
			for(i = 0; i < history.length; i++) {
				record = {
					data: [[i, history[i].value]],
					label: history[i].created
				};
				data.push(record);
			}
		}

		record = { data : [[i, metric.value]], label : 'This build' };
		data.push(record);

		return data;

	}

	function createWidgetDefinitionXyChart(data) {

		var betterData = [];

		for(var i = 0; i < data.length; i++) {
			var item = data[i];
			if( item != undefined ) {
				betterData.push(item.data[0]);
			}
		}

		var def = {
			data: [ 
				betterData 
			],
			options: {
				HtmlText : false,
				colors: [ '#FF3333' ],
				grid : {
				  verticalLines : true,
				  horizontalLines : true,
				  outlineWidth: 0,
				  minorVerticalLines: true
				},
				xaxis : { showLabels : true },
				yaxis : { showLabels : true },
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

	function createWidgetDefinitionPieChart(data) {

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

	function findHistory(id, data) {

	}

	function link(scope, element, attr) {
	
		var metric = scope.metric;
		
		if(attr.type == 'auto' || type.attr === undefined) {
			attr.type = 'xy-chart';
		}

		var data = createWidgetData(metric);
		var def = undefined;

		if(attr.type == 'pie-chart') {
			def = createWidgetDefinitionPieChart(data);
		}
		if(attr.type == 'xy-chart') {
			def = createWidgetDefinitionXyChart(data);
		}
		else {
			element.text('unsupported type: ' + attr.type 
				+ ', types are: pie-chart, xy-chart, auto');
		}
		
		if(def != undefined) {
			var domTargetElement = element.parent()[0];
			Flotr.draw(domTargetElement, def.data, def.options);
		}
	}
	
	var r = {
		restrict: 'E',
		link: link,
		scope: {
			metric: "=metric"
		}
	};	
	return r;
});
