//
//  PaymentLib.m
//  PopLibPreview
//
//  Created by popeveryday on 11/1/12.
//  Copyright (c) 2012 Best4U. All rights reserved.
//

#import "InAppPurchaseLib.h"


@implementation InAppPurchaseLib


-(id) initWithDelegate:(id)viewDelegate
{
    self = [super init];
    if (self) {
        self.delegate = viewDelegate;
        self.view = [viewDelegate view];
    }
    return self;
}

-(id) initWithDelegate:(id)delegate currentView:(UIView*)currentView{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.view = currentView;
    }
    return self;
}

-(BOOL) executePaymentWithIdentifier:(NSString*) identifier{
    if (![self preparePayment]) {
        return NO;
    }
    [ViewLib showLoading: _view];
    [self requestProductID:identifier];
    return YES;
}

-(BOOL) executeRestorePayment
{
    if (![self preparePayment]) {
        return NO;
    }
    
    [ViewLib showLoading: _view];
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
    return YES;
}

-(BOOL) preparePayment{
    if([SKPaymentQueue canMakePayments]){
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        return YES;
    }else{
        return NO;
    }
}

-(void) requestProductID:(NSString*) productid{
    SKProductsRequest* request = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject: productid]];
    request.delegate = self;
    [request start];
}

-(void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    if ([response.products  count] >  0  ) {
		SKProduct  * product = [response.products  objectAtIndex : 0 ];
        SKPayment  * payment = [ SKPayment  paymentWithProduct : product];
        [[ SKPaymentQueue  defaultQueue ]  addPayment : payment];
	}else{
        [self finishTransaction:nil isComplete:NO returnType:InAppPurchaseReturnTypeProductNotFound];
	}
}

-(void) paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction* transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self finishTransaction:transaction isComplete:YES returnType:InAppPurchaseReturnTypeComplete];
                break;
            case SKPaymentTransactionStateRestored:
                [self finishTransaction:transaction isComplete:YES returnType:InAppPurchaseReturnTypeRestore];
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"Purchase Failed Error: %@", transaction.error);
                [self finishTransaction:transaction isComplete:NO returnType:InAppPurchaseReturnTypeFail];
                break;
            case  SKPaymentTransactionStatePurchasing: NSLog(@"...Purchasing");
                break;
            case SKPaymentTransactionStateDeferred: NSLog(@"...Deferred");
                break;
            default:
                break;
        }
    }
}

-(void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    [self finishRestoreWithResult:YES paymentQueue:queue error:nil];
}

-(void) paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error{
    [self finishRestoreWithResult:NO paymentQueue:queue error:error];
}


//=========================

-(void) finishRestoreWithResult:(BOOL) result paymentQueue:(SKPaymentQueue*)queue error:(NSError*)error
{
    //get list of product identifiers
    NSMutableArray* purchasedItemIDs = [[NSMutableArray alloc] init];
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        [purchasedItemIDs addObject:productID];
    }
    
    
    
    //call delegate
    if (_delegate != nil && [_delegate respondsToSelector:@selector(inAppPurchaseDidRestoreCompleted:productIdentifiers:error:)] )
    {
        [self.delegate inAppPurchaseDidRestoreCompleted:result productIdentifiers:purchasedItemIDs error:error];
        
        //hide loading
        [ViewLib hideLoading: _view];
        
        //clear view reference
        _view = nil;
    }
}

-(void) finishTransaction:(SKPaymentTransaction*) transaction isComplete:(BOOL)isComplete returnType:(enum InAppPurchaseReturnType) returnType
{
    
    if (transaction != nil) {
        [[SKPaymentQueue  defaultQueue]  finishTransaction: transaction];
    }
    
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(inAppPurchaseDidCompleted:productIdentifier:inAppPurchaseReturnType:)])
    {
        [_delegate inAppPurchaseDidCompleted:isComplete
                           productIdentifier:transaction.payment.productIdentifier
                     inAppPurchaseReturnType: returnType];
        
        [ViewLib hideLoading: _view];
        _view = nil;
    }
}
@end
