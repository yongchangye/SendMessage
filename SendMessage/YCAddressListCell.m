//
//  YCAddressListCell.m
//  NewYoungCommunity
//
//  Created by 叶永长 on 5/29/15.
//  Copyright (c) 2015 YYC. All rights reserved.
//

#import "YCAddressListCell.h"

@implementation YCAddressListCell

- (void)awakeFromNib {
    // Initialization code
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self creatMainCell];
    }
    return self;
}

-(void)creatMainCell{
    self.headImage  = [[UIImageView alloc]initWithFrame:CGRectMake(16, 6, 49, 49)];
    [self.headImage setImage:[UIImage imageNamed:@"userDefine"]];
    [self addSubview:self.headImage];
    
    self.nameLabel =[[UILabel alloc]initWithFrame:CGRectMake(self.headImage.bounds.size.width+13+20, 22, 200, 20)];
    self.nameLabel.font = [UIFont systemFontOfSize:15];
    self.nameLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.nameLabel];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
