//
//  CollectionView.m
//  MBProgressHUD
//
//  Created by Trung Pham on 5/11/18.
//

#import "CollectionView.h"
#import "ViewLib.h"
#import "QUIBuilder.h"

@implementation CollectionView
{
    NSMutableDictionary* cellDatas;
}

-(instancetype)init{
    self = [super init];
    return self;
}

-(void)initUI
{
    //collectionview
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setScrollDirection: self.isScrollDirectionHorizontal ? UICollectionViewScrollDirectionHorizontal : UICollectionViewScrollDirectionVertical];
    [flow setItemSize: self.itemSize];
    [flow setMinimumInteritemSpacing: self.itemSpacing];
    [flow setMinimumLineSpacing: self.lineSpacing];
    [flow setSectionInset: self.sectionInset];
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:flow];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.allowsMultipleSelection = NO;
    [_collectionView setShowsHorizontalScrollIndicator:NO];
    
    [self addSubview: _collectionView];
    
    [ViewLib updateLayoutForView:_collectionView superEdge:@"L0R0T0B0" otherEdge:nil];
}

#pragma delegate
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([self.delegate respondsToSelector:@selector(numberOfSectionsInCollectionView:)])
    {
        return [self.delegate numberOfSectionsInCollectionView:collectionView];
    }
    
    return 1;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self.delegate respondsToSelector:@selector(collectionView:numberOfItemsInSection:)])
    {
        return [self.delegate collectionView:collectionView numberOfItemsInSection:section];
    }
    
    return self.itemData.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:cellForItemAtIndexPath:)])
    {
        return [self.delegate collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UICollectionViewCell" forIndexPath:indexPath];
    
    NSString* item = [self.itemData objectAtIndex: self.itemData.count > indexPath.row ? indexPath.row : 0];
    NSDictionary* uiElements;
    NSString* cellKey = [StringLib subStringBetween:[NSString stringWithFormat:@"%@",cell] startStr:@"<UICollectionViewCell: " endStr:@";"];
    
    if (self.isRemoveAllSubviewBeforeDrawCell)
    {
        for (UIView* view in cell.contentView.subviews)
        {
            [view removeFromSuperview];
        }
    }else{
        if(cell.contentView.subviews.count > 0)
        {
            if ([self.delegate respondsToSelector:@selector(collectionView:modifyCell:forItems:atIndexPath:)])
            {
                uiElements = [cellDatas objectForKey:cellKey];
                return [self.delegate collectionView:collectionView modifyCell:cell forItems:uiElements atIndexPath:indexPath];
            }
            
            return cell;
        }
    }
    
    
    if ([FileLib checkPathExisted:item])
    {
        uiElements = [QUIBuilder rebuildUIWithFile:item containerView:cell.contentView errorBlock:^(NSString *msg, NSException *exception) {
            NSLog(@"%@ %@", msg, exception);
        }];
    }else{
        uiElements = [QUIBuilder rebuildUIWithContent:item containerView:cell.contentView errorBlock:^(NSString *msg, NSException *exception) {
            NSLog(@"%@ %@", msg, exception);
        }];
    }
    
    if ([self.delegate respondsToSelector:@selector(collectionView:modifyCell:forItems:atIndexPath:)])
    {
        if(!cellDatas) cellDatas = [NSMutableDictionary new];
        [cellDatas setObject:uiElements forKey: cellKey];
        
        return [self.delegate collectionView:collectionView modifyCell:cell forItems:uiElements atIndexPath:indexPath];
    }
    
    return cell;
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:didSelectItemAtIndexPath:)])
    {
        [self.delegate collectionView:collectionView didSelectItemAtIndexPath:indexPath];
        return;
    }
    
    if(!self.itemSelectedBlock) return;
    self.itemSelectedBlock(indexPath.row);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
    {
        return [self.delegate collectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
    
    return ((UICollectionViewFlowLayout*)collectionViewLayout).itemSize;
}


@end
