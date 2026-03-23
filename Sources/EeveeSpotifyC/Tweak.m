#import <Orion/Orion.h>
#import <Foundation/Foundation.h>

static void writeDebugLog(NSString *message) {
    NSString *logPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"eeveespotify_debug.log"];
    NSString *timestamp = [[NSDate date] description];
    NSString *logMessage = [NSString stringWithFormat:@"[%@] %@\n", timestamp, message];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:logPath];
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:[logMessage dataUsingEncoding:NSUTF8StringEncoding]];
        [fileHandle closeFile];
    } else {
        [logMessage writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

__attribute__((constructor)) static void init() {
    @try {
        NSLog(@"[EeveeSpotify] Initializing tweak...");
        
        // Initialize Orion - do not remove this line.
        orion_init();
        
        NSLog(@"[EeveeSpotify] Tweak initialized successfully");
        // Custom initialization code goes here.
    }
    @catch (NSException *exception) {
        NSString *errorMsg = [NSString stringWithFormat:@"ERROR: Failed to initialize tweak: %@, Reason: %@", exception, [exception reason]];
        NSLog(@"[EeveeSpotify] %@", errorMsg);
        writeDebugLog(errorMsg);
    }
}
