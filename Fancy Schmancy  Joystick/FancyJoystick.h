//
//  FancyJoystick.h
//  Fancy Schmancy  Joystick
//
//  Created by Daniel Grönlund on 2014-05-01.
//  Copyright (c) 2014 danielgronlund. All rights reserved.
//

#import "cocos2d.h"


@protocol FancyJoystickDelegate <NSObject>
@optional
/**
 *  Implement this method to a delegate to directly handle when the joystick is moved
 */
- (void)joystickUpdatedDirection:(id)sender;
- (void)joystickReleased:(id)sender;
@end

@interface FancyJoystick : CCSprite

/**
 *  Direction the joystick is turning.
 *  Use direction to offset your game sprites position.
 */
@property (nonatomic,readonly) CGPoint direction;
@property (assign) id <FancyJoystickDelegate> delegate;

@end
