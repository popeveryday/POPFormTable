//
//  AlertObject.m
//  Pods
//
//  Created by Trung Pham Hieu on 8/11/16.
//
//

#import "AlertObject.h"
#import "GlobalConfig.h"
#import "StringLib.h"

@implementation AlertObject

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.callback != nil) self.callback([alertView buttonTitleAtIndex:buttonIndex], alertView.title);
}

+ (void)alertWithTitle:(NSString*) title message:(NSString*) message callback:(AlertViewCompletionBlock)callback cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...
{
    if (GC_Device_iOsVersion < 8.0f)
    {
        __block AlertObject *delegate = [[AlertObject alloc] init];
        delegate.callback = callback;
        
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:delegate
                                              cancelButtonTitle:cancelButtonTitle
                                              otherButtonTitles:nil];
        
        if (otherButtonTitles != nil)
        {
            [alertView addButtonWithTitle:otherButtonTitles];
            
            va_list args;
            va_start(args, otherButtonTitles);
            NSString* name;
            while ((name = va_arg(args, NSString*))) {
                if (name != nil && ![name isEqualToString:@""]) {
                    [alertView addButtonWithTitle: name];
                }
            }
            va_end(args);
        }
        
        delegate.callback = ^(NSString* buttonTitle, NSString* alertTitle) {
            callback(buttonTitle, alertTitle);
            alertView.delegate = nil;
            delegate = nil;
        };
        
        [alertView show];
    }else{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        void (^buttonHandler)(UIAlertAction *action) = ^void(UIAlertAction *action) {
            callback(action.title, title);
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
        
        
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
    }
}

@end
