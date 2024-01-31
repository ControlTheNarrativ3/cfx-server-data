var locale = [];

/**
 * Similar to the concept of gettext, this function returns the
 * localized string for the parsed string. The function supports
 * wrapping.
 *
 * @param {string} args The string we want localized
 * @return {string} Returns the localized string
 *
 */
function _U() {
	var args = arguments;
	var string = args[0];

	// Was a string specified?
	if (!string) {
		console.log('locale.js: no string was parsed');
		return 'locale.js: no string was parsed';
	}

	// Has the locale file been set?
	if (locale.length === 0) {
		console.log('locale.js: no locale has been set');
		return 'locale.js: no locale has been set';
	}

	// Does the translation exist?
	if (!locale[string]) {
		console.log('locale.js: translation [{0}] does not exist'.format(string));
		return 'locale.js: translation [{0}] does not exist'.format(string);
	}

	// Do we need to format the string?
	if (args.length === 1) {
		return capitalize(locale[string]);
	} else {
		return formatString(args);
	}
}

/**
 * Formats a string based on the provided arguments.
 *
 * @param {array} args - An array of arguments to be used in the string formatting
 * @return {string} The formatted string
 */
function formatString(args) {
	var string = capitalize(locale[args[0]]);

	for (var i = 1; i < args.length; i++) {
		string = string.replace(/%s/, args[i]);
	}

	return string;
}

/**
 * Capitalizes the first letter of a given string.
 *
 * @param {string} string - the input string
 * @return {string} the string with the first letter capitalized
 */
function capitalize(string) {
	return string[0].toUpperCase() + string.slice(1);
}


/**
 * Replaces placeholders in a string with the provided arguments.
 * // https://stackoverflow.com/a/35359503
 *
 * @param {type} paramName - description of parameter
 * @return {type} description of return value
 */
String.prototype.format = function () {
	var args = arguments;
	return this.replace(/{(\d+)}/g, function (match, number) {
		return typeof args[number] != 'undefined'
			? args[number]
			: match
			;
	});
};
