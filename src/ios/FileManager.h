//
//  FileManager.h
//  mvo
//
//  Created by Markus Voss on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>



/**
 * Sendt back to javascript if url is malformed
 */
int FILE_MANAGER_MALFORMEN_URL = 0;


/**
 * Sendt back to javascript before application starts downloading the file. 
 */
int FILE_MANAGER_DOWNLOAD_START = 1;


/**
 * Sendt back to javascript when application has finished  downloading the file. 
 */
int FILE_MANAGER_DOWNLOAD_FINISHED = 2;


/**
 * Sendt back to javascript if file name is null
 */
int FILE_MANAGER_FILE_NAME_MISSING = 3;


/**
 * Sendt back to javascript if file name is null
 */
int FILE_MANAGER_FILE_URL_MISSING = 4;


/**
 * Sendt back to javascript when file could not be created in file system.
 */
int FILE_MANAGER_FILE_COULD_NOT_BE_CREATED = 5;


/**
 * Sendt back to javascript when file could not be previewed by the application.
 */
int FILE_MANAGER_FILE_COULD_NOT_BE_PREVIEWED = 6;


/**
 * Sendt back to javascript when creating connectino failed
 */
int FILE_MANAGER_COULD_NOT_CONNECT = 7;


/**
 * Sendt back to javascript to notify about the progress of the download.
 */
int FILE_MANAGER_PROGRESS = 8;


@interface FileManager : CDVPlugin <UIDocumentInteractionControllerDelegate>{
	UIDocumentInteractionController *docInteractionController;
	NSMutableData *receivedData;
	NSString *filePath;
    NSString *suggestedFilename;
	int totalDownloaded;
	int totalLength;
}

@property (nonatomic, retain) UIDocumentInteractionController *docInteractionController;

- (void) openFile:(CDVInvokedUrlCommand*)command;

@end
