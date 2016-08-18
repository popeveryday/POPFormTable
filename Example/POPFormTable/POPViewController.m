//
//  POPViewController.m
//  POPFormTable
//
//  Created by popeveryday on 03/09/2016.
//  Copyright (c) 2016 popeveryday. All rights reserved.
//

#import "POPViewController.h"

@interface POPViewController ()

@end

@implementation POPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self addSectionWithName:@"General Settings"];
    [self addSwitch:@"a" title:@"Auto Save" isOn:YES action:@selector(switchAction:)];
    [self addTextField:@"b" title:@"Prefix Name" text:nil placeholder:@"Input here" keyboardType:UIKeyboardTypeDefault isSecure:NO];
    [self addTextFieldWide:@"c" text:nil placeholder:@"Enter your fullname" keyboardType:UIKeyboardTypeDefault isSecure:NO];
    [self addDatePicker:@"d" title:@"Start Date" defautValue:nil dateMode:UIDatePickerModeDateAndTime displayFormat:nil];
    [self addDetailButton:@"e" title:@"Selected Songs" selectAction:@selector(buttonAction:)];
    
    [self addTextFieldWide:@"f" img:[UIImage imageNamed:@"ic32_mail"] text:@"" placeholder:@"Email adress" keyboardType:UIKeyboardTypeDefault isSecure:NO];
    
    //validation
    [self addValidation:@"f"];
    
    self.ActionDoneWithKey = @selector(doneActionWithKey:);
    self.ActionSave = @selector(actionSave:);
    self.ActionCancel = @selector(actionCancel:);
    self.ActionDidEndEditingWithTextfield = @selector(actionTextFieldEndEditing:);
}

-(void) actionSave:(id)sender
{
    if (![self ValidateItemByKey:@"f"]) {
        [self addTexfieldSuffixImage:@"f" image:[UIImage imageNamed:@"ic32_error"]];
    }
}

-(void) actionTextFieldEndEditing:(UITextField*)textfield
{
    if ([[textfield valueForKey:@"key"] isEqualToString:@"f"]) {
        [self addTexfieldSuffixImage:@"f" image:[UIImage imageNamed: ![self ValidateItemByKey:@"f"] ? @"ic32_error" : @"ic32_valid" ]];
    }
}

-(void) actionCancel:(id)sender
{
    
}

-(void) doneActionWithKey:(NSString*)key
{
    
}

-(void) buttonAction:(id)sender
{
    
}

-(void) switchAction:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end





