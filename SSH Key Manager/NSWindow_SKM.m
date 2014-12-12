//
//  NSWindow_SKM.m
//  SSH Key Manager
//
//  Created by Cristoffer Fairweather on 10/6/14.
//  Copyright (c) 2014 C Fairweather. All rights reserved.
//

#import "NSWindow_SKM.h"
#import "AppDelegate.h"

@interface NSWindow_SKM ()<NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate>{
    BOOL saved;
    int lastShoSelected;
    NSString*attemptChangeHost;
    
    BOOL sshHostWindowMode_NEW;
}

@property (weak) AppDelegate *appDelegate;
@property (strong) NSMutableDictionary<NSMutableCopying> *dictionarySSHHosts;
@property (strong) SSHHostObject *shoSelected;

@end

@implementation NSWindow_SKM

-(void)applicationReady{
    saved = YES;
    self.appDelegate = [[NSApplication sharedApplication] delegate];
    [self populatePopupMenu];
    
    self.tableViewManualOptions.dataSource=self;
    self.tableViewManualOptions.delegate=self;
    
    if (self.dictionarySSHHosts.count > 0) {
//        Select 1st item;
        [self selectHost:[self.popUpButtonHost itemTitleAtIndex:0]];
    }
    
    [self.textFieldHostName setDelegate:self];
    [self.textFieldPort     setDelegate:self];
    [self.textFieldPortForwardingFrom setDelegate:self];
    [self.textFieldPortForwardingTo     setDelegate:self];
    [self.textFieldSSHHost  setDelegate:self];
    [self.textFieldSSHKey   setDelegate:self];
    [self.textFieldUsername setDelegate:self];
}

-(void)populatePopupMenu{
    NSArray *arraySSHConfigItems = self.appDelegate.arraySSHConfigItems;
    self.dictionarySSHHosts=[NSMutableDictionary new];
    
    for (int h=0; h<arraySSHConfigItems.count; h++) {
        if ([arraySSHConfigItems[h] hasPrefix:@"Host "]) {
            
            SSHHostObject *sho = [[SSHHostObject alloc] initWithHostString:arraySSHConfigItems[h]];
            
            NSString *hostname = sho.hostLabel;
            if(!hostname){
                
                NSLog(@"The hell?");
                
            }else{
                
                [self.dictionarySSHHosts setObject:sho forKey:hostname];
                
                [self.popUpButtonHost addItemWithTitle:hostname];
            }
            
        }
    }
}

-(BOOL)selectHost:(NSString*)host{
    if(!saved){
        attemptChangeHost=host;
        [self promptUserToSave];
        return NO;
    }
    self.shoSelected = [self.dictionarySSHHosts objectForKey:host];
    [self enableAllButtons:YES];
    
    self.textFieldHostName.stringValue = self.shoSelected.hostName;
    self.textFieldUsername.stringValue = (self.shoSelected.hostUsername) ? self.shoSelected.hostUsername : @"";
    self.buttonPortDefault.state = (self.shoSelected.altPortEnabled)? NSOffState : NSOnState;
    self.textFieldPort.stringValue = [NSString stringWithFormat:@"%d",(self.shoSelected.altPortEnabled)? self.shoSelected.altPort : 22];

    self.buttonUseSSHKey.state = (self.shoSelected.sshKeyEnabled)? NSOnState:NSOffState;
    self.buttonBackupKey.state = (self.shoSelected.sshKeyBackupEnabled)?NSOnState:NSOffState;
    
    self.textFieldSSHKey.stringValue = (self.shoSelected.sshKeyPath) ? self.shoSelected.sshKeyPath : @"";
    
    self.buttonPortForwardingEnabled.state = self.shoSelected.portMapEnabled? NSOnState:NSOffState;
    self.buttonPortForwardingReversedEnabled.state = self.shoSelected.portMapReversed? NSOnState:NSOffState;
    self.textFieldPortForwardingFrom.stringValue = (self.shoSelected.portMapFrom) ? self.shoSelected.portMapFrom : @"";
    self.textFieldPortForwardingTo.stringValue = (self.shoSelected.portMapTo) ? self.shoSelected.portMapTo : @"";
    
    self.buttonLogLevelDefault.state = self.shoSelected.logLevelChanged? NSOffState:NSOnState;
    if(self.shoSelected.logLevelChanged){
        if([self.shoSelected.logLevel isEqualToString:@"QUIET" ]){
            self.appDelegate.sliderValue = 0;
        }
        
        if([self.shoSelected.logLevel isEqualToString:@"FATAL" ]){
            self.appDelegate.sliderValue = 1;
        }
        
        if([self.shoSelected.logLevel isEqualToString:@"ERROR" ]){
            self.appDelegate.sliderValue = 2;
        }
        
        if([self.shoSelected.logLevel isEqualToString:@"VERBOSE" ]){
            self.appDelegate.sliderValue = 3;
        }
        
        if([self.shoSelected.logLevel isEqualToString:@"DEBUG" ]){
            self.appDelegate.sliderValue = 4;
        }
        
        if([self.shoSelected.logLevel isEqualToString:@"DEBUG1" ]){
            self.appDelegate.sliderValue = 5;
        }
        
        if([self.shoSelected.logLevel isEqualToString:@"DEBUG2" ]){
            self.appDelegate.sliderValue = 6;
        }
        
        if([self.shoSelected.logLevel isEqualToString:@"DEBUG3" ]){
            self.appDelegate.sliderValue = 7;
        }
        
    }
    
    [self.tableViewManualOptions reloadData];
    return YES;
}



