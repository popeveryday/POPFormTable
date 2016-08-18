//
//  POPFormTable.m
//  Pods
//
//  Created by Trung Pham Hieu on 3/9/16.
//
//

#import "POPFormTable.h"

@interface POPFormTable ()<UITextFieldDelegate>

@end

@implementation POPFormTable
{
    NSMutableArray* controls;
    UITextField* CurrentSelectdCellView;
    CGFloat animatedDistance;
    
    NSMutableArray* sections;
    CGFloat tableTitleFontSize;
    
    NSInteger rowIndexForCurrentSection;
}
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.2;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;

static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    controls = [[NSMutableArray alloc] init];
    _AllKeys = [[NSMutableArray alloc] init];
    
    
    
    _btnDone = [[UIBarButtonItem alloc] initWithTitle: LocalizedText(@"Done",nil) style:UIBarButtonItemStylePlain target:self action:@selector(Action_Done:)];
    _btnSave = [[UIBarButtonItem alloc] initWithTitle: LocalizedText(@"Save",nil) style:UIBarButtonItemStylePlain target:self action:@selector(Action_Save:)];
    _btnCancel = [[UIBarButtonItem alloc] initWithTitle: LocalizedText(@"Cancel",nil) style:UIBarButtonItemStylePlain target:self action:@selector(Action_Cancel:)];
    
    
    
    
}

-(void) setActionCancel:(SEL)ActionCancel{
    _ActionCancel = ActionCancel;
    self.navigationItem.leftBarButtonItem = _btnCancel;
}

