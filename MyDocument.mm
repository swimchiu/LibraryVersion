//
//  LibraryVersion
//
//  Created by Qiu ShuYun on 2014-10-14.
//  Copyright HYC 2014 . All rights reserved.
//
#import <dlfcn.h>
#import "MyDocument.h"
struct dylibInfo {
    char  name[256];			/* library's path name */
    char  type[5];			/* library's type x86/x64 */
    uint32_t timestamp;			/* library's build time stamp */
    uint32_t current_version;		/* library's current version number */
    uint32_t compatibility_version;	/* library's compatibility vers number*/
};
@implementation MyDocument
- (id)init
{
    self = [super init];
    if (self) 
    {   
        m_pVersionInfoList=[[NSMutableArray alloc] init];
        [m_pVersionInfoList removeAllObjects];
        //m_pdl = NULL;
    }
    return self;
}
- (void) dealloc 
{
   //Release Interface
    [super dealloc];
}

-(void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]
         addObserver:self 
            selector:@selector(closeWin:)
                name:NSWindowWillCloseNotification 
              object:mLibraryVersionWindow ];
    
 	[[NSNotificationCenter defaultCenter]
         addObserver:self 
            selector:@selector(Terminate:)
                name:NSApplicationWillTerminateNotification 
              object:nil];
 	
    [tableView setDataSource:(id)self];
    [tableView setDelegate:(id)self];
    [tableView setTarget:(id)self];
    
    [tableView registerForDraggedTypes:[NSArray arrayWithObjects:NSFilenamesPboardType,nil]];
    [tableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
    [mLibraryVersionWindow setTitle:@"Library Version"];
}
- (void)closeWin:(void *)userInfo
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
    [NSApp terminate:nil];
}
- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
    //[NSBundle loadNibNamed: @"DemoAPDocument" owner: self];
}

- (NSData *)dataRepresentationOfType:(NSString *)aType
{
    // Insert code here to write your document from the given data.  You can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use the new Tiger API -dataOfType:error:.  In this case you can also choose to override -writeToURL:ofType:error:, -fileWrapperOfType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    
    return nil;
}

- (BOOL)loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
    // Insert code here to read your document from the given data.  You can also choose to override -loadFileWrapperRepresentation:ofType: or -readFromFile:ofType: instead.
    
    // For applications targeted for Tiger or later systems, you should use the new Tiger API readFromData:ofType:error:.  In this case you can also choose to override -readFromURL:ofType:error: or -readFromFileWrapper:ofType:error: instead.
    
    return YES;
}
- (NSString *)displayName
{
    NSString *docTitle = @"Library Version";

    NSArray *windowControllers = [self windowControllers];
    
    if ([windowControllers count] > 0)
    {
        NSWindowController *controller = [windowControllers objectAtIndex: 0];
        NSWindow *window = [controller window];
        docTitle = [window title];
    }
    
    return docTitle;
}
////////////////////////////////////////////////////////////////////////////////
- (void)Terminate:(NSNotification*)note
{
}
- (void)closeAllDialogs
{
	if([mLibraryVersionWindow isVisible])
		[mLibraryVersionWindow close];
}

