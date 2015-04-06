//
//  WebFont.m
//  demo_异步下载字体
//
//  Created by yuangong on 1/30/15.
//  Copyright (c) 2015 daDreams. All rights reserved.
//

#import "UILabel+SLWebFont.h"

#import "SLFontDownloadManager.h"

@implementation UILabel(SLWebFont)

- (void)sl_setFontWithFontName:(NSString *)fontName size:(CGFloat)size
{
    if (fontName != nil && [fontName length] > 0) {
        
        UIFont* aFont = [UIFont fontWithName:fontName size:size];
        // If the font is already downloaded
        if (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame)) {
            // Go ahead and display the sample text
            self.font = aFont;
            return;
        }
        
        __weak UILabel *weakSelf = self;
        [SLFontDownloadManager downloadFontWithFontName:fontName success:^(NSString *fontName) {
            weakSelf.font = [UIFont fontWithName:fontName size:size];
        }];

    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
