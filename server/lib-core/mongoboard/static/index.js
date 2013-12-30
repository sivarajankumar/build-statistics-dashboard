
function ajaxGet(url, onSuccess) {
	$.ajax({ url: url, method: 'get'}).done(onSuccess);
}

function ajaxPost(url, data, onSuccess) {
	$.ajax({ url: url, method: 'post', data: data}).done(onSuccess);
}

function reloadReleases() {
	ajaxGet('releases.json', function(json) {
		var data = '';
		jQuery.each(json, function(j) {
			data = data + j.software + ' r' + j.revision + ' on ' + j.system + '<br>';
		});
		$('#releases').html(data);
	});
}

$(document).ready(function() {

	ajaxGet('templates.json', function(json) {
		var options = '';
		jQuery.each(json, function() { 
			options = options + '<option value="' + this.software + '">'; 
		});
		$('#dlist_software').html(options);
	});

	ajaxGet('releases/systems.json', function(json) {
		var options = '';
		jQuery.each(json, function() { 
			options = options + '<option value="' + this + '">'; 
		});
		$('#dlist_systems').html(options);
	});

	$("#create_rc").ajaxForm(function(json) { 
		alert('Created release candidate with id ' + json._id); 
		reloadReleases();
	});

	reloadReleases();

});
