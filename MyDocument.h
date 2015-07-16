/* MyDocument */
//
//  MyDocument.h
//  LibraryVersion
//
//  Created by Qiu ShuYun on 2014-10-14.
//  Copyright HYC 2014 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <stddef.h>
#include <string.h>
#include <malloc/malloc.h>

#include <crt_externs.h>
#include <Availability.h>

#include "mach-o/dyld.h"
@interface MyDocument : NSDocument
{
    IBOutlet NSWindow *mLibraryVersionWindow;
    IBOutlet NSButton *mClearBtn;
    IBOutlet NSTableView *tableView;
    NSMutableArray *m_pVersionInfoList;
    dylib m_pdl;
}
- (void)closeAllDialogs;
- (IBAction)doClearAll:(id)sender;
- (int32_t)getDylibVersion64:(NSString*)libraryName;
- (int32_t)getDylibVersion86:(NSString*)libraryName;
@end
