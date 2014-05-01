//
//  DemoScene.m
//  Fancy Schmancy  Joystick
//
//  Created by Daniel Grönlund on 2014-05-01.
//  Copyright (c) 2014 danielgronlund. All rights reserved.
//

#import "DemoScene.h"
#import "FancyJoystick.h"

@interface DemoScene ()
{
    CCSprite *_sprite;
    CCSpriteBatchNode *_batch;
    FancyJoystick *_joystick;
}

@end

@implementation DemoScene

+ (DemoScene *)scene
{
	return [[self alloc] init];
}
- (id)init
{
    self = [super init];
    if (!self) return(nil);
    
    CCNodeColor *background = [CCNodeColor nodeWithColor:[CCColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:1.0f]];
    [self addChild:background];
    
    [[CCSpriteFrameCache sharedSpriteFrameCache]addSpriteFramesWithFile:@"joystick.plist"];
    
    _batch = [CCSpriteBatchNode batchNodeWithFile:@"joystick.png"];
    
    [self addChild:_batch];
    
    _joystick = [[FancyJoystick alloc]init];
    _joystick.position = ccp(.5,.5);
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        // Scale down for iPhone demo purpose
        _joystick.scale = .5;
    }
    
    [_batch addChild:_joystick];
    _batch.contentSize = CGSizeMake([[UIScreen mainScreen]bounds].size.height, [[UIScreen mainScreen]bounds].size.width);
    
	return self;
}



@end
