//
//  SLFontDownloadManager.h
//  SLSetFont
//
//  Created by LiuShulong on 4/5/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SLFontDownloadManager : NSObject

+ (void)downloadFontWithFontName:(NSString *)fontName
                         success:(void(^)(NSString *fontName)) sccess;

@end