-(void) setActionSave:(SEL)ActionSave
{
    _ActionSave = ActionSave;
    self.navigationItem.rightBarButtonItem = _btnSave;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//--------------------------ADD CELL FUNCTIONS-----------------------------------------------------------------

-(void) addView:(NSString*) key withView:(UIView*) view
{
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = nil;
    item.type = POPFormTableCellType_View;
    item.control = view;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
}

-(UITextField*) addTextField:(NSString*) key title:(NSString*)title text:(NSString*)text placeholder:(NSString*) placeholder keyboardType:(UIKeyboardType)keyboardType isSecure:(BOOL) isSecure
{
    
    POPFormTable_Textfield* control = [[POPFormTable_Textfield alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    control.clearsOnBeginEditing = NO;
    control.textAlignment = [StringLib isValid:title] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    control.keyboardType = keyboardType;
    control.returnKeyType = UIReturnKeyDone;
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control.delegate = self;
    control.text = text;
    control.placeholder = placeholder;
    control.secureTextEntry = isSecure;
    control.key = key;
    
    //round corner & border
    if (self.customTextFieldCornerRadius > 0) {
        control.layer.cornerRadius = self.customTextFieldCornerRadius;
        control.layer.masksToBounds = YES;
        control.leftViewMode = UITextFieldViewModeAlways;
    }
    if (self.customTextFieldBorderColor != nil) control.layer.borderColor = [self.customTextFieldBorderColor CGColor];
    if (self.customTextFieldBorderWidth > 0) control.layer.borderWidth = self.customTextFieldBorderWidth;
    
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = title;
    item.type = POPFormTableCellType_TextBox;
    item.control = control;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
    
    return control;
}

-(UITextField*) addTextFieldWide:(NSString*) key text:(NSString*)text placeholder:(NSString*) placeholder keyboardType:(UIKeyboardType)keyboardType isSecure:(BOOL) isSecure
{
    return [self addTextFieldWide:key img:nil text:text placeholder:placeholder keyboardType:keyboardType isSecure:isSecure];
}

-(UITextField*) addTextFieldWide:(NSString*) key img:(UIImage*)img text:(NSString*)text placeholder:(NSString*) placeholder keyboardType:(UIKeyboardType)keyboardType isSecure:(BOOL) isSecure
{
    POPFormTable_TextfieldWide* control = [[POPFormTable_TextfieldWide alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    control.clearsOnBeginEditing = NO;
    control.textAlignment = NSTextAlignmentLeft;
    control.keyboardType = keyboardType;
    control.returnKeyType = UIReturnKeyDone;
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control.delegate = self;
    control.text = text;
    control.placeholder = placeholder;
    control.secureTextEntry = isSecure;
    control.key = key;
    
    //round corner & border
    if (self.customTextFieldCornerRadius > 0) {
        control.layer.cornerRadius = self.customTextFieldCornerRadius;
        control.layer.masksToBounds = YES;
        control.leftViewMode = UITextFieldViewModeAlways;
    }
    if (self.customTextFieldBorderColor != nil) control.layer.borderColor = [self.customTextFieldBorderColor CGColor];
    if (self.customTextFieldBorderWidth > 0) control.layer.borderWidth = self.customTextFieldBorderWidth;
    
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = nil;
    item.type = POPFormTableCellType_TextBoxWide;
    item.control = control;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
    
    if (img) {
        control.leftViewMode = UITextFieldViewModeAlways;
        UIImageView* passwordImage = ImageViewWithImage(img);
        UIView* passwordImageContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, passwordImage.frame.size.width + 10, passwordImage.frame.size.height)];
        [passwordImageContainer addSubview:passwordImage];
        control.leftView = passwordImageContainer;
    }
    
    return control;
}


-(void)addNumberTextField:(NSString*) key title:(NSString*)title value:(NSNumber*)value placeholder:(NSString*) placeholder{
    return [self addNumberTextField:key title:title value:value placeholder:placeholder isDecimal:NO decimalLength:0 prefix:nil suffix:nil];
}

-(void)addNumberTextField:(NSString*) key title:(NSString*)title value:(NSNumber*)value placeholder:(NSString*) placeholder isDecimal:(BOOL) isDecimal decimalLength:(int)decimalLength prefix:(NSString*)prefix suffix:(NSString*)suffix
{
    
    POPFormTable_NumberTextfield* control = [[POPFormTable_NumberTextfield alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    control.clearsOnBeginEditing = NO;
    control.textAlignment = NSTextAlignmentRight;
    control.keyboardType = isDecimal ? UIKeyboardTypeDecimalPad : UIKeyboardTypeNumberPad;
    control.returnKeyType = UIReturnKeyDone;
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control.delegate = self;
    control.value = value != nil ? value : (isDecimal?[NSNumber numberWithDouble:0]:[NSNumber numberWithInt:0]);
    control.placeholder = placeholder;
    control.isDecimal = isDecimal;
    control.decimalLength = decimalLength;
    control.key = key;
    control.prefix = prefix;
    control.suffix = suffix;
    [control validate];
    
    //round corner & border
    if (self.customTextFieldCornerRadius > 0) {
        control.layer.cornerRadius = self.customTextFieldCornerRadius;
        control.layer.masksToBounds = YES;
    }
    if (self.customTextFieldBorderColor != nil) control.layer.borderColor = [self.customTextFieldBorderColor CGColor];
    if (self.customTextFieldBorderWidth > 0) control.layer.borderWidth = self.customTextFieldBorderWidth;
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = title;
    item.type = POPFormTableCellType_NumberTextBox;
    item.control = control;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
}

-(void)addSwitch:(NSString*)key title:(NSString*)title isOn:(BOOL) isOn action:(SEL)action{
    POPFormTable_Switch* control = [[POPFormTable_Switch alloc] initWithFrame:CGRectZero];
    control.on = isOn;
    control.key = key;
    if (action != Nil) {
        [control addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    }
    
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = title;
    item.type = POPFormTableCellType_Switcher;
    item.control = control;
    item.action = action;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];
    item.rowIndex = rowIndexForCurrentSection;
    rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
}



// datasource is array of POPFormTable_PickerItem ======================
-(void)addPicker:(NSString*)key title:(NSString*)title pickerDataSource:(NSArray*)datasource defaultValue:(id)defaultValue{
    [self addPicker:key title:title pickerDataSource:datasource defaultValue:defaultValue autoDoneAfterSelect: NO];
}

-(void)addPicker:(NSString*)key title:(NSString*)title pickerDataSource:(NSArray*)datasource defaultValue:(id)defaultValue autoDoneAfterSelect:(BOOL)autoDoneAfterSelect{
    POPFormTable_PickerView* control1 = [[POPFormTable_PickerView alloc] init];
    control1.dataSource = control1;
    control1.delegate = control1;
    control1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control1.showsSelectionIndicator = YES;
    control1.autoDoneAfterSelect = autoDoneAfterSelect;
    control1.datarows = datasource;
    
    POPFormTable_Textfield* control = [[POPFormTable_Textfield alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    control.clearsOnBeginEditing = NO;
    control.textAlignment = NSTextAlignmentRight;
    control.keyboardType = UIKeyboardTypeNumberPad;
    control.returnKeyType = UIReturnKeyDone;
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control.delegate = self;
    control.inputView = control1;
    control.key = key;
    
    control1.displayTextfield = control;
    [control1 setSelectedValue:defaultValue];
    
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = title;
    item.type = POPFormTableCellType_Picker;
    item.control = control;
    item.subControl = control1;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
}

-(void)addDatePicker:(NSString*)key title:(NSString*)title defautValue:(NSDate*) defautValue dateMode:(enum UIDatePickerMode)dateMode displayFormat:(NSString*) displayFormat{
    
    
    POPFormTable_DatePickerView* control1 = [[POPFormTable_DatePickerView alloc] init];
    control1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control1.datePickerMode = dateMode;
    control1.dateFormat = displayFormat;
    
    
    POPFormTable_Textfield* control = [[POPFormTable_Textfield alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    control.clearsOnBeginEditing = NO;
    control.textAlignment = NSTextAlignmentRight;
    control.keyboardType = UIKeyboardTypeNumberPad;
    control.returnKeyType = UIReturnKeyDone;
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control.delegate = self;
    control.inputView = control1;
    control.key = key;
    
    control1.displayTextfield = control;
    [control1 setDate: defautValue != nil ? defautValue : [NSDate date]];
    
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = title;
    item.type = POPFormTableCellType_DatePicker;
    item.control = control;
    item.subControl = control1;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
}

-(void)addDetailButton:(NSString*)key title:(NSString*)title selectAction:(SEL)action{
    [self addDetailButton:key title:title text:nil selectAction:action];
}

-(void)addDetailButton:(NSString*)key title:(NSString*)title text:(NSString*)text selectAction:(SEL)action{
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = title;
    item.type = POPFormTableCellType_DetailButton;
    item.action = action;
    
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    if ([StringLib isValid:text]) {
        UIButton* control = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [control setFrame: CGRectMake(0, 6.0f, self.tableView.frame.size.width - 30 , 30.0f)];
        control.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [control setTitle:text forState:UIControlStateNormal];
        if(action != nil) [control addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        item.control = control;
    }
    
    [controls addObject:item];
    [_AllKeys addObject:key];
}

-(void)addLabel:(NSString*)key title:(NSString*)title text:(NSString*)text{
    UILabel* control = [[UILabel alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    control.textAlignment = NSTextAlignmentRight;
    control.text = text;
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = title;
    item.type = POPFormTableCellType_Label;
    item.control = control;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
}

//datasource is array of POPFormTable_ImagePickerItem
-(void)addImagePicker:(NSString*)key title:(NSString*)title imagePickerDataSource:(NSArray*)datasource defaultValue:(id)defaultValue
{
    [self addImagePicker:key title:title imagePickerDataSource:datasource defaultValue:defaultValue autoDoneAfterSelect:NO];
}

-(void)addImagePicker:(NSString*)key title:(NSString*)title imagePickerDataSource:(NSArray*)datasource defaultValue:(id)defaultValue autoDoneAfterSelect:(BOOL)autoDoneAfterSelect
{
    POPFormTable_ImagePickerView* control1 = [[POPFormTable_ImagePickerView alloc] init];
    control1.dataSource = control1;
    control1.delegate = control1;
    control1.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control1.showsSelectionIndicator = YES;
    control1.autoDoneAfterSelect = autoDoneAfterSelect;
    control1.datarows = datasource;
    
    POPFormTable_Textfield* control = [[POPFormTable_Textfield alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    control.clearsOnBeginEditing = NO;
    control.textAlignment = NSTextAlignmentRight;
    control.keyboardType = UIKeyboardTypeNumberPad;
    control.returnKeyType = UIReturnKeyDone;
    control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    control.delegate = self;
    control.inputView = control1;
    control.key = key;
    
    control1.displayTextfield = control;
    [control1 setSelectedValue:defaultValue];
    
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.title = title;
    item.type = POPFormTableCellType_ImagePicker;
    item.control = control;
    item.subControl = control1;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
}

-(UIButton*) addButton:(NSString*) key text:(NSString*)text clickAction:(SEL)action isDestructiveButton:(BOOL)isDestructiveButton
{
    return [self addButton:key text:text clickAction:action textColor:[UIColor redColor] bgColor:[UIColor clearColor]];
}

-(UIButton*) addButton:(NSString*) key text:(NSString*)text clickAction:(SEL)action textColor:(UIColor*)txtColor bgColor:(UIColor*)bgColor
{
    
    UIButton* control = [UIButton buttonWithType:UIButtonTypeSystem];
    [control setTitle:text forState:UIControlStateNormal];
    [control addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    //round corner
    if (self.customButtonCornerRadius > 0) {
        control.layer.cornerRadius = self.customButtonCornerRadius;
        control.layer.masksToBounds = YES;
    }
    
    
    [control setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    control.titleLabel.font = [UIFont fontWithName:control.titleLabel.font.familyName size:17];
    [control setTitleColor:txtColor forState:UIControlStateNormal];
    [control setBackgroundColor:bgColor];
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.type = POPFormTableCellType_Button;
    item.control = control;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
    
    return control;
}

-(UILabel*)addTitle:(NSString*) key title:(NSString*)title
{
    UILabel* control = [[UILabel alloc] initWithFrame:CGRectMake(110.0f, 10.0f, 185.0f, 30.0f)];
    control.textAlignment = NSTextAlignmentCenter;
    control.text = title;
    
    POPFormTable_CellInfo* item = [[POPFormTable_CellInfo alloc] init];
    item.key = key;
    item.type = POPFormTableCellType_Title;
    item.control = control;
    item.sectionIndex = sections == nil ? nil : [NSNumber numberWithInteger:sections.count-1];item.rowIndex = rowIndexForCurrentSection;rowIndexForCurrentSection++;
    
    [controls addObject:item];
    [_AllKeys addObject:key];
    return control;
}
//--------------------------CLEAN UP FUNCTIONS----------------------------------------------------

-(void) cleanup{
    for (POPFormTable_CellInfo* cell in controls)
    {
        switch (cell.type) {
            case POPFormTableCellType_TextBox:
            case POPFormTableCellType_TextBoxWide:
                ((POPFormTable_Textfield*)cell.control).delegate = nil;
                break;
            case POPFormTableCellType_NumberTextBox:
                ((POPFormTable_NumberTextfield*)cell.control).delegate = nil;
                break;
            case POPFormTableCellType_Picker:
                ((POPFormTable_PickerView*)((POPFormTable_Textfield*)cell.control).inputView).dataSource = nil;
                ((POPFormTable_PickerView*)((POPFormTable_Textfield*)cell.control).inputView).delegate = nil;
                ((POPFormTable_PickerView*)((POPFormTable_Textfield*)cell.control).inputView).datarows = nil;
                ((POPFormTable_PickerView*)((POPFormTable_Textfield*)cell.control).inputView).displayTextfield = nil;
                ((POPFormTable_Textfield*)cell.control).inputView = nil;
                ((POPFormTable_Textfield*)cell.control).delegate = nil;
                break;
            case POPFormTableCellType_DatePicker:
                ((POPFormTable_Textfield*)cell.control).delegate = nil;
                ((POPFormTable_Textfield*)cell.control).inputView = nil;
                break;
            case POPFormTableCellType_ImagePicker:
                ((POPFormTable_ImagePickerView*)((POPFormTable_Textfield*)cell.control).inputView).dataSource = nil;
                ((POPFormTable_ImagePickerView*)((POPFormTable_Textfield*)cell.control).inputView).delegate = nil;
                ((POPFormTable_ImagePickerView*)((POPFormTable_Textfield*)cell.control).inputView).datarows = nil;
                ((POPFormTable_ImagePickerView*)((POPFormTable_Textfield*)cell.control).inputView).displayTextfield = nil;
                ((POPFormTable_Textfield*)cell.control).inputView = nil;
                ((POPFormTable_Textfield*)cell.control).delegate = nil;
                break;
            case POPFormTableCellType_Switcher:
                if(cell.action != nil) [((POPFormTable_Switch*)cell.control) removeTarget:self action:cell.action forControlEvents:UIControlEventValueChanged];
                break;
            case POPFormTableCellType_DetailButton:
                if(cell.control != nil && cell.action != nil)
                    [cell.control addTarget:self action:cell.action forControlEvents:UIControlEventTouchUpInside];
                break;
            case POPFormTableCellType_Button:
                if(cell.control != nil && cell.action != nil) [cell.control addTarget:self action:cell.action forControlEvents:UIControlEventTouchUpInside];
                break;
            case POPFormTableCellType_Label:
            case POPFormTableCellType_Title:
            case POPFormTableCellType_View:
            default:
                break;
                
        }
        
        
        [cell.control removeFromSuperview];
        cell.control = nil;
        cell.action = nil;
        
        [cell.subControl removeFromSuperview];
        cell.subControl = nil;
    }
}

//--------------------------ADD SECTION FUNCTIONS----------------------------------------------------
-(void) addSectionWithName:(NSString*) sectionName{
    if (sections == nil) {
        sections = [[NSMutableArray alloc] init];
    }
    
    [sections addObject:sectionName];
    
    //reset
    rowIndexForCurrentSection = 0;
}

//--------------------------ADD CELL VALIDATION FUNCTIONS----------------------------------------------------

-(void) addValidation:(NSString*)key isRequire:(BOOL)isRequire minLength:(NSNumber*)minLength maxLength:(NSNumber*)maxLength minValue:(NSNumber*)minValue maxValue:(NSNumber*)maxValue
{
    for (POPFormTable_CellInfo* item in controls) {
        if (item.key == key) {
            item.isRequire = isRequire;
            item.maxLength = maxLength;
            item.minLength = minLength;
            item.maxValue = maxValue;
            item.minValue = minValue;
            return;
        }
    }
}


-(void) addValidation:(NSString*)key isRequire:(BOOL)isRequire minLength:(NSNumber*)minLength maxLength:(NSNumber*)maxLength
{
    [self addValidation:key isRequire:isRequire minLength:minLength maxLength:maxLength minValue:nil maxValue:nil];
}

-(void) addValidation:(NSString*)key isRequire:(BOOL)isRequire minValue:(NSNumber*)minValue maxValue:(NSNumber*)maxValue{
    [self addValidation:key isRequire:isRequire minLength:nil maxLength:nil minValue:minValue maxValue:maxValue];
}

-(void) addValidation:(NSString*)key maxValue:(NSNumber*)maxValue{
    [self addValidation:key isRequire:YES minLength:nil maxLength:nil minValue:nil maxValue:maxValue];
}

-(void) addValidation:(NSString*)key maxLength:(NSNumber*)maxLength{
    [self addValidation:key isRequire:YES minLength:nil maxLength:maxLength minValue:nil maxValue:nil];
}

-(void) addValidation:(NSString*)key{
    [self addValidation:key isRequire:YES minLength:nil maxLength:nil minValue:nil maxValue:nil];
}

-(BOOL) IsValidated
{
    BOOL isValid = YES;
    for (POPFormTable_CellInfo* item in controls) {
        
        if ([self ValidateItem:item] == NO) {
            item.titleColor = [UIColor redColor];
            isValid = NO;
        }else{
            item.titleColor = [UIColor blackColor];
        }
        
    }
    
    [self.tableView reloadData];
    
    return isValid;
}

-(BOOL) ValidateItemByKey:(NSString*) key
{
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        return [self ValidateItem:item];
    }
    return NO;
}

-(void) addTexfieldSuffixImage:(NSString*)key image:(UIImage*)image
{
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        
        switch (item.type) {
            case POPFormTableCellType_TextBox:
            case POPFormTableCellType_TextBoxWide:
            case POPFormTableCellType_NumberTextBox:
                [self addSuffixImage:image textField:item.control];
                break;
            case POPFormTableCellType_Picker:
            case POPFormTableCellType_DatePicker:
            case POPFormTableCellType_ImagePicker:
            case POPFormTableCellType_Switcher:
            case POPFormTableCellType_DetailButton:
            case POPFormTableCellType_Label:
            case POPFormTableCellType_Title:
            case POPFormTableCellType_View:
            default:
                break;
                
        }
        
        
    }
    
}



-(void) HideControllKeyboard
{
    for (POPFormTable_CellInfo* item in controls)
    {
        switch (item.type) {
            case POPFormTableCellType_TextBox:
            case POPFormTableCellType_TextBoxWide:
            case POPFormTableCellType_NumberTextBox:
            case POPFormTableCellType_Picker:
            case POPFormTableCellType_DatePicker:
            case POPFormTableCellType_ImagePicker:
                [((UITextField*)item.control) resignFirstResponder];
                break;
                
            case POPFormTableCellType_Switcher:
            case POPFormTableCellType_DetailButton:
            case POPFormTableCellType_Label:
            case POPFormTableCellType_Title:
            case POPFormTableCellType_View:
            default:
                break;
                
        }
        
    }
}

-(BOOL) ValidateItem:(POPFormTable_CellInfo*) item
{
    NSString* text = @"";
    NSNumber* num = Nil;
    
    
    switch (item.type) {
        case POPFormTableCellType_TextBox:
        case POPFormTableCellType_TextBoxWide:
            text = [((UITextField*)item.control).text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            if(item.isRequire == YES){
                if( [StringLib isValid: text] == NO ) return NO;
                if( item.minLength != nil && text.length < item.minLength.intValue ) return NO;
                if( item.maxLength != nil && text.length < item.maxLength.intValue ) return NO;
            }else{
                if( item.minLength != nil && text.length < item.minLength.intValue ) return NO;
                if( item.maxLength != nil && text.length < item.maxLength.intValue ) return NO;
            }
            break;
        case POPFormTableCellType_NumberTextBox:
            num = ((POPFormTable_NumberTextfield*)item.control).value;
            
            if (((POPFormTable_NumberTextfield*)item.control).isDecimal) {
                if(item.isRequire == YES){
                    if( [num doubleValue] == 0.0 ) return NO;
                    if( item.minValue != nil && [num doubleValue] < [item.minValue doubleValue] ) return NO;
                    if( item.maxValue != nil && [num doubleValue] > [item.maxValue doubleValue] ) return NO;
                }else{
                    if( item.minValue != nil && [num doubleValue] < [item.minValue doubleValue] ) return NO;
                    if( item.maxValue != nil && [num doubleValue] > [item.maxValue doubleValue] ) return NO;
                }
            }else{
                if(item.isRequire == YES){
                    if( [num intValue] == 0 ) return NO;
                    if( item.minValue != nil && [num intValue] < [item.minValue intValue] ) return NO;
                    if( item.maxValue != nil && [num intValue] > [item.maxValue intValue] ) return NO;
                }else{
                    if( item.minValue != nil && [num intValue] < [item.minValue intValue] ) return NO;
                    if( item.maxValue != nil && [num intValue] > [item.maxValue intValue] ) return NO;
                }
            }
            
            
            
            break;
        case POPFormTableCellType_Picker:
            if (item.isRequire && [StringLib isValid:((UITextField*)item.control).text] == NO) return NO;
            if (item.isRequire && ((POPFormTable_PickerView*)item.subControl).selectedValue == Nil) return NO;
            break;
        case POPFormTableCellType_DatePicker:
            if (item.isRequire && [StringLib isValid:((UITextField*)item.control).text] == NO) return NO;
            if (item.isRequire && ((POPFormTable_DatePickerView*)item.subControl).date == Nil) return NO;
            break;
        case POPFormTableCellType_ImagePicker:
            if (item.isRequire && [StringLib isValid:((UITextField*)item.control).text] == NO) return NO;
            if (item.isRequire && ((POPFormTable_ImagePickerView*)item.subControl).selectedValue == Nil) return NO;
            break;
        case POPFormTableCellType_Switcher:
        case POPFormTableCellType_DetailButton:
        case POPFormTableCellType_Label:
        case POPFormTableCellType_Title:
        case POPFormTableCellType_View:
        default:
            break;
            
    }
    return YES;
}


//----------------------------------------------------------------------------------------------------------
//--------------------------TABLE FUNCTIONS-----------------------------------------------------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return sections == nil ? 1 : sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger total = 0;
    for (POPFormTable_CellInfo* info in controls) {
        if(info.sectionIndex.integerValue == section) total++;
    }
    
    return total;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    
    POPFormTable_CellInfo* item = [self GetCellInfoByIndexPath:indexPath];
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    cell.textLabel.text = item.title;
    cell.textLabel.textColor = item.titleColor != Nil ? item.titleColor : [UIColor blackColor];
    
    cell.textLabel.numberOfLines = 3; // set the numberOfLines
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    if (item.fontSize > 0) {
        [cell.textLabel setFont: [UIFont fontWithName:cell.textLabel.font.fontName size:item.fontSize]];
    }else if(tableTitleFontSize > 0){
        [cell.textLabel setFont: [UIFont fontWithName:cell.textLabel.font.fontName size:tableTitleFontSize]];
    }
    
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    
    
    switch (item.type) {
        case POPFormTableCellType_DatePicker:
        case POPFormTableCellType_Picker:
        case POPFormTableCellType_TextBox:
            cell.accessoryView = item.control;
            break;
        case POPFormTableCellType_TextBoxWide:
            [cell.contentView addSubview: item.control];
            [item.control setFrame: CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            break;
        case POPFormTableCellType_View:
            [cell.contentView addSubview: item.control];
            [item.control setFrame: CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            break;
        case POPFormTableCellType_NumberTextBox:
        case POPFormTableCellType_ImagePicker:
        case POPFormTableCellType_Label:
        case POPFormTableCellType_Switcher:
            //[cell.contentView addSubview:item.control];
            cell.accessoryView = item.control;
            break;
        case POPFormTableCellType_Title:
        case POPFormTableCellType_Button:
            [cell.contentView addSubview: item.control];
            [item.control setFrame: CGRectMake(10, 5, cell.frame.size.width - 20, cell.frame.size.height - 10)];
            break;
        case POPFormTableCellType_DetailButton:
            if (item.control == nil) {
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
            }else{
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                [cell.contentView addSubview:item.control];
                cell.contentView.autoresizesSubviews = YES;
                [item.control setFrame: CGRectMake(0, 6.0f, self.tableView.frame.size.width - 30 , 30.0f)];
                
            }
        default:
            break;
    }
    
    if (item.isHidden) {
        [cell.textLabel setHidden:YES];
        if( cell.accessoryView != nil ) [cell.accessoryView setHidden:YES];
    }
    
    return cell;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    POPFormTable_CellInfo* info = [self GetCellInfoByIndexPath:indexPath];
    if (info.isHidden) {
        return 0;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    POPFormTable_CellInfo* item = [self GetCellInfoByIndexPath:indexPath];
    
    if (item.action != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:item.action withObject:item];
#pragma clang diagnostic pop
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return sections == nil ? @"" : sections[section];
}


//--------------------------TEXTFIELD FUNCTIONS-----------------------------------------------------------------
-(void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self SlideViewUpForTextfield:textField isOn:YES];
    
    if (self.ActionCancel != nil) {
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    }
    
    if (self.ActionSave != nil) {
        self.navigationItem.rightBarButtonItem = _btnDone;
    }
    
    CurrentSelectdCellView = textField;
    
    if (self.ActionDidBeginEditingWithTextfield != nil) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:self.ActionDidBeginEditingWithTextfield withObject:textField];
        #pragma clang diagnostic pop
    }
}

-(void) textFieldDidEndEditing:(UITextField *)textField
{
    [self SlideViewUpForTextfield:textField isOn:NO];
    
    if (self.ActionCancel != nil) {
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
    
    if (self.ActionSave != nil) {
        self.navigationItem.rightBarButtonItem = _btnSave;
    }
    
    if ([textField isKindOfClass:[POPFormTable_NumberTextfield class]])
    {
        [((POPFormTable_NumberTextfield*)textField) validate];
    }
    
    if (self.ActionDidEndEditingWithTextfield != nil) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:self.ActionDidEndEditingWithTextfield withObject:textField];
        #pragma clang diagnostic pop
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self Action_Done:Nil];
    return NO;
}

//--------------------------ACTION & OTHER FUNCTIONS-----------------------------------------------------------------

- (void)Action_Save:(id)sender{
    if (self.ActionSave != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:self.ActionSave withObject:Nil];
#pragma clang diagnostic pop
    }
}

- (void)Action_Cancel:(id)sender{
    if (self.ActionCancel != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:self.ActionCancel withObject:Nil];
#pragma clang diagnostic pop
    }
}


- (void)Action_Done:(id)sender
{
    [CurrentSelectdCellView resignFirstResponder];
    
    if (self.ActionDoneWithKey != nil) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:self.ActionDoneWithKey withObject: [CurrentSelectdCellView valueForKey:@"key"]];
#pragma clang diagnostic pop
    }
    
    if (self.ActionCancel != nil) {
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }
    
    if (self.ActionSave != nil) {
        self.navigationItem.rightBarButtonItem = _btnSave;
    }
}


-(void) SlideViewUpForTextfield:(UITextField*) textField isOn:(BOOL)isOn{
    CGRect viewFrame = self.view.frame;
    
    if (isOn) {
        CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
        CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
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
        if (self.view.bounds.size.height - subviewHeight > textFieldRect.origin.y) {
            subviewHeight = 0;
        }
        
        animatedDistance = floor(subviewHeight * heightFraction);
        
        CGRect viewFrame = self.view.frame;
        viewFrame.origin.y -= animatedDistance;
    }
    
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    
    [UIView commitAnimations];
}

-(void) SetCellValueByKey:(NSString*)key value:(id)value{
    for (int i = 0; i < controls.count; i++) {
        POPFormTable_CellInfo* item = [controls objectAtIndex:i];
        
        if (![item.key isEqualToString:key]) continue;
        
        switch (item.type) {
            case POPFormTableCellType_TextBoxWide:
            case POPFormTableCellType_TextBox: ((UITextField*)item.control).text = value; break;
            case POPFormTableCellType_NumberTextBox: ((POPFormTable_NumberTextfield*)item.control).value = value; break;
            case POPFormTableCellType_Picker: ((POPFormTable_PickerView*)item.subControl).selectedValue = value; break;
            case POPFormTableCellType_Switcher: ((POPFormTable_Switch*)item.control).on = [((NSNumber*)value) boolValue]; break;
            case POPFormTableCellType_DatePicker: ((POPFormTable_DatePickerView*)item.subControl).date = value; break;
            case POPFormTableCellType_ImagePicker: ((POPFormTable_PickerView*)item.subControl).selectedValue = value; break;
            case POPFormTableCellType_Title:
            case POPFormTableCellType_Label: ((UILabel*)item.control).text = value; break;
            case POPFormTableCellType_DetailButton:
                if(item.control != nil) [((UIButton*)item.control) setTitle:value forState:UIControlStateNormal]; break;
            case POPFormTableCellType_View:
                break;
            default:
                break;
        }
        
        return;
    }
}

-(id) GetCellValueByKey:(NSString*)key{
    for (int i = 0; i < controls.count; i++) {
        POPFormTable_CellInfo* item = [controls objectAtIndex:i];
        
        if (![item.key isEqualToString:key]) continue;
        
        switch (item.type) {
            case POPFormTableCellType_TextBoxWide:
            case POPFormTableCellType_TextBox: return ((UITextField*)item.control).text;
            case POPFormTableCellType_NumberTextBox: return ((POPFormTable_NumberTextfield*)item.control).value;
            case POPFormTableCellType_Picker: return ((POPFormTable_PickerView*)item.subControl).selectedValue;
            case POPFormTableCellType_Switcher: return [NSNumber numberWithBool:((POPFormTable_Switch*)item.control).on];
            case POPFormTableCellType_DatePicker: return ((POPFormTable_DatePickerView*)item.subControl).date;
            case POPFormTableCellType_ImagePicker: return ((POPFormTable_PickerView*)item.subControl).selectedValue;
            case POPFormTableCellType_Title:
            case POPFormTableCellType_Label: return ((UILabel*)item.control).text;
            case POPFormTableCellType_View: return item.control;
            default:
                return nil;
                break;
        }
    }
    return nil;
}

-(UITableViewCell*) GetCellByKey:(NSString*)key{
    
    POPFormTable_CellInfo* selectedInfo;
    for (POPFormTable_CellInfo* info in controls) {
        if ([info.key isEqualToString:key]){
            selectedInfo = info;
            break;
        }
    }
    
    if (selectedInfo == nil) return nil;
    return [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedInfo.rowIndex inSection:selectedInfo.sectionIndex.integerValue]];
}

-(void) SetCellTitleByKey:(NSString*) key title:(NSString*)title{
    [self SetCellTitleByKey:key title:title refreshTable:NO];
}

-(void) SetCellTitleByKey:(NSString*) key title:(NSString*)title refreshTable:(BOOL)refreshTable{
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        item.title = title;
        if(refreshTable) [self.tableView reloadData];
        break;
    }
}


-(NSString*) GetCellTitleByKey:(NSString*) key{
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        return item.title;
    }
    return Nil;
}


-(void) SetCellTitleColorByKey:(NSString*) key color:(UIColor*)color{
    [self SetCellTitleColorByKey:key color:color refreshTable:NO];
}

-(void) SetCellTitleColorByKey:(NSString*) key color:(UIColor*)color refreshTable:(BOOL)refreshTable{
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        item.titleColor = color;
        if(refreshTable) [self.tableView reloadData];
        break;
    }
}

-(void) SetCellHiddenByKey:(NSString*) key isHidden:(BOOL)isHidden{
    [self SetCellHiddenByKey:key isHidden:isHidden refreshTable:NO];
}


-(void) SetCellHiddenByKey:(NSString*) key isHidden:(BOOL)isHidden refreshTable:(BOOL)refreshTable{
    
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        item.isHidden = isHidden;
    }
    
    UITableViewCell* cell = [self GetCellByKey:key];
    if (cell == nil) return;
    if (cell.textLabel != nil) [cell.textLabel setHidden:isHidden];
    if (cell.accessoryView != nil) [cell.accessoryView setHidden:isHidden];
    
    if(refreshTable) [self.tableView reloadData];
}



-(void) SetCellReadOnlyByKey:(NSString*) key isReadonly:(BOOL)isReadonly{
    
    
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        item.isReadonly = isReadonly;
        
        switch (item.type) {
            case POPFormTableCellType_TextBox:
            case POPFormTableCellType_TextBoxWide:
                [((UITextField*)item.control) setEnabled:!isReadonly]; break;
            case POPFormTableCellType_NumberTextBox:
                [((POPFormTable_NumberTextfield*)item.control) setEnabled:!isReadonly]; break;
            case POPFormTableCellType_Picker:
                break;
            case POPFormTableCellType_Switcher:
                [((POPFormTable_Switch*)item.control) setEnabled:!isReadonly]; break;
            case POPFormTableCellType_DatePicker:
                [((POPFormTable_DatePickerView*)item.subControl) setEnabled:!isReadonly]; break;
            case POPFormTableCellType_ImagePicker:
                break;
            case POPFormTableCellType_Title:
            case POPFormTableCellType_Label:
                break;
            case POPFormTableCellType_DetailButton:
                break;
            case POPFormTableCellType_Button: [((UIButton*)item.control) setEnabled:!isReadonly];
                break;
            case POPFormTableCellType_View:
                break;
            default: break;
                
        }
    }
}

-(void) SetTableTitleFontSize:(CGFloat)fontSize{
    [self SetTableTitleFontSize:fontSize refreshTable:NO];
}

-(void) SetTableTitleFontSize:(CGFloat)fontSize refreshTable:(BOOL)refreshTable{
    tableTitleFontSize = fontSize;
    if(refreshTable) [self.tableView reloadData];
}


-(void) SetCellTitleFontSizeByKey:(NSString*) key fontSize:(CGFloat)fontSize{
    [self SetCellTitleFontSizeByKey:key fontSize:fontSize refreshTable:NO];
}

-(void) SetCellTitleFontSizeByKey:(NSString*) key fontSize:(CGFloat)fontSize refreshTable:(BOOL)refreshTable{
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        item.fontSize = fontSize;
        if(refreshTable) [self.tableView reloadData];
        break;
    }
}


-(UIColor*) GetCellTitleColorByKey:(NSString*) key{
    for (POPFormTable_CellInfo* item in controls) {
        if ([item.key isEqualToString:key] == NO) continue;
        return item.titleColor;
    }
    return Nil;
}

-(POPFormTable_CellInfo*) GetCellInfoByIndexPath:(NSIndexPath*)indexPath{
    
    
    for (POPFormTable_CellInfo* info in controls) {
        if(info.sectionIndex.integerValue == indexPath.section && info.rowIndex == indexPath.row){
            return info;
        }
    }
    
    return nil;
}

-(void)addSuffixImage:(UIImage*)img textField:(UITextField*)textfield
{
    textfield.rightViewMode = UITextFieldViewModeAlways;
    UIImageView* imgview = ImageViewWithImage(img);
    textfield.rightView = imgview;
}


@end

























//==================================================================================================================
//==================================================================================================================
//------------------------------------EXTEND CLASS -----------------------------------------------------------------
//==================================================================================================================
//==================================================================================================================




@implementation POPFormTable_CellInfo
@end


//------------------------------------EXTEND CLASS -----------------------------------------------------------------
@implementation POPFormTable_PickerView
- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) setSelectedValue:(id)selectedValue{
    for (int i = 0; i < _datarows.count; i++) {
        
        POPFormTable_PickerItem* item = [_datarows objectAtIndex:i];
        
        
        
        if ( ([item.value isKindOfClass:[NSString class]] && [item.value isEqualToString: selectedValue]) ||
            ([item.value isKindOfClass:[NSNumber class]] && [item.value isEqual:selectedValue])
            ) {
            [self selectRow:i inComponent:0 animated:YES];
            _selectedValue = selectedValue;
            if(_displayTextfield != nil){
                _displayTextfield.text = item.text;
            }
            return;
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _datarows.count;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = (UILabel *)view;
    if(!label)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 60.0f)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
    }
    
    POPFormTable_PickerItem* item = [_datarows objectAtIndex:row];
    
    label.text = item.text;
    
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    POPFormTable_PickerItem* item = [_datarows objectAtIndex:row];
    _selectedValue = item.value;
    
    if(_displayTextfield != nil){
        _displayTextfield.text = item.text;
        
        if (_autoDoneAfterSelect){
            [_displayTextfield resignFirstResponder];
        }
    }
    
}

@end

//------------------------------------EXTEND CLASS -----------------------------------------------------------------
@implementation POPFormTable_ImagePickerView
- (id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void) setSelectedValue:(id)selectedValue{
    
    
    for (int i = 0; i < _datarows.count; i++) {
        
        POPFormTable_ImagePickerItem* item = [_datarows objectAtIndex:i];
        
        if ( ([item.value isKindOfClass:[NSString class]] && [item.value isEqualToString: selectedValue]) ||
            ([item.value isKindOfClass:[NSNumber class]] && [item.value isEqual:selectedValue])
            ){
            [self selectRow:i inComponent:0 animated:YES];
            _selectedValue = selectedValue;
            if(_displayTextfield != nil){
                _displayTextfield.text = item.text;
            }
            return;
        }
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _datarows.count;
}


- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView* panel = (UIView*)view;
    UILabel* label;
    UIImageView* img;
    
    if(!panel)
    {
        panel = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 60.0f)];
        
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(60.0f, 0.0f, self.frame.size.width - 60.0f, 60.0f)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.adjustsFontSizeToFitWidth = YES;
        label.tag = 1;
        
        img = [[UIImageView alloc] initWithFrame:CGRectMake(14.0f, 14.0f, 32.0f, 32.0f)];
        img.tag = 2;
        
        [panel addSubview:label];
        [panel addSubview:img];
    }else{
        label = (UILabel*)[panel viewWithTag:1];
        img = (UIImageView*)[panel viewWithTag:2];
    }
    
    POPFormTable_ImagePickerItem* item = [_datarows objectAtIndex:row];
    
    label.text = item.text;
    img.image = [UIImage imageNamed:item.imageName];
    
    return panel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    POPFormTable_ImagePickerItem* item = [_datarows objectAtIndex:row];
    _selectedValue = item.value;
    
    if(_displayTextfield != nil){
        _displayTextfield.text = item.text;
        
        if (_autoDoneAfterSelect) [_displayTextfield resignFirstResponder];
    }
}

