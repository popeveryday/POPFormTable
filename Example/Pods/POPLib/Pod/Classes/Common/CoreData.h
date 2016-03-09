//
//  CoreData.h
//  BankHelper
//
//  Created by popeveryday on 4/21/13.
//  Copyright (c) 2013 Best4U. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ReturnSet.h"
#import "FileLib.h"

@interface CoreData : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *ManagedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *ManagedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *PersistentStoreCoordinator;

@property (strong, nonatomic) NSString* ModelName;
@property (strong, nonatomic) NSString* SqlFileName;

typedef enum {
    sum, count, min, max, average
} FunctionExpression;

+(CoreData*) Instance;
+(CoreData*) InitInstanceDataModel:(NSString*)modelName  sqlFileName:(NSString*)sqlFileName;
+(NSExpressionDescription*) BuildSearchExpressionForField:(NSString*) field function:(FunctionExpression) function expressionName:(NSString*) name resultType: (NSAttributeType) resultType;

-(id) InitCoreDataModel:(NSString*)modelName  sqlFileName:(NSString*)sqlFileName;

-(ReturnSet*) SearchTable:(NSString*) table predicatefilter:(NSPredicate*) predicatefilter sortField:(NSString*)sortField sortAscending:(BOOL) asc searchExpressionArray:(NSArray*) searchExpression resultType:(NSFetchRequestResultType) resultType;
-(ReturnSet*) SearchTable:(NSString*) table filter:(NSString*) filter sortField:(NSString*)sortField sortAscending:(BOOL) asc searchExpressionArray:(NSArray*) searchExpression resultType:(NSFetchRequestResultType) resultType;
-(ReturnSet*) SearchTable:(NSString*) table predicatefilter:(NSPredicate*) predicatefilter sortField:(NSString*)sortField sortAscending:(BOOL) asc searchExpressionArray:(NSArray*) searchExpression resultType:(NSFetchRequestResultType) resultType limit:(NSUInteger)limit offset:(NSUInteger) offset;
-(ReturnSet*) SearchTable:(NSString*) table sortField:(NSString*)sortField sortAscending:(BOOL) asc;
-(ReturnSet*) SearchTable:(NSString*) table filter:(NSString*) filter sortField:(NSString*)sortField sortAscending:(BOOL) asc;


-(id) InsertTable:(NSString*) table;
-(void) DeleteRecord:(id) record;
-(ReturnSet*) SaveChange;
-(NSManagedObjectContext*) GetEntity;


@end
