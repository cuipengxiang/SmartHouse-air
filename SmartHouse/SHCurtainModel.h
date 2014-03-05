//
//  SHCurtainModel.h
//  SmartHouse-Air
//
//  Created by 衣世倩 on 3/5/14.
//  Copyright (c) 2014 Roc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHCurtainModel : NSObject

@property (nonatomic,strong)NSString *deviceid;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *area;
@property (nonatomic,strong)NSString *channel;
@property (nonatomic,strong)NSString *opencmd;
@property (nonatomic,strong)NSString *closecmd;
@property (nonatomic,strong)NSString *stopcmd;

- (id)init;

@end
