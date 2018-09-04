//
//  ViewLib.h
//  Pods
//
//  Created by Trung Pham Hieu on 2/5/16.
//
//

#import <Foundation/Foundation.h>
#import "StringLib.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "GlobalConfig.h"
#import "CommonLib.h"
#import <PureLayout/PureLayout.h>

typedef void (^AlertViewCompletionBlock)(NSString* buttonTitle, NSString* alertTitle);

enum DisplayStyle{
    DisplayStyleReplaceNavigationRootVC,
    DisplayStylePush,
    DisplayStylePresent,
    DisplayStyleReplaceWindowRootVC,
};

enum ALControlType{
    ALControlTypeLabel,
    ALControlTypeImage,
    ALControlTypeView,
    ALControlTypeButton,
    ALControlTypeTextView,
    ALControlTypeTextField,
    ALControlTypeProgressView,
    ALControlTypeVisualEffectView,
    ALControlTypeColorLabel,
    ALControlTypeScrollView,
    ALControlTypePageView,
    ALControlTypeCollectionView,
    ALControlTypeSlider,
    ALControlTypeSwitch,
};


@interface ViewLib : NSObject

+(UIButton*)createButton:(NSString*)title frame:(CGRect)frame font:(NSString*) font fontSize: (CGFloat)size buttonType: (UIButtonType) buttonType backgroundColor: (UIColor*)backgroundColor foreColor:(UIColor*)foreColor  imageName:(NSString*)image highlightedImageName:(NSString*)highlightedImage target:(id) target selector:(SEL) selector;

+(UIButton*)createButton:(NSString*)title frame:(CGRect)frame font:(NSString*) font fontSize: (CGFloat)size buttonType: (UIButtonType) buttonType backgroundColor: (UIColor*)backgroundColor foreColor:(UIColor*)foreColor  image:(UIImage*)image highlightedImage:(UIImage*)highlightedImage target:(id) target selector:(SEL) selector;

+(UIButton*)createButtonWithImageName:(NSString*)image highlightedImageName:(NSString*)highlightedImage target:(id) target selector:(SEL) selector;

+(UIButton*)createButtonWithImage:(UIImage*)image highlightedImage:(UIImage*)highlightedImage target:(id) target selector:(SEL) selector;

+(MBProgressHUD*)showInformBoxNoInternet:(UIView*)uiview;

+(MBProgressHUD*)showInformBoxNoInternetPullDownToRefresh:(UIView*)uiview;

+(MBProgressHUD*)showInformBoxWithTitle:(NSString*)title detailText:(NSString*)detailText uiview:(UIView*)uiview delegate:(id<MBProgressHUDDelegate>) delegate;

+(void)hideInformBox:(UIView*) uiview;

+(void)hideInformBox:(UIView*) uiview afterDelay:(NSTimeInterval) delay;

+(void)showLoadingWhileExecuting:(SEL)method withObject:(id)object onTarget:(id)target displayOnView:(UIView*)uiview;

+(void)showLoadingWhileExecuting:(SEL)method withObject:(id)object onTargetAndViewController:(UIViewController*) controller;

+(void)showLoadingWhileExecuting:(SEL)method withObject:(id)object onTarget:(id)target title:(NSString*) title detailText:(NSString*)detailText displayOnView:(UIView*)uiview delegate:(id<MBProgressHUDDelegate>)delegate;

+(void)hideLoadingWithHUD:(MBProgressHUD*) loading;

+(MBProgressHUD*)showLoadingWithTitle:(NSString*)title detailText:(NSString*)detailText uiview:(UIView*)uiview container:(id<MBProgressHUDDelegate>)container;

+(MBProgressHUD*)showLoading:(UIView*) container;

+(void)hideLoading:(UIView*) container;

+(void)slideViewUpForTextfield:(UITextField*) textField viewContainer:(UIView*)view isOn:(BOOL)isOn;

+(CAEmitterLayer*) createSnowInView:(UIView*)view withImage:(UIImage*)snowImage;

+(UIDocumentInteractionController*)showOpenInWithFile:(NSString*)filePath container:(UIView*)container delegate:(id<UIDocumentInteractionControllerDelegate>)delegate;

+(UIDocumentInteractionController*)showOpenInWithFile:(NSString*)filePath containerBarButton:(UIBarButtonItem*)container delegate:(id<UIDocumentInteractionControllerDelegate>)delegate;

+(void)fixNavigationBarCoverContent:(UIViewController*) controller;

+(void)fixNavigationBarCoverContent:(UIViewController*) controller isFixed:(BOOL)isFixed;

+(void)fixNavigationBar:(UINavigationBar*)navbar translucentColor:(UIColor*)barColor;

+(UIEdgeInsets)collectionEdgeInsectFromHashString:(NSString*) hashString;

