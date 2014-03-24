/**
 * EventManager.js
 * Created by Markus Voss on 19/11/10.
 */

/**
 * The javascript object representation the FileManager. Call to funcions
 * of the FileManager with window.plugins.fileManager.functionName.
 */
function FileManager() {
}



/**
 * Event indication that url is malformed
 */
FileManager.prototype.FILE_MANAGER_MALFORMEN_URL = 0;


/**
 * Event sendt before application starts downloading the file. 
 */
FileManager.prototype.FILE_MANAGER_DOWNLOAD_START = 1;


/**
 * Event sendt when application has finished  downloading the file. 
 */
FileManager.prototype.FILE_MANAGER_DOWNLOAD_FINISHED = 2;


/**
 * Event Sendt if file name is null
 */
FileManager.prototype.FILE_MANAGER_FILE_NAME_MISSING = 3;


/**
 * Event sendt if file name is null
 */
FileManager.prototype.FILE_MANAGER_FILE_URL_MISSING = 4;

/**
 * Event sendt when file could not be created in the file system
 */
FileManager.prototype.FILE_MANAGER_FILE_COULD_NOT_BE_CREATED = 5;


/**
 * Event sendt when file could not be previewed by the application. This could indicate
 * a file type that is unknown to the iphone.
 */
FileManager.prototype.FILE_MANAGER_FILE_COULD_NOT_BE_PREVIEWED = 6;


/**
 * Event sendt when connection could not be made
 */
FileManager.prototype.FILE_MANAGER_COULD_NOT_CONNECT = 7;


/**
 * Event sendt to notify about the progress of the download. 
 */
FileManager.prototype.FILE_MANAGER_PROGRESS = 8;



/**
 * Opens a file. 
 * @param options The js json object containing the fileName and url of the file. 
 * @param callBackFunction The function to call when the operation has finished. 
 */
FileManager.prototype.openFile = function(options, callBackFunction) {
	if (!options) {
		options = {};
	}
	this.resultCallback = callBackFunction;
    cordova.exec("FileManager.openFile", options);
};


/**
 * The result method called by the objecticve C code. 
 */
FileManager.prototype.didFinishWithResult = function(response, progress) {
	if (this.resultCallback){
		this.resultCallback(response, progress);
	}
};

cordova.addConstructor(function() {
	if(!window.plugins ){
		window.plugins = {};
	}
	window.plugins.fileManager = new FileManager();
});
