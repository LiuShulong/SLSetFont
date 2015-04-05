//
//  SLFontDownloaderOperation.m
//  SLSetFont
//
//  Created by LiuShulong on 4/5/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "SLFontDownloaderOperation.h"
#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

typedef void(^CompleteBlock)(NSString *fontName);
typedef void (^Faiure)(NSError *);


@interface SLFontDownloaderOperation ()

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@property (nonatomic,copy) CompleteBlock completeBlock;
@property (nonatomic,copy) Faiure failure;
@property (nonatomic,strong) NSString *fontName;
@property (nonatomic,strong) NSString *errorMessage;

#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

@end

@implementation SLFontDownloaderOperation

@synthesize executing = _executing;
@synthesize finished = _finished;


- (id)initWithFontName:(NSString *)fontName completed:(void (^)(NSString *))complete failure:(void (^)(NSError *))failure
{
    if (self = [super init]) {
        self.executing = NO;
        self.finished = NO;
        self.fontName = fontName;
        self.completeBlock = complete;
        self.failure = failure;
    }
    
    return self;
}

- (void)start
{
    @synchronized(self) {
        
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        
        
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        
        __weak __typeof__ (self) wself = self;
        self.backgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof (wself) sself = wself;
            
            if (sself) {
                [sself cancel];
                
                [[UIApplication sharedApplication] endBackgroundTask:sself.backgroundTaskId];
                sself.backgroundTaskId = UIBackgroundTaskInvalid;
            }
        }];
#endif
        self.executing = YES;
        self.finished = NO;
    }
    
    [self downloadFont];
    
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
#endif
}

- (void)cancel {
    
    [super cancel];
    
    self.finished = YES;
    self.executing = NO;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
}



- (void)downloadFont
{
    // Create a dictionary with the font's PostScript name.
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.fontName,
                                  kCTFontNameAttribute, nil];
    
    // Create a new font descriptor reference from the attributes dictionary.
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    
    NSMutableArray *descs = [NSMutableArray arrayWithCapacity:0];
    [descs addObject:(__bridge id)desc];
    CFRelease(desc);
    
    __block BOOL errorDuringDownload = NO;
    
    // Start processing the font descriptor..
    // This function returns immediately, but can potentially take long time to process.
    // The progress is notified via the callback block of CTFontDescriptorProgressHandler type.
    // See CTFontDescriptor.h for the list of progress states and keys for progressParameter dictionary.
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler( (__bridge CFArrayRef)descs, NULL,  ^(CTFontDescriptorMatchingState state, CFDictionaryRef progressParameter) {
        
        //NSLog( @"state %d - %@", state, progressParameter);
        
        //        double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
        
        if (state == kCTFontDescriptorMatchingDidBegin) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Show an activity indicator
                
                NSLog(@"Begin Matching");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinish) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                
                _completeBlock(_fontName);
                
                // Log the font URL in the console
                CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)self.fontName, 0., NULL);
                CFStringRef fontURL = CTFontCopyAttribute(fontRef, kCTFontURLAttribute);
                CFRelease(fontURL);
                CFRelease(fontRef);
                
                if (!errorDuringDownload) {
                    NSLog(@"%@ downloaded", self.fontName);
                }
                
                [self done];
            });
        } else if (state == kCTFontDescriptorMatchingWillBeginDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"Begin Downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDidFinishDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Remove the progress bar
                NSLog(@"Finish downloading");
            });
        } else if (state == kCTFontDescriptorMatchingDownloading) {
            dispatch_async( dispatch_get_main_queue(), ^ {
                // Use the progress bar to indicate the progress of the downloading
                //                NSLog(@"Downloading %.0f%% complete", progressValue);
            });
        } else if (state == kCTFontDescriptorMatchingDidFailWithError) {
            // An error has occurred.
            // Get the error message
            
            [self done];
            
            NSError *error = [(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingError];
            if (error != nil) {
                _errorMessage = [error description];
            } else {
                _errorMessage = @"ERROR MESSAGE IS NOT AVAILABLE!";
            }
            // Set our flag
            errorDuringDownload = YES;
            
            dispatch_async( dispatch_get_main_queue(), ^ {
                NSLog(@"Download error: %@", _errorMessage);
                self.failure(error);
                
                
            });
            
        }
        
        return (bool)YES;
    });
    
}

- (void)reset
{
    self.completeBlock = nil;
    self.finished = NO;
    self.executing = NO;
}

#pragma mark - 字体是否存在
- (BOOL)fontExist:(NSString *)fontName
{
    
    UIFont* aFont = [UIFont fontWithName:fontName size:12.];
    // If the font is already downloaded
    if (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame)) {
        // Go ahead and display the sample text
        return YES;
    } else {
        return NO;
    }
    
    
}


@end
