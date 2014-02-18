//
//  SkiMonsterScene.m
//  SkiMonster
//
//  Created by Stevenson on 2/17/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//


#import <AudioToolbox/AudioToolbox.h>
#import "SkiMonsterScene.h"


@interface SkiMonsterScene()

@property (nonatomic) int nextObstacle;
@property (nonatomic) double nextObstacleSpawn;

@property (nonatomic) int nextFood;
@property (nonatomic) double nextFoodSpawn;

@property (nonatomic) SKSpriteNode *monster;
@property (nonatomic) NSMutableArray *obstacleArray;
@property (nonatomic) NSMutableArray *foodArray;

@property (nonatomic) NSTimer *monsterMove;

@property (nonatomic) int numOfFoodEaten;

#define kNumObstacles 15
#define kNumFood 5

@end


@implementation SkiMonsterScene

-(id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        self.monsterMove = [[NSTimer alloc] init];
        
        self.nextObstacle = 0;
        self.nextFood = 0;
        
        self.numOfFoodEaten = 0;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        self.monster = [SKSpriteNode spriteNodeWithImageNamed:@"abom_h"];
        self.monster.position = CGPointMake(150, CGRectGetHeight(self.frame)-150);
        [self addChild:self.monster];
        self.monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.monster.size];
        self.monster.physicsBody.dynamic = YES;
        self.monster.physicsBody.affectedByGravity = NO;
        
        self.obstacleArray = [[NSMutableArray alloc] initWithCapacity:kNumObstacles];
        self.foodArray = [[NSMutableArray alloc] initWithCapacity:kNumFood];
        
        for (int i=0;i<kNumObstacles; i++) {
            SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"tree"];
            obstacle.hidden = YES;
            [self.obstacleArray addObject:obstacle];
            [self addChild:obstacle];
        }
        
        for (int i=0;i<kNumFood; i++) {
            SKSpriteNode *food = [SKSpriteNode spriteNodeWithImageNamed:@"food"];
            food.hidden = YES;
            [self.foodArray addObject:food];
            [self addChild:food];
        }
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touch = [[touches anyObject] locationInView:self.view];
    CGPoint monsterLocation = self.monster.position;
    if ( touch.x < monsterLocation.x ) {
        self.monsterMove = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(moveMonsterInXDirection:) userInfo:@{@"direction" : @(-2.0)} repeats:YES];
    } else {
        self.monsterMove = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(moveMonsterInXDirection:) userInfo:@{@"direction" : @(2.0)} repeats:YES];
    }
}

-(void) moveMonsterInXDirection:(NSTimer *) timer
{
    CGFloat direction = [[[timer userInfo] objectForKey:@"direction"] floatValue];
    SKAction *moveAction = [SKAction moveByX:direction y:0.f duration:.4];
    
    [self.monster runAction:moveAction];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.monsterMove invalidate];
}

-(float)randomValueBetween:(float)low andValue:(float)high
{
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}


