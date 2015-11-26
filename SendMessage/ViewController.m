//
//  ViewController.m
//  SendMessage
//
//  Created by 叶永长 on 11/25/15.
//  Copyright © 2015 YYC. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <Foundation/Foundation.h>
#import "TKAddressBook.h"
#import "YCAddressListCell.h"
#import <MessageUI/MessageUI.h>
#import "pinyin.h"
@interface ViewController ()<MFMessageComposeViewControllerDelegate,UITableViewDataSource,UITableViewDelegate>
{
    UITableView *mainTableView;
    
    NSMutableArray *userMessageArray;
}
@property (nonatomic,strong)NSMutableDictionary * dataDic;
@property (nonatomic,strong)NSMutableArray * dataLine;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    _dataDic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@[@"其他"],@"其它", nil];
    _dataLine = [[NSMutableArray alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
    userMessageArray = [[NSMutableArray alloc]init];
    
    [self CopyAddressList];
    [self CreatMainView];
}

-(void)CreatMainView{
    mainTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, self.view.bounds.size.height)];
    mainTableView.delegate = self;
    mainTableView.dataSource = self;
    [self.view addSubview:mainTableView];
}
-(void)CopyAddressList{
    ABAddressBookRef addressBook = nil;
    addressBook = ABAddressBookCreateWithOptions(nil, nil);
    dispatch_semaphore_t sema = dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    
    CFArrayRef allpeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    NSLog(@"%ld",nPeople);
    for (NSInteger i = 0; i<nPeople; i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(allpeople, i);
        
        CFTypeRef abName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
        NSString *stringName = (__bridge NSString *)(abName);
        NSLog(@"firstName%@\n",stringName);
        
        CFTypeRef abLastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
        NSString *lastName = (__bridge NSString *)(abLastName);
        NSLog(@"lastName%@\n",lastName);
        
        CFTypeRef abFullName = ABRecordCopyCompositeName(person);
        NSString *fullName = (__bridge NSString *)(abFullName);
        NSLog(@"fullName全名%@",fullName);
        
        TKAddressBook *address = [[TKAddressBook alloc]init];
        address.name = fullName;
        address.recordID = (int)ABRecordGetRecordID(person);
        ABPropertyID multiproperties[] = {
            kABPersonPhoneProperty,
            kABPersonEmailProperty
        };
        NSInteger multipropertiesTotal = sizeof(multiproperties)/sizeof(ABPropertyID);
        for (NSInteger j = 0; j<multipropertiesTotal; j++) {
            ABPropertyID property = multiproperties[j];
            ABMultiValueRef valuesRef = ABRecordCopyValue(person, property);
            NSInteger valueCount = 0;
            if (valuesRef != nil) {
                valueCount = ABMultiValueGetCount(valuesRef);
            }
            if (valueCount == 0) {
                CFRelease(valuesRef);
                continue;
            }
            for (NSInteger k = 0; k<valueCount; k++) {
                CFTypeRef value = ABMultiValueCopyValueAtIndex(valuesRef, k);
                switch (j) {
                    case 0:{
                        address.tel = (__bridge NSString *)(value);
                        break;
                    }
                    case 1:{
                        address.email = (__bridge NSString *)(value);
                        break;
                    }
                    default:
                        break;
                }
            }
            NSLog(@"addressbook邮箱地址：%@\n手机号码：%@\n姓名：%@",address.email,address.tel,fullName);
        }
        address.pinyinFirst = [fullName uppercasePinYinFirstLetter];
        const char  temKeyChar = *[address.pinyinFirst UTF8String];
        int temKey = (int)temKeyChar;
        if ([self.dataDic objectForKey:address.pinyinFirst]==nil) {
            NSArray * ary = @[address];
            if (temKey<65 || temKey>90) {
                [self.dataDic setObject:ary forKey:@"其它"];
            }else{
                [self.dataDic setObject:ary forKey:address.pinyinFirst];
            }
        }else{
            if (temKey>64 && temKey<91) {
                NSMutableArray * ary = [NSMutableArray arrayWithArray:[self.dataDic objectForKey:address.pinyinFirst]];
                [ary addObject:address];
                [self.dataDic setObject:ary forKey:address.pinyinFirst];
            }else{
                NSMutableArray * ary = [NSMutableArray arrayWithArray:[self.dataDic objectForKey:@"其它"]];
                [ary addObject:address];
                [self.dataDic setObject:ary forKey:address.pinyinFirst];
                
            }
        }
        
        [userMessageArray addObject:address];
        
    }
    for (int i = 0; i<26; i++) {
        if ([self.dataDic objectForKey:[NSString stringWithFormat:@"%c",i+65]]!=nil) {
            [self.dataLine addObject:[NSString stringWithFormat:@"%c",i+65]];
        }
    }
    if ([self.dataDic objectForKey:@"其它"]!=nil) {
        [self.dataLine addObject:@"其它"];
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSString * key = self.dataLine[section];
    return [[self.dataDic objectForKey:key] count];
}
//几个分区
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataDic.count;//26个字母加一个其它
}
//分区头内容
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return self.dataLine[section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *idefineCell  =@"idefineCell";
    YCAddressListCell *cell = [tableView dequeueReusableCellWithIdentifier:idefineCell];
    if (nil == cell) {
        cell = [[YCAddressListCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idefineCell];
    }
    
    NSArray * array = [self.dataDic objectForKey:self.dataLine[indexPath.section]];
    //    NSLog(@"%ld",indexPath.row);
    TKAddressBook * address = [array objectAtIndex:indexPath.row];
    if ([address  isEqual:@"其他"]) {
        
    }else{
        cell.nameLabel.text = address.name;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray * array = [self.dataDic objectForKey:self.dataLine[indexPath.section]];
    TKAddressBook * address = [array objectAtIndex:indexPath.row];
    NSArray *aaaarray = [NSArray arrayWithObjects:address.tel, nil];
    if ([MFMessageComposeViewController canSendText]) {
        [self displaySMSComposerSheet:aaaarray];
    }else{
        NSLog(@"不能发送");
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"请在真机上测试" message:@"模拟器不支持短信功能" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
        [alertView show];
    }
}
-(void)displaySMSComposerSheet:(NSArray *)array{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.body = @"编辑短信内容";
    picker.recipients = array;
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    switch (result) {
        case MessageComposeResultSent:
        {
            
        }
            break;
        case MessageComposeResultFailed:{
            
        }
            break;
        case MessageComposeResultCancelled:{
            
        }
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return self.dataLine;
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
