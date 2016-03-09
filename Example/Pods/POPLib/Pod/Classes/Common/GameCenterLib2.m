//
//  LKGameCenter.m
//  LKNumberCircle
//
//  Created by Redseademon on 12/12/13.
//  Copyright (c) 2013 Redseademon. All rights reserved.
//

#import "GameCenterLib2.h"
NSString *const PresentAuthenticationViewController = @"present_authentication_view_controller";

@interface GameCenterLib2()<GKGameCenterControllerDelegate>
@end

@implementation GameCenterLib2{
    BOOL _enableGameCenter;
}
+ (instancetype)Instance
{
    static GameCenterLib2 *sharedGameKitHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGameKitHelper = [[GameCenterLib2 alloc] init];
    });
    return sharedGameKitHelper;
}

- (id)init
{
    self = [super init];
    if (self) {
        _enableGameCenter = YES;
    }
    return self;
}

- (void)authenticateLocalPlayerAtViewController:(UIViewController*)view
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error)
    {
        
        [self setLastError:error];
        
        if (viewController != nil) {
            // If it's needed display the login view controller.
            [self setAuthenticationViewController:viewController];
            [view presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                // If the player is already authenticated then indicate that the Game Center features can be used.
                _enableGameCenter = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"authenticateHandler error: %@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _enableGameCenter = NO;
            }
        }
    };
}

- (void)setAuthenticationViewController:(UIViewController *)authenticationViewController
{
    if (authenticationViewController != nil) {
        _authenticationViewController = authenticationViewController;
        [[NSNotificationCenter defaultCenter] postNotificationName:PresentAuthenticationViewController object:self];
    }
}

- (void)setLastError:(NSError *)error
{
    _lastError = [error copy];
    if (_lastError) {
        NSLog(@"GameKitHelper ERROR: %@", [[_lastError userInfo] description]);
    }
}

- (void)reportAchievements:(NSArray *)achievements
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
        return;
    }
    
    [GKAchievement reportAchievements:achievements
                withCompletionHandler:^(NSError *error ){
                    [self setLastError:error];
                }];
}

- (void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
        return;
    }
    
    GKAchievement *achievement = [[GKAchievement alloc] initWithIdentifier: identifier];
    [GKAchievement reportAchievements:@[achievement] withCompletionHandler:^(NSError *error)
    {
        if (error != nil)
        {
            NSLog(@"Error in reporting achievements: %@", error);
        }
    }];
}


- (void)reportAchievementIdentifier: (NSString*) identifier currentPoint:(NSInteger)currentPoint achievementPoint:(NSInteger) achievementPoint
{
    if (currentPoint > achievementPoint){
        [self reportAchievementIdentifier:identifier percentComplete:100];
    }else{
        double onePercent = achievementPoint/100;
        double percent = currentPoint/onePercent;
        [self reportAchievementIdentifier:identifier percentComplete:percent];
    }
    
}

- (void)showArchievementWithViewController:(UIViewController *)viewController
{
    [self showGKGameCenterViewController:viewController gameCenterType:GKGameCenterViewControllerStateAchievements];
}

- (void)showLeaderBoardWithViewController:(UIViewController *)viewController
{
    [self showGKGameCenterViewController:viewController gameCenterType:GKGameCenterViewControllerStateLeaderboards];
}

- (void)showGKGameCenterViewController:(UIViewController *)viewController gameCenterType:(GKGameCenterViewControllerState)gameCenterType
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
    }
    GKGameCenterViewController *gameCenterViewController = [[GKGameCenterViewController alloc] init];
    gameCenterViewController.gameCenterDelegate = self;
    gameCenterViewController.viewState = gameCenterType;
    gameCenterViewController.leaderboardIdentifier = _leaderboardIdentifier;
    [viewController presentViewController:gameCenterViewController animated:YES completion:nil];
}

- (void)gameCenterViewControllerDidFinish:
(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES
                                                 completion:nil];
}

- (void)reportScore:(int64_t)score
   forLeaderboardID:(NSString *)leaderboardID
{
    if (!_enableGameCenter) {
        NSLog(@"Local play is not authenticated");
    }
    //1
    GKScore *scoreReporter =
    [[GKScore alloc]
     initWithLeaderboardIdentifier:leaderboardID];
    scoreReporter.value = score;
    scoreReporter.context = 0;
    
    NSArray *scores = @[scoreReporter];
    
    //2
    [GKScore reportScores:scores
    withCompletionHandler:^(NSError *error) {
        [self setLastError:error];
    }];
}



@end
