//
//  TKAddressBook.h
//  NewYoungCommunity
//
//  Created by 叶永长 on 5/29/15.
//  Copyright (c) 2015 YYC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TKAddressBook : NSObject
@property (nonatomic,strong)NSString *name;
@property (nonatomic,assign)int recordID;
@property (nonatomic,strong)NSString *tel;
@property (nonatomic,strong)NSString *email;
@property (nonatomic,strong)NSString *pinyinFirst;
@end
