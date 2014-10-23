//
//  FancyJoystick.h
//  Fancy Schmancy  Joystick
//
//  Created by Daniel Grönlund on 2014-10-22.
//  Copyright (c) 2014 danielgronlund. All rights reserved.
//

//#import "cocos2d.h"
#import <SpriteKit/SpriteKit.h>

@protocol FancyJoystickDelegate <NSObject>
@optional
/**
 *  Implement this method to a delegate to directly handle when the joystick is moved
 */
- (void)joystickUpdatedDirection:(id)sender;
- (void)joystickReleased;
@end

@interface FancyJoystick : SKSpriteNode

/**
 *  Direction the joystick is turning.
 *  Use direction to offset your game sprites position.
 */
@property (nonatomic,readonly) CGPoint direction;
@property (assign) id <FancyJoystickDelegate> delegate;

@end
