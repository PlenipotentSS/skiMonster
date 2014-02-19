//
//  GameOverScreen.m
//  SkiMonster
//
//  Created by Stevenson on 2/18/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "SkiMonsterScene.h"
#import "GameOverScreen.h"
@interface GameOverScreen()

@property BOOL contentCreated;
@property (nonatomic) NSInteger highScore;

@end

@implementation GameOverScreen


- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated) {
        [self createContent];
        self.contentCreated = YES;
    }
}

-(NSInteger)highScore
{
    NSInteger highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"HighScore"];
    if (self.numSkiersEaten > highScore) {
        _highScore = self.numSkiersEaten;
        [[NSUserDefaults standardUserDefaults] setInteger:self.numSkiersEaten forKey:@"HighScore"];
    } else {
        _highScore = highScore;
    }
    return _highScore;
}

- (void)createContent
{
    SKLabelNode* highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    highScoreLabel.fontSize = 25;
    highScoreLabel.fontColor = [SKColor whiteColor];
    highScoreLabel.text = [NSString stringWithFormat:@"High Score: %d",(int)self.highScore];
    highScoreLabel.position = CGPointMake(self.size.width/2, self.size.height-100);
    [self addChild:highScoreLabel];
    
    if (self.highScore == self.numSkiersEaten) {
        SKAction *zoomOut = [SKAction scaleBy:1.5f duration:.4f];
        SKAction *zoomIn = [SKAction scaleBy:.75f duration:.4f];
        SKAction *zoom = [SKAction sequence:@[zoomOut,zoomIn]];
        
        [highScoreLabel runAction:zoom];
    }
    
    SKLabelNode* numberSkiersLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    numberSkiersLabel.fontSize = 80;
    numberSkiersLabel.fontColor = [SKColor whiteColor];
    numberSkiersLabel.text = [NSString stringWithFormat:@"%d",(int)self.numSkiersEaten];
    numberSkiersLabel.position = CGPointMake(self.size.width/2, 2.0 / 3.0 * self.size.height);
    [self addChild:numberSkiersLabel];
    
    SKLabelNode* SkiersEatenTitleLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    SkiersEatenTitleLabel.fontSize = 40;
    SkiersEatenTitleLabel.fontColor = [SKColor whiteColor];
    SkiersEatenTitleLabel.text = [NSString stringWithFormat:@"Skiers Eaten"];
    SkiersEatenTitleLabel.position = CGPointMake(self.size.width/2, numberSkiersLabel.frame.origin.y - numberSkiersLabel.frame.size.height - 20);
    [self addChild:SkiersEatenTitleLabel];
    
    SKLabelNode* tapLabel = [SKLabelNode labelNodeWithFontNamed:@"Courier"];
    tapLabel.fontSize = 25;
    tapLabel.fontColor = [SKColor whiteColor];
    tapLabel.text = @"(Tap to Play Again)";
    tapLabel.position = CGPointMake(self.size.width/2, SkiersEatenTitleLabel.frame.origin.y - SkiersEatenTitleLabel.frame.size.height - 40);
    [self addChild:tapLabel];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // Intentional no-op
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    SkiMonsterScene* skiScene = [[SkiMonsterScene alloc] initWithSize:self.size];
    skiScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:skiScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
}

@end
