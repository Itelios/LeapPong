//
//  PongLayer.h
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

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "LeapObjectiveC.h"


@class PongBall;
@class PongPlayer;

@interface PongLayer : CCLayer<LeapDelegate> {
    
    CGRect topBorder;
    CGRect bottomBorder;
    CGRect leftBorder;
    CGRect rightBorder;
    
    PongBall* ball;
    PongPlayer* player1;
    PongPlayer* player2;

    BOOL gamePause;
    BOOL waitForLeftPlayer;
    
    int ballSpeedX;
    int ballSpeedY;
    
    LeapController* controller;
    
    int player1Score;
    int player2Score;
    CCLabelTTF* scorePlayer1;
    CCLabelTTF* scorePlayer2;
    
    float ftime;
    
    int time;
    int multiplicator;
}

@end


@interface PongBall : CCSprite
@end

@interface PongPlayer : CCSprite
@end