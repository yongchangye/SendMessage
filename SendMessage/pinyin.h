/*
 *  pinyin.h
 *  Chinese Pinyin First Letter
 *
 *  Created by George on 4/21/10.
 *  Copyright 2010 RED/SAFI. All rights reserved.
 *
 */

/*
 * // Example
 *
 * #import "pinyin.h"
 *
 * NSString *hanyu = @"中国共产党万岁！";
 * for (int i = 0; i < [hanyu length]; i++)
 * {
 *     printf("%c", pinyinFirstLetter([hanyu characterAtIndex:i]));
 * }
 *
 */


/*

 *  Add two method for NSString class in category format.
 *  -uppercasePinYinFirstLetter
 *  -lowercasePinYinFirstLetter
 *
 *  // Example
 *  #import "pinyin.h"
 *  NSString *hanyu = @"中国共产党万岁！";
 *  NSLog(@"%@",[hanyu uppercasePinYinFirstLetter]);//Z
 *  NSLog(@"%@",[hanyu lowercasePinYinFirstLetter]);//z
 *
 */

#import <UIKit/UIKit.h>



#define ALPHA	@"ABCDEFGHIJKLMNOPQRSTUVWXYZ#"
char pinyinFirstLetter(unsigned short hanzi);


@interface NSString(FirstLetter)


- (NSString *) uppercasePinYinFirstLetter;
- (NSString *) lowercasePinYinFirstLetter;


@end