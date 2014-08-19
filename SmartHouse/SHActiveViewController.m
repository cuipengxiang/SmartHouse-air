//
//  SHActiveViewController.m
//  SmartHouse-Air
//
//  Created by Roc on 14-8-19.
//  Copyright (c) 2014年 Roc. All rights reserved.
//

#import "SHActiveViewController.h"
#import "SHLoginViewController.h"

@interface SHActiveViewController ()

@end

@implementation SHActiveViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 1024, 768)];
    [self.imageView setImage:[UIImage imageNamed:@"login_bg"]];
    [self.view addSubview:self.imageView];
    
    activeBox = [[UIImageView alloc] initWithFrame:CGRectMake(275.5, 100.0, 473.0, 493.0)];
    //[activeBox setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"active_box_bg"]]];
    [activeBox setImage:[UIImage imageNamed:@"active_box_bg"]];
    [self.imageView addSubview:activeBox];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouch)];
    [gesture setNumberOfTouchesRequired:1];
    [gesture setNumberOfTapsRequired:1];
    [gesture setDelegate:self];
    [self.view addGestureRecognizer:gesture];
    
    titleLable = [[UILabel alloc] initWithFrame:CGRectMake(275.5, 128.0, 473.0, 40.0)];
    [titleLable setBackgroundColor:[UIColor clearColor]];
    [titleLable setTextAlignment:NSTextAlignmentCenter];
    [titleLable setTextColor:[UIColor colorWithRed:0.702 green:0.310 blue:0.149 alpha:1]];
    [titleLable setFont:[UIFont systemFontOfSize:34.0]];
    [titleLable setText:@"获取激活码"];
    [self.view addSubview:titleLable];
    
    codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(275.5, 230.0, 473.0, 45.0)];
    [codeLabel setBackgroundColor:[UIColor clearColor]];
    [codeLabel setTextAlignment:NSTextAlignmentCenter];
    [codeLabel setTextColor:[UIColor colorWithRed:0.702 green:0.310 blue:0.149 alpha:1]];
    [codeLabel setFont:[UIFont systemFontOfSize:40.0]];
    [codeLabel setText:@"1 2 3 4 5 6"];
    [self.view addSubview:codeLabel];
    
    summaryLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    [summaryLabel setNumberOfLines:0];
    NSString *summary = @"发送上面的数字到13912345678获取验证码并填入下方输入框中";
    UIFont *font = [UIFont systemFontOfSize:26.0];
    CGSize size = CGSizeMake(423.0, 90.0);
    CGSize labelsize = [summary sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByCharWrapping];
    [summaryLabel setFrame:CGRectMake(300.5, 300.0, labelsize.width, labelsize.height)];
    [summaryLabel setTextAlignment:NSTextAlignmentCenter];
    [summaryLabel setBackgroundColor:[UIColor clearColor]];
    [summaryLabel setFont:font];
    [summaryLabel setTextColor:[UIColor colorWithRed:0.714 green:0.267 blue:0.086 alpha:1]];
    [summaryLabel setText:summary];
    [self.view addSubview:summaryLabel];

    activeField = [[UITextField alloc] initWithFrame:CGRectMake(323.5, 400.0, 376.0, 63.0)];
    [activeField setBackground:[UIImage imageNamed:@"active_input"]];
    [activeField setFont:[UIFont systemFontOfSize:40.0]];
    [activeField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [activeField setTextColor:[UIColor colorWithRed:0.714 green:0.267 blue:0.086 alpha:1]];
    [activeField setTextAlignment:NSTextAlignmentCenter];
    [activeField setDelegate:self];
    [self.view addSubview:activeField];
    
    submitButton = [[UIButton alloc] initWithFrame:CGRectMake(318.5, 486.0, 386.0, 74.0)];
    [submitButton setBackgroundImage:[UIImage imageNamed:@"btn_active_normal"] forState:UIControlStateNormal];
    [submitButton setBackgroundImage:[UIImage imageNamed:@"btn_active_pressed"] forState:UIControlStateHighlighted];
    [submitButton addTarget:self action:@selector(onSubmitClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:submitButton];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShow:)name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidHide:)name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(id)sender
{
    [activeBox setFrame:CGRectMake(275.5, -60.0, 473.0, 493.0)];
    [titleLable setFrame:CGRectMake(275.5, -32.0, 473.0, 40.0)];
    [codeLabel setFrame:CGRectMake(275.5, 70.0, 473.0, 45.0)];
    [summaryLabel setFrame:CGRectMake(300.5, 140.0, summaryLabel.frame.size.width, summaryLabel.frame.size.height)];
    [activeField setFrame:CGRectMake(323.5, 240.0, 376.0, 63.0)];
    [submitButton setFrame:CGRectMake(318.5, 326.0, 386.0, 74.0)];
}

- (void)keyboardDidHide:(id)sender
{
    [activeBox setFrame:CGRectMake(275.5, 100.0, 473.0, 493.0)];
    [titleLable setFrame:CGRectMake(275.5, 128.0, 473.0, 40.0)];
    [codeLabel setFrame:CGRectMake(275.5, 230.0, 473.0, 45.0)];
    [summaryLabel setFrame:CGRectMake(300.5, 300.0, summaryLabel.frame.size.width, summaryLabel.frame.size.height)];
    [activeField setFrame:CGRectMake(323.5, 400.0, 376.0, 63.0)];
    [submitButton setFrame:CGRectMake(318.5, 486.0, 386.0, 74.0)];
}

- (void)onSubmitClicked
{
    SHLoginViewController *loginController = [[SHLoginViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:loginController animated:YES completion:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [activeField setBackground:[UIImage imageNamed:@"active_input_focused"]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

- (void)onTouch
{
    [activeField resignFirstResponder];
    if (activeField.text.length == 0) {
        [activeField setBackground:[UIImage imageNamed:@"input_box"]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
