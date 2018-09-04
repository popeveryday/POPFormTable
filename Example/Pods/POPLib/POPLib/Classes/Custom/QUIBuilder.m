//
//  QUIBuilder.m
//  Lizks Studio
//
//  Created by Trung Pham Hieu on 8/25/17.
//  Copyright © 2017 poptato. All rights reserved.
//

#import "QUIBuilder.h"
#import <POPLib/NetServiceHelper.h>
#import <POPLib/POPLib.h>
#import "RTLabel.h"
#import "PageView.h"
#import "CollectionView.h"
#import <objc/runtime.h>
#import <FontAwesomeKit/FontAwesomeKit.h>

#define CONTROL_TYPES  @{@"label": @(ALControlTypeLabel),\
@"image": @(ALControlTypeImage), \
@"view": @(ALControlTypeView), \
@"button": @(ALControlTypeButton), \
@"textview": @(ALControlTypeTextView), \
@"textfield": @(ALControlTypeTextField), \
@"progressview": @(ALControlTypeProgressView), \
@"blurview": @(ALControlTypeVisualEffectView), \
@"colorlabel": @(ALControlTypeColorLabel),\
@"scrollview": @(ALControlTypeScrollView),\
@"pageview": @(ALControlTypePageView),\
@"collectionview": @(ALControlTypeCollectionView),\
@"slider": @(ALControlTypeSlider),\
@"switch": @(ALControlTypeSwitch),\
}

#define CONTROL_BREAK @"<<BrEak>>"
#define AUTOTEXT_BREAK @"<<AuToTeXt"
#define DEVICE_BREAK @"<<DeViCe"








@implementation QUIBuilder

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock
{
    return [self rebuildUIWithFile:file containerView:container device:QUIBuilderDeviceType_AutoDetectIphoneOnly genUIType:QUIBuilderGenUITypeDefault genUIModeKey:@"default" updateContentBlock:nil errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container updateContentBlock:(NSString*(^)(NSString *content)) updateContentBlock errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock
{
    return [self rebuildUIWithFile:file containerView:container device:QUIBuilderDeviceType_AutoDetectIphoneOnly genUIType:QUIBuilderGenUITypeDefault genUIModeKey:@"default" updateContentBlock:updateContentBlock errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock{
    return [self rebuildUIWithContent:content containerView:container device:QUIBuilderDeviceType_AutoDetectIphoneOnly genUIType:QUIBuilderGenUITypeDefault genUIModeKey:@"default" errorBlock:errorBlock];
}

+(NSDictionary*) rebuildUIWithFile:(NSString*)file containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device genUIType:(enum QUIBuilderGenUIType)genUIType genUIModeKey:(NSString*)genUIModeKey updateContentBlock:(NSString*(^)(NSString *content)) updateContentBlock errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock
{
    if(![FileLib checkPathExisted:file]) return nil;
    NSString* content = [FileLib readFile:file];
    
    if (updateContentBlock) {
        content = updateContentBlock(content);
    }
    
    return [self rebuildUIWithContent:content containerView:container device:device genUIType:genUIType genUIModeKey:genUIModeKey errorBlock:errorBlock];
}



//genUIModeKey: for filter some views will not be gen if in different mode.
//if not set mode or blank mode => do nothing
//if mode XX pass to function => view with mode = XX will show, view with mode != XX => not add, view not specific mode will not check mode and will be add.
+(NSDictionary*) rebuildUIWithContent:(NSString*)content containerView:(UIView*)container device:(enum QUIBuilderDeviceType)device genUIType:(enum QUIBuilderGenUIType)genUIType genUIModeKey:(NSString*)genUIModeKey errorBlock:(void(^)(NSString *msg, NSException *exception)) errorBlock
{
    
    NSDictionary* allItemDic = [self handleContent:content withDevice:device];
    
    NSString* propKey = @"starting", *propValue, *name, *applyMode;
    NSMutableDictionary* uiElements = [NSMutableDictionary new];
    NSDictionary* itemDic;
    
    @try{
        
        NSArray* sortedKeys = [allItemDic.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* a,NSString* b){
            return [a compare:b];
        }];
        
        NSArray* alreadAddedSubviews = [container subviews];
        
        //for creating view
        for (NSString* sortedItemKey in sortedKeys) {
            
            itemDic = [allItemDic objectForKey:sortedItemKey];
            
            applyMode = nil;
            if ([StringLib isValid:genUIModeKey])
            {
                propKey = @"applymode";
                if([itemDic.allKeys containsObject:propKey])
                {
                    applyMode = [itemDic objectForKey:propKey];
                    applyMode = [StringLib trim:applyMode];
                    
                    if (![applyMode isEqualToString:@""]) {
                        //not same ui mode key => not gen this item.
                        if(![[StringLib trim:[genUIModeKey uppercaseString]] isEqualToString:[applyMode uppercaseString]])
                            continue;
                    }
                }
            }
            
            propKey = @"name";
            name = [StringLib subStringBetween:sortedItemKey startStr:@"(" endStr:@")"];
            UIView* view;
            
            propKey = @"type";
            propValue = [itemDic objectForKey:propKey];
            enum ALControlType controlType = (enum ALControlType) [[CONTROL_TYPES objectForKey:propValue.lowercaseString] integerValue];
            
            propKey = @"superedge";
            NSString* superEdge = superEdge = [itemDic objectForKey:propKey];
            
            //otherEdge = B-10:tf, T10:abc
            propKey = @"otheredge";
            NSMutableDictionary* otherEdge = [NSMutableDictionary new];
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                NSArray* otherEdgeArr = [propValue componentsSeparatedByString:@","];
                
                for (NSString* oneEdge in otherEdgeArr) {
                    if(![oneEdge containsString:@":"]) continue;
                    NSArray* arr = [oneEdge componentsSeparatedByString:@":"];
                    NSString* edgeValue = [StringLib trim:arr[0]];
                    NSString* otherViewName = [StringLib trim:arr[1]];
                    UIView* otherView = [uiElements objectForKey:otherViewName];
                    if(!otherView) continue;
                    [otherEdge setObject:otherView forKey:edgeValue];
                }
            }
            
            UIView* containerView = container;
            propKey = [@"container" lowercaseString];
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([uiElements.allKeys containsObject:propValue])
                    containerView = [uiElements objectForKey:propValue];
            }
            
            if ([containerView isEqual:container] && genUIType != QUIBuilderGenUITypeDefault)
            {
                UIView* addedView;
                for (UIView* v in alreadAddedSubviews) {
                    if([v.viewName isEqualToString:name])
                    {
                        addedView = v;
                        break;
                    }
                }
                
                if (addedView) {
                    switch (genUIType) {
                        case QUIBuilderGenUITypeSkipItemIfExist:
                            continue;
                            break;
                        case QUIBuilderGenUITypeUpdateItemIfExist:
                            view = addedView;
                            break;
                        case QUIBuilderGenUITypeRemoveAndAddItemIfExist:
                            [addedView removeFromSuperview];
                            break;
                        default:
                            break;
                    }
                }
            }
            
            
            if (!view) {
                view = [ViewLib initAutoLayoutWithType:controlType viewContainer:containerView superEdge:superEdge otherEdge:otherEdge viewName:name];
            }
            
            view.viewName = name;
            [uiElements setObject:view forKey:name];
            
            if (applyMode)
            {
                [view.localizedTexts setObject:applyMode forKey:@"applyMode"];
            }
        }
        
        //for properties and action
        for (NSString* sortedItemKey in sortedKeys)
        {
            NSString* name = [StringLib subStringBetween:sortedItemKey startStr:@"(" endStr:@")"];
            UIView* view = [uiElements objectForKey:name];
            itemDic = [allItemDic objectForKey:sortedItemKey];
            
            //UIView
            propKey = @"borderwidth";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.layer.borderWidth = [propValue floatValue];
            }
            
            
            propKey = @"hidden";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.hidden = [self boolValue:propValue];
            }
            
            
            propKey = @"cornerradius";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if ([propValue.lowercaseString isEqualToString:@"auto"])
                {
                    CGSize viewSize = [self getViewSizeWithItemDic:itemDic];
                    CGFloat sideValue = viewSize.width > viewSize.height ? viewSize.height : viewSize.width;
                    if(sideValue > 0) view.layer.cornerRadius = sideValue / 2;
                }
                else
                {
                    view.layer.cornerRadius = [propValue floatValue];
                }
            }
            
            propKey = @"bgcolor";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.backgroundColor = [self colorObj:propValue];
            }
            
            propKey = @"tag";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.tag = [propValue integerValue];
            }
            
            
            propKey = @"bordercolor";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.layer.borderColor = [[self colorObj:propValue] CGColor];
            }
            
            propKey = @"alpha";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.alpha = [propValue floatValue];
            }
            
            propKey = @"clipstobounds";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.clipsToBounds = [self boolValue:propValue];
            }
            
            propKey = @"interaction";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.userInteractionEnabled = [self boolValue:propValue];
            }
            
            propKey = @"font";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).font = [self fontObj:propValue];
                if([view isKindOfClass:[UIButton class]]) ((UIButton*)view).titleLabel.font = [self fontObj:propValue];
            }
            
            propKey = @"shadown";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                [self applyShadownWithView:view value:propValue];
            }
            
            propKey = @"transform";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                view.transform = [self transformFromValue:propValue];
            }
            
            propKey = @"embeduifile";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                [self embedUIWithValue:propValue forView:view device:device genUIType:genUIType genUIModeKey:genUIModeKey];
            }
            
            propKey = @"circleprogress";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                [self addCircleProgressWithView:view value:propValue itemDic:itemDic];
            }
            
            //TextField, TextView
            propKey = @"placeholder";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                [view.localizedTexts setObject:propValue forKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).placeholder = [self textObj:propValue];
            }
            
            propKey = @"placeholdercolor";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) [self placeholderColorObj:propValue textfield:(UITextField*)view];
            }
            
            
            propKey = @"textcolor";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).textColor = [self colorObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).textColor = [self colorObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).textColor = [self colorObj:propValue];
            }
            
            
            propKey = @"returnkeytype";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).returnKeyType = [self returnKeyTypeObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).returnKeyType = [self returnKeyTypeObj:propValue];
            }
            
            
            propKey = @"textalignment";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).textAlignment = [self textAlignObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).textAlignment = [self textAlignObj:propValue];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).textAlignment = [self textAlignObj:propValue];
                if([view isKindOfClass:[RTLabel class]]) ((RTLabel*)view).textAlignment = [self textAlignObjRT:propValue];
            }
            
            
            propKey = @"text";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                [view.localizedTexts setObject:propValue forKey:propKey];
                
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).text = [self textObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).text = [self textObj:propValue];
                if([view isKindOfClass:[RTLabel class]]) [((RTLabel*)view) setText:[self textObj:propValue]];
                if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).text = [self textObj:propValue];
            }
            
            propKey = @"ispassword";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).secureTextEntry = [self boolValue:propValue];
            }
            
            
            
            propKey = @"clearbuttonmode";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).clearButtonMode = [self clearButtonModeObj:propValue];
            }
            
            propKey = @"autocaptype";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).autocapitalizationType = [self autocapTypeObj:propValue];
                if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).autocapitalizationType = [self autocapTypeObj:propValue];
            }
            
            
            //UIImageView, UIView
            propKey = @"contentmode";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UIButton class]])
                    ((UIButton*)view).imageView.contentMode = [self contentModeObj:propValue];
                else view.contentMode = [self contentModeObj:propValue];
            }
            
            
            propKey = @"src";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[UIImageView class]]) ((UIImageView*)view).image = [self imageObj:propValue];
            }
            
            //UIProgressView
            if ([view isKindOfClass:[UIProgressView class]])
            {
                propKey = @"progress";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UIProgressView*)view).progress = propValue.floatValue;
                }
                
                propKey = @"progresscolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UIProgressView*)view).progressTintColor = [self colorObj:propValue];
                }
                
                propKey = @"trackcolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UIProgressView*)view).trackTintColor = [self colorObj:propValue];
                }
                
                propKey = @"progressimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UIProgressView*)view).progressImage = [self imageObj:propValue];
                }
                
                propKey = @"trackimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UIProgressView*)view).trackImage = [self imageObj:propValue];
                }
                
            }
            
            //UISlider
            if ([view isKindOfClass:[UISlider class]])
            {
                propKey = @"value";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UISlider*)view).value = propValue.floatValue;
                }
                
                propKey = @"minvalue";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UISlider*)view).minimumValue = propValue.floatValue;
                }
                
                propKey = @"maxvalue";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UISlider*)view).maximumValue = propValue.floatValue;
                }
                
                propKey = @"minimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UISlider*)view).minimumValueImage = [self imageObj:propValue];
                }
                
                propKey = @"maximage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UISlider*)view).maximumValueImage = [self imageObj:propValue];
                }
                
                propKey = @"mintrackcolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UISlider*)view).minimumTrackTintColor = [self colorObj:propValue];
                }
                
                propKey = @"maxtrackcolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UISlider*)view).maximumTrackTintColor = [self colorObj:propValue];
                }
                
                propKey = @"thumbcolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UISlider*)view).thumbTintColor = [self colorObj:propValue];
                }
                
                propKey = @"thumbimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [((UISlider*)view) setThumbImage:[self imageObj:propValue] forState:(UIControlStateNormal)];
                }
            }
            
            //UIButton
            if ([view isKindOfClass:[UIButton class]]) {
                propKey = @"title";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [view.localizedTexts setObject:propValue forKey:propKey];
                    [self titleObj:propValue button:(UIButton*)view];
                }
                
                propKey = @"titlecolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [self titleColorObj:propValue button:(UIButton*)view];
                }
                
                propKey = @"bgimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [self bgImageObj:propValue button:(UIButton*)view];
                }
                
                propKey = @"titleimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [self titleImageObj:propValue button:(UIButton*)view];
                }
                
                propKey = @"showtouch";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    ((UIButton*)view).showsTouchWhenHighlighted = [self boolValue:propValue];
                }
            }
            
            //UISwitch
            if ([view isKindOfClass:[UISwitch class]]) {
                propKey = @"ison";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [((UISwitch*)view) setOn: [self boolValue:propValue]];
                }
                
                propKey = @"onimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [((UISwitch*)view) setOnImage: [self imageObj:propValue]];
                }
                
                propKey = @"offimage";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [((UISwitch*)view) setOffImage: [self imageObj:propValue]];
                }
                
                propKey = @"tintcolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [((UISwitch*)view) setTintColor: [self colorObj:propValue]];
                }
                
                propKey = @"thumbcolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [((UISwitch*)view) setThumbTintColor: [self colorObj:propValue]];
                }
                
                propKey = @"ontintcolor";
                if([itemDic.allKeys containsObject:propKey])
                {
                    propValue = [itemDic objectForKey:propKey];
                    [((UISwitch*)view) setOnTintColor: [self colorObj:propValue]];
                }
            }
            
            //UILabel, UIButton
            propKey = @"underline";
            if([itemDic.allKeys containsObject:propKey]
               && ([view isKindOfClass:[UILabel class]] || [view isKindOfClass:[UIButton class]]) )
            {
                propValue = [itemDic objectForKey:propKey];
                
                if([self boolValue:propValue]){
                    
                    NSString* stringValue = [view isKindOfClass:[UILabel class]] ? ((UILabel*)view).text : [((UIButton*)view) currentTitle];
                    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:stringValue];
                    [attributeString addAttribute:NSUnderlineStyleAttributeName
                                            value:[NSNumber numberWithInt:1]
                                            range:(NSRange){0,[attributeString length]}];
                    
                    if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).attributedText = attributeString;
                    if([view isKindOfClass:[UIButton class]]) ((UIButton*)view).titleLabel.attributedText = attributeString;
                }
            }
            
            //action
            propKey = @"action";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                [self applyAction:propValue forView:view uiElements:uiElements];
            }
            
            //scrollview
            propKey = @"contentsize";
            if([itemDic.allKeys containsObject:propKey] && [view isKindOfClass:[UIScrollView class]])
            {
                propValue = [itemDic objectForKey:propKey];
                ((UIScrollView*)view).contentSize = [self sizeValue:propValue];
            }
            
            //pageview & collectionview
            propKey = @"datasource";
            if([itemDic.allKeys containsObject:propKey])
            {
                propValue = [itemDic objectForKey:propKey];
                if([view isKindOfClass:[PageView class]]) [self buildPageView:(PageView*)view withDataSource:propValue itemDic:itemDic];
                if([view isKindOfClass:[CollectionView class]]) [self buildCollectionView:(CollectionView*)view withDataSource:propValue itemDic:itemDic];
                
            }
            
            //blur view or UIVisualEffectView
            propKey = @"blurstyle";
            if([itemDic.allKeys containsObject:propKey] && [view isKindOfClass:[UIVisualEffectView class]])
            {
                propValue = [itemDic objectForKey:propKey];
                [((UIVisualEffectView*)view) setEffect:[UIBlurEffect effectWithStyle: [self getBlurEffectStyle:propValue] ]];
            }
        }
    }@catch(NSException* exception)
    {
        NSString* error = [NSString stringWithFormat:@"ViewName:%@\nPropKey:%@\nException(%s): \n%@", name, propKey, __func__, exception];
        NSLog(@"%@", error);
        if(errorBlock) errorBlock(error, exception);
    }
    
    return uiElements;
}

