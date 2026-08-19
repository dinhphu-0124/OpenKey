
#import "MacroViewController.h"
#include "Engine.h"

#define MACRO_ADD_TEXT @"Thêm"
#define MACRO_EDIT_TEXT @"Sửa"

@interface MacroViewController ()

@end

@implementation MacroViewController{
    vector<vector<Uint32>> keys;
    vector<string> macroText;
    vector<string> macroContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.macroName.delegate = self;
    self.macroContent.delegate = self;
    
    self.AutoCapsMacro.state = vAutoCapsMacro ? NSControlStateValueOn : NSControlStateValueOff;
    
    //load data
    getAllMacro(keys, macroText, macroContent);
}

-(void)saveAndReload {
    getAllMacro(keys, macroText, macroContent);
    [self.tableView reloadData];
    
    vector<Byte> macroData;
    getMacroSaveData(macroData);
    NSData* _data = [NSData dataWithBytes:macroData.data() length:macroData.size()];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:_data forKey:@"macroData"];
    [self.buttonAdd setTitle:MACRO_ADD_TEXT];
}

- (IBAction)onDeleteMacro:(id)sender {
    if ([[self.macroName stringValue] compare:@""] == 0) {
        [self showMessage:@"Bạn hãy chọn từ cần xoá!"];
        return;
    }
    string text = [[self.macroName stringValue] UTF8String];
    if (deleteMacro(text)) {
        [self saveAndReload];
        self.macroName.stringValue = @"";
        self.macroContent.stringValue = @"";
        [self.macroName becomeFirstResponder];
    }
}

- (IBAction)onAddMacro:(id)sender {
    if ([[self.macroName stringValue] compare:@""] == 0 || [[self.macroContent stringValue] compare:@""] == 0) {
        [self showMessage:@"Bạn hãy nhập từ cần gõ tắt!"];
        return;
    }
    
    string text = [[self.macroName stringValue] UTF8String];
    string content = [[self.macroContent stringValue] UTF8String];

    addMacro(text, content);
    self.macroName.stringValue = @"";
    self.macroContent.stringValue = @"";
    [self.macroName becomeFirstResponder];
    [self saveAndReload];
}

- (IBAction)onImportFromMacOSTextReplacement:(id)sender {
    NSDictionary<NSString*, NSString*>* replacements = [NSSpellChecker sharedSpellChecker].userReplacementsDictionary;
    if (replacements.count == 0) {
        [self showMessage:@"Không tìm thấy dữ liệu Text Replacement nào trên macOS.\nBạn có thể thêm ở System Settings > Keyboard > Text Replacements."];
        return;
    }

    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText:@"Nhập từ Text Replacement macOS"];
    [alert setInformativeText:[NSString stringWithFormat:@"Tìm thấy %lu mục trong Text Replacement của macOS (đồng bộ qua iCloud). Bạn có muốn nhập vào danh sách gõ tắt không?\n\nCác từ trùng tên sẽ được cập nhật theo nội dung mới.", (unsigned long)replacements.count]];
    [alert addButtonWithTitle:@"Nhập"];
    [alert addButtonWithTitle:@"Huỷ"];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode != NSAlertFirstButtonReturn) {
            return;
        }
        int importedCount = 0;
        for (NSString* key in replacements) {
            string text = [key UTF8String];
            string content = [replacements[key] UTF8String];
            if (text.empty() || content.empty()) {
                continue;
            }
            if (addMacro(text, content)) {
                importedCount++;
            }
        }
        [self saveAndReload];
        [self showMessage:[NSString stringWithFormat:@"Đã nhập %d mục gõ tắt từ macOS.", importedCount]];
    }];
}

- (void)showMessage:(NSString*)msg {
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setInformativeText:msg];
    [alert addButtonWithTitle:@"OK"];
    [alert setMessageText:@"Gõ tắt"];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
        
    }];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    NSTextField *textField = [notification object];
    if (textField == self.macroName) {
        string text = [[self.macroName stringValue] UTF8String];
        if (hasMacro(text)) {
            [self.buttonAdd setTitle:MACRO_EDIT_TEXT];
        } else {
            [self.buttonAdd setTitle:MACRO_ADD_TEXT];
        }
    }
}

- (IBAction)onAutoCapButton:(NSButton *)sender {
    NSInteger val = sender.state == NSControlStateValueOn ? 1 : 0;
    vAutoCapsMacro = (int)val;
    [[NSUserDefaults standardUserDefaults] setInteger:vAutoCapsMacro forKey:@"vAutoCapsMacro"];
}

#pragma mark TableView
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return keys.size();
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString* cellId;
    NSTableCellView* v = nil;
    if (tableColumn == tableView.tableColumns[0]) {
        cellId = @"MacroCell";
        v = [tableView makeViewWithIdentifier:cellId owner:self];
        [v.textField setStringValue:[NSString stringWithUTF8String:macroText[row].c_str()]];
    } else if (tableColumn == tableView.tableColumns[1]) {
        cellId = @"ContentCell";
        v = [tableView makeViewWithIdentifier:cellId owner:self];
        [v.textField setStringValue:[NSString stringWithUTF8String:macroContent[row].c_str()]];
    }
    return v;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    [self.macroName setStringValue:[NSString stringWithUTF8String:macroText[row].c_str()]];
    [self.macroContent setStringValue:[NSString stringWithUTF8String:macroContent[row].c_str()]];
    [self.buttonAdd setTitle:MACRO_EDIT_TEXT];
    return YES;
}

@end
