//
//  PaymentLib.h
//  PopLibPreview
//
//  Created by popeveryday on 11/1/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>
#import "ReturnSet.h"
#import "ViewLib.h"

enum InAppPurchaseReturnType
{
    InAppPurchaseReturnTypeComplete,
    InAppPurchaseReturnTypeRestore,
    InAppPurchaseReturnTypeFail,
    InAppPurchaseReturnTypeProductNotFound,
};

@protocol InAppPurchaseDelegate <NSObject>

@optional
- (void) inAppPurchaseDidCompleted:(BOOL) isSuccess productIdentifier:(NSString*) productIdentifier inAppPurchaseReturnType:(enum InAppPurchaseReturnType) returnType;
-(void) inAppPurchaseDidRestoreCompleted:(BOOL) isSuccess productIdentifiers:(NSArray *)productIdentifiers error:(NSError *)error;

@end

@interface InAppPurchaseLib : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>


@property (nonatomic) id<InAppPurchaseDelegate> delegate;
@property (nonatomic) UIView* view;

-(id) initWithDelegate:(id)viewDelegate;
-(id) initWithDelegate:(id)delegate currentView:(UIView*)currentView;

-(BOOL) preparePayment;
-(void) requestProductID:(NSString*) productid;
-(BOOL) executePaymentWithIdentifier:(NSString*) identifier;
-(BOOL) executeRestorePayment;
@end


