//
//  MonsterPlayer.m
//  SkiMonster
//
//  Created by Stevenson on 2/19/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "MonsterPlayer.h"

@implementation MonsterPlayer

+(id) spriteNodeWithImageNamed:(NSString *)name
{
    MonsterPlayer *monster = [super spriteNodeWithImageNamed:name];
    if (monster) {
        CGSize monsterSize = monster.size;
        monsterSize = CGSizeMake(monsterSize.width*.4, monsterSize.width*.4);
        monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monsterSize];
        monster.physicsBody.dynamic = YES;
        monster.physicsBody.allowsRotation = NO;
        monster.physicsBody.affectedByGravity = NO;
        monster.physicsBody.collisionBitMask = 0x0;
        monster.zPosition = 5;
        monster.name = @"Monster";
    }
    return monster;
}



@end
