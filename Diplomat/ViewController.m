//
//  ViewController.m
//  Diplomat
//
//  Created by Cloud Dai on 11/5/15.
//  Copyright (c) 2015 Cloud Dai. All rights reserved.
//

#import "ViewController.h"

#import "WeiboProxy.h"
#import "WechatProxy.h"
#import "QQProxy.h"

static enum WXScene kWechatScene = WXSceneSession;

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)wechatLoginAction:(UIButton *)sender
{
  [self loginWithType:kDiplomatTypeWechat];
}

- (IBAction)weiboLoginAction:(UIButton *)sender
{
  [self loginWithType:kDiplomatTypeWeibo];
}

- (IBAction)qqLoginAction:(UIButton *)sender
{
  [self loginWithType:kDiplomatTypeQQ];
}

- (void)loginWithType:(NSString *)type
{
  [[Diplomat sharedInstance] authWithName:type
                                completed:^(id result, NSError *error) {
                                  [self showText:result];
                                  NSLog(@"error: %@", error);
                                }];
}

- (IBAction)shareTextToWeiboAction:(id)sender
{
  [self shareMessage:[self generateImageMessage] type:kDiplomatTypeWeibo];
}

- (IBAction)shareToWeiboAudioAction:(id)sender
{
  [self shareMessage:[self generateMusicMessage] type:kDiplomatTypeWeibo];
}

- (void)shareMessage:(DTMessage *)message type:(NSString *)name
{
  [[Diplomat sharedInstance] share:message
                              name:name
                         completed:^(id result, NSError *error) {
                           [self showText:result];
                         }];
}

- (IBAction)shareVideoToWeiboAction:(id)sender
{
  [self shareMessage:[self generateVideoMessage] type:kDiplomatTypeWeibo];
}

- (void)showText:(id)result
{
  NSString *text = [NSString stringWithFormat:@"%@", result];
  self.contentLabel.text = text;
}

- (IBAction)shareTextToWechat:(id)sender
{
  [self shareMessage:[self generateTextMessage] type:kDiplomatTypeWechat];
}

- (IBAction)sharePictureToWechat:(id)sender
{
  [self shareMessage:[self generateImageMessage] type:kDiplomatTypeWechat];
}

- (IBAction)shareMusicToWechat:(id)sender
{
  [self shareMessage:[self generateMusicMessage] type:kDiplomatTypeWechat];
}

- (IBAction)shareVideoToWechat:(id)sender
{
  [self shareMessage:[self generateVideoMessage] type:kDiplomatTypeWechat];
}

- (IBAction)shareTextToQQAction:(id)sender
{
  [self shareMessage:[self generateTextMessage] type:kDiplomatTypeQQ];
}

- (IBAction)shareImageToQQAction:(id)sender
{
  [self shareMessage:[self generateImageMessage] type:kDiplomatTypeQQ];
}

- (IBAction)shareMusicToQQAction:(id)sender
{
  [self shareMessage:[self generateMusicMessage] type:kDiplomatTypeQQ];
}

- (IBAction)shareVideoToQQAction:(id)sender
{
  [self shareMessage:[self generateVideoMessage] type:kDiplomatTypeQQ];
}

- (IBAction)shareNewsToQQAction:(id)sender
{
  [self shareMessage:[self generateWebPageMessage] type:kDiplomatTypeQQ];
}

- (DTMessage *)generateTextMessage
{
  DTTextMessage *message = [[DTTextMessage alloc] init];
  message.text = @"Hello world!";
  message.userInfo = @{kWechatSceneTypeKey: @(kWechatScene)};

  return message;
}

- (DTMessage *)generateImageMessage
{
  DTImageMessage *message = [[DTImageMessage alloc] init];
  message.title = @"我的头像";
  message.desc = @"我在分享我的头像来做测试";
  message.imageData = UIImageJPEGRepresentation([UIImage imageNamed:@"IMG_0965.jpg"], 0.75);;
  message.thumbnailableImage = [UIImage imageNamed:@"IMG_0965.jpg"];
  message.userInfo = @{kWechatSceneTypeKey: @(kWechatScene)};

  return message;
}

- (DTMessage *)generateMusicMessage
{
  DTAudioMessage *message = [[DTAudioMessage alloc] init];
  message.messageId = @"79jklfdja89u8klmkl98";
  message.title = @"成功闯关";
  message.desc = @"成功过关！我在玩#英语流利说#闯关之#逛超市#，每次说完英语都有种欲言又止、意犹未尽的感觉，小宇宙马上就要爆发啦。来听听我的伦敦郊区音";
  message.audioUrl = @"http://share.liulishuo.com/v2/share/8a6d90f0dcfa013245d752540071c562";
  message.audioDataUrl = @"http://cdn.llsapp.com/54251c18636d734cc90b4900_Zjk0MWQwMDAwMDBiODdlNQ==_1431672097.mp3";
  message.thumbnailableImage = [UIImage imageNamed:@"IMG_0965_thumb.png"];
  message.userInfo = @{kWechatSceneTypeKey: @(kWechatScene), kTencentQQSceneTypeKey: @(TencentSceneZone)};

  return message;
}

- (DTMessage *)generateVideoMessage
{
  DTVideoMessage *message = [[DTVideoMessage alloc] init];
  message.messageId = @"79jklfdja89u8klmkl98";
  message.title = @"奥迪Audi Q7全方位展示 Ara Blue";
  message.desc = @"奥迪Audi Q7全方位展示 Ara Blue 奥迪Audi Q7全方位展示 Ara Blue 奥迪Audi Q7全方位展示 Ara Blue。";
  message.videoUrl = @"http://v.youku.com/v_show/id_XOTU0NzkzMDM2.html";
  message.videoDataUrl = @"http://player.youku.com/embed/XOTU0NzkzMDM2";
  message.thumbnailableImage = [UIImage imageNamed:@"IMG_0965_thumb.png"];
  message.userInfo = @{kWechatSceneTypeKey: @(kWechatScene)};

  return message;
}

- (DTMessage *)generateWebPageMessage
{
  DTPageMessage *message = [[DTPageMessage alloc] init];
  message.title = @"一段新闻";
  message.desc = @"一段新闻的描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述描述.";
  message.webPageUrl = @"http://www.pingwest.com/can-machine-replace-sense-of-touch/";
  message.userInfo = @{kWechatSceneTypeKey: @(kWechatScene)};

  return message;
}
@end
