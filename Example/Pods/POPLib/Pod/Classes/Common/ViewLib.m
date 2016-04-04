//
//  ViewLib.m
//  Pods
//
//  Created by Trung Pham Hieu on 2/5/16.
//
//

#import "ViewLib.h"

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
    
    loading.labelText = title == nil ? LocalizedText(@"Loading",nil) : title;
    loading.detailsLabelText = detailText == nil ? LocalizedText(@"please wait",nil) : detailText;
    [loading show:YES];
    
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
            [loading hide:YES afterDelay:delay];
        }else{
            [loading hide:YES];
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
    
    loading.labelText = title == nil ? LocalizedText(@"Loading",nil) : title;
    loading.detailsLabelText = detailText == nil ? LocalizedText(@"please wait",nil) : detailText;
    loading.square = YES;
    
    [loading showWhileExecuting:method onTarget:target withObject:object animated:YES];
}

+(void)hideLoadingWithHUD:(MBProgressHUD*) loading{
    [loading hide:YES];
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
    loading.labelText = title == nil ? LocalizedText(@"Loading",nil) : title;
    loading.detailsLabelText = detailText == nil ? LocalizedText( @"please wait" ,nil) : detailText;
    [loading show:YES];
    
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
        [loading hide:YES];
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
        
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
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

+(void)createSnowInView:(UIView*)view{
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
    
    emitterCell.contents = (id)[[UIImage imageNamed:@"CommonLib.bundle/snow"] CGImage]; // 15
    emitterLayer.emitterCells = [NSArray arrayWithObject:emitterCell]; // 16
    [view.layer addSublayer:emitterLayer]; // 17
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

+(void)setNavigationBarColor:(UIColor*)color tintColor:(UIColor*)tintColor foregroundColor:(UIColor*)foregroundColor viewController:(UIViewController*)controller{
    [controller.navigationController.navigationBar setBarTintColor:color];
    [controller.navigationController.navigationBar setTintColor:tintColor];
    [controller.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : foregroundColor}];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
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

+(void)presentViewWithStorboardName:(NSString*)storyboardName storyboardViewID:(NSString*)viewID currentViewController:(UIViewController*)viewController displayStyle:(enum DisplayStyle) displayStyle prepareBlock:(void(^)(UIViewController* destinationVC))prepareBlock completeBlock:(void(^)())completeBlock
{
    UINavigationController* nav = (UINavigationController*) [viewController parentViewController];
    UIViewController* currentViewController = [nav.viewControllers firstObject];
    
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:storyboardName bundle:nil];
    UIViewController* nextViewController = [storyboard instantiateViewControllerWithIdentifier: viewID];
    
    if (prepareBlock != nil) {
        prepareBlock(nextViewController);
    }
    
    UIView* snapshot = viewController.navigationController != nil ? [viewController.navigationController.view snapshotViewAfterScreenUpdates:YES] : [viewController.view snapshotViewAfterScreenUpdates:YES];
    
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
            [[UIApplication sharedApplication].keyWindow setRootViewController:nextViewController];
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

@end