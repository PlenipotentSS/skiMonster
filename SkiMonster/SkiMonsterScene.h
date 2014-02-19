//
//  SkiMonsterScene.h
//  SkiMonster
//
//  Created by Stevenson on 2/17/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//


#import <SpriteKit/SpriteKit.h>

typedef enum objectMaskCategories
{
    COLLISION_CATEGORY_OBSTACLE     = 0x1 << 0,
    COLLISION_CATEGORY_FOOD         = 0x1 << 1,
    COLLISION_CATEGORY_MONSTER      = 0x1 << 2
} CollisionMaskCategories;

@interface SkiMonsterScene : SKScene

@end
