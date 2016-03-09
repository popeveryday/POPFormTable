//
//  LKGameCenter.h
//  LKNumberCircle
//
//  Created by Redseademon on 12/12/13.
//  Copyright (c) 2013 Redseademon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

extern NSString *const PresentAuthenticationViewController;

@interface GameCenterLib2 : NSObject

@property (nonatomic, readonly) UIViewController *authenticationViewController;
@property (nonatomic, readonly) NSError *lastError;
@property (nonatomic) NSString* leaderboardIdentifier;
 
+ (instancetype)Instance;
- (void)authenticateLocalPlayerAtViewController:(UIViewController*)view;
- (void)reportAchievements:(NSArray *)achievements;

- (void)showArchievementWithViewController:(UIViewController *)viewController;
- (void)showLeaderBoardWithViewController:(UIViewController *)viewController;

- (void)reportScore:(int64_t)score forLeaderboardID:(NSString*)leaderboardID;
- (void)reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;
- (void)reportAchievementIdentifier: (NSString*) identifier currentPoint:(NSInteger)currentPoint achievementPoint:(NSInteger) achievementPoint;


@end
