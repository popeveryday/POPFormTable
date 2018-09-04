//
//  ViewLib.m
//  Pods
//
//  Created by Trung Pham Hieu on 2/5/16.
//
//

#import "ViewLib.h"
#import "RTLabel.h"
#import "PageView.h"
#import "CollectionView.h"
#import "QUIBuilder.h"

@implementation ViewLib

+(UIButton*)createButton:(NSString*)title frame:(CGRect)frame font:(NSString*) font fontSize: (CGFloat)size buttonType: (UIButtonType) buttonType backgroundColor: (UIColor*)backgroundColor foreColor:(UIColor*)foreColor  imageName:(NSString*)image highlightedImageName:(NSString*)highlightedImage target:(id) target selector:(SEL) selector
{
    return [self createButton:title frame:frame font:font fontSize:size buttonType:buttonType backgroundColor:backgroundColor foreColor:foreColor image: image != nil ? [UIImage imageNamed:image] : nil highlightedImage: highlightedImage != nil ? [UIImage imageNamed:highlightedImage] : nil target:target selector:selector];
}

+(UIButton*)createButton:(NSString*)title frame:(CGRect)frame font:(NSString*) font fontSize: (CGFloat)size buttonType: (UIButtonType) buttonType backgroundColor: (UIColor*)backgroundColor foreColor:(UIColor*)foreColor  image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage target:(id) target selector:(SEL) selector
{
    UIButton *myButton = [UIButton buttonWithType:buttonType];
    
    myButton.frame = frame; // position in the parent view and set the size of the button
    
    if (backgroundColor != nil) {
        myButton.backgroundColor = backgroundColor;
    }
    
    if (foreColor != nil) {
        [myButton setTitleColor: foreColor forState:UIControlStateNormal];
    }
    
    if ( [StringLib isValid:font] && size > 0 ) {
        myButton.titleLabel.font = [UIFont fontWithName:font size:size];
    }else if(size > 0){
        myButton.titleLabel.font = [UIFont systemFontOfSize:size];
    }
    
    myButton.titleLabel.numberOfLines = 0;
    myButton.userInteractionEnabled = YES;
    
    if (title != nil) {
        [myButton setTitle:title forState:UIControlStateNormal];
    }
    
    
    if (selector != nil && target != nil) {
        [myButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (image != nil) {
        [myButton setBackgroundImage:image forState:UIControlStateNormal];
    }
    
    if (highlightedImage != nil) {
        [myButton setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    }
    
    return myButton;
}

+(UIButton*)createButtonWithImageName:(NSString*)image highlightedImageName:(NSString*)highlightedImage target:(id) target selector:(SEL) selector
{
    UIImage* img = [UIImage imageNamed:image];
    
    return [self createButton:nil frame:CGRectMake(0, 0, img.size.width, img.size.height) font:nil fontSize:18 buttonType:UIButtonTypeCustom backgroundColor:nil foreColor:nil imageName:image highlightedImageName:highlightedImage target:target selector:selector];
}

+(UIButton*)createButtonWithImage:(UIImage*)image highlightedImage:(UIImage*)highlightedImage target:(id) target selector:(SEL) selector
{
    return [self createButton:nil frame:CGRectMake(0, 0, image.size.width, image.size.height) font:nil fontSize:18 buttonType:UIButtonTypeCustom backgroundColor:nil foreColor:nil image:image highlightedImage:highlightedImage target:target selector:selector];
}

+(MBProgressHUD*)showInformBoxNoInternet:(UIView*)uiview
{
    return [self showInformBoxWithTitle:LocalizedText(@"No Internet",nil) detailText:LocalizedText(@"Please check your internet connection\nand try again.",nil) uiview:uiview delegate:nil];
}

+(MBProgressHUD*)showInformBoxNoInternetPullDownToRefresh:(UIView*)uiview
{
    return [self showInformBoxWithTitle:LocalizedText(@"No Internet",nil) detailText:LocalizedText(@"Please check your internet connection\nand pull down to refresh.",nil) uiview:uiview delegate:nil];
}

+(MBProgressHUD*)showInformBoxWithTitle:(NSString*)title detailText:(NSString*)detailText uiview:(UIView*)uiview delegate:(id<MBProgressHUDDelegate>) delegate
{
    MBProgressHUD* loading;
    NSInteger indicatorTag = 12345679;
    
    if ([uiview viewWithTag:indicatorTag]) {
        loading = (MBProgressHUD*)[uiview viewWithTag:indicatorTag];
    }else{
        loading = [[MBProgressHUD alloc] initWithView:uiview];
        [uiview addSubview:loading];
        if(delegate != nil) loading.delegate = delegate;
        loading.tag = indicatorTag;
        loading.mode = MBProgressHUDModeText;
        loading.animationType = MBProgressHUDAnimationFade;
    }
    
    loading.label.text = title == nil ? LocalizedText(@"Loading",nil) : title;
    loading.detailsLabel.text = detailText == nil ? LocalizedText(@"please wait",nil) : detailText;
    [loading showAnimated:YES];
    
    return loading;
}

+(void)hideInformBox:(UIView*) uiview{
    [self hideInformBox:uiview afterDelay:0];
}

+(void)hideInformBox:(UIView*) uiview afterDelay:(NSTimeInterval) delay{
    MBProgressHUD* loading;
    NSInteger indicatorTag = 12345679;
    
    if ([uiview viewWithTag:indicatorTag]) {
        loading = (MBProgressHUD*)[uiview viewWithTag:indicatorTag];
        if (delay > 0) {
            [loading hideAnimated:YES afterDelay:delay];
        }else{
            [loading hideAnimated:YES];
        }
        
    }
}

+(void)showLoadingWhileExecuting:(SEL)method withObject:(id)object onTarget:(id)target displayOnView:(UIView*)uiview
{
    [self showLoadingWhileExecuting:method withObject:object onTarget:target title:nil detailText:nil displayOnView:uiview delegate:nil];
}

+(void)showLoadingWhileExecuting:(SEL)method withObject:(id)object onTargetAndViewController:(UIViewController*) controller
{
    [self showLoadingWhileExecuting:method withObject:object onTarget:controller title:nil detailText:nil displayOnView:controller.view delegate:nil];
}

+(void)showLoadingWhileExecuting:(SEL)method withObject:(id)object onTarget:(id)target title:(NSString*) title detailText:(NSString*)detailText displayOnView:(UIView*)uiview delegate:(id<MBProgressHUDDelegate>)delegate
{
    MBProgressHUD* loading = [[MBProgressHUD alloc] initWithView:uiview];
    [uiview addSubview:loading];
    
    if (delegate != nil) {
        loading.delegate = delegate;
    }
    
    loading.label.text = title == nil ? LocalizedText(@"Loading",nil) : title;
    loading.detailsLabel.text = detailText == nil ? LocalizedText(@"please wait",nil) : detailText;
    loading.square = YES;
    
    [loading showWhileExecuting:method onTarget:target withObject:object animated:YES];
}

+(void)hideLoadingWithHUD:(MBProgressHUD*) loading{
    [loading hideAnimated:YES];
}

+(MBProgressHUD*)showLoadingWithTitle:(NSString*)title detailText:(NSString*)detailText uiview:(UIView*)uiview container:(id<MBProgressHUDDelegate>)container
{
    MBProgressHUD* loading;
    NSInteger indicatorTag = 12345678;
    
    if ([uiview viewWithTag:indicatorTag]) {
        loading = (MBProgressHUD*)[uiview viewWithTag:indicatorTag];
    }else{
        loading = [[MBProgressHUD alloc] initWithView:uiview];
        [uiview addSubview:loading];
        if(container != nil) loading.delegate = container;
        loading.tag = indicatorTag;
        loading.square = YES;
    }
    loading.square = YES;
    loading.label.text = title == nil ? LocalizedText(@"Loading",nil) : title;
    loading.detailsLabel.text = detailText == nil ? LocalizedText( @"please wait" ,nil) : detailText;
    [loading showAnimated:YES];
    
    return loading;
}

+(MBProgressHUD*)showLoading:(UIView*) container{
    return [self showLoadingWithTitle:nil detailText:nil uiview:container container:nil];
}

+(void)hideLoading:(UIView*) container{
    MBProgressHUD* loading;
    NSInteger indicatorTag = 12345678;
    
    
    if ([container viewWithTag:indicatorTag]) {
        loading = (MBProgressHUD*)[container viewWithTag:indicatorTag];
        [loading hideAnimated:YES];
    }
}

+(void)slideViewUpForTextfield:(UITextField*) textField viewContainer:(UIView*)view isOn:(BOOL)isOn{
    
    const CGFloat KEYBOARD_ANIMATION_DURATION = 0.2;
    const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
    const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
    const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
    const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
    
    CGRect viewFrame = view.frame;
    
    if (isOn) {
        CGRect textFieldRect = [view.window convertRect:textField.bounds fromView:textField];
        CGRect viewRect = [view.window convertRect:view.bounds fromView:view];
        CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
        CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
        CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
        CGFloat heightFraction = numerator / denominator;
        
        
        
        if (heightFraction < 0.0) heightFraction = 0.0;
        else if (heightFraction > 1.0) heightFraction = 1.0;
        
        
        UIInterfaceOrientation orientation = UIInterfaceOrientationPortrait;
#ifndef POPLIB_APP_EXTENSIONS
        orientation = [[UIApplication sharedApplication] statusBarOrientation];
#endif
        
        CGFloat subviewHeight = (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) ? PORTRAIT_KEYBOARD_HEIGHT : LANDSCAPE_KEYBOARD_HEIGHT;
        
        //neu co inputview (picker, datepicker) subview height ko doi so voi portrait height
        if (textField.inputView != Nil) {
            subviewHeight = PORTRAIT_KEYBOARD_HEIGHT;
        }
        
        // neu chu bi che thi cho animatedDistance = 0;
        if (view.bounds.size.height - subviewHeight > textFieldRect.origin.y) {
            subviewHeight = 0;
        }
        
        
        
        int animatedDistance = floor(subviewHeight * heightFraction);
        view.accessibilityHint = [NSString stringWithFormat:@"%d", animatedDistance];
        
        viewFrame.origin.y -= animatedDistance;
    }else{
        int animatedDistance = [view.accessibilityHint intValue];
        view.accessibilityHint = @"";
        viewFrame.origin.y += animatedDistance;
    }
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [view setFrame:viewFrame];
    [UIView commitAnimations];
}

+(CAEmitterLayer*) createSnowInView:(UIView*)view withImage:(UIImage*)snowImage
{
    //snow builder
    CAEmitterLayer *emitterLayer = [CAEmitterLayer layer]; // 1
    emitterLayer.emitterPosition = CGPointMake(view.bounds.size.width / 2, view.bounds.origin.y - 300); // 2
    emitterLayer.emitterZPosition = 10; // 3
    emitterLayer.emitterSize = CGSizeMake(view.bounds.size.width, 0); // 4
    emitterLayer.emitterShape = kCAEmitterLayerSphere; // 5
    
    CAEmitterCell *emitterCell = [CAEmitterCell emitterCell]; // 6
    emitterCell.scale = 0.2; // 7
    emitterCell.scaleRange = 0.7; // 8
    emitterCell.emissionRange = (CGFloat)M_PI_2; // 9
    emitterCell.lifetime = 100.0; // 10
    emitterCell.birthRate = 40; // 11
    emitterCell.velocity = 10; // 12
    emitterCell.velocityRange = 300; // 13
    emitterCell.yAcceleration = 1; // 14
    
    emitterCell.contents = (id)[snowImage CGImage]; // 15
    emitterLayer.emitterCells = [NSArray arrayWithObject:emitterCell]; // 16
    [view.layer addSublayer:emitterLayer]; // 17
    
    return emitterLayer;
}

+(UIDocumentInteractionController*)showOpenInWithFile:(NSString*)filePath container:(UIView*)container delegate:(id<UIDocumentInteractionControllerDelegate>)delegate
{
    
    
    if ( !IsOpenInAvailable(filePath) )
        return nil;
    
    UIDocumentInteractionController* documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    
    if(delegate != nil) documentController.delegate = delegate;
    
    Hashtable* identifier = [StringLib deparseString:GC_OpenIn_Identifiers];
    
    
    documentController.UTI = [identifier hashtable_GetValueForKey:[[filePath pathExtension] uppercaseString]] ;
    
    [documentController presentOpenInMenuFromRect:CGRectZero
                                           inView:container
                                         animated:YES];
    
    return documentController;
}

+(UIDocumentInteractionController*)showOpenInWithFile:(NSString*)filePath containerBarButton:(UIBarButtonItem*)container delegate:(id<UIDocumentInteractionControllerDelegate>)delegate
{
    
    
    if ( !IsOpenInAvailable(filePath) )
        return nil;
    
    UIDocumentInteractionController* documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:filePath]];
    
    if(delegate != nil) documentController.delegate = delegate;
    
    Hashtable* identifier = [StringLib deparseString:GC_OpenIn_Identifiers];
    
    
    documentController.UTI = [identifier hashtable_GetValueForKey:[[filePath pathExtension] uppercaseString]] ;
    
    [documentController presentOpenInMenuFromBarButtonItem:container animated:YES];
    
    return documentController;
}

+(void)fixNavigationBarCoverContent:(UIViewController*) controller{
    [self fixNavigationBarCoverContent:controller isFixed:YES];
}

+(void)fixNavigationBarCoverContent:(UIViewController*) controller isFixed:(BOOL)isFixed{
    controller.navigationController.navigationBar.translucent = isFixed ? NO : YES;
    if ([controller respondsToSelector:@selector(edgesForExtendedLayout)])
        controller.edgesForExtendedLayout = isFixed ? UIRectEdgeNone : UIRectEdgeAll;
}

+(void)fixNavigationBar:(UINavigationBar*)navbar translucentColor:(UIColor*)barColor
{
    CGRect frame = navbar.frame;
    frame.origin.y = -20.0f;
    frame.size.height += 20.0f;
    UIView *colorView = [[UIView alloc] initWithFrame:frame];
    colorView.opaque = NO;
    colorView.backgroundColor = barColor;
    navbar.barTintColor = barColor;
    [navbar.layer insertSublayer:colorView.layer atIndex:1];
}


+(UIEdgeInsets)collectionEdgeInsectFromHashString:(NSString*) hashString
{
    //structure hashString device = top, left, bottom, right
    //example @"iphonehd = 5, 20, 5, 20 & iphonehd5 = 5, 20, 5, 20 &...."
    
    Hashtable* hash = [StringLib deparseString:hashString];
    
    NSString* rs = [hash hashtable_GetValueForKey:GC_MobileAds_Device];
    
    if (rs == nil) {
        NSLog(@"CommonLib > GetCollectionEdgeInsectFromHashString > Cannot find EdgeInsect for device %@", GC_MobileAds_Device);
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    NSArray* parts = [rs componentsSeparatedByString:@","];
    
    CGFloat top = [parts[0] floatValue];
    CGFloat left = [parts[1] floatValue];
    CGFloat bottom = [parts[2] floatValue];
    CGFloat right = [parts[3] floatValue];
    
    return UIEdgeInsetsMake(top, left, bottom, right);
}

+(void)setNavigationBarColorHex:(NSString*)hexcolor viewController:(UIViewController*)controller{
    [self setNavigationBarColor:[CommonLib colorFromHexString:hexcolor alpha:1] viewController:controller];
}

+(void)setNavigationBarColor:(UIColor*)color viewController:(UIViewController*)controller
{
    [self setNavigationBarColor:color tintColor:[UIColor whiteColor] foregroundColor:[UIColor whiteColor] viewController:controller];
}

+(void)setNavigationBarColor:(UIColor*)color tintColor:(UIColor*)tintColor foregroundColor:(UIColor*)foregroundColor viewController:(UIViewController*)controller
{
    UINavigationBar* navbar;
    if ([controller isKindOfClass:[UINavigationController class]]) {
        navbar = ((UINavigationController*)controller).navigationBar;
    }else{
        navbar = controller.navigationController.navigationBar;
    }
    
    if (navbar) {
        [navbar setBarTintColor:color];
        [navbar setTintColor:tintColor];
        [navbar setTitleTextAttributes:@{NSForegroundColorAttributeName : foregroundColor}];
    }
    
#ifndef POPLIB_APP_EXTENSIONS
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
#endif
    
    //View controller-based status bar appearance -> NO (INFO.PLIST)
}

+(void)setToolbarColor:(UIColor*)color tintColor:(UIColor*)tintColor viewController:(UIViewController*)controller{
    [controller.navigationController.toolbar setBarTintColor:color];
    [controller.navigationController.toolbar setTintColor:[UIColor whiteColor]];
    
    //View controller-based status bar appearance -> NO (INFO.PLIST)
}

//check if this vc is root view controller or is push from navigation controller
+(BOOL)isRootViewController:(UIViewController*)controller{
    UIViewController *vc = [[controller.navigationController viewControllers] firstObject];
    return [vc isEqual: controller];
}

+(void)presentViewWithStorboardName:(NSString*)storyboardName storyboardViewID:(NSString*)viewID currentViewController:(UIViewController*)viewController displayStyle:(enum DisplayStyle) displayStyle prepareBlock:(void(^)(UIViewController* destinationVC))prepareBlock completeBlock:(void(^)(void))completeBlock
{
    UINavigationController* nav = (UINavigationController*) [viewController parentViewController];
    UIViewController* currentViewController = [nav.viewControllers firstObject];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController* nextViewController = [storyboard instantiateViewControllerWithIdentifier: viewID];
    
    [self presentViewController:nextViewController fromViewController:currentViewController displayStyle:displayStyle prepareBlock:prepareBlock completeBlock:completeBlock];
}

+(void)presentViewController:(UIViewController*)nextViewController fromViewController:(UIViewController*)currentViewController displayStyle:(enum DisplayStyle) displayStyle prepareBlock:(void(^)(UIViewController* destinationVC))prepareBlock completeBlock:(void(^)(void))completeBlock
{
    if (prepareBlock != nil) {
        prepareBlock(nextViewController);
    }
    
    UIView* snapshot = currentViewController.navigationController != nil ? [currentViewController.navigationController.view snapshotViewAfterScreenUpdates:YES] : [currentViewController.view snapshotViewAfterScreenUpdates:YES];
    
    UINavigationController* nav = (UINavigationController*) [currentViewController parentViewController];
    switch (displayStyle) {
        case DisplayStyleReplaceNavigationRootVC:
            [nav setViewControllers:@[ nextViewController ]];
            [currentViewController.view removeFromSuperview];
            currentViewController = nil;
            if (completeBlock != nil) {
                completeBlock();
            }
            break;
        case DisplayStylePresent:
            [nav presentViewController:nextViewController animated:YES completion:completeBlock];
            break;
            
        case DisplayStylePush:
            [nav pushViewController:nextViewController animated:YES];
            if (completeBlock != nil) {
                completeBlock();
            }
            break;
        case DisplayStyleReplaceWindowRootVC:
            [nextViewController.view addSubview:snapshot];
            
#ifndef POPLIB_APP_EXTENSIONS
            [[UIApplication sharedApplication].keyWindow setRootViewController:nextViewController];
#endif
            
            currentViewController = nil;
            [UIView animateWithDuration:.25 delay:0.25 options:UIViewAnimationOptionCurveLinear animations:^{
                snapshot.alpha = 0;
            } completion:^(BOOL finished) {
                [snapshot removeFromSuperview];
                if (completeBlock != nil) {
                    completeBlock();
                }
            }];
            break;
    }
}

+(void)displayPopoverController:(UIViewController*)view container:(UIViewController<UIPopoverControllerDelegate> *)container displayTarget:(id) displayTarget isIphonePushView:(BOOL) isIphonePushView
{
    [self displayPopoverController:view container:container displayTarget:displayTarget isIphonePushView:isIphonePushView isEmbedNavigationController:NO];
}

+(void)displayPopoverController:(UIViewController*)view container:(UIViewController<UIPopoverControllerDelegate> *)container displayTarget:(id) displayTarget isIphonePushView:(BOOL) isIphonePushView isEmbedNavigationController:(BOOL) isEmbedNavigationController
{
    [self displayPopoverController:view container:container displayTarget:displayTarget isIphonePushView:isIphonePushView isEmbedNavigationController:isIphonePushView customSize:CGSizeZero];
}

+(void)displayPopoverController:(UIViewController*)view container:(UIViewController<UIPopoverControllerDelegate> *)container displayTarget:(id) displayTarget isIphonePushView:(BOOL) isIphonePushView isEmbedNavigationController:(BOOL) isEmbedNavigationController customSize:(CGSize) customSize
{
    //using dispath_after to fix unshown problem in ios8
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (GC_Device_IsIpad)
        {
            UIPopoverController* aPopover = [[UIPopoverController alloc] initWithContentViewController: isEmbedNavigationController ? [[UINavigationController alloc] initWithRootViewController:view] : view ];
            
            aPopover.delegate = container;
            
            if ( !CGSizeEqualToSize(CGSizeZero, customSize) ) {
                [aPopover setPopoverContentSize: customSize];
            }else{
                [aPopover setPopoverContentSize: GC_Popover_Size];
            }
            
            
            
            [view setValue:aPopover forKey:@"popoverContainer"];
            [container setValue:aPopover forKey:@"popoverView"];
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                if ([displayTarget isKindOfClass:[UIBarButtonItem class]]) {
                    [aPopover presentPopoverFromBarButtonItem:displayTarget permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }else{
                    [aPopover presentPopoverFromRect:[displayTarget bounds] inView:displayTarget permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
                }
            }];
        }else{
            if (isIphonePushView) {
                [container.navigationController pushViewController:view animated:YES];
            }else{
                [container presentViewController:view animated:YES completion:nil];
            }
            
        }
    });
}


