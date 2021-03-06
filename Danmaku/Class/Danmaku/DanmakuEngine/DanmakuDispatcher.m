//
//  DanmakuDispatcher.m
//  Danmaku
//
//  Created by zhudf on 2017/4/22.
//  Copyright © 2017年 lostu.com. All rights reserved.
//

#import "DanmakuDispatcher.h"
#import "DanmakuSprite.h"

@interface DanmakuDispatcher()

@property (nonatomic, strong) NSMutableArray *activeSprites;
@property (nonatomic, strong) NSMutableArray *waitingSprites;
@property (nonatomic, strong) NSMutableArray *deadSprites;

@end

@implementation DanmakuDispatcher

- (instancetype)init
{
    if (self = [super init]) {
        _waitingSprites = @[].mutableCopy;
        _activeSprites  = @[].mutableCopy;
        _deadSprites    = @[].mutableCopy;
    }
    return self;
}

- (void)addSprite:(DanmakuSprite *)sprite
{
    // 以为下边要倒序遍历，所以这里从头插入
    [_waitingSprites insertObject:sprite atIndex:0];
}

- (void)dispatchSprites
{
    // 倒序遍历做 Delete 操作不会 Crash
    for (NSInteger i = _waitingSprites.count - 1; i >= 0; --i) {
        DanmakuSprite *sprite = _waitingSprites[i];
        
        /* 说明：
         * 1）shouldActiveSprite 是个鸡肋，会增加额外的计算，直接 Active 这个
         * Sprite，失败就说明轨道已全部占用
         * 2） 当然，下边 break 的逻辑严格来说是不准确的，每个 Sprite 占用的
         * Strip 个数可能是不一样的，所以逻辑中可以继续遍历小于这个 Strip 数的
         * Sprite
         */
        if ([self.delegate dispatcher:self activeSprite:sprite]) {
            [_waitingSprites removeObject:sprite];
        } else {
            // 1. 如果弹幕高度一样，那就直接 break
            // 2. 如果弹幕高度不一样，只要_watingDanmakus 数不是很大 不 break 也无妨
            
            // 优化：
            // 1. 视情况而定，最好 Danmaku.displaySize 提前计算好
            // 2. 代理返回类型可以要 NSRange 类型，以便能在这里直接 display needStripNumber 更下的弹幕
            break;
        }
    }
}

@end
