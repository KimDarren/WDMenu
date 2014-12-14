// developed by Kim Tae Jun (korean.darren@gmail.com)

#import "UIButton+WDExtensions.h"

#import <objc/runtime.h>

@implementation UIButton (WDExtensions)
@dynamic hitEdgeInsets;

static const NSString *WDHitEdgeInsetsKey = @"HitTestEdgeInsets";

- (void)setHitEdgeInsets:(UIEdgeInsets)hitEdgeInsets
{
    NSValue *value = [NSValue value:&hitEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &WDHitEdgeInsetsKey, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)hitEdgeInsets
{
    NSValue *value = objc_getAssociatedObject(self, &WDHitEdgeInsetsKey);
    if (value) {
        UIEdgeInsets edgeInsets; [value getValue:&edgeInsets];
        return edgeInsets;
    }
    else
        return UIEdgeInsetsZero;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    if (UIEdgeInsetsEqualToEdgeInsets(self.hitEdgeInsets, UIEdgeInsetsZero) || !self.enabled || self.hidden)
        return [super pointInside:point withEvent:event];
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}

@end