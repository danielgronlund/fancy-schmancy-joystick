//
//  GameScene.m
//  fancy-schamncy-joystick-sk
//
//  Created by Daniel Grönlund on 2014-10-22.
//  Copyright (c) 2014 Daniel Grönlund. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    self.backgroundColor = [UIColor colorWithWhite:.2 alpha:1.0];
    
    FancyJoystick *joystick = [[FancyJoystick alloc] init];
    joystick.position = CGPointMake(self.size.width / 2, self.size.height / 2);
    joystick.delegate = self;
    [self addChild:joystick];
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
