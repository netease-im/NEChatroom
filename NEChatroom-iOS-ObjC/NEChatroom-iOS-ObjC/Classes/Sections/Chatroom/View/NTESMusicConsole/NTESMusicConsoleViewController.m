//
//  NTESMusicConsoleViewController.m
//  NEChatroom-iOS-ObjC
//
//  Created by Wenchao Ding on 2021/1/28.
//  Copyright © 2021 netease. All rights reserved.
//
//  调音台

#import "NTESMusicConsoleViewController.h"
#import "NTESRtcConfig.h"
#import <NERtcSDK/NERtcSDK.h>

@interface NTESMusicConsoleViewController ()<UITableViewDataSource,UITableViewDelegate>

// 列表
@property (nonatomic, strong) UITableView *tableView;

// 耳返
@property (nonatomic, strong) UITableViewCell *earbackCell;

// 耳返开关
@property (nonatomic, strong) UISwitch *earbackSwitch;

// 采集
@property (nonatomic, strong) UITableViewCell *recordVolumeCell;

// 采集拖动条
@property (nonatomic, strong) UISlider *recordVolumeSlider;

// 伴音
@property (nonatomic, strong) UITableViewCell *audioMixingVolumeCell;

// 伴音拖动条
@property (nonatomic, strong) UISlider *audioMixingVolumeSlider;

// 单元格总和
@property (nonatomic, copy) NSArray<UITableViewCell *> *cells;

// 高度
@property (nonatomic, copy) NSArray<NSNumber *> *heights;

// 上下文
@property (nonatomic, strong) NTESChatroomDataSource *context;

// 耳返
- (void)earbackAction:(UISwitch *)sender;

// 采集音量
- (void)recordVolumeAction:(UISlider *)sender;

// 伴音音量
- (void)audioMixingVolumeAction:(UISlider *)sender;

@end

@implementation NTESMusicConsoleViewController

- (instancetype)initWithContext:(NTESChatroomDataSource *)context {
    self = [super init];
    if (self) {
        self.context = context;
    }
    return self;
}

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
    view.backgroundColor = UIColor.whiteColor;
    self.view = view;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.scrollEnabled = NO;
    self.tableView.tableFooterView = UIView.new;
    self.tableView.allowsSelection = NO;
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20);
    self.tableView.clipsToBounds = YES;
    self.tableView.separatorColor = [UIColor.lightGrayColor colorWithAlphaComponent:0.4];
    [self.view addSubview:self.tableView];

    // 耳返
    self.earbackSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    [self.earbackSwitch addTarget:self action:@selector(earbackAction:) forControlEvents:UIControlEventValueChanged];
    self.earbackCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    self.earbackCell.accessoryView = self.earbackSwitch;
    self.earbackCell.textLabel.text = @"耳返";
    self.earbackCell.textLabel.font = [UIFont systemFontOfSize:14];
    self.earbackCell.detailTextLabel.text = @"插入耳机后可使用耳返功能";
    self.earbackCell.detailTextLabel.font = [UIFont systemFontOfSize:12];
    self.earbackCell.detailTextLabel.textColor = UIColor.lightGrayColor;
    
    // 人声
    self.recordVolumeSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [self.recordVolumeSlider setThumbImage:[UIImage imageNamed:@"icon_music_console_slider_thumb"] forState:UIControlStateNormal];
    [self.recordVolumeSlider addTarget:self action:@selector(recordVolumeAction:) forControlEvents:UIControlEventValueChanged];
    self.recordVolumeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.recordVolumeCell.textLabel.text = @"人声";
    self.recordVolumeCell.textLabel.font = [UIFont systemFontOfSize:14];
    [self.recordVolumeCell.contentView addSubview:self.recordVolumeSlider];
    
    // 伴奏
    self.audioMixingVolumeSlider = [[UISlider alloc] initWithFrame:CGRectZero];
    [self.audioMixingVolumeSlider setThumbImage:[UIImage imageNamed:@"icon_music_console_slider_thumb"] forState:UIControlStateNormal];
    [self.audioMixingVolumeSlider addTarget:self action:@selector(audioMixingVolumeAction:) forControlEvents:UIControlEventValueChanged];
    self.audioMixingVolumeCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    self.audioMixingVolumeCell.textLabel.text = @"伴奏";
    self.audioMixingVolumeCell.textLabel.font = [UIFont systemFontOfSize:14];
    [self.audioMixingVolumeCell.contentView addSubview:self.audioMixingVolumeSlider];

    // 表格
    self.cells = @[self.earbackCell, self.recordVolumeCell, self.audioMixingVolumeCell];
    self.heights = @[@64,@49,@49];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"调音台";
    self.earbackSwitch.on = self.context.rtcConfig.earbackOn;
    self.recordVolumeSlider.maximumValue = 400;
    self.recordVolumeSlider.value = self.context.rtcConfig.audioRecordVolume;
    self.audioMixingVolumeSlider.maximumValue = 100;
    self.audioMixingVolumeSlider.value = self.context.rtcConfig.audioMixingVolume;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
    
    CGFloat height = 22.0;
    CGFloat top = 46.0/2-height/2;
    self.recordVolumeCell.textLabel.frame = CGRectMake(20, top, 50, height);
    self.audioMixingVolumeCell.textLabel.frame = CGRectMake(20, top, 50, height);
    
    CGFloat sliderWidth = self.tableView.bounds.size.width-90;
    self.recordVolumeSlider.frame = CGRectMake(CGRectGetMaxX(self.recordVolumeCell.textLabel.frame), top, sliderWidth, height);
    self.audioMixingVolumeSlider.frame = CGRectMake(CGRectGetMaxX(self.audioMixingVolumeCell.textLabel.frame), top, sliderWidth, height);
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (CGSize)preferredContentSize {
    CGFloat preferedHeight = 0;
    if (@available(iOS 11.0, *)) {
        CGFloat safeAreaBottom = UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
        preferedHeight += safeAreaBottom;
    }
    preferedHeight += [[self.heights valueForKeyPath:@"@sum.self"] doubleValue];
    preferedHeight += 20;
    return CGSizeMake(self.navigationController.view.bounds.size.width, preferedHeight);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cells[indexPath.row];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.heights[indexPath.row].doubleValue;
}

- (void)earbackAction:(UISwitch *)sender {
    self.context.rtcConfig.earbackOn = sender.on;
}

- (void)recordVolumeAction:(UISlider *)sender {
    self.context.rtcConfig.audioRecordVolume = sender.value;
}

- (void)audioMixingVolumeAction:(UISlider *)sender {
    self.context.rtcConfig.audioMixingVolume = sender.value;
    self.context.rtcConfig.effectVolume = sender.value;
    [NERtcEngine.sharedEngine setAudioMixingSendVolume:self.context.rtcConfig.audioMixingVolume];
    [NERtcEngine.sharedEngine setAudioMixingPlaybackVolume:self.context.rtcConfig.audioMixingVolume];
}

@end