// Table view dataSource methods
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [m_pVersionInfoList count];
}
- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
            row:(int)rowIndex
{
    // What is the identifier for the column?
    NSString *identifier = [aTableColumn identifier];
    
    dylibInfo *info =(dylibInfo*)[[m_pVersionInfoList objectAtIndex:rowIndex] bytes];
    if([identifier isEqualToString:@"File Name"])
    {
        NSString *strTemp = [NSString stringWithFormat:@"%s",info->name];
        return strTemp;
    }
    else if([identifier isEqualToString:@"Library Type"])
    {
        NSString *strTemp = [NSString stringWithFormat:@"%s",info->type];
        return strTemp;
    }
    else if ([identifier isEqualToString:@"Current Version"])
    {
        if (info->current_version)
        {
            NSString *programNumber = nil;
            programNumber = [NSString stringWithFormat:@"%d.%d.%d", (0xFF0000 & info->current_version) >>16,(0x00FF00 & info->current_version) >> 8,0x0000FF & info->current_version];
            return programNumber;
        }
    }
    else if ([identifier isEqualToString:@"Compatibility Version"])
    {
        if (info->compatibility_version)
        {
            NSString *programNumber = nil;
            programNumber = [NSString stringWithFormat:@"%d.%d.%d", (0xFF0000 & info->compatibility_version)>>16,(0x00FF00 & info->compatibility_version) >> 8,0x0000FF & info->compatibility_version];
            return programNumber;
        }
    }
    else if ([identifier isEqualToString:@"Build Time"])
    {
        if (info->compatibility_version)
        {
            NSString *programNumber = nil;
            programNumber = [NSString stringWithFormat:@"%d", info->timestamp];
            return programNumber;
        }
    }
    return nil;
}
- (int32_t)getDylibVersion64:(NSString*)dylibPth;
{
    const char* libraryName = [dylibPth UTF8String];
    void*                       m_pDeriverDllHandle;
    m_pDeriverDllHandle = dlopen(libraryName, RTLD_LOCAL);

    unsigned long i, j, n;
    struct load_command *load_commands, *lc;
    struct dylib_command *dl;
    const struct mach_header *mh;
    
    n = _dyld_image_count();
    for(i = 0; i < n; i++){
        mh = _dyld_get_image_header(i);
        if(mh->filetype != MH_DYLIB)
            continue;
//        load_commands = (struct load_command *)
#if __LP64__
        load_commands = (struct load_command *)((char *)mh + sizeof(struct mach_header_64));
#else
        load_commands = (struct load_command *)((char *)mh + sizeof(struct mach_header));
#endif
        lc = load_commands;
        for(j = 0; j < mh->ncmds; j++){
            if(lc->cmd == LC_ID_DYLIB){
                dl = (struct dylib_command *)lc;
                if(strcmp(_dyld_get_image_name(i), libraryName) == 0)
                {
                    memcpy(&m_pdl,&(dl->dylib),sizeof(dylib));
                    printf("x64 dynamic library\n");
                    printf("current_version:%d\n",m_pdl.current_version);
                    printf("compatibility_version:%d\n",m_pdl.compatibility_version);
                    printf("timestamp:%d\n",m_pdl.timestamp);
                    if(m_pDeriverDllHandle)
                        dlclose(m_pDeriverDllHandle);
                    m_pDeriverDllHandle = NULL;

                    return(dl->dylib.current_version);
                }
            }
            lc = (struct load_command *)((char *)lc + lc->cmdsize);
        }
    }
    if(m_pDeriverDllHandle)
        dlclose(m_pDeriverDllHandle);
    m_pDeriverDllHandle = NULL;

    return(-1);
}

-(int32_t)getDylibVersion86:(NSString *)dylibPth
{
    const char* strFilePath = [dylibPth UTF8String];
    FILE* fileHandle = fopen(strFilePath, "r");
    
    struct mach_header mh;
//    printf("sizeof mach_header:%lu\n",sizeof(mach_header));
    if(fileHandle)
    {
        size_t bytesRead = fread(&mh, 1, sizeof(mh), fileHandle);
//        printf("sizeof bytesRead:%lu\n",bytesRead);
        if(bytesRead == sizeof(mh))
        {
            if(mh.filetype == MH_DYLIB)
            {
                for(int j = 0; j < mh.ncmds; j++)
                {
                    struct load_command load_commands ;
                    fread(&load_commands, 1, sizeof(load_commands), fileHandle);
//                    printf("sizeof load_commands:%lu\n",sizeof(mach_header));
                    switch (load_commands.cmd)
                    {
                        case LC_SEGMENT:
                            break;
                        case LC_UUID:
                            break;
                        case LC_DYLD_INFO_ONLY:
                            break;
                        case LC_SYMTAB:
                            break;
                        case LC_LOAD_DYLIB:
                            break;
                        case LC_ID_DYLIB:
                        {
                            //                            struct dylib_command *dl = (struct dylib_command *)(&load_commands);
                            fseek(fileHandle, - sizeof(load_command), SEEK_CUR);
                            struct dylib_command dl = {0};
                            fread(&dl, 1, sizeof(dylib_command), fileHandle);
                            memcpy(&m_pdl,&(dl.dylib),sizeof(dylib));
                            printf("x86 dynamic library\n");
                            printf("current_version:%d\n",m_pdl.current_version);
                            printf("compatibility_version:%d\n",m_pdl.compatibility_version);
                            printf("timestamp:%d\n",m_pdl.timestamp);
                            return(0);
                        }
                            
                        default:
                            break;
                    }
                    
                    fseek(fileHandle, load_commands.cmdsize - sizeof(load_command), SEEK_CUR);
                }
            }
        }
    }
    
    fclose(fileHandle);
    return (-1);
}
- (IBAction)doClearAll:(id)sender
{
    [m_pVersionInfoList removeAllObjects];
    [tableView reloadData];
}

- (BOOL)tableView:(NSTableView *)tv writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard*)pboard
{
    // Copy the row numbers to the pasteboard.
    if(tv == tableView)
    {
        unsigned int first = [rowIndexes firstIndex];
        if(first == NSNotFound)
            return NO;
        unsigned int next				= first;
        dylibInfo *playListRecord	= NULL;
        NSMutableArray *dragFileList	= [[NSMutableArray alloc] init];
        while(next != NSNotFound)
        {
            playListRecord		= (dylibInfo *)[m_pVersionInfoList objectAtIndex: next];
            NSString *filePath	= nil; // Assume these exist
            int x				= next;
            //int x				= [tv selectedRow];
            int count			= [tv numberOfRows];
            if(x < 0 || x > count)
				return NO;
            filePath = [NSString stringWithFormat:@"%s",playListRecord->name];
            [dragFileList addObject:filePath];
            next = [rowIndexes indexGreaterThanIndex: next];
        }
        NSArray *fileList = [NSArray arrayWithArray:dragFileList];
        [dragFileList release];
        
        // Write data to the pasteboard
        [pboard declareTypes:[NSArray arrayWithObject:NSFilenamesPboardType] owner:nil];
        [pboard setPropertyList:fileList forType:NSFilenamesPboardType];
    }

    return YES;
}

