//
//  PongLayer.mm
//  LeapPong
//
//  Created by Vincent Saluzzo on 22/03/13.
//  Copyright 2013 ITELIOS SAS. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PongLayer.h"
#define PTM_RATIO 32

@implementation PongLayer

- (id)init
{
    self = [super init];
    if (self) {
        
        gamePause = YES;
        
        ballSpeedX = 5;
        ballSpeedY = 5;
        waitForLeftPlayer = NO;
        player1Score = 0;
        player2Score = 0;
        ftime = 1.00f;
        
        [self setUpObject];
        [self setUpLeap];
        [self setUpScoreLayer];
        [self schedule:@selector(tick:)];
    }
    return self;
}


-(void) setUpObject {
    
    CGSize s = [CCDirector sharedDirector].winSize;
    
    bottomBorder = CGRectMake(0, 0, s.width, 1);
    topBorder = CGRectMake(0, s.height-1, s.width, 1);
    leftBorder = CGRectMake(0, 0, 1, s.height);
    rightBorder = CGRectMake(s.width-1, 0, 1, s.height);
    
    ball = [[PongBall alloc] initWithFile:@"ball.png"];
    player1 = [[PongPlayer alloc] initWithFile:@"player.png"];
    player2 = [[PongPlayer alloc] initWithFile:@"player.png"];
    
    ball.position = ccp(s.width/2, s.height/2);
    player1.position = ccp(35, s.height/2);
    player2.position = ccp(s.width-35, s.height/2);
    
    [self addChild:ball];
    [self addChild:player1];
    [self addChild:player2];
}

-(void) setUpLeap {
    controller = [[LeapController alloc] initWithDelegate:self];
}

-(void) setUpScoreLayer {
    CGSize s = [CCDirector sharedDirector].winSize;
    scorePlayer1 = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(s.width/2, s.height) hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter lineBreakMode:kCCLineBreakModeMiddleTruncation fontName:@"Arial" fontSize:300.0f];
    scorePlayer2 = [CCLabelTTF labelWithString:@"0" dimensions:CGSizeMake(s.width/2, s.height) hAlignment:kCCTextAlignmentCenter vAlignment:kCCVerticalTextAlignmentCenter lineBreakMode:kCCLineBreakModeMiddleTruncation fontName:@"Arial" fontSize:300.0f];
    
    scorePlayer1.position = ccp(s.width/4, s.height/2);
    scorePlayer2.position = ccp(s.width/4*3, s.height/2);
    
    scorePlayer1.color = scorePlayer2.color = ccc3(50.0f, 50.0f, 50.0f);
    
    [self addChild:scorePlayer1 z:-1];
    [self addChild:scorePlayer2 z:-1];
}

-(void) tick:(ccTime)dt {
    if(gamePause == NO) {
        CGRect ballRect = CGRectMake(ball.position.x - ball.contentSize.width/2,
                                     ball.position.y - ball.contentSize.height/2,
                                     ball.contentSize.width,
                                     ball.contentSize.height);
        
        CGRect player1Rect = CGRectMake(player1.position.x - player1.contentSize.width/2,
                                     player1.position.y - player1.contentSize.height/2,
                                     player1.contentSize.width,
                                     player1.contentSize.height);
        
        CGRect player2Rect = CGRectMake(player2.position.x - player2.contentSize.width/2,
                                        player2.position.y - player2.contentSize.height/2,
                                        player2.contentSize.width,
                                        player2.contentSize.height);
        
        if(CGRectIntersectsRect(ballRect, topBorder) || CGRectIntersectsRect(ballRect, bottomBorder)) {
            ballSpeedY = -ballSpeedY;
        }
        if(CGRectIntersectsRect(ballRect, player1Rect) && waitForLeftPlayer) {
            ballSpeedX = -ballSpeedX;
            waitForLeftPlayer = NO;
        }
        if(CGRectIntersectsRect(ballRect, player2Rect) && !waitForLeftPlayer) {
            ballSpeedX = -ballSpeedX;
            waitForLeftPlayer = YES;
        }

        
        CGPoint newPoint = ccp(ball.position.x + ((float)ballSpeedX*ftime), ball.position.y + ((float)ballSpeedY*ftime));
        ball.position = newPoint;

        if(CGRectIntersectsRect(ballRect, leftBorder)) {
            player2Score++;
            [self resetBall];
        } else if(CGRectIntersectsRect(ballRect, rightBorder)) {
            player1Score++;
            [self resetBall];
        }
        
        scorePlayer1.string = [NSString stringWithFormat:@"%d", player1Score];
        scorePlayer2.string = [NSString stringWithFormat:@"%d", player2Score];
        time++;
        ftime += 0.001f;
    } else {
        
    }
}

-(void) resetBall {
    CGSize s = [CCDirector sharedDirector].winSize;
    ball.position = ccp(s.width/2, s.height/2);
    multiplicator = 1;
    time = 0;
    ftime = 1.00f;
}


#pragma mark - LeapDelegate methods

- (void)onInit:(LeapController *)controller {
    NSLog(@"LeapController Initialized");
}

- (void)onConnect:(LeapController *)controller {
    NSLog(@"LeapController Connected");
}

- (void)onDisconnect:(LeapController *)controller {
    NSLog(@"LeapController Disconnected");
    gamePause = YES;
}

- (void)onExit:(LeapController *)controller {
    NSLog(@"LeapController Exited");
    gamePause = YES;
}

- (void)onFrame:(LeapController *)aController {
    LeapFrame* aFrame = [aController frame:0];
    if([aFrame.hands count] >= 2) {
        gamePause = NO;
        
        LeapHand* leftHand = [aFrame.hands objectAtIndex:0];
        LeapHand* rightHand = [aFrame.hands objectAtIndex:1];
        if (leftHand.palmPosition.x > rightHand.palmPosition.x) {
            leftHand = [aFrame.hands objectAtIndex:1];
            rightHand = [aFrame.hands objectAtIndex:0];
        }
        
        float leftY = leftHand.palmPosition.y - 200.0f;
        float rightY = rightHand.palmPosition.y - 200.0f;
        
        CGSize visibleSize = [CCDirector sharedDirector].winSize;
        float ratio = visibleSize.height/200.0f;
        
        float realLeftY = leftY * ratio;
        float realRightY = rightY * ratio;
        
        
        if(fabs(realLeftY - player1.position.y) > visibleSize.height/20) {
            player1.position = ccp(player1.position.x, realLeftY);
        }
        if(fabs(realRightY - player2.position.y) > visibleSize.height/20) {
            player2.position = ccp(player2.position.x, realRightY);
            
        }
        
    } else {
        gamePause = YES;
    }
}


@end


@implementation PongBall


@end

@implementation PongPlayer



@end