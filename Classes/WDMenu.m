
#import "WDMenu.h"
#import "UIButton+WDExtensions.h"

// Macro to calculate rotation angle.
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

static CGFloat WDMenuOpenButtonIconSize = 16.0f;
static CGFloat WDMenuOpenButtonMaskSize = 44.0f;
static CGFloat WDMenuDefaultAnimationDuration = 0.25;

static NSString *WDMenuOpeningAnimationKey = @"openingAnimation";
static NSString *WDMenuClosingAnimationKey = @"closingAnimation";
static NSString *WDMenuRotaionAnimationKey = @"rotaionAnimation";

static NSString *WDKeyBounds = @"bounds";
static NSString *WDKeyPosition = @"position";
static NSString *WDKeyCornerRadius = @"cornerRadius";
static NSString *WDKeyRotation = @"transform.rotation.z";

typedef NS_ENUM(NSInteger, WDMenuAnimationOption) {
    WDMenuAnimationOptionOpening,
    WDMenuAnimationOptionClosing
};

@interface WDMenu ()

@property (nonatomic) BOOL status;
@property (nonatomic, retain) UIView *maskView;

@property (nonatomic, retain) NSDictionary *openingAnimations;
@property (nonatomic, retain) NSDictionary *closingAnimations;

@end

@implementation WDMenu

- (instancetype)initWithContentsView:(id)contentsView
                           superView:(UIView *)superView
                              height:(CGFloat)height
                         buttonImage:(UIImage *)buttonImage
{
    CGSize superSize = superView.frame.size;
    self = [super initWithFrame:CGRectMake(0, superSize.height - height, superSize.width, height)];
    if (self)
    {
        // Add contents view
        self.contentsView = contentsView;
        self.contentsView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentsView];
        
        // Set background color
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        
        // Initialize open button ('+' button)
        self.openButton = [[UIButton alloc] initWithFrame:CGRectMake(superSize.width - 33 - WDMenuOpenButtonIconSize,
                                                                     (height - WDMenuOpenButtonIconSize) / 2.0f,
                                                                     WDMenuOpenButtonIconSize,
                                                                     WDMenuOpenButtonIconSize)];    // Init with frame
        self.buttonImage = buttonImage;
        [self.openButton setImage:self.buttonImage forState:UIControlStateNormal]; // Set icon image
        [self.openButton addTarget:self action:@selector(openButtonEvent) forControlEvents:UIControlEventTouchUpInside]; // Add event
        [self.openButton setHitEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];    // Make open button more easy to touch.
        [self addSubview:self.openButton];
        
        // Initialize view will use as mask of current view.
        CGRect maskViewFrame = CGRectMake(superSize.width - WDMenuOpenButtonMaskSize - 19,
                                          (height - WDMenuOpenButtonMaskSize) / 2.0f,
                                          WDMenuOpenButtonMaskSize,
                                          WDMenuOpenButtonMaskSize);
        self.maskView = [[UIView alloc] initWithFrame:maskViewFrame];
        self.maskView.backgroundColor = [UIColor blackColor];
        self.maskView.layer.cornerRadius = WDMenuOpenButtonMaskSize/2.0f;
        self.layer.mask = self.maskView.layer;
        
        // Initialize dictionaries contain value of animations
        self.openingAnimations = @{WDKeyBounds: [NSValue valueWithCGRect:CGRectMake(0, 0, self.bounds.size.width*1.1f, self.bounds.size.width*1.1f)],
                                   WDKeyPosition: [NSValue valueWithCGPoint:CGPointMake(self.center.x, self.maskView.layer.position.y)],
                                   WDKeyCornerRadius: @(self.bounds.size.width*1.1f/2.0f),
                                   WDKeyRotation: @(DEGREES_TO_RADIANS(135.0f))};
        self.closingAnimations = @{WDKeyBounds: [NSValue valueWithCGRect:CGRectMake(0, 0, WDMenuOpenButtonMaskSize, WDMenuOpenButtonMaskSize)],
                                   WDKeyPosition: [NSValue valueWithCGPoint:self.openButton.center],
                                   WDKeyCornerRadius: @(WDMenuOpenButtonMaskSize/2.0f),
                                   WDKeyRotation: @(DEGREES_TO_RADIANS(0))};
        
        // Set default value of animation duration.
        self.animationDuration = WDMenuDefaultAnimationDuration;
    }
    return self;
}

#pragma mark - Setters

- (void)setAnimationDuration:(CGFloat)animationDuration
{
    _animationDuration = animationDuration;
}

- (void)setButtonImage:(UIImage *)buttonImage
{
    _buttonImage = buttonImage;
    [_openButton setImage:_buttonImage forState:UIControlStateNormal];
}

