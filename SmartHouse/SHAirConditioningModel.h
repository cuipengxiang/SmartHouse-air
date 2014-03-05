//
//  SHAirConditioningModel.h
//  SmartHouse-Air
//
//  Created by 衣世倩 on 3/5/14.
//  Copyright (c) 2014 Roc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHAirConditioningModel : NSObject

@property (nonatomic,strong)NSString *deviceid;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *mainaddr;
@property (nonatomic,strong)NSString *secondaryaddr;
@property (nonatomic,strong)NSArray *modes;

- (id)init;

@end
