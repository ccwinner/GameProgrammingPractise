//
//  GameOverScene.m
//  SK_NinJa_Game
//
//  Created by ccwinner on 16/6/10.
//  Copyright © 2016年 ccwinner. All rights reserved.
//

#import "GameOverScene.h"

@implementation GameOverScene

- (instancetype)initWithSize:(CGSize)size isWon:(BOOL)win{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [UIColor whiteColor];
        SKLabelNode *ln = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        ln.text = win ? @"You Win!" : @"You Lose!";
        ln.fontSize = 40;
        ln.fontColor = [UIColor blueColor];
        ln.position = CGPointMake(size.width * 0.5, size.height * 0.5);
        [self addChild:ln];
    }
    return self;
}


@end