@end

//------------------------------------EXTEND CLASS -----------------------------------------------------------------

@implementation POPFormTable_DatePickerView
- (id)init
{
    self = [super init];
    if (self) {
        [self addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return self;
}


-(void) setDate:(NSDate *)date{
    [super setDate:date];
    [self dateChanged:self];
}

- (void)dateChanged:(id)sender{
    if(_displayTextfield != nil){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat: _dateFormat];
        _displayTextfield.text = [formatter stringFromDate:self.date];
    }
}


@end

//------------------------------------EXTEND CLASS -----------------------------------------------------------------

@implementation POPFormTable_PickerItem
+(id) initWithText:(NSString*) text value:(id)value{
    POPFormTable_PickerItem* item = [[POPFormTable_PickerItem alloc] init];
    item.text = text;
    item.value = value;
    return item;
}
@end

//------------------------------------EXTEND CLASS -----------------------------------------------------------------

@implementation POPFormTable_ImagePickerItem
+(id) initWithText:(NSString*) text value:(id)value imageName:(NSString *)imageName{
    POPFormTable_ImagePickerItem* item = [[POPFormTable_ImagePickerItem alloc] init];
    item.text = text;
    item.value = value;
    item.imageName = imageName;
    return item;
}
@end

//------------------------------------EXTEND CLASS -----------------------------------------------------------------

@implementation POPFormTable_NumberTextfield
{
    NSNumber* _value;
    BOOL isJustTypeDot;
    NSInteger lastDotLength;
    NSInteger lastValueLength;
}

-(id) initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        self.thousandSeparator = @",";
        self.decimalSeparator = @".";
        [self addTarget:self action:@selector(didChangedValue:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

-(void) didChangedValue:(id)sender{
    [self validate];
}

-(void) validate
{
    if (![StringLib isValid:self.text]) {
        return;
    }
    
    //remove thousand separator
    NSString* value = self.text;
    
    if(_prefix != nil) value = [value stringByReplacingOccurrencesOfString:_prefix withString:@""];
    if([StringLib isValid:_suffix])
    {
        if([value hasSuffix:_suffix] || [StringLib contains:_suffix inString:value])
            value = [value stringByReplacingOccurrencesOfString:_suffix withString:@""];
        else if(value.length < lastValueLength){
            if(_suffix.length > 1){
                value = [value substringToIndex:value.length-1-(_suffix.length-1)];
            }else{
                value = [value substringToIndex:value.length-1];
            }
        }
        
    }
    
    if ([value hasSuffix:_decimalSeparator]) {
        isJustTypeDot = YES;
        lastDotLength = value.length;
    }else if(isJustTypeDot){
        if (lastDotLength <= value.length) {
            value = [NSString stringWithFormat:@"%@%@%@", [value substringToIndex:value.length-1], _decimalSeparator, [value substringFromIndex:value.length-1]];
            isJustTypeDot = NO;
        }else{
            isJustTypeDot = NO;
        }
    }
    
    value = [value stringByReplacingOccurrencesOfString:_thousandSeparator withString:@""];
    
    _value = [NSNumber numberWithDouble:[value doubleValue]];
    
    value = [StringLib formatDouble:_value.doubleValue decimalLength:self.isDecimal ? _decimalLength : 0];
    value = [NSString stringWithFormat:@"%@%@%@", [StringLib isValid:_prefix] ? _prefix : @"" , value, [StringLib isValid:_suffix] ? _suffix : @""];
    
    self.text = value;
    
    lastValueLength = value.length;
}


-(void) setValue:(NSNumber *)value{
    _value = value;
    self.text = [_value stringValue];
    [self validate];
}

-(NSNumber*) value {
    [self validate];
    return _value;
}

@end

//------------------------------------EXTEND CLASS -----------------------------------------------------------------

@implementation POPFormTable_Textfield

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset(bounds, 5, 5);
}

// text position
- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return CGRectInset(bounds, 5, 5);
}

@end

@implementation POPFormTable_TextfieldWide

@end

//------------------------------------EXTEND CLASS -----------------------------------------------------------------

@implementation POPFormTable_Switch

@end