-(void)update:(CFTimeInterval)currentTime
{

    [self enumerateChildNodesWithName:@"skiing" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)node;
        bg.position = CGPointMake(bg.position.x , bg.position.y- 5);
        
        if (bg.position.y <= -bg.size.height)
        {
            bg.position = CGPointMake(bg.position.x, bg.position.y + bg.size.height * 2);
        }
        
    }];
    
    double thisTime = CACurrentMediaTime();
    
    if (thisTime > self.nextFoodSpawn) {
        float randomSecond = [self randomValueBetween:0.20f andValue:1.0f];
        self.nextFoodSpawn = randomSecond + thisTime;
        float randomXPosition = [self randomValueBetween:0.0f andValue:CGRectGetHeight(self.frame)];
        float randDuration = [self randomValueBetween:5.0f andValue:8.0f];
        
        
        
        SKSpriteNode *food = self.foodArray[self.nextFood];
        self.nextFood++;
        if (self.nextFood >= self.foodArray.count) {
            self.nextFood = 0;
        }
        
        [food removeAllActions];
        
        float nextRandomXPosition = [self randomValueBetween:0.0f andValue:CGRectGetHeight(self.frame)];
        
        food.position = CGPointMake(nextRandomXPosition, 0);
        food.hidden = NO;
        
        CGPoint location = CGPointMake(randomXPosition, 1200);
        
        SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
        
        SKAction *hideFood = [SKAction runBlock:^{
            food.hidden = YES;
        }];
        
        SKAction *moveFoodThenHide = [SKAction sequence:@[moveAction,hideFood]];
        [food runAction:moveFoodThenHide];
    }
    
    
    if (thisTime > self.nextObstacleSpawn) {
        float randomSecond = [self randomValueBetween:0.20f andValue:1.0f];
        self.nextObstacleSpawn = randomSecond + thisTime;
        float randomXPosition = [self randomValueBetween:0.0f andValue:CGRectGetHeight(self.frame)];
        float obstacleDuration = 8.f;
        
        
        
        SKSpriteNode *obstacle = self.obstacleArray[self.nextObstacle];
        self.nextObstacle++;
        if (self.nextObstacle >= self.obstacleArray.count) {
            self.nextObstacle = 0;
        }
        
        [obstacle removeAllActions];
        
        obstacle.position = CGPointMake(randomXPosition, 0);
        obstacle.hidden = NO;
        
        CGPoint location = CGPointMake(randomXPosition, 1000);
        
        SKAction *moveAction = [SKAction moveTo:location duration:obstacleDuration];
        
        SKAction *hideObstacle = [SKAction runBlock:^{
            obstacle.hidden = YES;
        }];
        
        SKAction *moveObstacleThenHide = [SKAction sequence:@[moveAction,hideObstacle]];
        [obstacle runAction:moveObstacleThenHide];
    }
    
    for (SKSpriteNode *thisFood in self.foodArray) {
        if ([self.monster intersectsNode:thisFood]) {
            [thisFood setHidden:YES];
//            self.numOfFoodEaten++;
            [self gobbleSound];
//            if (self.numOfFoodEaten == kNumFood) {
//                UILabel *lose = [[UILabel alloc] initWithFrame:self.view.frame];
//                lose.text = @"You Won!";
//                lose.center = self.view.center;
//                [self.view addSubview:lose];
//                [UIView animateWithDuration:1.f animations:^{
//                    lose.alpha = 0;
//                } completion:^(BOOL finished) {
//                    [lose removeFromSuperview];
//                }];
//            }
        }
    }
    
    for (SKSpriteNode *thisObstacle in self.obstacleArray) {
        if ([self.monster intersectsNode:thisObstacle]) {
            [self.monster removeFromParent];
            UILabel *lose = [[UILabel alloc] initWithFrame:self.view.frame];
            lose.text = @"You Died!";
            lose.center = self.view.center;
            [self.view addSubview:lose];
            [UIView animateWithDuration:1.f animations:^{
                lose.alpha = 0;
            } completion:^(BOOL finished) {
                [lose removeFromSuperview];
            }];
        }
    }
}

-(void)gobbleSound{
	//Get the filename of the sound file:
	NSString *path = [NSString stringWithFormat:@"%@%@", [[NSBundle mainBundle] resourcePath], @"/gobble.wav"];
    
	//declare a system sound
	SystemSoundID soundID;
    
	//Get a URL for the sound file
	NSURL *filePath = [NSURL fileURLWithPath:path isDirectory:NO];
    
    CFURLRef urlRef = (__bridge CFURLRef)(filePath);
	//Use audio sevices to create the sound
	AudioServicesCreateSystemSoundID(urlRef, &soundID);
	//Use audio services to play the sound
	AudioServicesPlaySystemSound(soundID);
    [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(removeAudio:) userInfo:@{@"soundID":@(soundID)} repeats:NO];
}

-(void) removeAudio:(NSTimer*) timer;
{
    SystemSoundID soundID = (SystemSoundID)[[[timer userInfo] objectForKey:@"soundID"] intValue];
    AudioServicesDisposeSystemSoundID(soundID);
}

@end
