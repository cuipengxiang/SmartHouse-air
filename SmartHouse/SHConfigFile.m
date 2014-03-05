//
//  SHConfigFile.m
//  SmartHouse-Air
//
//  Created by Roc on 14-3-5.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHConfigFile.h"
#import "AppDelegate.h"

@implementation SHConfigFile
    
- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)readFile
{
    AppDelegate *myDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (!myDelegate.models) {
        myDelegate.models = [[NSMutableArray alloc] init];
    }
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSString *file = [documentDirectory stringByAppendingPathComponent:@"test1.txt"];
    NSError *error;
    
    NSString *filecontent = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:&error];
    
}

@end
