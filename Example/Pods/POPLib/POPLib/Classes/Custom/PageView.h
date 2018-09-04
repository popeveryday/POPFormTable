//
//  PageView.h
//  POPLib
//
//  Created by Trung Pham on 5/10/18.
//

#import <UIKit/UIKit.h>

#pragma HWViewPagerDelegate
@protocol HWViewPagerDelegate <NSObject>
-(void)pagerDidSelectedPage:(NSInteger)selectedPage;
@end

@interface  HWViewPager : UICollectionView

-(void) setPagerDelegate:(id<HWViewPagerDelegate>)pagerDelegate;
-(void) setPage:(NSInteger)page isAnimation:(BOOL)isAnim;

@end




@protocol PageViewDelegate <NSObject>

@optional
-(void)pageView:(HWViewPager *)viewPager didSelectedPage:(NSInteger)selectedPage;

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView;

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView modifyCell:(UICollectionViewCell *)cell forItems:(NSDictionary*)uiElements atIndexPath:(NSIndexPath *)indexPath;

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface PageView : UIView <UICollectionViewDelegate, UICollectionViewDataSource, HWViewPagerDelegate>
//item is qui content or patch to qui file
@property (nonatomic) NSArray* itemData;
@property (nonatomic) HWViewPager* collectionView;

@property (nonatomic) CGSize itemSize;
@property (nonatomic) CGFloat itemSpacing;
@property (nonatomic) CGFloat lineSpacing;
@property (nonatomic) UIEdgeInsets sectionInset;
@property (nonatomic) BOOL isRemoveAllSubviewBeforeDrawCell;

@property (nonatomic) id<PageViewDelegate> delegate;

@property (nonatomic) void (^itemSelectedBlock)(NSInteger index);

-(void) initUI;


@end