-(void)promptUserToSave{
    
    [self.windowPromptSave setDefaultButtonCell:[self.buttonPromptSave cell]];
    [self beginSheet:self.windowPromptSave completionHandler:NULL];

}

- (IBAction)actionPromptSave:(id)sender {
    [self.shoSelected commitValues];
    [self.shoSelected updateHostString];
    
    [NSApp stopModal];
    [self.windowPromptSave orderOut: nil];
    [[NSApplication sharedApplication] endSheet:self.windowPromptSave returnCode:NSOKButton];
    saved=YES;
    [self actionLogConfigFile:self];
    [self selectHost:attemptChangeHost];
}

- (IBAction)actionPromptCancel:(id)sender {
    [self.shoSelected revertValues];
    [self.shoSelected updateHostString];
    
    [NSApp stopModal];
    [self.windowPromptSave orderOut: nil];
    [[NSApplication sharedApplication] endSheet:self.windowPromptSave returnCode:NSOKButton];
    saved=YES;
    [self selectHost:attemptChangeHost];
}



//Used for confirming the user wants to delete a record
-(void)actionPromptDeleteConfirm:(id)sender{
    
    NSMutableString* hostMutableString = self.shoSelected.hostString;
    
    [self.popUpButtonHost removeItemWithTitle:self.shoSelected.hostLabel];
    [self.dictionarySSHHosts removeObjectForKey:self.shoSelected.hostLabel];
    [self.appDelegate.arraySSHConfigItems removeObject:hostMutableString];
    [self actionLogConfigFile:sender];
    
    
    if (self.dictionarySSHHosts.count > 0) {
        //        Select 1st item;
        [self.popUpButtonHost selectItemAtIndex:0];
        [self selectHost:[self.popUpButtonHost itemTitleAtIndex:0]];
    }
    [self actionPromptDeleteCancel:sender];
}

-(void)actionPromptDeleteCancel:(id)sender{
    [NSApp stopModal];
    [self.windowPromptDelete orderOut: nil];
    [[NSApplication sharedApplication] endSheet:self.windowPromptDelete returnCode:NSOKButton];
    
}


