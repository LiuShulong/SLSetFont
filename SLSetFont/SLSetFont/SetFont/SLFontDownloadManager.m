//
//  SLFontDownloadManager.m
//  SLSetFont
//
//  Created by LiuShulong on 4/5/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "SLFontDownloadManager.h"
#import "SLFontDownloaderOperation.h"

#define kMaxOperationCount 2

@interface SLFontDownloadManager ()

@property (nonatomic,strong) NSOperationQueue *downloadQueue;
@property (nonatomic,strong) NSMutableDictionary *callbacksDict;
@property (strong, nonatomic) dispatch_queue_t barrierQueue;

@end

@implementation SLFontDownloadManager

+ (SLFontDownloadManager *)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        self.downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = kMaxOperationCount;
        self.callbacksDict = [NSMutableDictionary new];
        self.barrierQueue = dispatch_queue_create("com.fontDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (void)dealloc {
    [self.downloadQueue cancelAllOperations];
}

+ (void)downloadFontWithFontName:(NSString *)fontName success:(void (^)(NSString *))success
{
    __block SLFontDownloaderOperation *operation;
    __weak SLFontDownloadManager *manager = [SLFontDownloadManager sharedDownloader];
    
    if (fontName == nil || [fontName length] == 0) {
        NSLog(@"不能为空");
        return;
    }
    __block BOOL first = NO;
    dispatch_barrier_sync(manager.barrierQueue, ^{
        
        if (!manager.callbacksDict[fontName]) {
            manager.callbacksDict[fontName] = [NSMutableArray new];
            first = YES;
        }
        
        // Handle single download of simultaneous download request for the same URL
        NSMutableArray *callbackArray = manager.callbacksDict[fontName];
        
        [callbackArray addObject:success];
        
    });
    
    if (first) {
        operation = [[SLFontDownloaderOperation alloc] initWithFontName:fontName completed:^(NSString *fontName) {
            //启动剩余的operation
            
            for (CompleteBlock callback in [manager callbacksForFont:fontName]) {
                if (callback) {
                    callback(fontName);
                }
            }
            [manager removeCallbacksForFontName:fontName];
        } failure:^(NSError * error) {
            [manager removeCallbacksForFontName:fontName];
        }];
        
        [manager.downloadQueue addOperation:operation];
        
        NSLog(@"count:%@",@(manager.downloadQueue.operationCount));
    }
    
}


- (void)removeCallbacksForFontName:(NSString *)fontName {
    dispatch_barrier_async(self.barrierQueue, ^{
        [self.callbacksDict removeObjectForKey:fontName];
    });
}


- (NSArray *)callbacksForFont:(NSString *)fontName {
    __block NSArray *callbacksArray;
    dispatch_sync(self.barrierQueue, ^{
        callbacksArray = self.callbacksDict[fontName];
    });
    return [callbacksArray copy];
}



@end