+(void) clearQUIViewWithUIElement:(NSDictionary*) uiElements
{
    for (UIView* view in uiElements.allValues) {
        [self cleanUpView:view];
    }
}

+(void) clearView:(UIView*)mainView includeAllSubView:(BOOL)includeAllSubView
{
    [self cleanUpView:mainView];
    
    if(!includeAllSubView) return;
    
    for (UIView* view in mainView.subviews) {
        
        if ([view isKindOfClass:[CollectionView class]]) {
            ((CollectionView*)view).delegate = nil;
        }
        
        if ([view isKindOfClass:[PageView class]]) {
            ((PageView*)view).delegate = nil;
        }
        
        @try{ [view setValue:nil forKey:@"delegate"]; }@catch(NSException* exception){}
        
        [view removeConstraints:view.constraints];
        
        [view removeAllHandleEvent];
        [view removeFromSuperview];
    }
}

+(void) cleanUpView:(UIView*)view
{
    if ([view isKindOfClass:[CollectionView class]]) {
        ((CollectionView*)view).delegate = nil;
    }
    
    if ([view isKindOfClass:[PageView class]]) {
        ((PageView*)view).delegate = nil;
    }
    
    @try{ [view setValue:nil forKey:@"delegate"]; }@catch(NSException* exception){}
    
    [view removeConstraints:view.constraints];
    
    [view removeAllHandleEvent];
    [view removeFromSuperview];
}


+(NSString*) genCode:(NSDictionary*)uiElements
{
    return [self genCode:uiElements shouldGenCodeForView:nil];
}

+(NSString*) genCode:(NSDictionary*)uiElements shouldGenCodeForView:(BOOL(^)(UIView *view)) checkViewBlock
{
    NSString* init = @"", *getset = @"";
    
    NSArray* sortedArrayKeys = [uiElements.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* a,NSString* b){
        return [a compare:b];
    }];
    
    for (NSString* key in sortedArrayKeys)
    {
        id control = [uiElements objectForKey:key];
        
        if (checkViewBlock) {
            if(! checkViewBlock(control) ) continue;
        }
        
        init = [NSString stringWithFormat:@"%@%@* %@;\n",init, [control class], key];
        getset = [NSString stringWithFormat:@"%@%@ = [_uiElements objectForKey:@\"%@\"];\n", getset, key, key];
    }
    
    
    NSString* gencode = @"NSString* file = [FileLib getDocumentPath:@\"[PATH_TO_QUI_FILE]\"];\n_uiElements = [QUIBuilder rebuildUIWithFile:file containerView:<#self.view#> device:<#QUIBuilderDeviceType_AutoDetectUniversal#> genUIType:QUIBuilderGenUITypeDefault genUIModeKey:@\"default\" updateContentBlock:nil errorBlock:^(NSString *msg, NSException *exception) {\
    NSLog(@\"%@\", msg);\
    }];";
    
    return [NSString stringWithFormat:@"%@\n\n%@\n\n%@", init, gencode, getset];
}

+(void) refreshLocalizedForView:(UIView*)view withKey:(NSString*)key
{
    if(![view.localizedTexts.allKeys containsObject:key]) return;
    
    NSString* propValue = [view.localizedTexts objectForKey:key];
    if ([key isEqualToString:@"text"])
    {
        if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).text = [self textObj:propValue];
        if([view isKindOfClass:[UITextView class]]) ((UITextView*)view).text = [self textObj:propValue];
        if([view isKindOfClass:[RTLabel class]]) [((RTLabel*)view) setText:[self textObj:propValue]];
        if([view isKindOfClass:[UILabel class]]) ((UILabel*)view).text = [self textObj:propValue];
    }
    
    if ([key isEqualToString:@"title"])
    {
        if([view isKindOfClass:[UIButton class]]) [self titleObj:propValue button:(UIButton*)view];
    }
    
    if ([key isEqualToString:@"placeholder"])
    {
        if([view isKindOfClass:[UITextField class]]) ((UITextField*)view).placeholder = [self textObj:propValue];
    }
}

//update value (iphone 6) to iphone 4,5,6plus
//iphone X is same as iphone 6
//ipadpro10 and ipadpro12 base on ipadhd (768px)
+(double) valueByDeviceScale:(double)value withDevice:(enum QUIBuilderDeviceType)deviceType
{
    NSString* device = [self getDeviceCode:deviceType];
    
    double result = value;
    if ([@"iphone5,iphone4" containsString:device]) {
        result = value * (320.0f/375.0f);
    }
    
    if ([device isEqualToString: @"iphone6p"]) {
        result = value * (414.0f/375.0f);
    }
    
    
    
    if ([device isEqualToString: @"ipadpro10"]) {
        result = value * (834.0f/768.0f);
    }
    
    if ([device isEqualToString: @"ipadpro12"]) {
        result = value * (1024.0f/768.0f);
    }
    
    return result;
}










#pragma builder functions

//embedUIFile = doc: quibuilder/home/home.qui
+(void) embedUIWithValue:(NSString*)fileValue forView:(UIView*)view device:(enum QUIBuilderDeviceType)device genUIType:(enum QUIBuilderGenUIType)genUIType genUIModeKey:(NSString*)genUIModeKey
{
    NSString* path = [self pathObj:fileValue];
    if (!path) return;
    
    [self rebuildUIWithFile:path containerView:view device:device genUIType:genUIType genUIModeKey:genUIModeKey updateContentBlock:nil errorBlock:^(NSString *msg, NSException *exception) {
        NSLog(@"%@", exception);
    }];
}