#pragma mark - Actions

- (void)openButtonEvent
{
    if (_status)
        [self closingAnimation];
    else
        [self openingAnimation];
}

#pragma mark - Methods to generate animation

- (CABasicAnimation *)animationWithKeyPath:(NSString *)keyPath andOption:(WDMenuAnimationOption)option
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
    if (option == WDMenuAnimationOptionOpening) {
        animation.toValue = _openingAnimations[keyPath];
        animation.fromValue = _closingAnimations[keyPath];
    } else {
        animation.toValue = _closingAnimations[keyPath];
        animation.fromValue = _openingAnimations[keyPath];
    }
    
    return animation;
}

- (CAAnimationGroup *)animationGroupWithAnimations:(NSArray *)animations andKey:(NSString *)key
{
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.animations = animations;
    animationGroup.duration = _animationDuration;
    animationGroup.delegate = self;
    [animationGroup setValue:key forKey:@"id"];
    animationGroup.autoreverses = NO;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    return animationGroup;
}

#pragma mark - Animations

- (void)openingAnimation
{
    [self animateRotaionWithOption:WDMenuAnimationOptionOpening];
    CABasicAnimation *boundsAnimation = [self animationWithKeyPath:WDKeyBounds andOption:WDMenuAnimationOptionOpening];
    CABasicAnimation *positionAnimation = [self animationWithKeyPath:WDKeyPosition andOption:WDMenuAnimationOptionOpening];
    CABasicAnimation *cornerRadiusAnimation = [self animationWithKeyPath:WDKeyCornerRadius andOption:WDMenuAnimationOptionOpening];
    CAAnimationGroup *animationGroup = [self animationGroupWithAnimations:@[boundsAnimation, positionAnimation, cornerRadiusAnimation]
                                                                   andKey:WDMenuOpeningAnimationKey];
    
    [_maskView.layer addAnimation:animationGroup forKey:WDMenuOpeningAnimationKey];
}

- (void)closingAnimation
{
    [self animateRotaionWithOption:WDMenuAnimationOptionClosing];
    CABasicAnimation *boundsAnimation = [self animationWithKeyPath:WDKeyBounds andOption:WDMenuAnimationOptionClosing];
    CABasicAnimation *positionAnimation = [self animationWithKeyPath:WDKeyPosition andOption:WDMenuAnimationOptionClosing];
    CABasicAnimation *cornerRadiusAnimation = [self animationWithKeyPath:WDKeyCornerRadius andOption:WDMenuAnimationOptionClosing];
    CAAnimationGroup *animationGroup = [self animationGroupWithAnimations:@[boundsAnimation, positionAnimation, cornerRadiusAnimation]
                                                                   andKey:WDMenuClosingAnimationKey];
    
    [_maskView.layer addAnimation:animationGroup forKey:WDMenuClosingAnimationKey];
}

// This methos makes icon button rotate.
- (void)animateRotaionWithOption:(WDMenuAnimationOption)option
{
    CABasicAnimation *rotationAnimation = [self animationWithKeyPath:WDKeyRotation andOption:option];
    rotationAnimation.duration = _animationDuration;
    
    [_openButton.layer addAnimation:rotationAnimation forKey:WDMenuRotaionAnimationKey];
}

#pragma mark - CAAnimation delegates

- (void)animationDidStart:(CAAnimation *)animation
{
    _status = !_status;
    _openButton.userInteractionEnabled = NO;
    if ([[animation valueForKey:@"id"] isEqualToString:WDMenuClosingAnimationKey]) {
        _maskView.layer.bounds = [_closingAnimations[WDKeyBounds] CGRectValue];
        _maskView.layer.position = [_closingAnimations[WDKeyPosition] CGPointValue];
        _maskView.layer.cornerRadius = [_closingAnimations[WDKeyCornerRadius] floatValue];
        _openButton.transform = CGAffineTransformMakeRotation([_closingAnimations[WDKeyRotation] floatValue]);
    } else {
        _maskView.layer.bounds = [_openingAnimations[WDKeyBounds] CGRectValue];
        _maskView.layer.position = [_openingAnimations[WDKeyPosition] CGPointValue];
        _maskView.layer.cornerRadius = [_openingAnimations[WDKeyCornerRadius] floatValue];
        _openButton.transform = CGAffineTransformMakeRotation([_openingAnimations[WDKeyRotation] floatValue]);
    }
}

- (void)animationDidStop:(CAAnimation *)animation finished:(BOOL)flag
{
    _openButton.userInteractionEnabled = YES;
}

@end
