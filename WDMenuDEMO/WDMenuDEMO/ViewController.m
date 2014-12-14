#import "ViewController.h"
#import "WDMenu.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *contentsView = [[[NSBundle mainBundle] loadNibNamed:@"MenuContentsView" owner:self options:nil] objectAtIndex:0];   // It's just dummy contents view.
    UIImage *buttonImage = [UIImage imageNamed:@"WDMenu_open_button"];    // Generate dummy image for open button.

    WDMenu *menu = [[WDMenu alloc] initWithContentsView:contentsView
                                              superView:self.view       // The reason WDMenu needs SuperView property is to calculate position.
                                                 height:62.0f
                                            buttonImage:buttonImage];   // Init WDMenu with some options.
    [self.view addSubview:menu];
    
    /*
    // More tips!
    menu.animationDuration = 5.0f;  // You can set the custom animation duration. (Default value : 0.25f)
    menu.backgroundColor = [UIColor redColor];  // You can set the background color, too. (Default value : [UIColor colorWithWhite:1 alpha:0.5])
    */
}

@end