-(void)enableAllButtons:(BOOL) enabled{
    self.buttonHostSettings.enabled = enabled;
    self.buttonOpenInTerminal.enabled = enabled;
    self.buttonHostRemove.enabled = enabled;
    self.buttonOpenInTerminal.enabled = enabled;
    self.textFieldHostName.enabled = enabled;
    self.textFieldUsername.enabled = enabled;
    self.buttonPortDefault.enabled = enabled;
    self.textFieldPort.enabled = enabled && self.shoSelected.altPortEnabled;
    self.buttonUseSSHKey.enabled = enabled;
    self.buttonSelectSSHKey.enabled = enabled;
    self.buttonBackupKey.enabled = enabled;
//    self.textFieldSSHKey.enabled = enabled && self.shoSelected.sshKeyEnabled;
    self.buttonPortForwardingEnabled.enabled=enabled;
    self.buttonPortForwardingReversedEnabled.enabled=enabled;
    self.textFieldPortForwardingFrom.enabled = enabled && self.shoSelected.portMapEnabled;
    self.textFieldPortForwardingTo.enabled = enabled && self.shoSelected.portMapEnabled;
    self.sliderLogLevel.enabled=enabled && self.shoSelected.logLevelChanged;
    self.buttonLogLevelDefault.enabled = enabled;
}


//Actions


- (IBAction)actionHostChanged:(id)sender {
    [self selectHost:[(NSPopUpButton*)sender selectedItem].title ];
}

- (IBAction)actionHostSettings:(id)sender {
//    Show dropdown menu to edit Host Label
    sshHostWindowMode_NEW=NO;
    self.textFieldSSHHost.stringValue = self.shoSelected.hostLabel;
    [self.windowHostSettings setDefaultButtonCell:[self.buttonHostSettingsSave cell]];
    [self beginSheet:self.windowHostSettings completionHandler:NULL];
}


