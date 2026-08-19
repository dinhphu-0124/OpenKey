
#import "AppDelegate.h"
#import "ConvertToolViewController.h"
#import "OpenKeyManager.h"
#import "ConvertTool.h"

extern AppDelegate* appDelegate;

@interface ConvertToolViewController ()

@end

@implementation ConvertToolViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.SHotKey.Parent = self;
    [self fillData];
    
    // Apply modern macOS native icons
    if (@available(macOS 11.0, *)) {
        NSImageSymbolConfiguration *config = [NSImageSymbolConfiguration configurationWithPointSize:12 weight:NSFontWeightMedium];
        NSImage *convertImg = [NSImage imageWithSystemSymbolName:@"arrow.triangle.2.circlepath" accessibilityDescription:@"Chuyển mã"];
        if (convertImg) {
            self.ConvertButton.image = [convertImg imageWithSymbolConfiguration:config];
            self.ConvertButton.imagePosition = NSImageLeft;
        }
        NSImage *closeImg = [NSImage imageWithSystemSymbolName:@"xmark.circle" accessibilityDescription:@"Đóng"];
        if (closeImg) {
            self.OKButton.image = [closeImg imageWithSymbolConfiguration:config];
            self.OKButton.imagePosition = NSImageLeft;
        }
    } else {
        self.ConvertButton.image = [NSImage imageNamed:NSImageNameRefreshTemplate];
        self.OKButton.image = [NSImage imageNamed:NSImageNameStopProgressFreestandingTemplate];
    }
}

-(void)fillData {
    NSArray* codeData = [OpenKeyManager getTableCodes];
    [self.FromCode removeAllItems];
    [self.FromCode addItemsWithTitles:codeData];
    [self.ToCode removeAllItems];
    [self.ToCode addItemsWithTitles:codeData];
    
    self.AlertWhenComplete.state = !convertToolDontAlertWhenCompleted ? NSControlStateValueOn : NSControlStateValueOff;
    
    self.ToAllCaps.state = convertToolToAllCaps ? NSControlStateValueOn : NSControlStateValueOff;
    self.ToNonCaps.state = convertToolToAllNonCaps ? NSControlStateValueOn : NSControlStateValueOff;
    self.ToCapsFirstLetter.state = convertToolToCapsFirstLetter ? NSControlStateValueOn : NSControlStateValueOff;
    self.ToCapsCharEachWord.state = convertToolToCapsEachWord ? NSControlStateValueOn : NSControlStateValueOff;
    
    self.ToRemoveSign.state = convertToolRemoveMark ? NSControlStateValueOn : NSControlStateValueOff;
    
    [self.FromCode selectItemAtIndex:convertToolFromCode];
    [self.ToCode selectItemAtIndex:convertToolToCode];
    
    self.SControl.state = (convertToolHotKey & 0x100) ? NSControlStateValueOn : NSControlStateValueOff;
    self.SOption.state = (convertToolHotKey & 0x200) ? NSControlStateValueOn : NSControlStateValueOff;
    self.SCommand.state = (convertToolHotKey & 0x400) ? NSControlStateValueOn : NSControlStateValueOff;
    self.SShift.state = (convertToolHotKey & 0x800) ? NSControlStateValueOn : NSControlStateValueOff;
    [self.SHotKey setTextByChar:((convertToolHotKey>>24) & 0xFF)];
}

-(void)turnOffAllOption {
    convertToolToAllCaps = false;
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolToAllCaps forKey:@"convertToolToAllCaps"];
    convertToolToAllNonCaps = false;
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolToAllNonCaps forKey:@"convertToolToAllNonCaps"];
    convertToolToCapsFirstLetter = false;
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolToCapsFirstLetter forKey:@"convertToolToCapsFirstLetter"];
    convertToolToCapsEachWord = false;
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolToCapsEachWord forKey:@"convertToolToCapsEachWord"];
}

- (IBAction)onAlertWhenCompleted:(NSButton *)sender {
    NSInteger val = [self setCustomValue:sender keyToSet:@"convertToolDontAlertWhenCompleted"];
    convertToolDontAlertWhenCompleted = (int)!val;
}

- (IBAction)onToAllCaps:(NSButton *)sender {
    [self turnOffAllOption];
    NSInteger val = [self setCustomValue:sender keyToSet:@"convertToolToAllCaps"];
    convertToolToAllCaps = (int)val;
    [self fillData];
}

- (IBAction)onToNonCaps:(NSButton *)sender {
    [self turnOffAllOption];
    NSInteger val = [self setCustomValue:sender keyToSet:@"convertToolToAllNonCaps"];
    convertToolToAllNonCaps = (int)val;
    [self fillData];
}