//-1,1 => CGAffineTransformMakeScale(-1, 1)
+(CGAffineTransform)transformFromValue:(NSString*)value
{
    NSArray* arr = [value componentsSeparatedByString:@","];
    CGFloat x = [arr[0] floatValue];
    CGFloat y = arr.count > 1 ? [arr[1] floatValue] : x;
    return CGAffineTransformMakeScale(x, y);
}

+(void) buildCollectionView:(CollectionView*)view withDataSource:(NSString*)propValue itemDic:(NSDictionary*)itemDic
{
    CGSize itemSize = CGSizeMake(100, 100);
    CGFloat itemSpacing = 10;
    CGFloat lineSpacing = 10;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    BOOL scrollHorizontal = NO;
    BOOL redrawCell = NO;
    
    
    NSString* _itemSize = [itemDic objectForKey:@"itemsize"];
    NSString* _itemSpacing = [itemDic objectForKey:@"itemspacing"];
    NSString* _lineSpacing = [itemDic objectForKey:@"linespacing"];
    NSString* _sectionInset = [itemDic objectForKey:@"sectioninset"];
    NSString* _scrollHorizontal = [itemDic objectForKey:@"scrollhorizontal"];
    NSString* _redrawCell = [itemDic objectForKey:@"redrawcell"];
    
    NSArray* arr;
    if([StringLib isValid: _itemSize])
    {
        arr = [_itemSize containsString:@","] ? [_itemSize componentsSeparatedByString:@","] : [_itemSize containsString:@";"] ? [_itemSize componentsSeparatedByString:@";"] : @[_itemSize, _itemSize];
        itemSize = CGSizeMake([[arr objectAtIndex:0] floatValue], [[arr objectAtIndex:1] floatValue]);
    }
    if([StringLib isValid: _itemSpacing]) itemSpacing = [_itemSpacing floatValue];
    if([StringLib isValid: _lineSpacing]) lineSpacing = [_lineSpacing floatValue];
    if([StringLib isValid: _sectionInset])
    {
        arr = [_sectionInset containsString:@","] ? [_sectionInset componentsSeparatedByString:@","] : [_sectionInset containsString:@";"] ? [_sectionInset componentsSeparatedByString:@";"] : @[_sectionInset, _sectionInset, _sectionInset, _sectionInset];
        sectionInset = UIEdgeInsetsMake([[arr objectAtIndex:0] floatValue], [[arr objectAtIndex:1] floatValue], [[arr objectAtIndex:2] floatValue], [[arr objectAtIndex:3] floatValue]);
    }
    if([StringLib isValid: _scrollHorizontal]) scrollHorizontal = [_scrollHorizontal.lowercaseString containsString:@"true"];
    if([StringLib isValid: _redrawCell]) redrawCell = [_redrawCell.lowercaseString containsString:@"true"];
    
    NSDictionary* dataSource = [[StringLib deparseString:propValue] toDictionary];
    NSInteger total = [[dataSource objectForKey:@"totalItem"] integerValue];
    NSString* itemFileOrData = [dataSource objectForKey:@"itemFile"];
    if(itemFileOrData) itemFileOrData = [self pathObj:itemFileOrData];
    if(!itemFileOrData){
        itemFileOrData = [dataSource objectForKey:@"itemData"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"<<BrEak2>>" withString:@"<<BrEak>>"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"<<FoR2" withString:@"<<FoR"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"FoR2>>" withString:@"FoR>>"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"<<ReP2" withString:@"<<ReP"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"ReP2>>" withString:@"ReP>>"];
    }
    
    NSString* temp;
    if (itemFileOrData) {
        NSMutableArray* pageData = [NSMutableArray new];
        NSMutableDictionary* otherKeyValues = [NSMutableDictionary new];
        
        for (NSString* key in dataSource.allKeys) {
            if([key isEqualToString:@"totalItem"]) continue;
            if([key isEqualToString:@"itemFile"]) continue;
            if([key isEqualToString:@"itemData"]) continue;
            temp = [dataSource objectForKey:key];
            temp = [NSString stringWithFormat:@"data = %@", temp];
            [otherKeyValues setObject:[self getItemFromForloop:temp maxSize:total] forKey:key];
        }
        
        
        NSArray* tempArr;
        for (NSInteger i = 0; i < total; i++)
        {
            temp = [FileLib checkPathExisted:itemFileOrData] ? [FileLib readFile: itemFileOrData] : itemFileOrData;
            
            for (NSString* key in otherKeyValues.allKeys)
            {
                tempArr = [otherKeyValues objectForKey:key];
                if(tempArr.count > i)
                    temp = [temp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$%@$",key] withString:[tempArr objectAtIndex:i]];
            }
            [pageData addObject:temp];
        }
        
        view.itemSize = itemSize;
        view.itemSpacing = itemSpacing;
        view.lineSpacing = lineSpacing;
        view.sectionInset = sectionInset;
        view.isScrollDirectionHorizontal = scrollHorizontal;
        view.isRemoveAllSubviewBeforeDrawCell = redrawCell;
        view.itemData = pageData;
        [view initUI];
    }
}

/*
 Other key except (totalItem, itemFile, itemData) will be foreach add to data
 1. dataSource = totalItem [EqL] 2 [AnD] itemFile [EqL] doc:quibuilder/item.qui
 2. dataSource = totalItem [EqL] 2 [AnD] itemData [EqL]
 type [EqL2] button
 [AnD2] name [EqL2] lala2
 */
+(void) buildPageView:(PageView*)view withDataSource:(NSString*)propValue itemDic:(NSDictionary*)itemDic
{
    
    CGSize itemSize = CGSizeMake(100, 100);
    CGFloat itemSpacing = 10;
    CGFloat lineSpacing = 10;
    UIEdgeInsets sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    BOOL redrawCell = NO;
    
    NSString* _itemSize = [itemDic objectForKey:@"itemsize"];
    NSString* _itemSpacing = [itemDic objectForKey:@"itemspacing"];
    NSString* _lineSpacing = [itemDic objectForKey:@"linespacing"];
    NSString* _sectionInset = [itemDic objectForKey:@"sectioninset"];
    NSString* _redrawCell = [itemDic objectForKey:@"redrawcell"];
    
    NSArray* arr;
    if([StringLib isValid: _itemSize])
    {
        arr = [_itemSize containsString:@","] ? [_itemSize componentsSeparatedByString:@","] : [_itemSize containsString:@";"] ? [_itemSize componentsSeparatedByString:@";"] : @[_itemSize, _itemSize];
        itemSize = CGSizeMake([[arr objectAtIndex:0] floatValue], [[arr objectAtIndex:1] floatValue]);
    }
    if([StringLib isValid: _itemSpacing]) itemSpacing = [_itemSpacing floatValue];
    if([StringLib isValid: _lineSpacing]) lineSpacing = [_lineSpacing floatValue];
    if([StringLib isValid: _sectionInset])
    {
        arr = [_sectionInset containsString:@","] ? [_sectionInset componentsSeparatedByString:@","] : [_sectionInset containsString:@";"] ? [_sectionInset componentsSeparatedByString:@";"] : @[_sectionInset, _sectionInset, _sectionInset, _sectionInset];
        sectionInset = UIEdgeInsetsMake([[arr objectAtIndex:0] floatValue], [[arr objectAtIndex:1] floatValue], [[arr objectAtIndex:2] floatValue], [[arr objectAtIndex:3] floatValue]);
    }
    if([StringLib isValid: _redrawCell]) redrawCell = [_redrawCell.lowercaseString containsString:@"true"];
    
    NSDictionary* dataSource = [[StringLib deparseString:propValue] toDictionary];
    NSInteger total = [[dataSource objectForKey:@"totalItem"] integerValue];
    NSString* itemFileOrData = [dataSource objectForKey:@"itemFile"];
    if(itemFileOrData) itemFileOrData = [self pathObj:itemFileOrData];
    if(!itemFileOrData){
        itemFileOrData = [dataSource objectForKey:@"itemData"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"<<BrEak2>>" withString:@"<<BrEak>>"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"<<FoR2" withString:@"<<FoR"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"FoR2>>" withString:@"FoR>>"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"<<ReP2" withString:@"<<ReP"];
        itemFileOrData = [itemFileOrData stringByReplacingOccurrencesOfString:@"ReP2>>" withString:@"ReP>>"];
    }
    
    NSString* temp;
    if (itemFileOrData) {
        NSMutableArray* pageData = [NSMutableArray new];
        NSMutableDictionary* otherKeyValues = [NSMutableDictionary new];
        
        for (NSString* key in dataSource.allKeys) {
            if([key isEqualToString:@"totalItem"]) continue;
            if([key isEqualToString:@"itemFile"]) continue;
            if([key isEqualToString:@"itemData"]) continue;
            temp = [dataSource objectForKey:key];
            temp = [NSString stringWithFormat:@"data = %@", temp];
            [otherKeyValues setObject:[self getItemFromForloop:temp maxSize:total] forKey:key];
        }
        
        
        NSArray* tempArr;
        for (NSInteger i = 0; i < total; i++)
        {
            temp = [FileLib checkPathExisted:itemFileOrData] ? [FileLib readFile: itemFileOrData] : itemFileOrData;
            
            for (NSString* key in otherKeyValues.allKeys)
            {
                tempArr = [otherKeyValues objectForKey:key];
                if(tempArr.count > i)
                    temp = [temp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$%@$",key] withString:[tempArr objectAtIndex:i]];
            }
            [pageData addObject:temp];
        }
        
        view.itemData = pageData;
        
        view.itemSize = itemSize;
        view.itemSpacing = itemSpacing;
        view.lineSpacing = lineSpacing;
        view.sectionInset = sectionInset;
        
        [view initUI];
    }
}

//contentsize = width,height
+(CGSize) sizeValue:(NSString*)value
{
    NSArray* arr = [value componentsSeparatedByString:@","];
    CGFloat width = [arr[0] floatValue];
    CGFloat height = [arr.lastObject floatValue];
    return CGSizeMake(width, height);
}

+(CGSize) getViewSizeWithItemDic:(NSDictionary*)itemDic
{
    NSString* tempstr = [itemDic objectForKey:@"superedge"];
    for (NSString* letter in [@"T,R,L,B,C,H,V,W,E,S" componentsSeparatedByString:@","] ) {
        tempstr = [tempstr stringByReplacingOccurrencesOfString:letter withString:[NSString stringWithFormat:@",%@",letter]];
    }
    
    CGFloat width = 0, height = 0, tempValue = 0;
    for (NSString* item in [tempstr componentsSeparatedByString:@","])
    {
        @try{
            
            if(![item hasPrefix:@"E"] && ![item hasPrefix:@"W"] && ![item hasPrefix:@"S"]) continue;
            tempValue = [[[StringLib trim:item] substringFromIndex:1] floatValue];
            
            if([item hasPrefix:@"W"]) width = tempValue;
            if([item hasPrefix:@"E"]) height = tempValue;
            if([item hasPrefix:@"S"]) width = height = tempValue;
            
            if(width > 0 && height > 0) break;
            
        }@catch(NSException* exception)
        {
            NSString* error = [NSString stringWithFormat:@"Exception(%s):cornerradius \n%@", __func__, exception];
            NSLog(@"%@", error);
        }
    }
    
    return CGSizeMake(width, height);
}


//circleProgress = 0.9
//circleProgress = false => not to draw
//circleProgress = custom(progress, size, strokeColor, fillColor, lineWidth)
//circleProgress = custom(0.9, 40;40 , red, clear, 5)
//circleProgress = custom(0.9, 40 , red)
//circleProgress = custom(0.9, , , , 5)
+(void) addCircleProgressWithView:(UIView*)view value:(NSString*)value itemDic:(NSDictionary*)itemDic
{
    value = [StringLib trim:value];
    if([value.lowercaseString isEqualToString:@"false"]) return;
    
    CGSize size = [self getViewSizeWithItemDic:itemDic];
    CGFloat progress = 0.0f, lineWidth = 0;
    UIColor* strokeColor = nil, *fillColor = nil;
    
    
    if ([value.lowercaseString hasPrefix:@"custom"]) {
        NSString* options = [StringLib subStringBetween:value startStr:@"(" endStr:@")"];
        if([StringLib isValid:options]){
            NSArray* arr = [options componentsSeparatedByString:@","];
            
            NSString* _progress = arr.count > 0 ? arr[0] : nil;
            NSString* _size = arr.count > 1 ? arr[1] : nil;
            NSString* _strokeColor = arr.count > 2 ? arr[2] : nil;
            NSString* _fillColor = arr.count > 3 ? arr[3] : nil;
            NSString* _lineWidth = arr.count > 4 ? arr[4] : nil;
            
            if([StringLib isValid: _progress]) progress = [_progress floatValue];
            if([StringLib isValid: _strokeColor]) strokeColor = [self colorObj:_strokeColor];
            if([StringLib isValid: _fillColor]) fillColor = [self colorObj:_fillColor];
            if([StringLib isValid: _lineWidth]) lineWidth = [_lineWidth floatValue];
            if([StringLib isValid: _size]){
                NSArray* locarr = [_size componentsSeparatedByString:@";"];
                size = CGSizeMake([locarr[0] floatValue], locarr.count>1?[locarr[1] floatValue]:0);
            }
        }
    }else{
        progress = [value floatValue];
    }
    
    [ViewLib drawCircleProgressWithView:view progress:progress size:size strokeColor:strokeColor fillColor:fillColor lineWidth:lineWidth];
}




//shadown = default or shadown = true
//shadown = false
//shadown = custom(color, radius, offset, opacity)
//ex: shadown with color = '#FFCC00', radius = 0.4f, offset = CGSizeMake(0, 2), opacity = 0.5f
//    shadown = custom(#FFCC00, 0.4, 0;2 , 0.5)
//ex: shadown with color = '#FFCC00' alpha 0.5, offset = CGSizeMake(0, 2)
//    shadown = custom(#FFCC00;0.5,,0;2)
//ex: shadown with offset = CGPointMake(0, 2)
//    shadown = custom(, , 0;2 )
+(void) applyShadownWithView:(UIView*)view value:(NSString*)value
{
    
    value = [StringLib trim:value];
    if([value.lowercaseString isEqualToString:@"false"]) return;
    
    UIColor* color = [UIColor grayColor];
    CGFloat radius = 8.0f;
    CGSize offset = CGSizeMake(0, 2);
    CGFloat opacity = 0.5f;
    
    
    if ([value.lowercaseString hasPrefix:@"custom"]) {
        NSString* options = [StringLib subStringBetween:value startStr:@"(" endStr:@")"];
        if([StringLib isValid:options]){
            NSArray* arr = [options componentsSeparatedByString:@","];
            NSString* _color = arr.count > 0 ? arr[0] : nil;
            NSString* _radius = arr.count > 1 ? arr[1] : nil;
            NSString* _offset = arr.count > 2 ? arr[2] : nil;
            NSString* _opacity = arr.count > 3 ? arr[3] : nil;
            if([StringLib isValid: _color]) color = [self colorObj:_color];
            if([StringLib isValid: _radius]) radius = [_radius floatValue];
            if([StringLib isValid: _opacity]) opacity = [_opacity floatValue];
            if([StringLib isValid: _offset]){
                NSArray* locarr = [_offset componentsSeparatedByString:@";"];
                offset = CGSizeMake([locarr[0] floatValue], locarr.count>1?[locarr[1] floatValue]:0);
            }
        }
    }
    
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowRadius = radius;
}

//action = show(box)  ==> view/button tap to show the object name 'box'.
//action = show(box,item..)  ==> view/button tap to show the object name 'box' and 'item' and more.
//action = hide(box,item..)  ==> view/button tap to hide the object name 'box' and 'item' and more.
//action = toggle(box,item...)  ==> view/button tap to show/hide the object name 'box' and 'item' and more.
//action = observer(number) ==> call [ObserverObject sendObserver:number]
//action = observer(number,obj,key) ==> [ObserverObject sendObserver:number object:@"obj" notificationKey:@"key"]
//action = observer(number,,key) ==> [ObserverObject sendObserver:number object:nil notificationKey:@"key"]
//action = observer(number,obj) ==> [ObserverObject sendObserver:number object:@"obj" notificationKey:nil]
// if view => userinteraction = yes + add tab gesture
// if button => addtarget for button
+(void) applyAction:(NSString*)action forView:(UIView*)view uiElements:(NSMutableDictionary*) uiElements
{
    
    action = [StringLib trim:action];
    
    //encode all special characters: ( ) ,
    action = [action stringByReplacingOccurrencesOfString:@"((" withString:@"[OpEnBrAcKeT]"];
    action = [action stringByReplacingOccurrencesOfString:@"))" withString:@"[ClOsEBrAcKeT]"];
    action = [action stringByReplacingOccurrencesOfString:@",," withString:@"[CoMmA]"];
    
    NSString* actionkey = [[action componentsSeparatedByString:@"("] firstObject];
    NSString* objNamesOrData = [StringLib subStringBetween:action startStr:@"(" endStr:@")"];
    void (^actionBlock)(void);
    
    if ([action hasPrefix:@"show"] || [action hasPrefix:@"hide"] || [action hasPrefix:@"toggle"])
    {
        actionBlock = ^void()
        {
            UIView* obj;
            NSArray* objNameArr = [objNamesOrData componentsSeparatedByString:@","];
            
            for (NSString* objName in objNameArr) {
                obj = [uiElements objectForKey:[StringLib trim:objName]];
                if(!objName || !obj) return;
                
                [obj setHidden: [actionkey isEqualToString:@"show"] ? NO : ([actionkey isEqualToString:@"hide"] ? YES : !obj.hidden) ];
            }
        };
        
        
    }
    else if([action hasPrefix:@"observer"])
    {
        if(!objNamesOrData || ![StringLib isValid:objNamesOrData]) return;
        
        actionBlock = ^void()
        {
            NSArray* arr = [objNamesOrData componentsSeparatedByString:@","];
            NSInteger index = [[arr objectAtIndex:0] integerValue];
            NSString* object = arr.count >= 2 ? [arr objectAtIndex:1] : nil;
            NSString* key = arr.count >= 3 ? [arr objectAtIndex:2] : nil;
            
            object = [object stringByReplacingOccurrencesOfString:@"[OpEnBrAcKeT]" withString:@"("];
            object = [object stringByReplacingOccurrencesOfString:@"[ClOsEBrAcKeT]" withString:@")"];
            object = [object stringByReplacingOccurrencesOfString:@"[CoMmA]" withString:@","];
            
            key = [key stringByReplacingOccurrencesOfString:@"[OpEnBrAcKeT]" withString:@"("];
            key = [key stringByReplacingOccurrencesOfString:@"[ClOsEBrAcKeT]" withString:@")"];
            key = [key stringByReplacingOccurrencesOfString:@"[CoMmA]" withString:@","];
            
            [ObserverObject sendObserver:index object:object notificationKey:key];
        };
    }
    
    [view handleControlEvent:UIControlEventTouchUpInside withBlock:actionBlock];
}

+(NSDictionary*) extractKeyValueFromItemString:(NSString*)item
{
    NSArray* allValues = [StringLib deparseString:item].values;
    NSArray* allKeys = [StringLib deparseString:item.lowercaseString].keys;
    if(!allValues || !allKeys) return nil;
    return @{ @"allKeys": allKeys, @"allValues": allValues };
}

//type = view & name = abc & title = hello & bgColor = red
//CONTROL_BREAK
//type = [abc] & name = copy_of_abc & bgColor = blue
// => type = view & name = copy_of_abc & bgColor = blue & title = hello
+(NSDictionary*) typeFromObjectName:(NSString*)objectName currentObjectStr:(NSString*)currentItem arrayItems:(NSArray*)allItems deviceUpdateDic:(NSDictionary*)deviceUpdateDic
{
    objectName = [objectName stringByReplacingOccurrencesOfString:@"[" withString:@""];
    objectName = [objectName stringByReplacingOccurrencesOfString:@"]" withString:@""];
    objectName = [[StringLib trim:objectName] lowercaseString];
    
    NSDictionary* temp = [self extractKeyValueFromItemString:currentItem];
    NSArray* allValues = [temp objectForKey:@"allValues"];
    NSArray* allKeys = [temp objectForKey:@"allKeys"];
    
    NSString* propKey, *name;
    NSArray* keys, *values;
    NSMutableDictionary* resultDict = [NSMutableDictionary new];
    for (NSString* item in allItems)
    {
        temp = [self extractKeyValueFromItemString:item];
        keys = [temp objectForKey:@"allKeys"];
        values = [temp objectForKey:@"allValues"];
        
        propKey = @"name";
        if(![keys containsObject:propKey]) continue;
        name = [values objectAtIndex:[keys indexOfObject:propKey]];
        name = [[StringLib trim:name] lowercaseString];
        
        
        if ([name isEqualToString:objectName]) {
            
            for (NSString* key in keys) {
                [resultDict setObject:[values objectAtIndex:[keys indexOfObject:key]] forKey:key];
            }
            
            for (NSString* key in allKeys)
            {
                if([key isEqualToString:@"type"]) continue;
                [resultDict setObject:[allValues objectAtIndex:[allKeys indexOfObject:key]] forKey:key];
            }
            
            NSArray* _allValues, *_allKeys;
            if(deviceUpdateDic && [deviceUpdateDic.allKeys containsObject:name])
            {
                NSDictionary* _temp = [self extractKeyValueFromItemString: [deviceUpdateDic objectForKey:name]];
                _allValues = [_temp objectForKey:@"allValues"];
                _allKeys = [_temp objectForKey:@"allKeys"];
                
                for (NSString* key in _allKeys)
                {
                    if([key isEqualToString:@"type"] || [key isEqualToString:@"name"]) continue;
                    [resultDict setObject:[_allValues objectAtIndex:[_allKeys indexOfObject:key]] forKey:key];
                }
            }
            
            break;
        }
    }
    
    NSString* propValue = [resultDict objectForKey:@"type"];
    if(![CONTROL_TYPES.allKeys containsObject:propValue.lowercaseString])
    {
        return [self typeFromObjectName:propValue currentObjectStr:[StringLib parseStringFromDictionary:resultDict] arrayItems:allItems deviceUpdateDic:deviceUpdateDic];
    }
    
    return [self extractKeyValueFromItemString:[StringLib parseStringFromDictionary:resultDict]];
}


//red > [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal]
//blue;#ffcc00,0.5 > [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal]
//          [button setTitleColor:Color2(@"#ffcc00", 0.5) forState:UIControlStateHighlighted]
+(void)titleColorObj:(NSString*)value button:(UIButton*)button
{
    if([value containsString:@";"])
    {
        NSArray* arr = [value componentsSeparatedByString:@";"];
        [button setTitleColor:[self colorObj:arr[0]] forState:UIControlStateNormal];
        [button setTitleColor:[self colorObj:arr[1]] forState:UIControlStateHighlighted];
        return;
    }
    
    [button setTitleColor:[self colorObj:value] forState:UIControlStateNormal];
}

+(void)placeholderColorObj:(NSString*)value textfield:(UITextField*)textfield
{
    if(![StringLib isValid:value] || ![StringLib isValid:textfield.placeholder]) return;
    NSAttributedString *str = [[NSAttributedString alloc] initWithString:textfield.placeholder attributes:@{ NSForegroundColorAttributeName : [self colorObj:value], NSFontAttributeName: textfield.font }];
    textfield.attributedPlaceholder = str;
}


//abc > [button setTitle:@"abc" forState:UIControlStateNormal]
//abc;def > [button setTitle:@"abc" forState:UIControlStateNormal]
//          [button setTitle:@"def" forState:UIControlStateHighlighted]
+(void)titleImageObj:(NSString*)value button:(UIButton*)button
{
    if([value containsString:@";"])
    {
        NSArray* arr = [value componentsSeparatedByString:@";"];
        [button setImage:[self imageObj:arr[0]] forState:UIControlStateNormal];
        [button setImage:[self imageObj:arr[1]] forState:UIControlStateHighlighted];
        return;
    }
    
    [button setImage:[self imageObj:value] forState:UIControlStateNormal];
}

//abc > [button setTitle:@"abc" forState:UIControlStateNormal]
//abc;def > [button setTitle:@"abc" forState:UIControlStateNormal]
//          [button setTitle:@"def" forState:UIControlStateHighlighted]
+(void)bgImageObj:(NSString*)value button:(UIButton*)button
{
    if([value containsString:@";"])
    {
        NSArray* arr = [value componentsSeparatedByString:@";"];
        [button setBackgroundImage:[self imageObj:arr[0]] forState:UIControlStateNormal];
        [button setBackgroundImage:[self imageObj:arr[1]] forState:UIControlStateHighlighted];
        return;
    }
    
    [button setBackgroundImage:[self imageObj:value] forState:UIControlStateNormal];
}




//abc > [button setTitle:@"abc" forState:UIControlStateNormal]
//abc;def > [button setTitle:@"abc" forState:UIControlStateNormal]
//          [button setTitle:@"def" forState:UIControlStateHighlighted]
+(void)titleObj:(NSString*)value button:(UIButton*)button
{
    if([value containsString:@";"])
    {
        NSArray* arr = [value componentsSeparatedByString:@";"];
        [button setTitle:[self textObj:arr[0]] forState:UIControlStateNormal];
        [button setTitle:[self textObj:arr[1]] forState:UIControlStateHighlighted];
        return;
    }
    
    
    [button setTitle:[self textObj:value] forState:UIControlStateNormal];
}

+(UIBlurEffectStyle)getBlurEffectStyle:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"dark"]) return UIBlurEffectStyleDark;
    if([value isEqualToString:@"extralight"]) return UIBlurEffectStyleExtraLight;
    if([value isEqualToString:@"light"]) return UIBlurEffectStyleLight;
    
    if (@available(iOS 10, *)) {
        if([value isEqualToString:@"regular"]) return UIBlurEffectStyleRegular;
        if([value isEqualToString:@"prominent"]) return UIBlurEffectStyleProminent;
    }
    
    return UIBlurEffectStyleLight;
}

