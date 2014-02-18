//
//  SkiMonsterScene.m
//  SkiMonster
//
//  Created by Stevenson on 2/17/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SkiMonsterScene.h"
@interface SkiMonsterScene()

@property (nonatomic) int nextObstacle;
@property (nonatomic) double nextObstacleSpawn;

@property (nonatomic) int nextFood;
@property (nonatomic) double nextFoodSpawn;

@property (nonatomic) SKSpriteNode *monster;
@property (nonatomic) NSMutableArray *obstacleArray;
@property (nonatomic) NSMutableArray *foodArray;

#define kNumObstacles 15
#define kNumFood 5

@end


@implementation SkiMonsterScene

-(id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        self.nextObstacle = 0;
        self.nextFood = 0;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        self.monster = [SKSpriteNode spriteNodeWithImageNamed:@"abom_h"];
        self.monster.position = CGPointMake(CGRectGetMidY(self.frame), CGRectGetHeight(self.frame)-150);
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
        
        CGPoint location = CGPointMake(randomXPosition, 1000);
        
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
    
}

@end
