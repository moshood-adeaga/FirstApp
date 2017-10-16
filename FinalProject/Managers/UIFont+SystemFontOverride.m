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

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:fontSize];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"AmericanTypewriter-Condensed" size:fontSize];
}

#pragma clang diagnostic pop
@end
