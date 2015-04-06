//
//  UIButton+WebFont.m
//  SLSetFont
//
//  Created by LiuShulong on 4/6/15.
//  Copyright (c) 2015 LiuShulong. All rights reserved.
//

#import "UIButton+WebFont.h"
#import "SLFontDownloadManager.h"

@implementation UIButton (WebFont)

- (void)sl_setFontWithFontName:(NSString *)fontName size:(CGFloat)size
{
    if (fontName != nil && [fontName length] > 0) {
        
        UIFont* aFont = [UIFont fontWithName:fontName size:size];
        
        // If the font is already downloaded
        if (aFont && ([aFont.fontName compare:fontName] == NSOrderedSame || [aFont.familyName compare:fontName] == NSOrderedSame)) {
            // Go ahead and display the sample text
            self.titleLabel.font = aFont;
            return;
        }
        
        __weak UIButton *weakSelf = self;

        [SLFontDownloadManager downloadFontWithFontName:fontName success:^(NSString *fontName) {
            weakSelf.titleLabel.font = [UIFont fontWithName:fontName size:size];
        }];
        
    }
}


@end