+(UIViewContentMode)contentModeObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"scaletofill"]) return UIViewContentModeScaleToFill;
    if([value isEqualToString:@"scaleaspectfit"]) return UIViewContentModeScaleAspectFit;
    if([value isEqualToString:@"scaleaspectfill"]) return UIViewContentModeScaleAspectFill;
    if([value isEqualToString:@"redraw"]) return UIViewContentModeRedraw;
    if([value isEqualToString:@"center"]) return UIViewContentModeCenter;
    if([value isEqualToString:@"top"]) return UIViewContentModeTop;
    if([value isEqualToString:@"bottom"]) return UIViewContentModeBottom;
    if([value isEqualToString:@"left"]) return UIViewContentModeLeft;
    if([value isEqualToString:@"right"]) return UIViewContentModeRight;
    if([value isEqualToString:@"topleft"]) return UIViewContentModeTopLeft;
    if([value isEqualToString:@"topright"]) return UIViewContentModeTopRight;
    if([value isEqualToString:@"bottomleft"]) return UIViewContentModeBottomLeft;
    if([value isEqualToString:@"bottomright"]) return UIViewContentModeBottomRight;
    return UIViewContentModeCenter;
}

+(UITextAutocapitalizationType) autocapTypeObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"words"]) return UITextAutocapitalizationTypeWords;
    if([value isEqualToString:@"sentences"]) return UITextAutocapitalizationTypeSentences;
    if([value isEqualToString:@"allcharacters"]) return UITextAutocapitalizationTypeAllCharacters;
    if([value isEqualToString:@"ac"]) return UITextAutocapitalizationTypeAllCharacters;
    return UITextAutocapitalizationTypeNone;
}