- (IBAction)actionSaveSSHHostNameChange:(id)sender {
//    Can only save if new hostlabel doesn't exist and is not blank
    if (sshHostWindowMode_NEW){
        if((![[self.textFieldSSHHost.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] &&
            [self.dictionarySSHHosts objectForKey:[self.textFieldSSHHost.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] == nil
            )){
            
            NSMutableString *mString = [[NSString stringWithFormat:@"Host %@\n  HostName %@.local",self.textFieldSSHHost.stringValue, self.textFieldSSHHost.stringValue] mutableCopy];
            [self.appDelegate.arraySSHConfigItems addObject:mString];
            SSHHostObject *shoNew = [[SSHHostObject alloc] initWithHostString:mString];
            
            
            [self.dictionarySSHHosts setObject:shoNew forKey:shoNew.hostLabel];
            [self.popUpButtonHost addItemWithTitle:shoNew.hostLabel];
            
            
            [self actionLogConfigFile:nil];
            [self actionCancelSSHHostSettings:sender];
            NSMenuItem *lastPopUpItem = self.popUpButtonHost.itemArray[self.popUpButtonHost.itemArray.count-1];
            
            [self.popUpButtonHost selectItem:lastPopUpItem];
            [self selectHost:shoNew.hostLabel];
            [self.textFieldHostName becomeFirstResponder];
            saved=YES;
        }else{
            NSBeep();
        }
    }else{
        if((![[self.textFieldSSHHost.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@""] &&
            [self.dictionarySSHHosts objectForKey:[self.textFieldSSHHost.stringValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]] == nil
            )
           || [self.textFieldSSHHost.stringValue isEqualToString:self.shoSelected.hostLabel]){
            
            [self.dictionarySSHHosts removeObjectForKey:self.shoSelected.hostLabel];
            self.shoSelected.hostLabel = self.textFieldSSHHost.stringValue;
            [[self.popUpButtonHost selectedItem] setTitle:self.shoSelected.hostLabel];
            [self.dictionarySSHHosts setObject:self.shoSelected forKey:self.shoSelected.hostLabel];
            
            
            [self actionLogConfigFile:nil];
            [self actionCancelSSHHostSettings:sender];
            saved=YES;
        }else{
            NSBeep();
        }
    }
}

- (IBAction)actionCancelSSHHostSettings:(id)sender {
    [NSApp stopModal];
    
    [self.windowHostSettings orderOut: nil];
    
    [[NSApplication sharedApplication] endSheet:self.windowHostSettings returnCode:NSOKButton];
}

- (IBAction)actionHostAdd:(id)sender {
    //    Show dropdown to pick name and hostname. Creates blank (empty) host item
    sshHostWindowMode_NEW=YES;
    self.textFieldSSHHost.stringValue = @"";
    [self.windowHostSettings setDefaultButtonCell:[self.buttonHostSettingsSave cell]];
    [self beginSheet:self.windowHostSettings completionHandler:NULL];
}

- (IBAction)actionHostRemove:(id)sender {
//    Remove from base array of items as well
    
    [self.windowPromptDelete setDefaultButtonCell:[self.buttonPromptDeleteCancel cell]];
    [self beginSheet:self.windowPromptDelete completionHandler:NULL];
}

- (IBAction)actionHostNameChanged:(id)sender {
    if (![self.shoSelected.hostName isEqualToString:@""]) {
        self.shoSelected.hostName = [sender stringValue];
        saved=NO;
    }else{
        [sender setPlaceholderString:@"Hostname cannot be empty"];
    }
}

- (IBAction)actionUsernameChanged:(id)sender {
    self.shoSelected.hostUsername = [sender stringValue];
    saved=NO;
}

- (IBAction)actionPortDefaultChanged:(id)sender {
    self.textFieldPort.enabled = ([(NSButton*)sender state]==NSOnState) ? NO : YES;
}

- (IBAction)actionLogLevelSlider:(id)sender {
    int level = self.appDelegate.sliderValue;
    if(!self.shoSelected.logLevelChanged){
        [self.textFieldLogLevelDesc setStringValue:@"INFO"];
        saved=NO;
        return;
    }
    
    switch (level) {
        case 0:
            self.shoSelected.logLevel = @"QUIET";
            break;
        case 1:
            self.shoSelected.logLevel = @"FATAL";
            break;
        case 2:
            self.shoSelected.logLevel = @"ERROR";
            break;
        case 3:
            self.shoSelected.logLevel = @"VERBOSE";
            break;
        case 4:
            self.shoSelected.logLevel = @"DEBUG";
            break;
        case 5:
            self.shoSelected.logLevel = @"DEBUG1";
            break;
        case 6:
            self.shoSelected.logLevel = @"DEBUG2";
            break;
        case 7:
            self.shoSelected.logLevel = @"DEBUG3";
            break;
            
        default:
            break;
    }
    [self.textFieldLogLevelDesc setStringValue:self.shoSelected.logLevel];
    saved=NO;
}

- (IBAction)actionLogLevelDefault:(id)sender {
    self.sliderLogLevel.enabled = ([(NSButton*)sender state]==NSOnState) ? NO : YES;
    self.shoSelected.logLevelChanged=([(NSButton*)sender state]==NSOnState) ? NO : YES;
    
    if(!self.shoSelected.logLevelChanged){
        [self.textFieldLogLevelDesc setStringValue:@"INFO"];
    }else{
        [self actionLogLevelSlider:nil];
    }
    saved=NO;
    
}

- (IBAction)actionPortChanged:(id)sender {
    if (![[sender stringValue] isEqualToString:@""]){
        self.shoSelected.altPort = [sender intValue];
        saved=NO;
    }
}

- (IBAction)actionOpenInTerminal:(id)sender {
//    I don't know.
}

- (IBAction)actionUseSSHKeyChanged:(id)sender {
    self.buttonSelectSSHKey.enabled = ([(NSButton*)sender state]==NSOnState) ? YES : NO;
    self.shoSelected.sshKeyEnabled = ([(NSButton*)sender state]==NSOnState) ? YES : NO;
    saved=NO;
}

- (IBAction)actionBackupKey:(id)sender {
    self.shoSelected.sshKeyBackupEnabled = ([(NSButton*)sender state]==NSOnState) ? YES : NO;
    saved=NO;
}

- (IBAction)actionSelectSSHKey:(id)sender {
//    Open file selection dialog to ~/.ssh/
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    [panel setDirectoryURL:[[NSURL URLWithString:NSHomeDirectory()] URLByAppendingPathComponent:@".ssh"]];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            NSString *path = [url.path stringByStandardizingPath];
            NSRange search = [path rangeOfString:NSHomeDirectory()];
            
            if(search.location==0){
                path = [path stringByReplacingCharactersInRange:search withString:@"~"];
            }
            self.shoSelected.sshKeyPath= path;
            [self.textFieldSSHKey setStringValue:path];
            saved=NO;
            break;
        }
    }
}

- (IBAction)actionPortForwardingEnabledChanged:(id)sender {
    self.shoSelected.portMapEnabled = ([(NSButton*)sender state]==NSOnState) ? YES : NO;
    self.textFieldPortForwardingFrom.enabled = ([(NSButton*)sender state]==NSOnState) ? YES : NO;
    self.textFieldPortForwardingTo.enabled   = ([(NSButton*)sender state]==NSOnState) ? YES : NO;
    saved=NO;
}

- (IBAction)actionPortForwardingReversedEnabledChanged:(id)sender {
    self.shoSelected.portMapReversed = ([(NSButton*)sender state]==NSOnState) ? YES : NO;
    saved=NO;
}

- (IBAction)actionPortForwardingFromChanged:(id)sender {
    self.shoSelected.portMapFrom = [self.textFieldPortForwardingFrom stringValue];
    saved=NO;
}

- (IBAction)actionPortForwardingToChanged:(id)sender {
    self.shoSelected.portMapTo   = [self.textFieldPortForwardingTo stringValue];
    saved=NO;
}
- (IBAction)actionLabelsChanged:(id)sender {
//    Who knows
}

- (IBAction)actionTableViewChanged:(id)sender {
//    Huh?
}

- (IBAction)actionLogConfigFile:(id)sender {
    [self.shoSelected commitValues];
    
    for (int b=0; b<self.appDelegate.arraySSHConfigItems.count; b++) {
        NSString *item = self.appDelegate.arraySSHConfigItems[b];
        NSLog(@"%d:%@", b,item);
        saved=YES;
    }
    
    [self.appDelegate writeToSSHFile];
    
}



//Table view nonsense
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    if(self.shoSelected){
        return self.shoSelected.manualOptions.count;
    }
    return 0;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    if([tableColumn.identifier isEqualToString:@"Option"]){
        return [self.shoSelected.manualOptions allKeys][row];
    }else{
        
        return [self.shoSelected.manualOptions allValues][row];
    }
}
-(BOOL)tableView:(NSTableView *)tableView shouldReorderColumn:(NSInteger)columnIndex toColumn:(NSInteger)newColumnIndex{
    return NO;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
//    int a=0;
}

