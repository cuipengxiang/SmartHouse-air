//
//  SHActiveViewController.h
//  SmartHouse-Air
//
//  Created by Roc on 14-8-19.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SHActiveViewController : UIViewController<UIGestureRecognizerDelegate, UITextFieldDelegate>
{
    UIImageView *activeBox;
    UILabel *titleLable;
    UILabel *summaryLabel;
    UITextField *activeField;
    UIButton *submitButton;
    UILabel *codeLabel;
}

@property (nonatomic, strong)UIImageView *imageView;

@end