+(UITextFieldViewMode) clearButtonModeObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"whileediting"]) return UITextFieldViewModeWhileEditing;
    if([value isEqualToString:@"unlessediting"]) return UITextFieldViewModeUnlessEditing;
    if([value isEqualToString:@"we"]) return UITextFieldViewModeWhileEditing;
    if([value isEqualToString:@"ue"]) return UITextFieldViewModeUnlessEditing;
    if([value isEqualToString:@"always"]) return UITextFieldViewModeAlways;
    return UITextFieldViewModeNever;
}

NSString* andStr = @"[AnD]";
NSString* equalStr = @"[EqL]";

//abc > LocalizedText(@"abc", nil)
//'abc ' > LocalizedText(@"abc ", nil)
//"abc " > LocalizedText(@"abc ", nil)
//""abc "" > LocalizedText(@"\"abc \"", nil)
//[zh-Hant]:"   time is: 08:30 PM" => LocalizedText(@"   time is: 08:30 PM", @"zh-Hant")
//[localized]: en [EqL] Language [AnD] vi [EqL] Ngôn Ngữ [AnD] zh-Hant [EqL] 语言
//   => CURRENT_LANG_CODE = [CommonLib getLocalizedWithDefaultLanguageCode:defaultKey];
//   => [CURRENT_LANG_CODE isEqualToString:@"vi"] ? @"Ngôn Ngữ" :
//      [CURRENT_LANG_CODE isEqualToString:@"zh-Hant"] ? @"语言" : @"Language"
//  Note: first language will be the default language
+(NSString*) textObj:(NSString*)value
{
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* langCode = [StringLib trim:arr[0]] ;
        
        
        
        if( ([langCode hasPrefix:@"["] && [langCode hasSuffix:@"]"]) )
        {
            NSString* data = @"";
            
            langCode = [StringLib trim:[[langCode substringToIndex:langCode.length-1] substringFromIndex:1]];
            
            for (int i = 1; i < arr.count; i++) {
                data = [NSString stringWithFormat:@"%@%@%@",data, data.length > 0 ? @":": @"", arr[i] ];
            }
            
            if (![langCode.lowercaseString isEqualToString:@"localized"]) {
                return LocalizedText( [self spaceAndNewLineTextObj:data], langCode);
            }
            
            
            NSDictionary* langs = [[StringLib deparseString:data autoTrimKeyValue:YES] toDictionary];
            NSString* defaultKey = [StringLib trim: [[data componentsSeparatedByString:@"="] firstObject]];
            NSString* resultText = [langs objectForKey:defaultKey];
            NSString* currentLangCode = [CommonLib getLocalizedWithDefaultLanguageCode:defaultKey];
            for (NSString* key in langs.allKeys)
            {
                if ([key isEqualToString:currentLangCode]) {
                    resultText = [langs objectForKey:key];
                    break;
                }
            }
            
            resultText = [resultText stringByReplacingOccurrencesOfString:@"[EqL]" withString:@"="];
            resultText = [resultText stringByReplacingOccurrencesOfString:@"[AnD]" withString:@"&"];
            
            return [self spaceAndNewLineTextObj:resultText];
        }
        
    }
    
    return LocalizedText([self spaceAndNewLineTextObj: value], nil);
}

//replace " -> '
//replace \\n -> \n (line break)
+(NSString*) spaceAndNewLineTextObj:(NSString*)value
{
    value = [StringLib trim:value];
    
    
    for (NSString* letter in @[@"\"", @"'"])
    {
        if([value hasPrefix:letter] && [value hasSuffix:letter]){
            value = [[value substringToIndex:value.length-1] substringFromIndex:1];
        }
    }
    
    value = [value stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
    
    return value;
}



+(NSTextAlignment) textAlignObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"right"]) return NSTextAlignmentRight;
    if([value isEqualToString:@"center"]) return NSTextAlignmentCenter;
    if([value isEqualToString:@"justified"]) return NSTextAlignmentJustified;
    if([value isEqualToString:@"natural"]) return NSTextAlignmentNatural;
    return NSTextAlignmentLeft;
}

+(RTTextAlignment) textAlignObjRT:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"right"]) return RTTextAlignmentRight;
    if([value isEqualToString:@"center"]) return RTTextAlignmentCenter;
    if([value isEqualToString:@"justified"]) return RTTextAlignmentJustify;
    if([value isEqualToString:@"justify"]) return RTTextAlignmentJustify;
    return RTTextAlignmentLeft;
}



//12 > [UIFont systemFontOfSize:12]
//bold:12 > [UIFont boldSystemFontOfSize:12]
//italic:12 > [UIFont italicSystemFontOfSize:12]
//bold-italic:12 > [UIFont italicSystemFontOfSize:12]
//Arial:12 > [UIFont fontWithName:@"Arial" size:12];
+(UIFont*) fontObj:(NSString*)value
{
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* prefix = [[StringLib trim:arr[0]] lowercaseString];
        NSString* data = [StringLib trim:arr[1]];
        
        if([prefix isEqualToString:@"bold"]) return [UIFont boldSystemFontOfSize:[data floatValue]];
        if([prefix isEqualToString:@"italic"]) return [UIFont italicSystemFontOfSize:[data floatValue]];
        if([prefix isEqualToString:@"bold-italic"] || [prefix isEqualToString:@"italic-bold"])
        {
            UIFont* font = [UIFont systemFontOfSize:[data floatValue]];
            
            UIFontDescriptor * fontD = [font.fontDescriptor
                                        fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold
                                        | UIFontDescriptorTraitItalic];
            return [UIFont fontWithDescriptor:fontD size:0];
        }
        else return [UIFont fontWithName:[StringLib trim:arr[0]] size:[data floatValue]];
        
    }
    
    return [UIFont systemFontOfSize:[value floatValue]];
    
    return [UIFont systemFontOfSize:[value floatValue]];
}

+(UIReturnKeyType)returnKeyTypeObj:(NSString*)value
{
    value = [value lowercaseString];
    if([value isEqualToString:@"go"]) return UIReturnKeyGo;
    if([value isEqualToString:@"google"]) return UIReturnKeyGoogle;
    if([value isEqualToString:@"join"]) return UIReturnKeyJoin;
    if([value isEqualToString:@"next"]) return UIReturnKeyNext;
    if([value isEqualToString:@"route"]) return UIReturnKeyRoute;
    if([value isEqualToString:@"search"]) return UIReturnKeySearch;
    if([value isEqualToString:@"send"]) return UIReturnKeySend;
    if([value isEqualToString:@"yahoo"]) return UIReturnKeyYahoo;
    if([value isEqualToString:@"done"]) return UIReturnKeyDone;
    if([value isEqualToString:@"emergencycall"]) return UIReturnKeyEmergencyCall;
    
    if (@available(iOS 9, *)) {
        if([value isEqualToString:@"continue"]) return UIReturnKeyContinue;
    }
    
    return UIReturnKeyDefault;
}

