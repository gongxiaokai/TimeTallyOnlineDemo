//
//  RegisterViewController.m
//  TimeTallyDemoOnline
//
//  Created by gongwenkai on 2017/1/12.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()<ServerOperationsDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPswField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"注册";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//输入检查 6-20为正常字符
- (BOOL)inputCheck:(NSString*)passWord{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
    
}

- (void)didRegisterBackWithTag:(int)tag{
    [self loginAlertWithReslut:tag];
}


//提交注册
- (IBAction)clickRegister:(id)sender {
    
    //输入检查
    BOOL userNameCheck = [self inputCheck:self.userNameField.text];
    BOOL userPswCheck = [self inputCheck:self.userPswField.text];
    if (!userNameCheck | !userPswCheck) {
        [self showAlertInfoWithTag:0 andMessage:@"用户名或密码出错\n请输入6-20位合法字符"];
        return;
    }
    
    //取消键盘响应
    [self.userNameField resignFirstResponder];
    [self.userPswField resignFirstResponder];

    ServerOperations *ops = [ServerOperations sharedInstance];
    ops.delegate = self;
    [ops registerWithUser:self.userNameField.text andPsw:self.userPswField.text];
}


//登录提示
- (void)loginAlertWithReslut:(int)result{
    switch (result) {
        case 0:
            //连接远程数据库失败
            [self showAlertInfoWithTag:0 andMessage:@"连接远程数据库失败"];
            break;
        case 1:
            //注册成功
            [self showAlertInfoWithTag:1 andMessage:@"注册成功"];
            break;
        case 2:
            //注册失败 用户已经存在
            [self showAlertInfoWithTag:2 andMessage:@"注册失败\n用户已经存在"];
            break;
        default:
            break;
    }
}

//弹出提示框
- (void)showAlertInfoWithTag:(int)tag andMessage:(NSString*)message {
    UIAlertController *alertVC =[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    if (tag == 1) {
        [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [[NSUserDefaults standardUserDefaults] setObject:self.userNameField.text forKey:@"userName"];
            [self.navigationController popViewControllerAnimated:YES];
        }]];

    }else{
        [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];

    }
    [self presentViewController:alertVC animated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
