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
}

-(void) buttonAction:(id)sender{
    
}

-(void) switchAction:(id)sender{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
