//
//  SLFontDownloaderOperation.h
//  SLSetFont
//
//  Created by LiuShulong on 4/5/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteBlock)(NSString *fontName);

@interface SLFontDownloaderOperation : NSOperation

@property (readonly,strong,nonatomic) NSURLRequest *request;

- (id)initWithFontName:(NSString *)fontName
             completed:(void(^)(NSString *fontName))complete
               failure:(void(^)(NSError *))failure;

@end
