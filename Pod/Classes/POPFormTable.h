//
//  POPFormTable.h
//  Pods
//
//  Created by Trung Pham Hieu on 3/9/16.
//
//

#import <UIKit/UIKit.h>
#import <POPLib/POPLib.h>

@interface POPFormTable : UITableViewController
@property (nonatomic) UIBarButtonItem* btnDone;
@property (nonatomic) UIBarButtonItem* btnSave;
@property (nonatomic) UIBarButtonItem* btnCancel;

@property (nonatomic) SEL ActionSave;
@property (nonatomic) SEL ActionCancel;
@property (nonatomic) SEL ActionDoneWithKey; //return key of current cell
@property (nonatomic) NSMutableArray* AllKeys;

@property (nonatomic) CGFloat customButtonCornerRadius;
@property (nonatomic) CGFloat customTextFieldCornerRadius;
@property (nonatomic) UIColor* customTextFieldBorderColor;
@property (nonatomic) CGFloat customTextFieldBorderWidth;

-(UITextField*) addTextField:(NSString*) key title:(NSString*)title text:(NSString*)text placeholder:(NSString*) placeholder keyboardType:(UIKeyboardType)keyboardType isSecure:(BOOL) isSecure;
-(UITextField*) addTextFieldWide:(NSString*) key text:(NSString*)text placeholder:(NSString*) placeholder keyboardType:(UIKeyboardType)keyboardType isSecure:(BOOL) isSecure;
-(void)addNumberTextField:(NSString*) key title:(NSString*)title value:(NSNumber*)value placeholder:(NSString*) placeholder;
-(void)addNumberTextField:(NSString*) key title:(NSString*)title value:(NSNumber*)value placeholder:(NSString*) placeholder isDecimal:(BOOL) isDecimal decimalLength:(int)decimalLength prefix:(NSString*)prefix suffix:(NSString*)suffix;
-(void)addSwitch:(NSString*)key title:(NSString*)title isOn:(BOOL) isOn action:(SEL)action;
-(void)addPicker:(NSString*)key title:(NSString*)title pickerDataSource:(NSArray*)datasource defaultValue:(id)defaultValue;
-(void)addPicker:(NSString*)key title:(NSString*)title pickerDataSource:(NSArray*)datasource defaultValue:(id)defaultValue autoDoneAfterSelect:(BOOL)autoDoneAfterSelect;
-(void)addDatePicker:(NSString*)key title:(NSString*)title defautValue:(NSDate*) defautValue dateMode:(enum UIDatePickerMode)dateMode displayFormat:(NSString*) displayFormat;
-(void)addDetailButton:(NSString*)key title:(NSString*)title selectAction:(SEL)action;
-(void)addDetailButton:(NSString*)key title:(NSString*)title text:(NSString*)text selectAction:(SEL)action;
-(void)addImagePicker:(NSString*)key title:(NSString*)title imagePickerDataSource:(NSArray*)datasource defaultValue:(id)defaultValue;
-(void)addLabel:(NSString*)key title:(NSString*)title text:(NSString*)text;
-(UIButton*)addButton:(NSString*) key text:(NSString*)text clickAction:(SEL)action isDestructiveButton:(BOOL)isDestructiveButton;
-(UIButton*) addButton:(NSString*) key text:(NSString*)text clickAction:(SEL)action textColor:(UIColor*)txtColor bgColor:(UIColor*)bgColor;
-(UILabel*)addTitle:(NSString*) key title:(NSString*)title;

-(void) cleanup;

-(id) GetCellValueByKey:(NSString*)key;
-(void) SetCellValueByKey:(NSString*)key value:(id)value;


-(void) SetCellTitleByKey:(NSString*) key title:(NSString*)title;
-(void) SetCellTitleByKey:(NSString*) key title:(NSString*)title refreshTable:(BOOL)refreshTable;
-(void) SetCellTitleColorByKey:(NSString*) key color:(UIColor*)color;
-(void) SetCellTitleColorByKey:(NSString*) key color:(UIColor*)color refreshTable:(BOOL)refreshTable;
-(void) SetCellTitleFontSizeByKey:(NSString*) key fontSize:(CGFloat)fontSize;
-(void) SetCellTitleFontSizeByKey:(NSString*) key fontSize:(CGFloat)fontSize refreshTable:(BOOL)refreshTable;
-(void) SetCellHiddenByKey:(NSString*) key isHidden:(BOOL)isHidden;
-(void) SetCellHiddenByKey:(NSString*) key isHidden:(BOOL)isHidden refreshTable:(BOOL)refreshTable;
-(void) SetCellReadOnlyByKey:(NSString*) key isReadonly:(BOOL)isReadonly;
-(void) SetTableTitleFontSize:(CGFloat)fontSize;
-(void) SetTableTitleFontSize:(CGFloat)fontSize refreshTable:(BOOL)refreshTable;


