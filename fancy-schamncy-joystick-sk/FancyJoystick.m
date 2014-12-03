//
//  FancyJoystick.m
//  Fancy Schmancy  Joystick
//
//  Created by Daniel Grönlund on 2014-10-22.
//  Copyright (c) 2014 danielgronlund. All rights reserved.
//

#import "FancyJoystick.h"
#import "SKEase.h"

#define kNumberOfStickLayers 20.0
#define kNumberOfDefaultLayers 6.0
#define kMaxDistance 80.0
#define kStiffness 30.0 // recomended between 1.0 - 99.0, default is 30.0

#define joystickNormalizedCenter CGPointMake(.50,.50)

#define kStickTag @"stick"

@interface FancyJoystick ()
{
    SKSpriteNode *_knob;
    CGPoint *_lastTouch;
}

- (CGFloat)angleBetween:(CGPoint)startPoint and:(CGPoint)endPoint;

@end

@implementation FancyJoystick

#pragma mark - Cocos2d Compatability Functions

// Functions and macros imported and adapted from cocos2d & chipmunk
// to enable support for some of the caclulations made in the Fancy Schmancy Joystick class.

#define CC_SWAP( x, y )			\
({ __typeof__(x) temp  = (x);		\
x = y; y = temp;		\
})

#pragma mark - Calculation

CGFloat SKDistanceBetweenPoints(CGPoint first, CGPoint second) {
    return hypotf(second.x - first.x, second.y - first.y);
}

float clampf(float value, float min_inclusive, float max_inclusive)
{
    if (min_inclusive > max_inclusive) {
        CC_SWAP(min_inclusive,max_inclusive);
    }
    return value < min_inclusive ? min_inclusive : value < max_inclusive? value : max_inclusive;
}

CGPoint CGPointMult(const CGPoint v, const CGFloat s)
{
    return CGPointMake(v.x*s, v.y*s);
}

CGPoint CGPointAdd(const CGPoint v1, const CGPoint v2)
{
    return CGPointMake(v1.x + v2.x, v1.y + v2.y);
}

#pragma mark - Fancy Initialization


- (id)init
{
    self = [super initWithColor:[UIColor clearColor] size:CGSizeMake(200, 200)];
    if (self) {
        
        // Setting up rubber base sprites
        for (int i = 1; i < kNumberOfDefaultLayers; i ++) {
            NSString *fileName = [NSString stringWithFormat:@"layer%d.png",i];
            SKSpriteNode *layer = [SKSpriteNode spriteNodeWithImageNamed:fileName];
            
            [self addChild:layer];
            layer.position = joystickNormalizedCenter;
        }
        
        // Setting up metal stick sprites
        for (int i = kNumberOfDefaultLayers; i < kNumberOfStickLayers + kNumberOfDefaultLayers; i ++) {
            SKSpriteNode *stickLayer = [SKSpriteNode spriteNodeWithImageNamed:@"stick.png"];
            [self addChild:stickLayer];
            
            float stickScale = .98;
            float scaleSubtraction = ((kNumberOfStickLayers - (i - kNumberOfDefaultLayers)) /kNumberOfStickLayers);
            stickScale = stickScale - (scaleSubtraction * .5);
            stickLayer.scale = stickScale;
            stickLayer.position = joystickNormalizedCenter;
            stickLayer.name = kStickTag;
        }
        
        _knob = [SKSpriteNode spriteNodeWithImageNamed:@"knob.png"];
        [self addChild:_knob];
        _knob.position = joystickNormalizedCenter;
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

#pragma

- (CGFloat)angleBetween:(CGPoint)startPoint and:(CGPoint)endPoint
{
    
    CGPoint originPoint = CGPointMake(endPoint.x - startPoint.x, endPoint.y - startPoint.y);
    float bearingRadians = atan2f(originPoint.y, originPoint.x);
    float bearingDegrees = bearingRadians * (180.0 / M_PI);
    bearingDegrees = (bearingDegrees > 0.0 ? bearingDegrees : (360.0 + bearingDegrees));
    return bearingDegrees;
}

#pragma mark - Touch Implementation

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    [self removeAllActions];
    for (SKSpriteNode *layer in self.children) {
     [layer removeAllActions];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    float distance = SKDistanceBetweenPoints( [touch locationInNode:self.parent], self.position);
    distance =  clampf(distance, 0, kMaxDistance);
    
    float angle = [self angleBetween:self.position and:[touch locationInNode:self.parent]];
    
    float vx = cos(angle * M_PI / 180) * (distance * 1.5);
    float vy = sin(angle * M_PI / 180) * (distance * 1.5);
    
    _direction = CGPointMake(vx / distance, vy / distance);
    
    float darkness = (127 * (vy / kMaxDistance));
    
    float i = 0;
    float count = self.children.count;
    for (SKSpriteNode *layer in self.children) {
        
        CGPoint addition = CGPointMult( CGPointMake(vx ,vy ), i / count );
        layer.position = CGPointAdd(joystickNormalizedCenter, addition);
        if ([layer.name isEqualToString:kStickTag]) {
            layer.color = [UIColor colorWithWhite:.8 - (( darkness / 200.0) * (i / count)) alpha:1.0];
        }
        i ++;
    }
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(joystickUpdatedDirection:)])[self.delegate joystickUpdatedDirection:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self removeAllActions];
    for (SKSpriteNode *layer in self.children) {
        [layer removeAllActions];
    }
    float duration = 1.0 - (kStiffness / 100.0);
    
    for (SKSpriteNode *sprite in self.children) {
        SKAction *resetAction = [SKEase MoveToWithNode:sprite EaseFunction:CurveTypeElastic Mode:EaseOut Time:duration ToVector:CGVectorMake(joystickNormalizedCenter.x, joystickNormalizedCenter.y)];
        [sprite runAction:resetAction];
    }
    _direction = CGPointMake(0, 0);
    if (self.delegate != nil) {
        if ([self.delegate respondsToSelector:@selector(joystickReleased:)])[self.delegate joystickReleased:self];
    }
}


@end
