//
//  ViewController.m
//  SkiMonster
//
//  Created by Stevenson on 2/17/14.
//  Copyright (c) 2014 Steven Stevenson. All rights reserved.
//

#import "ViewController.h"
#import "SkiMonsterScene.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewWillLayoutSubviews
{
    SKView *skyMonsterView = (SKView *)self.view;
    skyMonsterView.showsFPS = YES;
    skyMonsterView.showsNodeCount = YES;
    
    SKScene *scene = [SkiMonsterScene sceneWithSize:skyMonsterView.bounds.size];
    scene.backgroundColor = [UIColor whiteColor];
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    [skyMonsterView presentScene:scene];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
