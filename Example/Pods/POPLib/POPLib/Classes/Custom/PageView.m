//
//  PageView.m
//  POPLib
//
//  Created by Trung Pham on 5/10/18.
//

#import "PageView.h"
#import "FileLib.h"
#import "QUIBuilder.h"
#import "ViewLib.h"

@implementation PageView
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
    [flow setItemSize: self.itemSize];
    [flow setMinimumInteritemSpacing: self.itemSpacing];
    [flow setMinimumLineSpacing: self.lineSpacing];
    [flow setSectionInset: self.sectionInset];
    
    
    _collectionView = [[HWViewPager alloc] initWithFrame:self.frame collectionViewLayout:flow];
    [_collectionView setPagerDelegate:self];
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

#pragma mark - HWViewPagerDelegate
-(void)pagerDidSelectedPage:(NSInteger)selectedPage
{
    if (_delegate && [_delegate respondsToSelector:@selector(pageView:didSelectedPage:)]) {
        [_delegate pageView:_collectionView didSelectedPage:selectedPage];
    }
}

@end






#pragma HWViewPager

#define VELOCITY_STANDARD 0.6f

@interface HWViewPager() <UICollectionViewDelegate>

typedef NS_ENUM(NSInteger, PagerControlState) {
    PagerControlStateStayCurrent,
    PagerControlStateMoveToLeft,
    PagerControlStateMoveToRight
};

@property (strong, nonatomic) UICollectionViewFlowLayout * flowLayout;
@property CGRect beforeFrame;
@property NSInteger itemsTotalNum;
@property CGFloat itemWidthWithMargin;
@property NSInteger selectedPageNum;
@property CGFloat scrollBeginOffset;
@property enum PagerControlState pagerControlState;

@property (weak, nonatomic) IBOutlet id<HWViewPagerDelegate> userPagerDelegate;

@end



@implementation HWViewPager

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initialize];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if(self){
        [self initialize];
    }
    return self;
}


-(void)initialize{
    //페이징은 NO로 바꿔주고.
    [self setScrollEnabled:YES];
    [self setPagingEnabled:NO];
    
    self.selectedPageNum = 0;
    self.flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    
    //스크롤방향은 horiozontal
    [self.flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [self setDelegate:self];
    self.beforeFrame = CGRectMake(0, 0, 0, 0);
    
    self.pagerControlState = PagerControlStateStayCurrent;
    [self setDecelerationRate: UIScrollViewDecelerationRateFast];
}



-(void)setPagerDelegate:(id<HWViewPagerDelegate>)pagerDelegate{
    self.userPagerDelegate = pagerDelegate;
}






#pragma mark - override...
-(void)layoutSubviews{
    [super layoutSubviews];
    
    //현재 뷰의 프레임 크기와 이전의 프레임과 다르다면, 아이템의 크기도 함께 바꿔준다.
    if(!CGRectEqualToRect(self.frame, self.beforeFrame)){
        //flowLayout의 아이템 사이즈를 현재뷰의 width에서 왼쪽인섹션 *2 만큼 빼주고, 셀간여백만큼도 빼준다.
        CGFloat widthNew = self.frame.size.width - (self.flowLayout.sectionInset.left *2) - self.flowLayout.minimumLineSpacing;
        CGFloat heightNew = self.frame.size.height - self.flowLayout.sectionInset.top - self.flowLayout.sectionInset.bottom;
        self.flowLayout.itemSize = CGSizeMake(widthNew, heightNew);
        self.beforeFrame = self.frame;
        
        self.itemWidthWithMargin = widthNew + self.flowLayout.minimumLineSpacing;
        
        //현재 선택된 페이지의 오프셋으로 이동시켜준다.
        int targetX = [self getOffsetFromPage:self.selectedPageNum scrollView:self];
        [self setContentOffset:CGPointMake(targetX, 0)];
        
    }
}



-(void)reloadData{
    
    [super reloadData];
    
    self.itemsTotalNum = 0;
    
    NSInteger sectionNum = [self numberOfSections];
    for(int i=0; i<sectionNum; i++){
        self.itemsTotalNum += [self.dataSource collectionView:self numberOfItemsInSection:sectionNum];
    }
    //새로 불렸을 때, 페이지넘을 0으로, 오프셋도 0으로 이동시켜준다.
    self.selectedPageNum = 0;
    [self setContentOffset:CGPointMake(0, 0)];
}



#pragma mark - ScrollViewDelegate
//컬렉션뷰 델리게이트 중에 있는 스크롤관련 델리게이트.
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //스크롤 시작한 위치를 저장해둔다.
    self.scrollBeginOffset = scrollView.contentOffset.x;
    self.pagerControlState = PagerControlStateStayCurrent;
}


