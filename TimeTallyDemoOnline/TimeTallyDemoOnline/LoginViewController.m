//
//  LoginViewController.m
//  TimeTallyDemoOnline
//
//  Created by gongwenkai on 2017/1/12.
//  Copyright © 2017年 gongwenkai. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()<ServerOperationsDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *userPswField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"登录";
    [[CoreDataOperations sharedInstance] loadTallyTypeToSqlite];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    self.userNameField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    self.userPswField.text = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//去注册
- (IBAction)clickRegister:(id)sender {
    [self.userPswField resignFirstResponder];
    [self.userPswField resignFirstResponder];
}

//输入检查 6-20为正常字符
- (BOOL)inputCheck:(NSString*)passWord{
    NSString *passWordRegex = @"^[a-zA-Z0-9]{6,20}+$";
    NSPredicate *passWordPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",passWordRegex];
    return [passWordPredicate evaluateWithObject:passWord];
    
}

//去登录
- (IBAction)clickLogin:(id)sender {
    
    //输入检查
    BOOL userNameCheck = [self inputCheck:self.userNameField.text];
    BOOL userPswCheck = [self inputCheck:self.userPswField.text];
    if (!userNameCheck | !userPswCheck) {
        [self showAlertInfoWithTag:999 andMessage:@"用户名或密码出错\n请输入6-20位合法字符"];
        return;
    }
    //键盘收起
    [self.userPswField resignFirstResponder];
    [self.userNameField resignFirstResponder];
    
    ServerOperations *op = [ServerOperations sharedInstance];
    op.delegate = self;
    [op loginWithUser:self.userNameField.text andPsw:self.userPswField.text];
}

//登录结果
- (void)didLoginBackWithTag:(int)tag{
    [self loginAlertWithReslut:tag];
}

//验证登录
- (void)loginAlertWithReslut:(int)result{
    switch (result) {
        case 0:
            //连接远程数据库失败
            [self showAlertInfoWithTag:result andMessage:@"连接远程数据库失败"];
            break;
        case 1:
            //验证成功
            [self performSegueWithIdentifier:@"toHome" sender:nil];
            break;
        case 2:
            //密码错误
            [self showAlertInfoWithTag:result andMessage:@"密码错误"];
            break;
        case 3:
            //用户不存在
            [self showAlertInfoWithTag:result andMessage:@"用户名不存在\n请注册"];
            break;
        default:
            break;
    }
}

//弹出提示框
- (void)showAlertInfoWithTag:(int)tag andMessage:(NSString*)message {
    UIAlertController *alertVC =[UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
    if (tag == 3) {
        [alertVC addAction:[UIAlertAction actionWithTitle:@"注册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self performSegueWithIdentifier:@"toRegister" sender:nil];
        }]];
    }
    [self presentViewController:alertVC animated:YES completion:nil];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    NSLog(@"准备push");
    //本地保存用户名
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoaded"];
    [[NSUserDefaults standardUserDefaults] setObject:self.userNameField.text forKey:@"userName"];
    
}
@end
