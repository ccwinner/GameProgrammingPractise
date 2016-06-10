//
//  GameScene.m
//  SK_NinJa_Game
//
//  Created by ccwinner on 16/6/9.
//  Copyright (c) 2016年 ccwinner. All rights reserved.
//

#import "GameScene.h"
#import "GameOverScene.h"

typedef NS_OPTIONS(NSUInteger, PhysicsType) {
    PhysicsTypeNone = 1 << 0,
    PhysicsTypeProjectile = 1 << 1,
    PhysicsTypeMonster = 1 << 2,
    PhysicsTypeAll = 1 << 3
};


@interface GameScene ()<SKPhysicsContactDelegate>
{
    NSInteger _monsterKilled;
}
@property (nonatomic, strong) SKSpriteNode *player;

@end

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    self.backgroundColor = [UIColor whiteColor];
    self.physicsWorld.gravity = CGVectorMake(0, 0);
    self.physicsWorld.contactDelegate = self;
    _monsterKilled = 0;
    //player
    self.player.position = CGPointMake(self.size.width * 0.1, self.size.height * 0.5);
    [self addChild:_player];
    
    //monsters
    [self runAction:[SKAction repeatActionForever:
                     [SKAction sequence:@[
                                        [SKAction runBlock:^{
                         [self addMonsters];}],
                                        [SKAction waitForDuration:1.5]
                                          ]]]];
    //    an.autoplayLooped default to YES
    SKAudioNode *an = [[SKAudioNode alloc] initWithFileNamed:@"background-music-aac.caf"];
    an.autoplayLooped = YES;
    [self addChild:an];
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}
#pragma mark - SKPhysicalDelegate
- (void)didBeginContact:(SKPhysicsContact *)contact {
    
    SKPhysicsBody *this = nil;
    SKPhysicsBody *that = nil;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        this = contact.bodyA;
        that = contact.bodyB;
    } else {
        this = contact.bodyB;
        that = contact.bodyA;
    }
    
    if (this.categoryBitMask & PhysicsTypeProjectile && that.categoryBitMask & PhysicsTypeMonster) {
        //做碰撞处理
        [self displayCollision:(SKSpriteNode *)this.node and:(SKSpriteNode *)that.node];
    }
}
#pragma mark - methods
-(void)addMonsters {
    
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    CGFloat arcY = [self getRandom:monster.size.height * 0.5 to:self.size.height - monster.size.height * 0.5];
    monster.position = CGPointMake(self.size.width + monster.size.width, arcY);
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.categoryBitMask = PhysicsTypeMonster;
    monster.physicsBody.collisionBitMask = PhysicsTypeNone;
    monster.physicsBody.contactTestBitMask = PhysicsTypeProjectile;
    [self addChild:monster];
    
    //设置持续显示时间->速度,设置动作结束后从画面中移除
    SKAction *monsterAction = [SKAction moveTo:CGPointMake(-monster.size.width, arcY) duration:[self getRandom:4.0 to:5.0]];
    //是否输赢的逻辑
    SKAction *loseGame = [SKAction runBlock:^{
        SKScene *gs = [[GameOverScene alloc] initWithSize:self.size isWon:NO];
        [self.view presentScene:gs transition:[SKTransition flipHorizontalWithDuration:0.5]];
    }];
    //不移除的话，大量的monster node会快速消耗设备的内存
    SKAction *monsterActionDone = [SKAction removeFromParent];
    //sequence方法让内部的Action按顺序执行
    [monster runAction:[SKAction sequence:@[monsterAction, loseGame, monsterActionDone]]];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //声音
    [self runAction:[SKAction playSoundFileNamed:@"pew-pew-lei.caf" waitForCompletion:NO]];
    //根据触碰的点算出距离，然后从player的位置发射子弹
    UITouch *touch = touches.anyObject;
    CGPoint poi = [touch locationInNode:self];
    
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.player.position;
    
    CGFloat offX = poi.x - projectile.position.x;
    if ( offX <= 0) {
        return; //触控点的位置必须大于子弹的起始位置
    }
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width * 0.5];
    projectile.physicsBody.contactTestBitMask = PhysicsTypeMonster;
    projectile.physicsBody.collisionBitMask = PhysicsTypeNone;
    projectile.physicsBody.categoryBitMask = PhysicsTypeProjectile;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    [self addChild:projectile];
    
    CGFloat tangent = (poi.y - projectile.position.y) / offX;
    CGPoint des = CGPointMake(self.size.width + projectile.position.x, (self.size.width + projectile.position.x) * tangent);
    
    SKAction *moveAction = [SKAction moveTo:des duration:1.5];
    SKAction *completion = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[moveAction, completion]]];
}

-(CGFloat)getRandom:(CGFloat)min to:(CGFloat)max {
    return arc4random_uniform(max - min) + min;
}

- (void)displayCollision:(SKSpriteNode *)nodeA and:(SKSpriteNode *)nodeB {
    [nodeA removeFromParent];
    [nodeB removeFromParent];
    _monsterKilled++;
    _monsterKilled <= 30 ? : [self.view presentScene:[[GameOverScene alloc] initWithSize:self.size isWon:YES] transition:[SKTransition flipHorizontalWithDuration:0.5]];
}
#pragma mark - lazy loads
-(SKSpriteNode *)player {
    if (!_player) {
        _player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
    }
    return _player;
}

@end
