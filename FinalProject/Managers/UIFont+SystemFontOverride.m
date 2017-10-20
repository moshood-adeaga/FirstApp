//
//  UIFont+SystemFontOverride.m
//  FinalProject
//
//  Created by Moshood Adeaga on 15/10/2017.
//  Copyright © 2017 moshood. All rights reserved.
//

#import "UIFont+SystemFontOverride.h"

@implementation UIFont (SystemFontOverride)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"
// An Overide System to Override Fonts in the App.
+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    NSUserDefaults *standardUserDefaults;
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [UIFont fontWithName:[standardUserDefaults objectForKey:@"settingsFont"]size:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    NSUserDefaults *standardUserDefaults;
    standardUserDefaults = [NSUserDefaults standardUserDefaults];
    return [UIFont fontWithName:[standardUserDefaults objectForKey:@"settingsFont"] size:fontSize];
}

#pragma clang diagnostic pop
@end