+(id) initAutoLayoutWithType:(enum ALControlType)type viewContainer:(UIView*)viewContainer superEdge:(NSString*)superEdge otherEdge:(NSDictionary*)otherEdge
{
    return [self initAutoLayoutWithType:type viewContainer:viewContainer superEdge:superEdge otherEdge:otherEdge viewName:nil];
}

+(id) initAutoLayoutWithType:(enum ALControlType)type viewContainer:(UIView*)viewContainer superEdge:(NSString*)superEdge otherEdge:(NSDictionary*)otherEdge viewName:(NSString*)viewName
{
    id control;
    
    if (type == ALControlTypeLabel) {
        control = [UILabel newAutoLayoutView];
        [(UILabel*)control setLineBreakMode:NSLineBreakByTruncatingTail];
        [(UILabel*)control setNumberOfLines:0];
        [(UILabel*)control setTextAlignment:NSTextAlignmentLeft];
    }
    else if (type == ALControlTypeColorLabel)
    {
        control = [RTLabel newAutoLayoutView];
        [(RTLabel*)control setLineBreakMode:RTTextLineBreakModeWordWrapping];
        [(RTLabel*)control setTextAlignment:RTTextAlignmentLeft];
    }
    else if (type == ALControlTypeImage)
    {
        control = [UIImageView newAutoLayoutView];
        ((UIImageView*)control).contentMode = UIViewContentModeScaleAspectFit;
        ((UIImageView*)control).backgroundColor = [UIColor colorWithRed:224 green:224 blue:224 alpha:1];
    }
    else if (type == ALControlTypeView)
    {
        control = [UIView newAutoLayoutView];
    }
    else if (type == ALControlTypeButton)
    {
        control = [UIButton buttonWithType:UIButtonTypeCustom];
        [control configureForAutoLayout];
    }
    else if (type == ALControlTypeTextView)
    {
        control = [UITextView newAutoLayoutView];
    }
    else if (type == ALControlTypeTextField)
    {
        control = [UITextField newAutoLayoutView];
    }
    else if (type == ALControlTypeProgressView)
    {
        control = [UIProgressView newAutoLayoutView];
    }
    else if (type == ALControlTypeVisualEffectView)
    {
        control = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        [control configureForAutoLayout];
    }
    else if (type == ALControlTypeScrollView)
    {
        control = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [control configureForAutoLayout];
    }
    else if (type == ALControlTypePageView)
    {
        control = [[PageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [control configureForAutoLayout];
    }
    else if (type == ALControlTypeCollectionView)
    {
        control = [[CollectionView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [control configureForAutoLayout];
    }
    else if (type == ALControlTypeSlider)
    {
        control = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [control configureForAutoLayout];
    }
    else if (type == ALControlTypeSwitch)
    {
        control = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [control configureForAutoLayout];
    }
    
    
    
    //fix bug UIVisualEffectView add subview
    if (GC_Device_iOsVersion >= 11 && [viewContainer isKindOfClass:[UIVisualEffectView class]]) {
        [((UIVisualEffectView*)viewContainer).contentView addSubview:control];
    }else{
        [viewContainer addSubview:control];
    }
    
    if(viewName) ((UIView*)control).viewName = viewName;
    
    [self updateLayoutForView:control superEdge:superEdge otherEdge:otherEdge];
    
    return control;
}

+(void) updateLayoutForView:(ALView*)view superEdge:(NSString*)superEdge otherEdge:(NSDictionary*)otherEdge
{
    
    NSMutableArray* addedEdge = [[NSMutableArray alloc] init];
    if (otherEdge != nil) {
        for (NSString* edge in otherEdge.allKeys) {
            [addedEdge addObject:[self pinEdgeWithView:view edgeStr:edge otherView:[otherEdge objectForKey:edge]]];
        }
    }
    
    if (superEdge != nil)
    {
        for (NSString* letter in [@"T,R,L,B,C,H,V,W,E,S" componentsSeparatedByString:@","] ) {
            superEdge = [superEdge stringByReplacingOccurrencesOfString:letter withString:[NSString stringWithFormat:@",%@",letter]];
        }
        
        NSArray* superEdgeArray = [[superEdge stringByReplacingOccurrencesOfString:@",," withString:@","] componentsSeparatedByString:@","];
        
        for (NSString* edgeStr in superEdgeArray) {
            if (![StringLib isValid:edgeStr]) continue;
            if([addedEdge containsObject:[edgeStr substringToIndex:1]]) continue;
            [self pinEdgeWithView:view edgeStr:edgeStr otherView:nil];
        }
    }
}

+(NSString*) pinEdgeWithView:(UIView*)view edgeStr:(NSString*)edgeStr otherView:(UIView*)otherView
{
    NSString* direction = [edgeStr substringToIndex:1];
    NSLayoutConstraint* lct = nil;
    NSArray<NSLayoutConstraint*>* lctArr = nil;
    
    if ([direction isEqualToString:@"C"]) {
        lctArr = [view autoCenterInSuperview];
        for (NSLayoutConstraint* _lct in lctArr)
        {
            _lct.identifier = [NSString stringWithFormat:@"%@%@|%@", direction, @([lctArr indexOfObject:_lct]), [view valueForKey:@"viewName"] ];
        };
        
        return direction;
    }
    
    if ([direction isEqualToString:@"H"]) {
        lct = [view autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        lct.identifier = [NSString stringWithFormat:@"%@|%@",direction, [view valueForKey:@"viewName"]];
        return direction;
    }
    
    if ([direction isEqualToString:@"V"]) {
        lct = [view autoAlignAxisToSuperviewAxis:ALAxisVertical];
        lct.identifier = [NSString stringWithFormat:@"%@|%@",direction, [view valueForKey:@"viewName"]];
        return direction;
    }
    
    enum NSLayoutRelation relation = [StringLib contains:@">" inString:edgeStr] ? NSLayoutRelationGreaterThanOrEqual : [StringLib contains:@"<" inString:edgeStr] ? NSLayoutRelationLessThanOrEqual : NSLayoutRelationEqual;
    NSString* insetStr = [[[edgeStr substringFromIndex:1] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@"<" withString:@""];
    
    //Width: W100, Height: E100, Size: S100#100 or S100
    if ( [StringLib contains:direction inString:@"WES"] ) {
        if(![StringLib isValid:insetStr]) return direction;
        
        if([direction isEqualToString:@"S"])
        {
            NSArray* sizeParts = [insetStr componentsSeparatedByString:@"#"];
            CGFloat width = [[sizeParts firstObject] floatValue];
            CGFloat height = sizeParts.count >= 2 ? [[sizeParts objectAtIndex:1] floatValue] : width;
            lctArr = [view autoSetDimensionsToSize:CGSizeMake(width, height)];
            for (NSLayoutConstraint* _lct in lctArr)
            {
                _lct.identifier = [NSString stringWithFormat:@"%@%@|%@", direction, @([lctArr indexOfObject:_lct]), [view valueForKey:@"viewName"] ];
            };
        }
        else if([direction isEqualToString:@"W"])
        {
            CGFloat width = [insetStr floatValue];
            lct = [view autoSetDimension:ALDimensionWidth toSize:width relation:relation];
            lct.identifier = [NSString stringWithFormat:@"%@|%@",direction, [view valueForKey:@"viewName"]];
        }
        else
        {
            CGFloat height = [insetStr floatValue];
            lct = [view autoSetDimension:ALDimensionHeight toSize:height relation:relation];
            lct.identifier = [NSString stringWithFormat:@"%@|%@",direction, [view valueForKey:@"viewName"]];
        }
        
        return direction;
    }
    
    
    
    CGFloat inset = [StringLib isValid:insetStr] ? [insetStr floatValue] : 10;
    enum ALEdge edge = [StringLib indexOf:direction inString:@" LRTB"];
    
    if (otherView == nil) {
        if(edge == ALEdgeLeft) edge = ALEdgeLeading;
        else if(edge == ALEdgeRight) edge = ALEdgeTrailing;
        lct = [view autoPinEdgeToSuperviewEdge:edge withInset:inset relation:relation];
        lct.identifier = [NSString stringWithFormat:@"%@|%@",direction, [view valueForKey:@"viewName"]];
    }else{
        enum ALEdge otheredge = [[@"02143" substringWithRange: NSMakeRange(edge, 1)] integerValue];
        lct = [view autoPinEdge:edge toEdge:otheredge ofView:otherView withOffset:inset relation:relation];
        lct.identifier = [NSString stringWithFormat:@"%@|%@",direction, [view valueForKey:@"viewName"]];
    }
    
    return direction;
}

+(CGFloat)getCustomPaddingSuperEdge:(NSString*)key fullText:(NSString*)fullText
{
    key = [[key stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""];
    NSInteger index = [StringLib indexOf:key inString:fullText];
    NSString* customPaddingStr = @"";
    NSString* nextLetter = @"";
    for (NSInteger i = index+1; i < fullText.length ; i++) {
        nextLetter = [fullText substringWithRange: NSMakeRange(i, 1) ];
        if ( [StringLib contains:nextLetter inString:@"LTRBC"] ) break;
        customPaddingStr = [customPaddingStr stringByAppendingString: nextLetter];
    }
    if ([customPaddingStr isEqualToString:@""]) return 10;
    return [customPaddingStr floatValue];
}

+(CAShapeLayer*) drawCircleProgressWithView:(UIView*)view progress:(CGFloat)progress size:(CGSize)size strokeColor:(UIColor*)strokeColor fillColor:(UIColor*)fillColor lineWidth:(CGFloat)lineWidth
{
    CAShapeLayer *progressLayer = [self drawCircleProgress:progress size:size strokeColor:strokeColor fillColor:fillColor lineWidth:lineWidth];
    [view.layer addSublayer:progressLayer];
    return progressLayer;
}

+(CAShapeLayer*) drawCircleProgress:(CGFloat)progress size:(CGSize)size strokeColor:(UIColor*)strokeColor fillColor:(UIColor*)fillColor lineWidth:(CGFloat)lineWidth
{
    CGFloat startAngle = - ((float)M_PI / 2); // 90 degrees
    CGFloat endAngle = (2 * (float)M_PI) + startAngle;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(size.width/2,
                                             size.width/2)
                          radius:size.width/2
                      startAngle:startAngle
                        endAngle:endAngle
                       clockwise:YES];
    
    CAShapeLayer *progressLayer = [[CAShapeLayer alloc] init];
    [progressLayer setPath:bezierPath.CGPath];
    [progressLayer setStrokeColor:strokeColor?strokeColor.CGColor:[UIColor grayColor].CGColor];
    [progressLayer setFillColor:fillColor?fillColor.CGColor:[UIColor clearColor].CGColor];
    [progressLayer setLineWidth:lineWidth<=0?5.0:lineWidth];
    [progressLayer setStrokeEnd:progress];
    
    return progressLayer;
}

+ (void)alertWithTitle:(NSString*) title message:(NSString*) message fromViewController:(UIViewController*)fromViewController callback:(AlertViewCompletionBlock)callback cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    void (^buttonHandler)(UIAlertAction *action) = ^void(UIAlertAction *action) {
        if(callback) callback(action.title, title);
    };
    
    if (otherButtonTitles != nil)
    {
        [alertController addAction:[UIAlertAction actionWithTitle:otherButtonTitles style:UIAlertActionStyleDefault handler:buttonHandler]];
        
        va_list args;
        va_start(args, otherButtonTitles);
        NSString* name;
        while ((name = va_arg(args, NSString*))) {
            if ([StringLib isValid:name]) {
                [alertController addAction:[UIAlertAction actionWithTitle:name style:UIAlertActionStyleDefault handler:buttonHandler]];
            }
        }
        va_end(args);
    }
    
    [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:buttonHandler]];
    
#ifndef POPLIB_APP_EXTENSIONS
    if(!fromViewController) fromViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
#endif
    
    if(fromViewController) [fromViewController presentViewController:alertController animated:YES completion:nil];
}

+(BOOL)alertNetworkConnectionStatusWithTitle:(NSString*) title message:(NSString*)message fromViewController:(UIViewController*)vc
{
    if (![NetLib isNetworkConnectionReady]) {
        [self alertWithTitle:(!title ? LocalizedText(@"Connection error",nil) : title) message:(!message ? LocalizedText(@"Unable to connect with the server.\nCheck your internet connection and try again.",nil) : message) fromViewController:vc callback:nil cancelButtonTitle:LocalizedText(@"OK",nil) otherButtonTitles:nil];
        return NO;
    }
    return YES;
}

+(BOOL)alertNetworkConnectionStatusFromViewController:(UIViewController*)vc{
    return [self alertNetworkConnectionStatusWithTitle:nil message:nil fromViewController:vc];
}

+(NSArray*)alertUpgrageFeaturesWithContainer:(id)container isIncludeRestoreButton:(BOOL)isIncludeRestoreButton fromViewController:(UIViewController*)vc callback:(AlertViewCompletionBlock)callback
{
    [self alertWithTitle:LocalizedText( @"Upgrage Required" ,nil) message:LocalizedText( @"To unlock this feature you need to upgrade to pro version. Would you like to upgrade now?" ,nil) fromViewController:vc callback:callback cancelButtonTitle:LocalizedText( @"Later" ,nil) otherButtonTitles:LocalizedText( @"Yes, upgrade now" ,nil), isIncludeRestoreButton ? LocalizedText( @"Restore purchases" ,nil) : nil, nil];
    
    return @[LocalizedText( @"Yes, upgrade now" ,nil), LocalizedText( @"Restore purchases" ,nil)];
}

+(NSArray*)alertUpgrageFeaturesUnlimitWithContainer:(id)container limitMessage:(NSString*)limitMessage isIncludeRestoreButton:(BOOL)isIncludeRestoreButton fromViewController:(UIViewController*)vc callback:(AlertViewCompletionBlock)callback
{
    NSString* message = LocalizedText(@"To use unlimited features you need to upgrade to pro version. Would you like to upgrade now?",nil);
    if ( [StringLib isValid:limitMessage] ) {
        message = [NSString stringWithFormat:@"%@\n%@",limitMessage, message];
    }
    
    [self alertWithTitle:LocalizedText(@"Upgrage Required",nil) message:message fromViewController:vc callback:callback cancelButtonTitle:LocalizedText(@"Later",nil) otherButtonTitles:LocalizedText(@"Yes, upgrade now",nil), isIncludeRestoreButton ? LocalizedText(@"Restore purchases",nil) : nil, nil];
    
    return @[LocalizedText(@"Yes, upgrade now",nil), LocalizedText(@"Restore purchases",nil)];
}

+(NSArray*)alertUpgrageProVersionWithContainer:(id)container featuresMessage:(NSString*)featuresMessage isIncludeRestoreButton:(BOOL)isIncludeRestoreButton fromViewController:(UIViewController*)vc callback:(AlertViewCompletionBlock)callback
{
    NSString* message = LocalizedText(@"Purchase to unlock following features?",nil);
    
    if ( [StringLib isValid:featuresMessage] ) {
        message = [NSString stringWithFormat:@"%@\n%@", message, featuresMessage];
    }else{
        message = LocalizedText(@"Purchase to unlock full features?",nil);
    }
    
    [self alertWithTitle:LocalizedText(@"Upgrage to Pro Version",nil) message:message fromViewController:vc callback:callback cancelButtonTitle:LocalizedText(@"Later",nil) otherButtonTitles:LocalizedText(@"Yes, upgrade now",nil), isIncludeRestoreButton ? LocalizedText(@"Restore purchases",nil) : nil, nil];
    
    return @[LocalizedText(@"Yes, upgrade now",nil), LocalizedText(@"Restore purchases",nil)];
}

+ (void)alert:(NSString*) message
{
    [self alertWithTitle:nil message:message];
}

+ (void)alertWithTitle:(NSString*)title message:(NSString*) message
{
    [self alertWithTitle:(title?title:LocalizedText(@"Message", nil)) message:message fromViewController:nil callback:nil cancelButtonTitle:LocalizedText(@"OK", nil) otherButtonTitles:nil];
}

@end