-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSString* key = [self.shoSelected.manualOptions allKeys][row];
    if([tableColumn.identifier isEqualToString:@"Option"]){
        NSString *value = [self.shoSelected.manualOptions objectForKey:key];
        
        [self.shoSelected.manualOptions removeObjectForKey:key];
        [self.shoSelected.manualOptions setObject:value forKey:object];
        
    }else{
        [self.shoSelected.manualOptions setObject:object forKey:key];
    }
    [self.shoSelected updateHostString];
    [self.tableViewManualOptions reloadData];
    saved=NO;
}

-(void)controlTextDidChange:(NSNotification *)obj{
    NSTextField *textField = [obj object];
    
    if(self.textFieldHostName==textField){
        [self actionHostNameChanged:textField];
        
    }else if (self.textFieldUsername==textField){
        [self actionUsernameChanged:textField];
        
    }else if (self.textFieldPort==textField){
        [self actionPortChanged:textField];
        
    }else if (self.textFieldPortForwardingFrom==textField){
        [self actionPortForwardingFromChanged:textField];
        
    }else if (self.textFieldPortForwardingTo==textField){
        [self actionPortForwardingToChanged:textField];
        
    }
}

- (IBAction)actionMenuNew:(id)sender {
}

- (IBAction)actionMenuClose:(id)sender {
}

- (IBAction)actionMenuSave:(id)sender {
    [self actionLogConfigFile:self];
}
@end
