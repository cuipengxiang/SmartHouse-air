//
//  SHModeModel.h
//  SmartHouse-Air
//
//  Created by 衣世倩 on 3/5/14.
//  Copyright (c) 2014 Roc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHModeModel : NSObject

@property (nonatomic,strong)NSString *modeid;
@property (nonatomic,strong)NSString *name;
@property (nonatomic,strong)NSString *area;
@property (nonatomic,strong)NSString *modecmd;

- (id)init;

@end
