//
//  NSWindow_SKM.h
//  SSH Key Manager
//
//  Created by Cristoffer Fairweather on 10/6/14.
//  Copyright (c) 2014 C Fairweather. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SSHHostObject.h"
#import "OnlyIntegerNumberFormatter.h"

@interface NSWindow_SKM : NSWindow

-(void)applicationReady;

@property (weak) IBOutlet NSMenuItem *menuSave;
- (IBAction)actionMenuNew:(id)sender;
- (IBAction)actionMenuClose:(id)sender;
- (IBAction)actionMenuSave:(id)sender;

@property (weak) IBOutlet NSPopUpButton *popUpButtonHost;
@property (weak) IBOutlet NSButton *buttonOpenInTerminal;
@property (weak) IBOutlet NSButton *buttonHostSettings;
@property (weak) IBOutlet NSButton *buttonHostRemove;
@property (weak) IBOutlet NSTextField *textFieldHostName;
@property (weak) IBOutlet NSTextField *textFieldUsername;
@property (weak) IBOutlet NSButton *buttonPortDefault;
@property (weak) IBOutlet NSButton *buttonLogLevelDefault;
@property (weak) IBOutlet NSSlider *sliderLogLevel;
@property (weak) IBOutlet NSTextField *textFieldLogLevelDesc;
@property (weak) IBOutlet NSTextField *textFieldPort;
@property (weak) IBOutlet NSButton *buttonUseSSHKey;
@property (weak) IBOutlet NSButton *buttonBackupKey;
@property (weak) IBOutlet NSTextField *textFieldSSHKey;
@property (weak) IBOutlet NSButton *buttonSelectSSHKey;
@property (weak) IBOutlet NSButton *buttonPortForwardingEnabled;
@property (weak) IBOutlet NSButton *buttonPortForwardingReversedEnabled;
@property (weak) IBOutlet NSTextField *textFieldPortForwardingFrom;
@property (weak) IBOutlet NSTextField *textFieldPortForwardingTo;
@property (weak) IBOutlet NSTokenField *tokenFieldLabels;
@property (weak) IBOutlet NSTableView *tableViewManualOptions;

//Window Change SSH Host
@property (weak) IBOutlet NSWindow *windowHostSettings;
@property (weak) IBOutlet NSTextField *textFieldSSHHost;
@property (weak) IBOutlet NSButton *buttonHostSettingsSave;
- (IBAction)actionSaveSSHHostNameChange:(id)sender;
- (IBAction)actionCancelSSHHostSettings:(id)sender;

//Window Prompt Save
@property (weak) IBOutlet NSWindow *windowPromptSave;
@property (weak) IBOutlet NSWindow *windowPromptDelete;
@property (weak) IBOutlet NSButton *buttonPromptDeleteCancel;
@property (weak) IBOutlet NSButton *buttonPromptSave;
- (IBAction)actionPromptSave:(id)sender;
- (IBAction)actionPromptCancel:(id)sender;
- (IBAction)actionPromptDeleteCancel:(id)sender;
- (IBAction)actionPromptDeleteConfirm:(id)sender;

//Section Main
- (IBAction)actionHostChanged:(id)sender;
- (IBAction)actionHostSettings:(id)sender;
- (IBAction)actionHostAdd:(id)sender;
- (IBAction)actionHostRemove:(id)sender;
- (IBAction)actionHostNameChanged:(id)sender;
- (IBAction)actionUsernameChanged:(id)sender;
- (IBAction)actionPortDefaultChanged:(id)sender;
- (IBAction)actionLogLevelSlider:(id)sender;
- (IBAction)actionLogLevelDefault:(id)sender;
- (IBAction)actionPortChanged:(id)sender;
- (IBAction)actionOpenInTerminal:(id)sender;

//Section Keys
- (IBAction)actionUseSSHKeyChanged:(id)sender;
- (IBAction)actionBackupKey:(id)sender;
- (IBAction)actionSelectSSHKey:(id)sender;
- (IBAction)actionPortForwardingEnabledChanged:(id)sender;
- (IBAction)actionPortForwardingReversedEnabledChanged:(id)sender;
- (IBAction)actionPortForwardingFromChanged:(id)sender;
- (IBAction)actionPortForwardingToChanged:(id)sender;

//Section Other
@property (weak) IBOutlet NSButton *buttonManualOptionRemove;
@property (weak) IBOutlet NSButton *buttonManualOptionAdd;
- (IBAction)actionManualOptionAdd:(id)sender;
- (IBAction)actionManualOptionRemove:(id)sender;
- (IBAction)actionLabelsChanged:(id)sender;
- (IBAction)actionTableViewChanged:(id)sender;
- (IBAction)actionLogConfigFile:(id)sender;

//Table stuffs


@end