-(void) HideControllKeyboard;


-(UITableViewCell*) GetCellByKey:(NSString*)key;
-(NSString*) GetCellTitleByKey:(NSString*) key;
-(UIColor*) GetCellTitleColorByKey:(NSString*) key;

-(void) addValidation:(NSString*)key isRequire:(BOOL)isRequire minLength:(NSNumber*)minLength maxLength:(NSNumber*)maxLength minValue:(NSNumber*)minValue maxValue:(NSNumber*)maxValue;


-(void) addValidation:(NSString*)key isRequire:(BOOL)isRequire minLength:(NSNumber*)minLength maxLength:(NSNumber*)maxLength;
-(void) addValidation:(NSString*)key isRequire:(BOOL)isRequire minValue:(NSNumber*)minValue maxValue:(NSNumber*)maxValue;
-(void) addValidation:(NSString*)key maxValue:(NSNumber*)maxValue;
-(void) addValidation:(NSString*)key maxLength:(NSNumber*)maxLength;
-(void) addValidation:(NSString*)key;
-(BOOL) IsValidated;

-(void) addSectionWithName:(NSString*) sectionName;
@end

enum POPFormTableCellType {
    POPFormTableCellType_TextBox,
    POPFormTableCellType_NumberTextBox,
    POPFormTableCellType_Picker,
    POPFormTableCellType_DatePicker,
    POPFormTableCellType_Switcher,
    POPFormTableCellType_Label,
    POPFormTableCellType_DetailButton,
    POPFormTableCellType_ImagePicker,
    POPFormTableCellType_Button,
    POPFormTableCellType_Title,
};

@interface POPFormTable_CellInfo:NSObject
@property (nonatomic) NSString* key;
@property (nonatomic) NSString* title;
@property (nonatomic) enum POPFormTableCellType type;
@property (nonatomic) id control;
@property (nonatomic) id subControl;
@property (nonatomic) SEL action;
@property (nonatomic) UIColor* titleColor;
@property (nonatomic) CGFloat fontSize; //pointSize default 17.0
@property (nonatomic) BOOL isHidden;
@property (nonatomic) BOOL isReadonly;
@property (nonatomic) NSNumber* sectionIndex;
@property (nonatomic) NSInteger rowIndex;


//all cell
@property (nonatomic) BOOL isRequire;
//textfield
@property (nonatomic) NSNumber* minLength;
@property (nonatomic) NSNumber* maxLength;
//textfield number
@property (nonatomic) NSNumber* minValue;
@property (nonatomic) NSNumber* maxValue;


@end


@interface POPFormTable_PickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic) NSArray* datarows;
@property (nonatomic) UITextField* displayTextfield;
@property (nonatomic) id selectedValue;
@property (nonatomic) BOOL autoDoneAfterSelect;
@end

@interface POPFormTable_ImagePickerView : UIPickerView <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic) NSArray* datarows;
@property (nonatomic) UITextField* displayTextfield;
@property (nonatomic) id selectedValue;
@property (nonatomic) BOOL autoDoneAfterSelect;
@end


@interface POPFormTable_DatePickerView : UIDatePicker
@property (nonatomic) UITextField* displayTextfield;
@property (nonatomic) NSString* dateFormat;
@end


@interface POPFormTable_PickerItem : NSObject
@property (nonatomic) NSString* text;
@property (nonatomic) id value;
+(id) initWithText:(NSString*) text value:(id)value;
@end


@interface POPFormTable_ImagePickerItem : NSObject
@property (nonatomic) NSString* text;
@property (nonatomic) id value;
@property (nonatomic) NSString* imageName;
+(id) initWithText:(NSString*) text value:(id)value imageName:(NSString*)imageName;
@end

@interface POPFormTable_NumberTextfield : UITextField
@property (nonatomic) NSString* key;
@property (nonatomic) BOOL isDecimal;
@property (nonatomic) NSNumber* value;

@property (nonatomic) NSString* thousandSeparator; //default is ,
@property (nonatomic) NSString* decimalSeparator;  //default is .
@property (nonatomic) int decimalLength;  //default is 2
@property (nonatomic) NSString* prefix;
@property (nonatomic) NSString* suffix;

-(void) validate;
@end


@interface POPFormTable_Textfield : UITextField
@property (nonatomic) NSString* key;
@end

@interface POPFormTable_Switch : UISwitch
@property (nonatomic) NSString* key;
@end
