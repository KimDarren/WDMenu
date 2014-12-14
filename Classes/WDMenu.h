#import <UIKit/UIKit.h>

@interface WDMenu : UIView

@property (nonatomic) CGFloat animationDuration;    // Default value : 0.25f

@property (strong, nonatomic) UIImage *buttonImage;
@property (strong, nonatomic) UIButton *openButton;
@property (strong, nonatomic) UIView *contentsView;

- (instancetype)initWithContentsView:(id)contentsView
                           superView:(UIView *)superView
                              height:(CGFloat)height
                         buttonImage:(UIImage *)buttonImage;

@end