+(BOOL) boolValue:(NSString*)value
{
    return [value.lowercaseString isEqualToString:@"true"];
}

//red > [UIColor redColor]
//ff00ff > Color(@"ff00ff")
//ff00ff, 0.5 > Color2(@"ff00ff", 0.5)
//ff00ff; 0.5 > Color2(@"ff00ff", 0.5)
//image:IMAGE_VALUE_FOR >
+(UIColor*) colorObj:(NSString*)value
{
    NSString* value1 = [[StringLib trim:value] lowercaseString];
    
    if([value1 isEqualToString:@"black"]) return [UIColor blackColor];
    if([value1 isEqualToString:@"darkgray"]) return [UIColor darkGrayColor];
    if([value1 isEqualToString:@"lightgray"]) return [UIColor lightGrayColor];
    if([value1 isEqualToString:@"white"]) return [UIColor whiteColor];
    if([value1 isEqualToString:@"gray"]) return [UIColor grayColor];
    if([value1 isEqualToString:@"red"]) return [UIColor redColor];
    if([value1 isEqualToString:@"green"]) return [UIColor greenColor];
    if([value1 isEqualToString:@"blue"]) return [UIColor blueColor];
    if([value1 isEqualToString:@"cyan"]) return [UIColor cyanColor];
    if([value1 isEqualToString:@"yellow"]) return [UIColor yellowColor];
    if([value1 isEqualToString:@"magenta"]) return [UIColor magentaColor];
    if([value1 isEqualToString:@"orange"]) return [UIColor orangeColor];
    if([value1 isEqualToString:@"purple"]) return [UIColor purpleColor];
    if([value1 isEqualToString:@"brown"]) return [UIColor brownColor];
    if([value1 isEqualToString:@"clear"]) return [UIColor clearColor];
    
    if([value1 containsString:@":"]){
        NSArray* arr = [value1 componentsSeparatedByString:@":"];
        NSString* prefix = [[StringLib trim:arr[0]] lowercaseString];
        NSString* data = [StringLib trim:arr[1]];
        if([prefix isEqualToString:@"image"])
        {
            return [UIColor colorWithPatternImage:[self imageObj:data]];
        }
    }
    
    if([value1 containsString:@","]){
        NSArray* arr = [value1 componentsSeparatedByString:@","];
        return Color2([StringLib trim:arr[0]], [[StringLib trim:arr[1]] floatValue] );
    }
    
    if([value1 containsString:@";"]){
        NSArray* arr = [value1 componentsSeparatedByString:@";"];
        return Color2([StringLib trim:arr[0]], [[StringLib trim:arr[1]] floatValue] );
    }
    
    return Color(value1);
}



//abc > [UIImage imageNamed:@"abc"]
//file: abc > [UIImage imageWithContentsOfFile:@"abc"]
//doc: abc > [UIImage imageWithContentsOfFile: [FileLib getDocumentPath:@"abc"]]
//lib: abc > [UIImage imageWithContentsOfFile: [FileLib getLibraryPath:@"abc"]]
//temp: abc > [UIImage imageWithContentsOfFile: [FileLib getTempPath:@"abc"]]
//color: ffcc00 > [UIImage imageWithContentsOfFile: [FileLib getTempPath:@"abc"]]
//icon: FAKFontAwesome,,red,30,40;40 ==> refer imageIconAwesome function
+(UIImage*) imageObj:(NSString*)value
{
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* prefix = [[StringLib trim:arr[0]] lowercaseString];
        NSString* data = [StringLib trim:arr[1]];
        
        if([prefix isEqualToString:@"doc"]) data = [FileLib getDocumentPath:data];
        if([prefix isEqualToString:@"lib"]) data = [FileLib getLibraryPath:data];
        if([prefix isEqualToString:@"temp"]) data = [FileLib getTempPath:data];
        if([prefix isEqualToString:@"color"])
        {
            return [ImageLib createCanvasImageWithColor:[self colorObj:data] size:CGSizeMake(1.0f, 1.0f) isTransparent:YES];
        }
        if([prefix isEqualToString:@"icon"])
        {
            return [self imageIconAwesome:data];
        }
        
        if([FileLib checkPathExisted:data])
            return [UIImage imageWithContentsOfFile:data];
        
        [ViewLib alert:[NSString stringWithFormat:@"%s: %@ not found",__func__, value]];
        return nil;
    }
    
    return [UIImage imageNamed:value];
}

//icon: FAKFontAwesome,,red,30,40;40
//icon: fontawesome,,#ffccff;0.5,30
//icon: fontawesome,,#ffccff;0.5,30,50
//icon: awesome,
+(UIImage*)imageIconAwesome:(NSString*)value
{
    NSString* classname = nil;
    NSString* character = nil;
    UIColor* color = [UIColor redColor];
    CGFloat fontSize = 30;
    CGSize imageSize = CGSizeMake(30, 30);
    
    NSArray* arr = [value componentsSeparatedByString:@","];
    
    classname = arr[0];
    if(arr.count > 1) character = arr[1];
    if(arr.count > 2) color = [self colorObj:arr[2]];
    if(arr.count > 3) fontSize = [arr[3] floatValue];
    if(arr.count > 4)
    {
        arr = [arr[4] componentsSeparatedByString:@";"];
        imageSize = CGSizeMake([arr[0] floatValue], [arr[arr.count>1?1:0] floatValue]);
    }else{
        imageSize = CGSizeMake(fontSize, fontSize);
    }
    
    return [self iconAwesomeWithClassname:classname character:character color:color fontSize:fontSize imageSize:imageSize];
}

+(UIImage*)iconAwesomeWithClassname:(NSString*)classname character:(NSString*)character color:(UIColor*)color fontSize:(CGFloat)fontSize imageSize:(CGSize)imageSize
{
    FAKIcon* icon;
    classname = [StringLib trim:classname.lowercaseString];
    
    if([@[@"fakfontawesome",@"fontawesome",@"awesome"] containsObject:classname])
        icon = [FAKFontAwesome iconWithCode:character size:fontSize];
    else if([@[@"fakmaterialicons",@"materialicons",@"material"] containsObject:classname])
        icon = [FAKMaterialIcons iconWithCode:character size:fontSize];
    else if([@[@"fakocticons",@"octicons",@"oct"] containsObject:classname])
        icon = [FAKOcticons iconWithCode:character size:fontSize];
    else if([@[@"fakionicons",@"ionicons",@"ion"] containsObject:classname])
        icon = [FAKIonIcons iconWithCode:character size:fontSize];
    else if([@[@"fakzocial",@"zocial",@"social"] containsObject:classname])
        icon = [FAKZocial iconWithCode:character size:fontSize];
    else if([@[@"fakfoundationicons",@"foundationicons",@"foundation"] containsObject:classname])
        icon = [FAKFoundationIcons iconWithCode:character size:fontSize];
    else icon = [FAKFontAwesome iconWithCode:@"" size:30];
    
    if(!icon) return [UIImage new];
    
    [icon addAttribute:NSForegroundColorAttributeName value:color];
    return [UIImage imageWithStackedIcons:@[icon] imageSize:imageSize];;
}

+(NSString*) pathObj:(NSString*)value
{
    if([value containsString:@":"]){
        NSArray* arr = [value componentsSeparatedByString:@":"];
        NSString* prefix = [[StringLib trim:arr[0]] lowercaseString];
        NSString* data = [StringLib trim:arr[1]];
        
        if([prefix isEqualToString:@"doc"]) data = [FileLib getDocumentPath:data];
        if([prefix isEqualToString:@"lib"]) data = [FileLib getLibraryPath:data];
        if([prefix isEqualToString:@"temp"]) data = [FileLib getTempPath:data];
        
        if([FileLib checkPathExisted:data])
            return data;
        
        [ViewLib alert:[NSString stringWithFormat:@"%s: %@ not found",__func__, value]];
        return nil;
    }
    
    if([FileLib checkPathExisted:value]){
        return value;
    }
    
    [ViewLib alert:[NSString stringWithFormat:@"%s: %@ not found",__func__, value]];
    
    return nil;
}




#pragma Handle Comment, Replace item, and device type


//remove all comment // /* */
//
+(NSDictionary*) handleContent:(NSString*)content withDevice:(enum QUIBuilderDeviceType)deviceType
{
    content = [self removeAllComment:content];
    
    //fill default data from define
    if([content containsString:AUTOTEXT_BREAK]){
        NSString* defaultValue = [StringLib subStringBetween:content startStr:AUTOTEXT_BREAK endStr:@">>"];
        if([StringLib isValid:defaultValue])
        {
            content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@%@>>", AUTOTEXT_BREAK, defaultValue] withString:@""];
            
            defaultValue = [defaultValue stringByReplacingOccurrencesOfString:@"=" withString:@""];
            defaultValue = [StringLib trim:defaultValue];
            
            content = [self fillAutoTextWithContent:content autoTextFile:defaultValue];
        }
    }
    
    //if has no device break
    if(![content containsString:DEVICE_BREAK])
    {
        content = [self fillAutoTextWithContent:content withDevice:deviceType];
        content = [self generateForloopWithContent:content];
        content = [self generateSmartReplaceWithContent:content];
        content = [self fillAutoNumberByDeviceWithContent:content withDevice:deviceType];
        return [self rebuildFinalItemWithContent: content];
    }
    
    NSArray* arr = [content componentsSeparatedByString:DEVICE_BREAK];
    content = arr[0];
    
    NSString* deviceCode = [self getDeviceCode:deviceType];
    
    BOOL isFoundDevContent = NO;
    NSString* device, *devContent, *devContentIpadBase;
    for (int i = 1; i < arr.count; i++)
    {
        devContent = arr[i];
        device = [StringLib subStringBetween:devContent startStr:@"=" endStr:@">>"];
        devContent = [devContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"=%@>>", device] withString:@""];
        device = [[StringLib trim:device] lowercaseString];
        
        if ([deviceCode hasPrefix:@"ipad"] && [device isEqualToString:@"ipadhd"]) {
            devContentIpadBase = devContent;
        }
        
        if(![deviceCode isEqualToString:device]) continue;
        
        if ([deviceCode hasPrefix:@"ipad"] && ![deviceCode isEqualToString:@"ipadhd"])
        {
            content = [content stringByAppendingFormat:@"%@\n%@", CONTROL_BREAK, devContentIpadBase];
        }
        
        content = [content stringByAppendingFormat:@"%@\n%@", CONTROL_BREAK, devContent];
        isFoundDevContent = YES;
        break;
    }
    
    if (!isFoundDevContent && devContentIpadBase && [deviceCode hasPrefix:@"ipad"] ) {
        content = [content stringByAppendingFormat:@"%@\n%@", CONTROL_BREAK, devContentIpadBase];
    }
    
    
    content = [self fillAutoTextWithContent:content withDevice:deviceType];
    content = [self generateForloopWithContent:content];
    content = [self generateSmartReplaceWithContent:content];
    content = [self fillAutoNumberByDeviceWithContent:content withDevice:deviceType];
    return [self rebuildFinalItemWithContent: content];
}

+(NSString*) getDeviceCode:(enum QUIBuilderDeviceType)deviceType
{
    NSString* deviceCode;
    if (deviceType != QUIBuilderDeviceType_AutoDetectUniversal && deviceType != QUIBuilderDeviceType_AutoDetectIphoneOnly) {
        NSArray* deviceList = [[@"iPhone4,iPhone5,iPhone6,iPhone6p,iPhoneX,iPadHD,iPadPro10,iPadPro12" lowercaseString] componentsSeparatedByString:@","];
        if(deviceList.count > deviceType) deviceCode = [deviceList objectAtIndex:deviceType];
    }
    
    if (!deviceCode) {
        deviceCode = [CommonLib getDeviceByResolution];
        if (deviceType == QUIBuilderDeviceType_AutoDetectIphoneOnly && [deviceCode hasPrefix:@"ipad"]) {
            deviceCode = @"iphone4";
        }
    }
    return deviceCode;
}

