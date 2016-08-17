//
//  AlertObject.h
//  Pods
//
//  Created by Trung Pham Hieu on 8/11/16.
//
//

#import <Foundation/Foundation.h>

@interface AlertObject : NSObject

typedef void (^AlertViewCompletionBlock)(NSString* buttonTitle, NSString* alertTitle);
@property (strong,nonatomic) AlertViewCompletionBlock callback;

+ (void)alertWithTitle:(NSString*) title message:(NSString*) message callback:(AlertViewCompletionBlock)callback cancelButtonTitle:(NSString*) cancelButtonTitle otherButtonTitles:(NSString*) otherButtonTitles,...;


@end
