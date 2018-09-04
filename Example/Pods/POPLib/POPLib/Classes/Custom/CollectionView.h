//
//  CollectionView.h
//  MBProgressHUD
//
//  Created by Trung Pham on 5/11/18.
//

#import <UIKit/UIKit.h>

@protocol CollectionViewDelegate <NSObject>
@optional
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView modifyCell:(UICollectionViewCell *)cell forItems:(NSDictionary*)uiElements atIndexPath:(NSIndexPath *)indexPath;

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface CollectionView : UIView <UICollectionViewDelegate, UICollectionViewDataSource>
//item is qui content or patch to qui file
@property (nonatomic) NSArray* itemData;
@property (nonatomic) UICollectionView* collectionView;

@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat itemSpacing;
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) UIEdgeInsets sectionInset;
@property (nonatomic) BOOL isScrollDirectionHorizontal;
@property (nonatomic) BOOL isRemoveAllSubviewBeforeDrawCell;

@property (nonatomic) id<CollectionViewDelegate> delegate;

@property (nonatomic) void (^itemSelectedBlock)(NSInteger index);

-(void) initUI;


@end
