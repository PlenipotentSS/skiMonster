//
//  SkiMonsterScene.m
//  SkiMonster
//
//  Created by Stevenson on 2/17/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//





#import <AudioToolbox/AudioToolbox.h>
#import "SkiMonsterScene.h"
#import "YMCPhysicsDebugger.h"
#import "GameOverScreen.h"


@interface SkiMonsterScene() <SKPhysicsContactDelegate>

@property (nonatomic) int nextObstacle;
@property (nonatomic) double nextObstacleSpawn;

@property (nonatomic) int nextFood;
@property (nonatomic) double nextFoodSpawn;

@property (nonatomic) SKSpriteNode *monster;
@property (nonatomic) NSMutableArray *obstacleArray;
@property (nonatomic) NSMutableArray *foodArray;

@property (nonatomic) NSTimer *monsterMove;

@property (nonatomic) BOOL playingSound;

@property (nonatomic) SKLabelNode *loseLabel;

@property (nonatomic) SKLabelNode *foodEatenLabel;

@property (nonatomic) SKLabelNode *livesLabel;

@property (nonatomic) NSInteger lives;

@property (nonatomic) BOOL isDead;

@property (nonatomic) NSInteger numOfFoodEaten;

@property (nonatomic) CGFloat speedMultiplier;

@property (nonatomic) CGFloat tappedXOrigin;

@property (nonatomic) BOOL monsterIsRecooperating;

@property (nonatomic) CGFloat monsterXOrigin;

#define kNumTrees 30
#define kNumPoles 4
#define kNumFood 10
#define SpeedIncrease .001
#define MonsterYLevel CGRectGetHeight(self.frame)-150

@end


@implementation SkiMonsterScene

-(id)initWithSize:(CGSize)size
{
    self = [super initWithSize:size];
    if (self) {
        self.monsterMove = [[NSTimer alloc] init];
        self.speedMultiplier = 1.f;
        self.tappedXOrigin = -1.f;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.contactDelegate = self;
        
        [YMCPhysicsDebugger init];
        
        [self bringMonsterToScene];
        [self addNPCs];
        
        self.loseLabel = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNueue"];
        self.loseLabel.fontSize = 50;
        self.loseLabel.fontColor = [UIColor blackColor];
        self.loseLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        
        [self addChild:self.loseLabel];
        self.loseLabel.hidden = YES;
        
        self.loseLabel = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNueue"];
        self.loseLabel.fontSize = 50;
        self.loseLabel.fontColor = [UIColor blackColor];
        self.loseLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        self.loseLabel.text = @"You Lose!";
        
        [self addChild:self.loseLabel];
        self.loseLabel.hidden = YES;
        
        self.foodEatenLabel = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNueue"];
        self.foodEatenLabel.fontSize = 16;
        self.foodEatenLabel.fontColor = [UIColor blackColor];
        self.foodEatenLabel.position = CGPointMake(CGRectGetWidth(self.frame)-80, CGRectGetHeight(self.frame)-40);
        self.foodEatenLabel.text = @"Skiers Eaten: 0";
        [self addChild:self.foodEatenLabel];
        
        self.livesLabel = [[SKLabelNode alloc] initWithFontNamed:@"HelveticaNueue"];
        self.livesLabel.fontSize = 16;
        self.livesLabel.fontColor = [UIColor blackColor];
        self.livesLabel.position = CGPointMake(50, CGRectGetHeight(self.frame)-40);
        self.livesLabel.text = @"Lives: 1";
        [self addChild:self.livesLabel];
        
        //[self drawPhysicsBodies];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setNumOfFoodEaten:(NSInteger)numOfFoodEaten
{
    _numOfFoodEaten = numOfFoodEaten;
    self.foodEatenLabel.text = [NSString stringWithFormat:@"Skiers Eaten: %d",(int)numOfFoodEaten];
}

-(void) bringMonsterToScene
{
    self.isDead = NO;
    self.numOfFoodEaten = 0;
    self.lives = 1;
    self.monster = [SKSpriteNode spriteNodeWithImageNamed:@"abom_h"];
    self.monster.position = CGPointMake(150, MonsterYLevel);
    
    CGSize monsterSize = self.monster.size;
    monsterSize = CGSizeMake(monsterSize.width*.4, monsterSize.width*.4);
    self.monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monsterSize];
    self.monster.physicsBody.dynamic = YES;
    self.monster.physicsBody.allowsRotation = NO;
    self.monster.physicsBody.affectedByGravity = NO;
    self.monster.physicsBody.categoryBitMask = COLLISION_CATEGORY_MONSTER;
    self.monster.physicsBody.contactTestBitMask = COLLISION_CATEGORY_FOOD | COLLISION_CATEGORY_OBSTACLE;
    self.monster.name = @"Monster";
    [self addChild:self.monster];
}

-(void) addNPCs
{
    self.nextObstacle = 0;
    self.nextFood = 0;
    self.numOfFoodEaten = 0;
    
    self.obstacleArray = [[NSMutableArray alloc] initWithCapacity:kNumTrees];
    self.foodArray = [[NSMutableArray alloc] initWithCapacity:kNumFood];
    
    for (int i=0;i<kNumTrees; i++) {
        SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"tree"];
        
        CGSize obstacleSize = obstacle.size;
        obstacleSize = CGSizeMake(obstacleSize.width*.4, obstacleSize.width*.4);
        obstacle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obstacleSize];
        obstacle.physicsBody.dynamic = NO;
        obstacle.physicsBody.categoryBitMask = COLLISION_CATEGORY_OBSTACLE;
        obstacle.hidden = YES;
        obstacle.name = @"Tree";
        obstacle.zPosition = 10;
        [self.obstacleArray addObject:obstacle];
        [self addChild:obstacle];
    }
    
    for (int i=0;i<kNumPoles; i++) {
        SKSpriteNode *obstacle = [SKSpriteNode spriteNodeWithImageNamed:@"lift_pole"];
        
        CGSize obstacleSize = obstacle.size;
        obstacleSize = CGSizeMake(obstacleSize.width*.4, obstacleSize.width*.4);
        obstacle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:obstacleSize];
        obstacle.physicsBody.dynamic = NO;
        obstacle.physicsBody.categoryBitMask = COLLISION_CATEGORY_OBSTACLE;
        obstacle.hidden = YES;
        obstacle.name = @"Pole";
        obstacle.zPosition = 10;
        [self.obstacleArray addObject:obstacle];
        [self addChild:obstacle];
    }
    
    [self shuffleArray];
    
    for (int i=0;i<kNumFood; i++) {
        [self createFood];
    }
}