+(void)setNavigationBarColorHex:(NSString*)hexcolor viewController:(UIViewController*)controller;

+(void)setNavigationBarColor:(UIColor*)color viewController:(UIViewController*)controller;

+(void)setNavigationBarColor:(UIColor*)color tintColor:(UIColor*)tintColor foregroundColor:(UIColor*)foregroundColor viewController:(UIViewController*)controller;

+(void)setToolbarColor:(UIColor*)color tintColor:(UIColor*)tintColor viewController:(UIViewController*)controller;

+(BOOL)isRootViewController:(UIViewController*)controller;

+(void)presentViewWithStorboardName:(NSString*)storyboardName storyboardViewID:(NSString*)viewID currentViewController:(UIViewController*)viewController displayStyle:(enum DisplayStyle) displayStyle prepareBlock:(void(^)(UIViewController* destinationVC))prepareBlock completeBlock:(void(^)(void))completeBlock;

+(void)presentViewController:(UIViewController*)nextViewController fromViewController:(UIViewController*)currentViewController displayStyle:(enum DisplayStyle) displayStyle prepareBlock:(void(^)(UIViewController* destinationVC))prepareBlock completeBlock:(void(^)(void))completeBlock;

+(void)displayPopoverController:(UIViewController*)view container:(UIViewController<UIPopoverControllerDelegate> *)container displayTarget:(id) displayTarget isIphonePushView:(BOOL) isIphonePushView;

+(void)displayPopoverController:(UIViewController*)view container:(UIViewController<UIPopoverControllerDelegate> *)container displayTarget:(id) displayTarget isIphonePushView:(BOOL) isIphonePushView isEmbedNavigationController:(BOOL) isEmbedNavigationController;

+(void)displayPopoverController:(UIViewController*)view container:(UIViewController<UIPopoverControllerDelegate> *)container displayTarget:(id) displayTarget isIphonePushView:(BOOL) isIphonePushView isEmbedNavigationController:(BOOL) isEmbedNavigationController customSize:(CGSize) customSize;

+(id) initAutoLayoutWithType:(enum ALControlType)type viewContainer:(UIView*)viewContainer superEdge:(NSString*)superEdge otherEdge:(NSDictionary*)otherEdge;

+(id) initAutoLayoutWithType:(enum ALControlType)type viewContainer:(UIView*)viewContainer superEdge:(NSString*)superEdge otherEdge:(NSDictionary*)otherEdge viewName:(NSString*)viewName;

+(void) updateLayoutForView:(ALView*)view superEdge:(NSString*)superEdge otherEdge:(NSDictionary*)otherEdge;

+(NSString*) pinEdgeWithView:(UIView*)view edgeStr:(NSString*)edgeStr otherView:(UIView*)otherView;

+(CGFloat)getCustomPaddingSuperEdge:(NSString*)key fullText:(NSString*)fullText;

+(CAShapeLayer*) drawCircleProgressWithView:(UIView*)view progress:(CGFloat)progress size:(CGSize)size strokeColor:(UIColor*)strokeColor fillColor:(UIColor*)fillColor lineWidth:(CGFloat)lineWidth;

+(CAShapeLayer*) drawCircleProgress:(CGFloat)progress size:(CGSize)size strokeColor:(UIColor*)strokeColor fillColor:(UIColor*)fillColor lineWidth:(CGFloat)lineWidth;

+ (void)alertWithTitle:(NSString*) title message:(NSString*) message fromViewController:(UIViewController*)fromViewController callback:(AlertViewCompletionBlock)callback cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...;

+(BOOL)alertNetworkConnectionStatusWithTitle:(NSString*) title message:(NSString*)message fromViewController:(UIViewController*)vc;

+(BOOL)alertNetworkConnectionStatusFromViewController:(UIViewController*)vc;

+(NSArray*)alertUpgrageFeaturesWithContainer:(id)container isIncludeRestoreButton:(BOOL)isIncludeRestoreButton fromViewController:(UIViewController*)vc callback:(AlertViewCompletionBlock)callback;

+(NSArray*)alertUpgrageFeaturesUnlimitWithContainer:(id)container limitMessage:(NSString*)limitMessage isIncludeRestoreButton:(BOOL)isIncludeRestoreButton fromViewController:(UIViewController*)vc callback:(AlertViewCompletionBlock)callback;

+(NSArray*)alertUpgrageProVersionWithContainer:(id)container featuresMessage:(NSString*)featuresMessage isIncludeRestoreButton:(BOOL)isIncludeRestoreButton fromViewController:(UIViewController*)vc callback:(AlertViewCompletionBlock)callback;

+ (void)alertWithTitle:(NSString*)title message:(NSString*) message;

+ (void)alert:(NSString*) message;

@end

