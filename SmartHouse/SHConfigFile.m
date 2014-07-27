//
//  SHConfigFile.m
//  SmartHouse-Air
//
//  Created by Roc on 14-3-5.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHConfigFile.h"
#import "AppDelegate.h"
#import "SHRoomModel.h"
#import "SHModeModel.h"
#import "SHLightModel.h"
#import "SHCurtainModel.h"
#import "SHAirConditioningModel.h"

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
    NSString *file = [documentDirectory stringByAppendingPathComponent:@"test.xml"];
    NSData *data = [NSData dataWithContentsOfFile:file];
    
    TFHpple *hpple = [[TFHpple alloc] initWithXMLData:data encoding:@"utf-8"];
    NSArray *house = [hpple searchWithXPathQuery:@"//House"];
    TFHppleElement *houseElement = [house objectAtIndex:0];
    myDelegate.host1 = [houseElement.attributes objectForKey:@"insidehost"];
    myDelegate.host2 = [houseElement.attributes objectForKey:@"outsidehost"];
    myDelegate.host = myDelegate.host1;
    myDelegate.port = [[houseElement.attributes objectForKey:@"port"] integerValue];

    SHRoomModel *wholeHouse = [[SHRoomModel alloc] init];
    wholeHouse.roomid = [[houseElement attributes] objectForKey:@"id"];
    wholeHouse.name = [[houseElement attributes] objectForKey:@"name"];
    NSArray *houseMode = [hpple searchWithXPathQuery:@"//House/Mode"];
    for (int i = 0; i < houseMode.count; i++) {
        SHModeModel *modeModel = [[SHModeModel alloc] init];
        TFHppleElement *modeElement = [houseMode objectAtIndex:i];
        modeModel.modeid = [[modeElement attributes] objectForKey:@"id"];
        modeModel.name = [[modeElement attributes] objectForKey:@"name"];
        modeModel.modecmd = [[modeElement attributes] objectForKey:@"cmd"];
        modeModel.area = [[modeElement attributes] objectForKey:@"area"];
        [wholeHouse.modes addObject:modeModel];
    }
    
    
    NSArray *rooms = [hpple searchWithXPathQuery:@"//Room"];
    for (int i = 0; i < rooms.count; i++) {
        SHRoomModel *roomModel = [[SHRoomModel alloc] init];
        TFHppleElement *roomElement = [rooms objectAtIndex:i];
        roomModel.name = [[roomElement attributes] objectForKey:@"name"];
        roomModel.roomid = [[roomElement attributes] objectForKey:@"id"];
        
        NSArray *modes = [roomElement searchWithXPathQuery:@"//Mode"];
        for (int j = 0; j < modes.count; j++) {
            SHModeModel *modeModel = [[SHModeModel alloc] init];
            TFHppleElement *modeElement = [modes objectAtIndex:j];
            modeModel.modeid = [[modeElement attributes] objectForKey:@"id"];
            modeModel.name = [[modeElement attributes] objectForKey:@"name"];
            modeModel.modecmd = [[modeElement attributes] objectForKey:@"cmd"];
            modeModel.area = [[modeElement attributes] objectForKey:@"area"];
            [roomModel.modes addObject:modeModel];
        }
        
        NSArray *lights = [roomElement searchWithXPathQuery:@"//Light"];
        for (int j = 0; j < lights.count; j++) {
            SHLightModel *lightModel = [[SHLightModel alloc] init];
            TFHppleElement *lightElement = [lights objectAtIndex:j];
            lightModel.deviceid = [[lightElement attributes] objectForKey:@"id"];
            lightModel.name = [[lightElement attributes] objectForKey:@"name"];
            lightModel.fade = [[lightElement attributes] objectForKey:@"fade"];
            lightModel.area = [[lightElement attributes] objectForKey:@"area"];
            lightModel.channel = [[lightElement attributes] objectForKey:@"channel"];
            [roomModel.lights addObject:lightModel];
            [wholeHouse.lights addObject:lightModel];
        }
        
        NSArray *curtains = [roomElement searchWithXPathQuery:@"//Curtain"];
        for (int j = 0; j < curtains.count; j++) {
            SHCurtainModel *curtainModel = [[SHCurtainModel alloc] init];
            TFHppleElement *curtainElement = [curtains objectAtIndex:j];
            curtainModel.deviceid = [[curtainElement attributes] objectForKey:@"id"];
            curtainModel.name = [[curtainElement attributes] objectForKey:@"name"];
            curtainModel.area = [[curtainElement attributes] objectForKey:@"area"];
            curtainModel.channel = [[curtainElement attributes] objectForKey:@"channel"];
            curtainModel.opencmd = [[curtainElement attributes] objectForKey:@"opencmd"];
            curtainModel.closecmd = [[curtainElement attributes] objectForKey:@"closecmd"];
            curtainModel.stopcmd = [[curtainElement attributes] objectForKey:@"stopcmd"];
            [roomModel.curtains addObject:curtainModel];
            [wholeHouse.curtains addObject:curtainModel];
        }
        
        NSArray *airconditionings = [roomElement searchWithXPathQuery:@"//Air_conditioning"];
        for (int j = 0; j < airconditionings.count; j++) {
            SHAirConditioningModel *airconditioningModel = [[SHAirConditioningModel alloc] init];
            TFHppleElement *airconditioningElement = [airconditionings objectAtIndex:j];
            airconditioningModel.deviceid = [[airconditioningElement attributes] objectForKey:@"id"];
            airconditioningModel.name = [[airconditioningElement attributes] objectForKey:@"name"];
            airconditioningModel.mainaddr = [[airconditioningElement attributes] objectForKey:@"mainaddr"];
            airconditioningModel.secondaryaddr = [[airconditioningElement attributes] objectForKey:@"secondaryaddr"];
            airconditioningModel.modes = [(NSString *)[[airconditioningElement attributes] objectForKey:@"modes"] componentsSeparatedByString:@"|"];
            [roomModel.airconditionings addObject:airconditioningModel];
            [wholeHouse.airconditionings addObject:airconditioningModel];
        }
        
        [myDelegate.models addObject:roomModel];
    }
    [myDelegate.models insertObject:wholeHouse atIndex:0];
}

@end
