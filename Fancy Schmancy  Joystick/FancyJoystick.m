//
//  FancyJoystick.m
//  Fancy Schmancy  Joystick
//
//  Created by Daniel Grönlund on 2014-05-01.
//  Copyright (c) 2014 danielgronlund. All rights reserved.
//

#import "FancyJoystick.h"

#define kNumberOfStickLayers 20.0
#define kNumberOfDefaultLayers 6.0
#define kMaxDistance 80.0
#define kStiffness 10.0 // recomended between 0.0 - 100.0

#define joystickNormalizedCenter ccp(.50,.50)

#define kStickTag @"stick"

@interface FancyJoystick ()
{
  
    CCSprite *_knob;
    CGPoint *_lastTouch;
    
}

- (CGFloat)angleBetween:(CGPoint)startPoint and:(CGPoint)endPoint;

@end

@implementation FancyJoystick

- (id)init
{
    self = [super initWithTexture:nil rect:CGRectMake(0, 0, 200, 200)];
    if (self) {
        
        // Setting up rubber base sprites
        for (int i = 1; i < kNumberOfDefaultLayers; i ++) {
            NSString *fileName = [NSString stringWithFormat:@"layer%d.png",i];
            CCSprite *layer = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:fileName]];
            [self addChild:layer];
            layer.positionType = CCPositionTypeNormalized;
            
            self.positionType = CCPositionTypeNormalized;
            
            layer.position = joystickNormalizedCenter;
        }

        // Setting up metal stick sprites
        for (int i = kNumberOfDefaultLayers; i < kNumberOfStickLayers + kNumberOfDefaultLayers; i ++) {
            CCSpriteFrame *stickFrame = [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"stick.png"];
            
            CCSprite *stickLayer = [CCSprite spriteWithSpriteFrame:stickFrame];
            stickLayer.positionType = CCPositionTypeNormalized;
            [self addChild:stickLayer];
            
            float stickScale = .98;
            float scaleSubtraction = ((kNumberOfStickLayers - (i - kNumberOfDefaultLayers)) /kNumberOfStickLayers);
            stickScale = stickScale - (scaleSubtraction * .5);
            stickLayer.scale = stickScale;
            stickLayer.position = joystickNormalizedCenter;
            stickLayer.name = kStickTag;
        }
        
        _knob = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache]spriteFrameByName:@"knob.png"]];
        [self addChild:_knob];
        _knob.positionType = CCPositionTypeNormalized;
        _knob.position = joystickNormalizedCenter;
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

- (CGFloat)angleBetween:(CGPoint)startPoint and:(CGPoint)endPoint
{
    CGPoint originPoint = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    float bearingRadians = atan2f(originPoint.y, originPoint.x);
    float bearingDegrees = bearingRadians * (180.0 / M_PI);
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees));
    return bearingDegrees;
}

#pragma mark - Touch Implementation

- (void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self stopAllActions];
}

- (void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    float distance = ccpDistance( touch.locationInWorld, self.positionInPoints);
    distance =  clampf(distance, 0, kMaxDistance);
    float angle = [self angleBetween:self.positionInPoints and:touch.locationInWorld];
    
    float vx = cos(angle * M_PI / 180) * (distance * 1.5);
    float vy = sin(angle * M_PI / 180) * (distance * 1.5);
    
    _direction = ccp(vx / distance, vy / distance);
    
    float darkness = (127 * (vy / kMaxDistance));
    
    float i = 0;
    float count = self.children.count;
    for (CCSprite *layer in self.children) {
        CGPoint addition = ccpMult( ccp(vx / self.contentSize.width,vy / self.contentSize.height), i / count );
        layer.position = ccpAdd(joystickNormalizedCenter, addition);
        if ([layer.name isEqualToString:kStickTag]) {
            layer.color = [CCColor colorWithWhite:.8 - (( darkness / 200.0) * (i / count)) alpha:1.0];
        }
        i ++;
    }
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(joystickUpdatedDirection:)])[self.delegate joystickUpdatedDirection:self];
    }
}

- (void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self stopAllActions];
    float duration = 1.0 - (kStiffness / 100.0);
    id resetAction = [CCActionEaseElasticOut actionWithAction:[CCActionMoveTo actionWithDuration:duration  position:joystickNormalizedCenter]];
    for (CCSprite *sprite in self.children) {
        [sprite runAction:[resetAction copy]];
    }
    _direction = ccp(0, 0);
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(joystickReleased:)])[self.delegate joystickReleased];
    }
}

@end