//remove all // or /* */
+(NSString*) removeAllComment:(NSString*)content
{
    if (![content containsString:@"//"] && ![content containsString:@"/*"]) {
        return content;
    }
    
    NSMutableArray* comments = [NSMutableArray new];
    [comments addObjectsFromArray:[StringLib allSubStringBetween:content startStr:@"//" endStr:@"\n" includeStartEnd:YES]];
    
    for (NSString* item in comments) {
        content = [content stringByReplacingOccurrencesOfString:item withString: [item hasSuffix:@"\n"] ? @"\n" : @"" ];
    }
    
    [comments removeAllObjects];
    [comments addObjectsFromArray:[StringLib allSubStringBetween:content startStr:@"/*" endStr:@"*/" includeStartEnd:YES]];
    
    for (NSString* item in comments) {
        content = [content stringByReplacingOccurrencesOfString:item withString: [item hasSuffix:@"\n"] ? @"\n" : @"" ];
    }
    
    
    return content;
}

///<<[ a = 1 & b = 2 ]>>
///text = #a# and #b#
///==> text = 1 and 2
// if need to use # -> convert to ##
+(NSString*) fillAutoTextWithContent:(NSString*)content withDevice:(enum QUIBuilderDeviceType)deviceType
{
    
    //convert all ## to [HaSh]
    content = [content stringByReplacingOccurrencesOfString:@"^^" withString:@"[HaSh]"];
    
    
    
    NSMutableArray* list = [NSMutableArray new];
    NSString* autoText;
    while (YES) {
        autoText = [StringLib subStringBetween:content startStr:@"<<[" endStr:@"]>>"];
        if(autoText == nil) break;
        content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<<[%@]>>", autoText] withString:@""];
        [list addObject:autoText];
    }
    
    content = [self fillAutoTextWithContent:content replaceContents:list];
    
    //convert all [HaSh] to #
    content = [content stringByReplacingOccurrencesOfString:@"[HaSh]" withString:@"#"];
    
    return content;
}

+(NSString*) fillAutoTextWithContent:(NSString*)content autoTextFile:(NSString*)autoTextFile
{
    NSString* realFile = [FileLib getFullPathFromParam:autoTextFile defaultPath:nil];
    if(![FileLib checkPathExisted:realFile]) return content;
    
    NSString* replaceContent = [FileLib readFile:realFile];
    return [self fillAutoTextWithContent:content replaceContents:@[replaceContent]];
}


///<<[ a = 1 & b = 2 ]>>
///text = #a# and #b#
///==> text = 1 and 2
+(NSString*) fillAutoTextWithContent:(NSString*)content replaceContents:(NSArray*)replaceContents
{
    NSMutableDictionary* data;
    for (NSString* each in replaceContents) {
        NSDictionary* dic = [[StringLib deparseString:each] toDictionary];
        if(data){
            for (NSString* key in dic.allKeys) {
                [data setObject:[dic objectForKey:key] forKey:key];
            }
        }else{
            data = [NSMutableDictionary dictionaryWithDictionary:dic];
        }
    }
    
    
    NSString* value;
    for (NSString* key in data.allKeys) {
        value = [data objectForKey:key];
        content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"#%@#",key] withString:value];
    }
    return content;
}

+(NSDictionary*) rebuildFinalItemWithContent:(NSString*)content
{
    NSArray* items = [content componentsSeparatedByString:CONTROL_BREAK];
    NSArray* allValues, *allKeys;
    
    NSMutableDictionary* finalDic = [NSMutableDictionary new];
    NSString* propKey, *propValue, *sortname;
    NSMutableDictionary* itemDic;
    NSMutableDictionary* itemNameDic = [NSMutableDictionary new];
    int indexer = 1;
    NSMutableDictionary* inheritedItemNames = [NSMutableDictionary new];
    
    for (NSString* item in items)
    {
        
        NSDictionary* temp = [self extractKeyValueFromItemString:item];
        if(!temp) continue;
        allValues = [temp objectForKey:@"allValues"];
        allKeys = [temp objectForKey:@"allKeys"];
        
        propKey = @"name";
        NSString* name = [allKeys containsObject:propKey] ? [allValues objectAtIndex:[allKeys indexOfObject:propKey]] : [NSString stringWithFormat:@"view%@", @(finalDic.count)];
        
        
        
        if ([itemNameDic.allKeys containsObject:name])
        {
            sortname = [itemNameDic objectForKey:name];
            itemDic = [finalDic objectForKey:sortname];
        }
        else
        {
            itemDic = [NSMutableDictionary new];
            sortname = [NSString stringWithFormat:@"%05d(%@)", indexer++,name];
            [itemNameDic setObject:sortname forKey:name];
        }
        
        for (NSString* key in allKeys)
        {
            propValue = [allValues objectAtIndex:[allKeys indexOfObject:key]];
            [itemDic setObject:propValue forKey:key];
            
            if ([key isEqualToString:@"type"] && ![CONTROL_TYPES.allKeys containsObject:propValue.lowercaseString])
            {
                [inheritedItemNames setObject:propValue forKey:sortname];
            }
        }
        
        [finalDic setObject:itemDic forKey:sortname];
    }
    
    
    //Fill for repeat view
    for (NSString* itemkey in inheritedItemNames.allKeys)
    {
        //itemTypeName to find
        NSString* typeItemName = [inheritedItemNames objectForKey:itemkey];
        NSMutableDictionary* srcDic = [self getSrcDicWithTypeItemName:typeItemName finalDic:finalDic itemNameDic:itemNameDic];
        
        if (!srcDic)
        {
            NSLog(@"Type not found: %@ for item name: %@", typeItemName, itemkey);
            [finalDic removeObjectForKey:itemkey];
            continue;
        }
        
        itemDic = [finalDic objectForKey:itemkey];
        NSMutableDictionary* resultDic = [[NSMutableDictionary alloc] initWithDictionary:srcDic];
        for (NSString* key in itemDic.allKeys)
        {
            if([key isEqualToString:@"type"]) continue;
            [resultDic setObject:[itemDic objectForKey:key] forKey:key];
        }
        
        [finalDic setObject:resultDic forKey:itemkey];
    }
    
    return finalDic;
}

+(NSMutableDictionary*) getSrcDicWithTypeItemName:(NSString*)typeItemName finalDic:(NSMutableDictionary*)finalDic itemNameDic:(NSMutableDictionary*) itemNameDic
{
    NSString* sortname = [itemNameDic objectForKey:typeItemName];
    
    if (!sortname)
    {
        NSLog(@"Type not found: %@ for item name: %@", typeItemName, sortname);
        return nil;
    }
    
    NSMutableDictionary* srcDic = [finalDic objectForKey:sortname];
    
    NSString* type = [srcDic objectForKey:@"type"];
    if (![CONTROL_TYPES.allKeys containsObject:type.lowercaseString])
    {
        NSMutableDictionary* parentDic = [self getSrcDicWithTypeItemName:type finalDic:finalDic itemNameDic:itemNameDic];
        NSMutableDictionary* resultDic = [[NSMutableDictionary alloc] initWithDictionary:parentDic];
        for (NSString* key in srcDic.allKeys)
        {
            if([key isEqualToString:@"type"]) continue;
            [resultDic setObject:[srcDic objectForKey:key] forKey:key];
        }
        return resultDic;
    }
    
    return srcDic;
}


//             iphone4/5      iphone6/X         iphone6p
// superEdge = L20            L30              L40
//                              ALL
// ==> superEdge = L^30^
// if need to use ^ -> convert to ^^
+(NSString*) fillAutoNumberByDeviceWithContent:(NSString*)content withDevice:(enum QUIBuilderDeviceType)deviceType
{
    NSString* device = [self getDeviceCode:deviceType];
    
    //convert all ^^ to [UpPeR]
    content = [content stringByReplacingOccurrencesOfString:@"^^" withString:@"[UpPeR]"];
    
    NSArray* items = [StringLib allSubStringBetween:content startStr:@"^" endStr:@"^"];
    
    double value;
    for (NSString* item in items) {
        value = [item doubleValue];
        if ([@"iphone5,iphone4" containsString:device]) {
            value = value * (320.0f/375.0f);
        }
        
        if ([device isEqualToString: @"iphone6p"]) {
            value = value * (414.0f/375.0f);
        }
        
        
        
        if ([device isEqualToString: @"ipadpro10"]) {
            value = value * (834.0f/768.0f);
        }
        
        if ([device isEqualToString: @"ipadpro12"]) {
            value = value * (1024.0f/768.0f);
        }
        
        content = [content stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"^%@^",item] withString:[@(value) stringValue]];
    }
    
    //convert all [UpPeR] to ^
    content = [content stringByReplacingOccurrencesOfString:@"[UpPeR]" withString:@"^"];
    
    return content;
}



#pragma FOR EACH loop functions
/*
 FoR x = from_float : to_float & y = ...                      ex: FoR x = 1:5 & y = a,b,c,d,e
 FoR totalItem = 5 & x = from_float : to_float & y = ...      ex: FoR totalItem = 2 & x = 1:5 & y = a,b,c,d,e
 FoR key = x & data = from_float : to_float                   ex: FoR key = x & data = 1:5
 FoR key = x & data = from_float : to_float : inteval_float   ex: FoR key = x & data = 1:10:2
 FoR key = x & data = from_letter: to_letter                  ex: FoR key = x & data = a:z
 FoR key = x & data = text1, text2, text3...                  ex: FoR key = x & data = hello,demo,abc,oh yeah
 note:  + for special character:  : => ::  , => ,,
 + all item will be trim so need to add '' or "" to show the space arround.
 ex: for x in top,,bottom, a::b,' '," hello moto "
 + for $COUNTER$ for counter item begin with 1 each (for each loop)
 + for $[key]COUNTER$ replace counter for specific key
 ex: $xCOUNTER$ to replace counter for key x
 + if NEW for (without key and data) use totalItem to limit indicate total and max item of other value.
 ex: FoR totalItem = 2 & x = 1:5 & y = a,b,c,d,e ==> ...1.a..2...b
 
 Example:
 <<FoR key = x & data = 1:3
 ...
 & name = item$x$
 ...
 FoR>>
 
 ==> convert to 3 times of this code
 
 ...
 & name = item1
 ...
 
 ...
 & name = item2
 ...
 
 ...
 & name = item3
 ...
 */
+(NSString*) generateForloopWithContent:(NSString*)content
{
    NSDictionary* items = [StringLib buildTreeSubStringBetween:content startStr:@"<<FoR" endStr:@"FoR>>"];
    
    NSMutableDictionary* rs = [NSMutableDictionary new];
    NSArray* sortedKeys = [items.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* a,NSString* b)
                           {
                               return [a compare:b];
                           }];
    NSString* value;
    for (NSString* key in sortedKeys) {
        if([key isEqualToString:@"content"]) continue;
        value = [items objectForKey:key];
        
        if ([value containsString:@"[ObJeCt"]) {
            for (NSString* k in rs.allKeys)
            {
                value = [value stringByReplacingOccurrencesOfString:k withString: [rs objectForKey:k] ];
            }
        }
        
        value = [self buildForloopWithContent:value];
        
        [rs setObject:value forKey:key];
    }
    
    NSString* final = [items objectForKey:@"content"];
    for (NSString* key in rs.allKeys) {
        final = [final stringByReplacingOccurrencesOfString:key withString:[rs objectForKey:key]];
    }
    
    return final;
}