- (NSDragOperation)tableView:(NSTableView*)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)op
{
    // Add code here to validate the drop
    if(tv == tableView)
    {
        NSPasteboard *pb	= [info draggingPasteboard];
        NSArray *pasteTypes = [NSArray arrayWithObjects:NSFilenamesPboardType,nil];
        NSString *bestType	= [pb availableTypeFromArray:pasteTypes];
        if(bestType != nil)
        {
            NSArray *files = [pb propertyListForType:NSFilenamesPboardType];
            int numberOfFiles = [files count];
            NSString *fileName = nil;
            int i = 0;
            for(;i < numberOfFiles;++i)
            {
                fileName = (NSString *)[files objectAtIndex:i];
                if(	[[fileName pathExtension] isEqualToString:@"dylib"])
				{
//                    [self getDylibVersion:fileName];
//                    dylibInfo info = {0};
//                    info.current_version = m_pdl.current_version;
//                    info.compatibility_version = m_pdl.compatibility_version;
//                    info.timestamp = m_pdl.timestamp;
//                    strcpy(info.name,[[fileName lastPathComponent] UTF8String]);
//                    printf("current_version:%d\n",info.current_version);
//                    printf("compatibility_version:%d\n",info.compatibility_version);
//                    printf("timestamp:%d\n",info.timestamp);

                    //[m_pDVBTInfoList addObject:[NSData dataWithBytes:&info length:sizeof(dylibInfo)]];
				}
            }
            //[tableView reloadData];
            return NSDragOperationEvery;
        }
    }
    return NSDragOperationNone;
}


- (BOOL)tableView:(NSTableView *)aTableView acceptDrop:(id <NSDraggingInfo>)info
              row:(NSInteger)row dropOperation:(NSTableViewDropOperation)operation
{
    if(aTableView == tableView)
    {
        NSPasteboard *pb	= [info draggingPasteboard];
        NSArray *pasteTypes = [NSArray arrayWithObjects:NSFilenamesPboardType,nil];
        NSString *bestType	= [pb availableTypeFromArray:pasteTypes];
        if(bestType != nil)
        {
            NSArray *files					= [pb propertyListForType:NSFilenamesPboardType];
            NSMutableArray *fileNameArray	= [[NSMutableArray alloc] init];
            int numberOfFiles				= [files count];
            NSString *fileName				= nil;
            int i							= 0;
            for(;i < numberOfFiles;++i)
            {
                fileName = (NSString *)[files objectAtIndex:i];
                if(	[[fileName pathExtension] isEqualToString:@"dylib"])
                {
					[fileNameArray addObject:fileName];
                    dylibInfo info = {0};
                    
                    if([self getDylibVersion86:fileName] != -1)
                    {
                        info.current_version = m_pdl.current_version;
                        info.compatibility_version = m_pdl.compatibility_version;
                        info.timestamp = m_pdl.timestamp;
                        //strcpy(info.name,[[fileName lastPathComponent] UTF8String]);
                        strcpy(info.type,"x86");
                        printf("current_version:%d\n",info.current_version);
                        printf("compatibility_version:%d\n",info.compatibility_version);
                        printf("timestamp:%d\n",info.timestamp);
                    }
                    else
                    {
                        if([self getDylibVersion64:fileName] != -1)
                        {
                            info.current_version = m_pdl.current_version;
                            info.compatibility_version = m_pdl.compatibility_version;
                            info.timestamp = m_pdl.timestamp;
                            //strcpy(info.name,[[fileName lastPathComponent] UTF8String]);
                            strcpy(info.type,"x64");
                            printf("current_version:%d\n",info.current_version);
                            printf("compatibility_version:%d\n",info.compatibility_version);
                            printf("timestamp:%d\n",info.timestamp);
                        }
                    }
                    strcpy(info.name,[[fileName lastPathComponent] UTF8String]);
                    [m_pVersionInfoList addObject:[NSData dataWithBytes:&info length:sizeof(dylibInfo)]];
				}
            }
			if([fileNameArray count] == 0)
			{
				[fileNameArray release];
				fileNameArray = nil;
				return YES;
			}
            [tableView reloadData];
            [fileNameArray release];
			fileNameArray = nil;
        }
        return YES;
    }
    return NO;
}
@end
