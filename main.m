#include <stdio.h>
#import <Foundation/Foundation.h>a

void usage() {
printf("Usage...\n");
}

int main(int argc, char **argv, char **envp) {
if (argc < 2) { usage(); return 0; }
NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
[@"" writeToFile:[NSString  stringWithCString:argv[2]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
NSString *out = @"";
NSString *in = [NSString stringWithCString:argv[1]];
NSFileManager *fm = [NSFileManager defaultManager];
NSArray *fileNames = [fm contentsOfDirectoryAtPath:in error:nil];
for (NSString *str in fileNames) {
printf([str UTF8String]); printf("\n");
NSArray *name = [str componentsSeparatedByString:@"."];
out = [out stringByAppendingString:@"%hook "];
out = [out stringByAppendingString:[name objectAtIndex:0]];
out = [out stringByAppendingString:@"\n"];
//NSString *fn = [NSString stringWithFormat:@"%@/%@", in, str];
//NSLog(fn);
NSString *fileContent = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", in, str]];
//NSLog(in);
//NSLog(fileContent);
NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
printf("%%hook\n");
for (NSString *line in lines) {
//NSLog(line);
if (([line rangeOfString:@"+"].location != NSNotFound || [line rangeOfString:@"-"].location != NSNotFound) && [line rangeOfString:@";"].location != NSNotFound) {
NSString *printable = @"";
line = [line stringByReplacingOccurrencesOfString:@";" withString:@""];
printf([line UTF8String]);
printf([printable UTF8String]);
if ([line rangeOfString:@"void"].location == NSNotFound) { printable = @" { %log; return %orig; }\n"; printf(" { %%log; return %%orig; }\n"); }
else { printable = @" { %log; %orig; }\n"; printf(" { %%log %%orig; }\n"); }
out = [out stringByAppendingString:line];
out = [out stringByAppendingString:printable];
}
}
out = [out stringByAppendingString:@"%end\n\n"];
printf("%%end\n\n");
//NSLog(out);
NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:[NSString  stringWithCString:argv[2]]];
[fh seekToEndOfFile];

NSData *data = [out dataUsingEncoding:NSUTF8StringEncoding]; // obtain an NSData somehow
[fh writeData:data];
[fh closeFile];
//BOOL success = [out writeToFile:[NSString  stringWithCString:argv[2]] atomically:NO encoding:NSUTF8StringEncoding error:nil];
//if (success) printf("File successfully written!\n");
//else printf("File write failed!\n");
out = @"";
}
[pool release];
	return 0;
}

// vim:ft=objc