- (IBAction)onToCapsFirstLetter:(NSButton *)sender {
    [self turnOffAllOption];
    NSInteger val = [self setCustomValue:sender keyToSet:@"convertToolToCapsFirstLetter"];
    convertToolToCapsFirstLetter = (int)val;
    [self fillData];
}

- (IBAction)onToCapsCharEachWord:(NSButton *)sender {
    [self turnOffAllOption];
    NSInteger val = [self setCustomValue:sender keyToSet:@"convertToolToCapsEachWord"];
    convertToolToCapsEachWord = (int)val;
    [self fillData];
}

- (IBAction)onToRemoveSign:(NSButton *)sender {
    NSInteger val = [self setCustomValue:sender keyToSet:@"convertToolRemoveMark"];
    convertToolRemoveMark = (int)val;
}

- (IBAction)onFromCodeSelected:(NSPopUpButton *)sender {
    convertToolFromCode = [self.FromCode indexOfSelectedItem];
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolFromCode forKey:@"convertToolFromCode"];
}

- (IBAction)onToCodeSelected:(NSPopUpButton *)sender {
    convertToolToCode = [self.ToCode indexOfSelectedItem];
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolToCode forKey:@"convertToolToCode"];
}

- (NSInteger)setCustomValue:(NSButton*)sender keyToSet:(NSString*) key {
    NSInteger val = 0;
    if (sender.state == NSControlStateValueOn) {
        val = 1;
    } else {
        val = 0;
    }
    if (key != nil)
        [[NSUserDefaults standardUserDefaults] setInteger:val forKey:key];
    return val;
}

- (IBAction)onReverseCode:(id)sender {
    NSInteger code = [self.ToCode indexOfSelectedItem];
    [self.ToCode selectItemAtIndex:[self.FromCode indexOfSelectedItem]];
    [self.FromCode selectItemAtIndex:code];
    convertToolFromCode = [self.FromCode indexOfSelectedItem];
    convertToolToCode = [self.ToCode indexOfSelectedItem];
}

- (IBAction)onSControl:(NSButton *)sender {
    NSInteger val = sender.state == NSControlStateValueOn ? 1 : 0;
    convertToolHotKey &= (~0x100);
    convertToolHotKey |= val << 8;
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolHotKey forKey:@"convertToolHotKey"];
    [appDelegate setQuickConvertString];
}

- (IBAction)onSOption:(NSButton *)sender {
    NSInteger val = sender.state == NSControlStateValueOn ? 1 : 0;
    convertToolHotKey &= (~0x200);
    convertToolHotKey |= val << 9;
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolHotKey forKey:@"convertToolHotKey"];
    [appDelegate setQuickConvertString];
}

- (IBAction)onSCommand:(NSButton *)sender {
    NSInteger val = sender.state == NSControlStateValueOn ? 1 : 0;
    convertToolHotKey &= (~0x400);
    convertToolHotKey |= val << 10;
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolHotKey forKey:@"convertToolHotKey"];
    [appDelegate setQuickConvertString];
}

- (IBAction)onSShift:(NSButton *)sender {
    NSInteger val = sender.state == NSControlStateValueOn ? 1 : 0;
    convertToolHotKey &= (~0x800);
    convertToolHotKey |= val << 11;
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolHotKey forKey:@"convertToolHotKey"];
    [appDelegate setQuickConvertString];
}

-(void)onMyTextFieldKeyChange:(unsigned short)keyCode character:(unsigned short)character {
    convertToolHotKey &= 0xFFFFFF00;
    convertToolHotKey |= keyCode;
    convertToolHotKey &= 0x00FFFFFF;
    convertToolHotKey |= ((unsigned int)character<<24);
    [[NSUserDefaults standardUserDefaults] setInteger:convertToolHotKey forKey:@"convertToolHotKey"];
    [appDelegate setQuickConvertString];
}

- (IBAction)onConvertButton:(id)sender {
    if ([OpenKeyManager quickConvert]) {
        if (!convertToolDontAlertWhenCompleted) {
            [OpenKeyManager showMessage: self.view.window message:@"Chuyển mã thành công!" subMsg:@"Kết quả đã được lưu trong clipboard."];
        }
    } else {
        [OpenKeyManager showMessage: self.view.window message:@"Không có dữ liệu trong clipboard!" subMsg:@"Hãy sao chép một đoạn text để chuyển đổi!"];
    }
}

- (IBAction)onOKButton:(id)sender {
    [self.view.window close];
}


@end