-(void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    CGPoint point = *targetContentOffset;
    
    //먼저 벨로서티 기준에 따라서 이동 여부를 결정
    //벨로시티가 오른쪽으로 기준보다 크다면, 오른쪽으로 이동 시켜준다.
    if(velocity.x > VELOCITY_STANDARD){
        //        NSLog(@"벨로서티가 기준보다 커서, 오른쪽으로 이동해야한다!");
        self.pagerControlState = PagerControlStateMoveToRight;
    }//벨로서티가 왼쪽으로 기준보다 작다면, 왼쪽으로 이동시켜준다.
    else if(velocity.x < -VELOCITY_STANDARD){
        //        NSLog(@"벨로서티가 -기준보다 작아서, 왼쪽으로 이동해야한다!");
        self.pagerControlState = PagerControlStateMoveToLeft;
    }
    
    //총 스크롤 한 거리.
    CGFloat scrolledDistance = self.scrollBeginOffset - scrollView.contentOffset.x;
    // 컨텐츠 크기의 반.
    CGFloat standardDistance = self.itemWidthWithMargin/2;
    
    //컨텐츠 크기의 반만큼보다 많이 스크롤을 했다면,
    if(scrolledDistance < -standardDistance){
        self.pagerControlState = PagerControlStateMoveToRight;
        
    }else if(scrolledDistance > standardDistance){
        self.pagerControlState = PagerControlStateMoveToLeft;
    }
    
    //선택페이지를 결정한다.
    if(self.pagerControlState == PagerControlStateMoveToLeft && self.selectedPageNum > 0){
        self.selectedPageNum--;
    }
    else if (self.pagerControlState == PagerControlStateMoveToRight && self.selectedPageNum <self.itemsTotalNum-1){
        self.selectedPageNum++;
    }
    
    //페이지가 설정되고, 델리게이트가 설정되어있다면, 델리게이트를 호출한다.
    if(self.userPagerDelegate){
        [self.userPagerDelegate pagerDidSelectedPage:self.selectedPageNum];
    }
    
    point.x = [self getOffsetFromPage:self.selectedPageNum scrollView:scrollView];
    *targetContentOffset = point;
    
}


//해당 페이지의 컨텐트오프셋을 구하는 메소드.
-(CGFloat) getOffsetFromPage:(NSInteger)pageNum scrollView:(UIScrollView*)scrollView{
    
    if(pageNum == 0){
        return 0;
    }
    else if(pageNum >= self.itemsTotalNum-1){
        return scrollView.contentSize.width - self.frame.size.width;
    }
    
    return (self.itemWidthWithMargin*pageNum) - (self.flowLayout.minimumLineSpacing/2);
}


-(void) setPage:(NSInteger)page isAnimation:(BOOL)isAnim{
    
    if(page == self.selectedPageNum || page >= self.itemsTotalNum){
        return;
    }
    
    CGFloat offset = [self getOffsetFromPage:page scrollView:self];
    [self setContentOffset:CGPointMake(offset, 0) animated:isAnim];
    self.selectedPageNum = page;
    if(self.userPagerDelegate != nil){
        [self.userPagerDelegate pagerDidSelectedPage:page];
    }
}




@end