-(void) createFood
{
    SKSpriteNode *food = [SKSpriteNode spriteNodeWithImageNamed:@"food"];
    
    CGSize foodSize = food.size;
    foodSize = CGSizeMake(foodSize.width*.4, foodSize.width*.4);
    food.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:foodSize];
    
    food.physicsBody.dynamic = NO;
    food.physicsBody.density = 10000;
    food.physicsBody.restitution = 0.f;
    food.physicsBody.allowsRotation = NO;
    self.monster.physicsBody.affectedByGravity = NO;
    food.physicsBody.categoryBitMask = COLLISION_CATEGORY_FOOD;
    food.physicsBody.contactTestBitMask = COLLISION_CATEGORY_OBSTACLE;
    food.physicsBody.collisionBitMask = 0;
    food.physicsBody.usesPreciseCollisionDetection = YES;
    food.hidden = YES;
    food.name = @"Food";
    [self.foodArray addObject:food];
    [self addChild:food];
}

-(void) shuffleArray
{
    for (NSUInteger i =0;i<[self.obstacleArray count];++i) {
        NSInteger nElements = [self.obstacleArray count] - i;
        NSInteger n = arc4random_uniform((int)nElements) + i;
        [self.obstacleArray exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touch = [[touches anyObject] locationInView:self.view];
    self.tappedXOrigin = touch.x;
    self.monsterXOrigin = self.monster.position.x;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.isDead) {
        CGPoint touch = [[touches anyObject] locationInView:self.view];
        CGFloat xChanged = self.tappedXOrigin-touch.x;
        CGPoint newLocation = CGPointMake(self.monsterXOrigin-xChanged, self.monster.position.y);
        SKAction *moveAction = [SKAction moveTo:newLocation duration:.1f];
        
        [self.monster runAction:moveAction];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isDead) {
        [self bringMonsterToScene];
        self.loseLabel.hidden = YES;
    }
    self.tappedXOrigin = -1.f;
}

-(float)randomValueBetween:(float)low andValue:(float)high
{
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

#pragma mark - SKPhysicsContactDelegate
-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKNode *nodeA = [contact.bodyA node];
    SKNode *nodeB = [contact.bodyB node];
    //NSLog(@"%@ %@",[nodeA name],[nodeB name]);
    if (!self.monsterIsRecooperating) {
        if ([[nodeA name] isEqualToString:@"Monster"]) {
            if ([[nodeB name] isEqualToString:@"Food"]) {
                [nodeB setHidden:YES];
                [nodeB removeFromParent];
                [self.foodArray removeObject:nodeB];
                [self createFood];
                
                self.numOfFoodEaten++;
                if (self.numOfFoodEaten % 10 == 0) {
                    self.lives++;
                    self.livesLabel.text = [NSString stringWithFormat:@"Lives: %d",(int)self.lives];
                }
                [self gobbleSound];
            } else {
                if (self.lives == 0) {
                    [self endGame];
                } else {
                    self.lives--;
                    self.livesLabel.text = [NSString stringWithFormat:@"Lives: %d",(int)self.lives];
                    
                    self.monsterIsRecooperating = YES;
                    SKAction *blinkActionOff = [SKAction scaleXTo:-1.f duration:.2f];
                    
                    SKAction *blinkActionOn = [SKAction scaleXTo:1.f duration:.2f];
                    
                    SKAction *doneRecooperating = [SKAction runBlock:^{
                        self.monsterIsRecooperating = NO;
                    }];
                    
                    CGPoint monsterOrigin = CGPointMake(150, MonsterYLevel);
                    SKAction *moveMonsterToCenter = [SKAction moveTo:monsterOrigin duration:.4f];
                    
                    SKAction *blinkMonster = [SKAction sequence:@[moveMonsterToCenter,blinkActionOff,blinkActionOn,blinkActionOff,blinkActionOn,blinkActionOff,blinkActionOn,doneRecooperating]];
                    [self.monster runAction:blinkMonster];
                }
            }
        }
    }
}

#pragma mark - end Game
-(void)endGame {
    [self.monster removeFromParent];
    self.loseLabel.hidden = NO;
    self.speedMultiplier = 1.f;
    
    self.isDead = YES;
    self.monster = nil;
    [self.monsterMove invalidate];
    
    GameOverScreen* gameOverScene = [[GameOverScreen alloc] initWithSize:self.size];
    gameOverScene.numSkiersEaten = self.numOfFoodEaten;
    [self.view presentScene:gameOverScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
}

#pragma mark - update game loop
-(void)update:(CFTimeInterval)currentTime
{
    self.speedMultiplier += SpeedIncrease;
    
    [self enumerateChildNodesWithName:@"skiing" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode *bg = (SKSpriteNode *)node;
        bg.position = CGPointMake(bg.position.x , bg.position.y- 5);
        
        if (bg.position.y <= -bg.size.height)
        {
            bg.position = CGPointMake(bg.position.x, bg.position.y + bg.size.height * 2);
        }
        
    }];
    
    double thisTime = CACurrentMediaTime();
    
    if (thisTime > self.nextObstacleSpawn) {
        float randomSecond = [self randomValueBetween:0.20f andValue:1.0f]/(self.speedMultiplier);
        self.nextObstacleSpawn = randomSecond + thisTime;
        float randomXPosition = [self randomValueBetween:0.0f andValue:CGRectGetHeight(self.frame)];
        float obstacleDuration = 8.f/self.speedMultiplier;
        
        
        
        SKSpriteNode *obstacle = self.obstacleArray[self.nextObstacle];
        self.nextObstacle++;
        if (self.nextObstacle >= self.obstacleArray.count) {
            self.nextObstacle = 0;
        }
        
        obstacle.position = CGPointMake(randomXPosition, CGRectGetMinY(self.frame));
        obstacle.hidden = NO;
        
        CGPoint location = CGPointMake(randomXPosition,  CGRectGetHeight(self.frame));
        
        SKAction *moveAction = [SKAction moveTo:location duration:obstacleDuration];
        
        SKAction *hideObstacle = [SKAction runBlock:^{
            obstacle.hidden = YES;
        }];
        
        SKAction *moveObstacleThenHide = [SKAction sequence:@[moveAction,hideObstacle]];
        [obstacle runAction:moveObstacleThenHide];
    }
    
    
    if (thisTime > self.nextFoodSpawn) {
        float randomSecond = [self randomValueBetween:1.0f andValue:5.0f]/self.speedMultiplier;
        self.nextFoodSpawn = randomSecond + thisTime;
        float randomXPosition = [self randomValueBetween:0.0f andValue:CGRectGetWidth(self.frame)];
        float foodDuration = [self randomValueBetween:8.0f andValue:20.f]/self.speedMultiplier;
        
        
        
        SKSpriteNode *food = self.foodArray[self.nextFood];
        self.nextFood++;
        if (self.nextFood >= self.foodArray.count) {
            self.nextFood = 0;
        }
        
        //original food position
        food.position = CGPointMake(randomXPosition, CGRectGetMinY(self.frame));
        food.hidden = NO;
        
        
        //next food position
        
        float nextRandomXPosition = [self randomValueBetween:0.0f andValue:CGRectGetWidth(self.frame)];
        CGPoint location = CGPointMake(nextRandomXPosition,  CGRectGetHeight(self.frame));
        
        
        //actions
        SKAction *moveAction = [SKAction moveTo:location duration:foodDuration];
        
        SKAction *hideFood = [SKAction runBlock:^{
            food.hidden = YES;
        }];
        
        SKAction *removeActions = [SKAction runBlock:^{
            [food removeAllActions];
        }];
        
        //run actions
        SKAction *moveObstacleThenHide = [SKAction sequence:@[moveAction,hideFood,removeActions]];
        [food runAction:moveObstacleThenHide];
    }
}

-(void)gobbleSound{
    if (!self.playingSound) {
        self.playingSound = YES;
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
        [NSTimer scheduledTimerWithTimeInterval:.8f target:self selector:@selector(removeAudio:) userInfo:@{@"soundID":@(soundID)} repeats:NO];
    }
}

-(void) removeAudio:(NSTimer*) timer;
{
    SystemSoundID soundID = (SystemSoundID)[[[timer userInfo] objectForKey:@"soundID"] intValue];
    AudioServicesDisposeSystemSoundID(soundID);
    self.playingSound = NO;
}

@end
