//
//  FileManager.m
//  mvo
//
//  Created by Markus Voss on 11/29/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "FileManager.h"
#import <Cordova/CDVPlugin.h>
#ifdef PHONEGAP_FRAMEWORK
#import <PhoneGap/PhoneGapViewController.h>
#else
#import "PhoneGapViewController.h"
#endif


@implementation FileManager

@synthesize docInteractionController;


- (void)initDocControllerWithUrl:(NSString*) path 
{
	if (self.docInteractionController == nil) {
		self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
		self.docInteractionController.delegate = self;
	}
	else {
		self.docInteractionController.URL = [NSURL fileURLWithPath:path];
	}

}


-(void) notifyUserAboutEvent:(int) event 
{
	NSString* jsString = nil;
	jsString = [[NSString alloc] initWithFormat:@"window.plugins.fileManager.didFinishWithResult('%d');", event];
	[self.webView stringByEvaluatingJavaScriptFromString:jsString];
	
}


-(void) notifyUserAboutProgress:(float) progress
{
	NSString* jsString = nil;
	jsString = [[NSString alloc] initWithFormat:@"window.plugins.fileManager.didFinishWithResult('%d', '%0.0f');", FILE_MANAGER_PROGRESS, progress];
	[self.webView stringByEvaluatingJavaScriptFromString:jsString];
}


-(void) startFileDownload:(NSURL*) url withFilePath:(NSString*) filePath
{
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		receivedData = [[NSMutableData data] retain];
	} else {
		[self notifyUserAboutEvent: FILE_MANAGER_COULD_NOT_CONNECT];
	}
}


/**
 * Gets the filepath to the document directory in the application
 */
- (NSString *) getDocumentDirPath 
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return documentsDirectory;
}


//- (void)openFile:(NSMutableArray*)file withDict:(NSMutableDictionary*)options
- (void) addEvent:(CDVInvokedUrlCommand*)command
{	
	NSDictionary* options = [command.arguments objectAtIndex:0];
	NSString *url = [options valueForKey:@"fileUrl"];
	if ([url length] == 0) {
		[self notifyUserAboutEvent: FILE_MANAGER_FILE_URL_MISSING];
		return;
	}
			 NSLog(@"Open file, %@", url);
	NSString *fileName = [options valueForKey:@"fileName"];
	if ([url length] == 0) {
		[self notifyUserAboutEvent: FILE_MANAGER_FILE_NAME_MISSING];
		return;
	}
	
	filePath = [[NSString alloc] initWithFormat:@"%@/%@", [self getDocumentDirPath], fileName];
	
	NSURL *fileUrl = [NSURL URLWithString:url];
	if (fileUrl == nil) {
		[self notifyUserAboutEvent: FILE_MANAGER_MALFORMEN_URL];
		return;
	}
	
	totalDownloaded = 0;
	totalLength = 0;
	[self notifyUserAboutEvent: FILE_MANAGER_DOWNLOAD_START];
	[self startFileDownload: fileUrl withFilePath: filePath];
}


- (void) previewDownloadedFile 
{
	[self initDocControllerWithUrl: filePath];
	 BOOL result = [self.docInteractionController presentPreviewAnimated:YES];
	 if (!result) {
		 NSLog(@"Could not open file");
		 [self notifyUserAboutEvent: FILE_MANAGER_FILE_COULD_NOT_BE_PREVIEWED];
	 }
	 [filePath release];
     [suggestedFilename release];
}


- (void) showOpenInMenuForFile
{
	/*
	 CGRect rect = CGRectMake(0, 0, 300, 300);
	 PhoneGapViewController* cont = (PhoneGapViewController*)[ super appViewController ];	
	 if (NO == [docController presentOpenInMenuFromRect:rect inView:cont.view animated:YES]) {
	 NSString* jsString2 = nil;
	 jsString2 = [[NSString alloc] initWithFormat:@"window.plugins.fileManager.openFileCB('%@');", @"Kunne ikke åpne dokument"];
	 [webView stringByEvaluatingJavaScriptFromString:jsString2];
	 }*/
}


-  (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller
{
	PhoneGapViewController* cont = (PhoneGapViewController*)[ super appViewController ];
	return cont;
}

- (void) documentInteractionControllerWillBeginPreview: (UIDocumentInteractionController *) controller
{

}

- (void)documentInteractionControllerDidEndPreview:(UIDocumentInteractionController *)controller
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *deleteFilePath = [[NSString alloc] initWithFormat:@"%@/%@", documentsDirectory, controller.name];
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	[fileManager removeItemAtPath:deleteFilePath error:NULL];
	[fileManager release];
	[deleteFilePath release];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application
{
	// needs to be implemented to be able to send file to application
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
	// needs to be implemented to be able to send file to application
}

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController *)controller 
{
	// needs to be implemented to conform with protocol
}


- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{	
	totalLength = [response expectedContentLength];
    suggestedFilename = [[NSString alloc] initWithFormat:@"%@", [response suggestedFilename]];
	NSLog(@"did receive response, expected length: %i", [response expectedContentLength]);
    NSLog(@"suggestedFilename %@", suggestedFilename);
	// This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    [receivedData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	totalDownloaded = totalDownloaded + [data length];
	float downloaded = 0;
	downloaded = totalDownloaded * 100 / totalLength;
	NSLog(@"did receive data percentt: %0.1f  length: %i", downloaded, [data length]);
	[self notifyUserAboutProgress: downloaded];
    [receivedData appendData:data];
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    [receivedData release];
	[filePath release];
    if (suggestedFilename != nil) {
        [suggestedFilename release];
    }
	
	[self notifyUserAboutEvent: FILE_MANAGER_COULD_NOT_CONNECT];
    //NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription],[[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	[self notifyUserAboutEvent: FILE_MANAGER_DOWNLOAD_FINISHED];
    [connection release];
    
    if (suggestedFilename != nil && [suggestedFilename isEqualToString:@"unknown"] == NO) {
        NSLog(@"Use suggested filename %@", suggestedFilename);
        filePath = [[NSString alloc] initWithFormat:@"%@/%@", [self getDocumentDirPath], suggestedFilename];
    }
	
	// save the file to the filesystem
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if ([fileManager createFileAtPath: filePath contents: receivedData attributes: nil] == NO) {
        NSLog (@"Couldn't create the file\n");
		[self notifyUserAboutEvent: FILE_MANAGER_FILE_COULD_NOT_BE_CREATED];
	}
	[receivedData release];
	[fileManager release];
	[self previewDownloadedFile];
}

@end