// <<FoR x = 1:3 & y = a,b,c ... FoR>> ==>  1..a. 2..b. 3.c..
// <<FoR key = x & data = 1:3 ... FoR>> ==>  1... 2... 3...
// replace special character: , :
+(NSString*) buildForloopWithContent:(NSString*)content
{
    NSString* fordata = [StringLib subStringBetween:content startStr:@"<<FoR" endStr:@"\n"];
    NSDictionary* dic = [[StringLib deparseString:fordata] toDictionary];
    
    if ([dic.allKeys containsObject:@"key"] && [dic.allKeys containsObject:@"data"])
    {
        return [self buildForloopWithContent2:content];
    }
    else
    {
        NSString* replaceContent = [StringLib subStringBetween:content startStr:@"\n" endStr:@"FoR>>"];
        NSInteger total = [dic.allKeys containsObject:@"totalItem"] ? [[dic objectForKey:@"totalItem"] integerValue] : -1;
        NSMutableDictionary* dicKeyItem = [NSMutableDictionary new];
        NSArray* items;
        for (NSString* key in dic.allKeys)
        {
            if([key isEqualToString:@"totalItem"]) continue;
            fordata = [NSString stringWithFormat:@"key = %@ & data = %@",key, [dic objectForKey:key]];
            items = [self getItemFromForloop:fordata maxSize:total];
            if(total == -1) total = items.count;
            [dicKeyItem setObject:items forKey:key];
        }
        
        NSString* temp, *result = @"";
        for (NSInteger i = 0; i < total; i++)
        {
            temp = replaceContent;
            
            for (NSString* key in dicKeyItem.allKeys)
            {
                items = [dicKeyItem objectForKey:key];
                
                if(items.count > i) temp = [temp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$%@$",key] withString: [items objectAtIndex:i] ];
                
                temp = [temp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$%@COUNTER$",key] withString:[@(i+1) stringValue]];
            }
            
            
            temp = [temp stringByReplacingOccurrencesOfString:@"$COUNTER$" withString:[@(i+1) stringValue]];
            
            result = [NSString stringWithFormat:@"%@%@", result, temp];
        }
        
        return result;
    }
}


// <<FoR key = x & data = 1:3 ... FoR>> ==>  1... 2... 3...
// replace special character: , :
+(NSString*) buildForloopWithContent2:(NSString*)content
{
    NSString* fordata = [StringLib subStringBetween:content startStr:@"<<FoR" endStr:@"\n"];
    NSArray* items = [self getItemFromForloop:fordata maxSize:-1];
    
    NSDictionary* dic = [[StringLib deparseString:fordata] toDictionary];
    NSString* key = [dic objectForKey:@"key"];
    
    
    NSString* replaceContent = [StringLib subStringBetween:content startStr:@"\n" endStr:@"FoR>>"];
    NSString* result = @"", *temp = @"";
    NSInteger counter = 1;
    for (NSString* item in items) {
        temp = [replaceContent stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$%@$",key] withString:item];
        temp = [temp stringByReplacingOccurrencesOfString:@"$COUNTER$" withString:[@(counter) stringValue]];
        temp = [temp stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$%@COUNTER$",key] withString:[@(counter) stringValue]];
        result = [NSString stringWithFormat:@"%@%@", result, temp];
        counter++;
    }
    
    return result;
}

//data = 1:20
//data = 1:20:2
//data = 50:10
//data = a,b,c,d
+(NSArray*) getItemFromForloop:(NSString*)fordata maxSize:(NSInteger)maxSize
{
    fordata = [fordata stringByReplacingOccurrencesOfString:@",," withString:@"[CoMmA]"];
    fordata = [fordata stringByReplacingOccurrencesOfString:@"::" withString:@"[CoLoN]"];
    NSDictionary* dic = [[StringLib deparseString:fordata] toDictionary];
    NSString* data = [dic objectForKey:@"data"];
    
    NSMutableArray* items = [NSMutableArray new];
    if ([data containsString:@":"]) {
        NSArray* arr = [data componentsSeparatedByString:@":"];
        CGFloat from = [StringLib trim:[arr objectAtIndex:0]].floatValue;
        CGFloat to = [StringLib trim:[arr objectAtIndex:1]].floatValue;
        CGFloat inteval = arr.count == 3 ? [StringLib trim:[arr objectAtIndex:2]].floatValue : 1;
        
        if (from < to) {
            for (CGFloat i = from; i <= to; i+= inteval) {
                [items addObject: [NSString stringWithFormat:@"%@",@(i)] ];
                if(maxSize > 0 && items.count >= maxSize) break;
            }
        }else{
            for (CGFloat i = from; i >= to; i-= inteval) {
                [items addObject: [NSString stringWithFormat:@"%@",@(i)] ];
                if(maxSize > 0 && items.count >= maxSize) break;
            }
        }
        
        
    }else{
        NSArray* arr = [data componentsSeparatedByString:@","];
        for (NSString* item in arr) {
            [items addObject: [StringLib trim:[[item stringByReplacingOccurrencesOfString:@"[CoMmA]" withString:@","] stringByReplacingOccurrencesOfString:@"[CoLoN]" withString:@":"]]];
            if(maxSize > 0 && items.count >= maxSize) break;
        }
    }
    return items;
}

#pragma Smart replace
/*
 <<ReP x = 1:5 & y = 1,2,3,4
 <<ReP key = bank & data = ???
 ....ReP>>
 key and data similar to FoR
 */
+(NSString*)generateSmartReplaceWithContent:(NSString*)content
{
    NSDictionary* items = [StringLib buildTreeSubStringBetween:content startStr:@"<<ReP" endStr:@"ReP>>"];
    
    NSMutableDictionary* rs = [NSMutableDictionary new];
    NSArray* sortedKeys = [items.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString* a,NSString* b)
                           {
                               return [a compare:b];
                           }];
    NSString* value;
    for (NSString* key in sortedKeys) {
        if([key isEqualToString:@"content"]) continue;
        value = [items objectForKey:key];
        
        if ([value containsString:@"[ObJeCt"]) {
            for (NSString* k in rs.allKeys)
            {
                value = [value stringByReplacingOccurrencesOfString:k withString: [rs objectForKey:k] ];
            }
        }
        
        value = [self buildReplacementWithContent:value];
        
        [rs setObject:value forKey:key];
    }
    
    NSString* final = [items objectForKey:@"content"];
    for (NSString* key in rs.allKeys) {
        final = [final stringByReplacingOccurrencesOfString:key withString:[rs objectForKey:key]];
    }
    
    return final;
}

// <<ReP x = 1:5 & y = a,b,c,d ...ReP>> ==>  1.a.. 2.b.. 3.c..
// <<ReP key = x & data = 1:3 ... ReP>> ==>  1... 2... 3...
// replace special character: , :
+(NSString*) buildReplacementWithContent:(NSString*)content
{
    NSString* fordata = [StringLib subStringBetween:content startStr:@"<<ReP" endStr:@"\n"];
    NSDictionary* dic = [[StringLib deparseString:fordata] toDictionary];
    
    if ([dic.allKeys containsObject:@"key"] && [dic.allKeys containsObject:@"data"])
    {
        return [self buildReplacementWithContent2:content];
    }
    else
    {
        NSString* replaceContent = [StringLib subStringBetween:content startStr:@"\n" endStr:@"ReP>>"];
        NSInteger total = [dic.allKeys containsObject:@"totalItem"] ? [[dic objectForKey:@"totalItem"] integerValue] : -1;
        NSMutableDictionary* dicKeyItem = [NSMutableDictionary new];
        NSArray* items;
        for (NSString* key in dic.allKeys)
        {
            if([key isEqualToString:@"totalItem"]) continue;
            fordata = [NSString stringWithFormat:@"key = %@ & data = %@",key, [dic objectForKey:key]];
            items = [self getItemFromForloop:fordata maxSize:total];
            if(total == -1) total = items.count;
            [dicKeyItem setObject:items forKey:key];
        }
        
        NSString* result = replaceContent;
        for (NSInteger i = 0; i < total; i++)
        {
            for (NSString* key in dicKeyItem.allKeys)
            {
                items = [dicKeyItem objectForKey:key];
                
                if(items.count > i) result = [StringLib replaceOneTimeWithContent:result original:[NSString stringWithFormat:@"$%@$",key] replacement:[items objectAtIndex:i]];
            }
        }
        
        return result;
    }
}



// <<ReP key = x & data = 1:3 ... ReP>> ==>  1... 2... 3...
// replace special character: , :
+(NSString*) buildReplacementWithContent2:(NSString*)content
{
    NSString* fordata = [StringLib subStringBetween:content startStr:@"<<ReP" endStr:@"\n"];
    NSArray* items = [self getItemFromForloop:fordata maxSize:-1];
    
    NSDictionary* dic = [[StringLib deparseString:fordata] toDictionary];
    NSString* key = [dic objectForKey:@"key"];
    
    
    NSString* replaceContent = [StringLib subStringBetween:content startStr:@"\n" endStr:@"ReP>>"];
    
    for (NSString* item in items) {
        replaceContent = [StringLib replaceOneTimeWithContent:replaceContent original:[NSString stringWithFormat:@"$%@$",key] replacement:item];
    }
    
    return replaceContent;
}





@end






@implementation UIView (UIBlockActionView)

-(void)setViewName:(NSString *)viewName
{
    objc_setAssociatedObject(self, (__bridge const void*)(@"viewName"), viewName, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSString *)viewName{
    return objc_getAssociatedObject(self, (__bridge const void*)@"viewName");
}


-(void)setLocalizedTexts:(NSMutableDictionary *)localizedTexts
{
    objc_setAssociatedObject(self, (__bridge const void*)(@"localizedTexts"), localizedTexts, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSMutableDictionary *)localizedTexts{
    NSMutableDictionary* value = objc_getAssociatedObject(self, (__bridge const void*)@"localizedTexts");
    if(!value)
    {
        value = [NSMutableDictionary new];
        [self setLocalizedTexts: value];
    }
    
    return value;
}


#pragma ACTION BLOCK FUNCTIONS
NSMutableDictionary* _actionBlock;

-(void) handleControlEvent:(UIControlEvents)event
                 withBlock:(ActionBlock) action
{
    if(!_actionBlock) _actionBlock = [NSMutableDictionary new];
    NSString* key = [[[NSString stringWithFormat:@"%@",self] componentsSeparatedByString:@";"] firstObject];
    [_actionBlock setObject:action forKey:key ];
    
    if ([self isKindOfClass:[UIButton class]])
    {
        [(UIButton*)self addTarget:self action:@selector(callActionBlock:) forControlEvents:event];
    }else{
        [self setUserInteractionEnabled:YES];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapgesture:)]];
    }
}

-(void) removeAllHandleEvent
{
    if(!_actionBlock) return;
    NSString* key = [[[NSString stringWithFormat:@"%@",self] componentsSeparatedByString:@";"] firstObject];
    [_actionBlock removeObjectForKey: key];
    
}

- (void) tapgesture: (UITapGestureRecognizer *)recognizer
{
    [self callActionBlock:nil];
}

-(void) callActionBlock:(id)sender
{
    NSString* key = [[[NSString stringWithFormat:@"%@",self] componentsSeparatedByString:@";"] firstObject];
    ActionBlock block = [_actionBlock objectForKey: key];
    if (block) {
        block();
    }
}

@end
































