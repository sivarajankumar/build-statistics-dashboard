var Helpers = {
	evalFormResultSuccess: function($scope) {
			$scope.messages = [ Translator.success() ];
			$scope.messageClass = 'info';
	},
	evalFormResultError: function(result, $scope) {
			$scope.messages = Translator.errors(result.errors);
			$scope.messageClass = 'error';
	}
};

var Translator = {
	errors: function (errorKeys) {
		if ( !errorKeys ) return [ 'Unknown error!' ];

		var texts = [];

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
};


