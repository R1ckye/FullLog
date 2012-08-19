/* 
 *  Made by Rickye
 *  License:
 *  This tool is fully open, which means you can modify, use or do what you want. 
 *  BTW, if you using my code please send me an email about it.
 *  ricqy@me.com
 *  Follow me on Twitter: R1cqye
 */

#include <stdio.h>

void usage() {
printf("Usage: FullLog /path/of/headers/ /path/to/output/file\n");
}

int main(int argc, char **argv, char **envp) {
    if (argc < 2) { usage(); return 0; } //If the user didn't enter the 2 arguments show the usage and return
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [@"" writeToFile:[NSString  stringWithCString:argv[2]] atomically:YES encoding:NSUTF8StringEncoding error:nil]; //Make the file empty
    NSString *out = @"";    
    NSString *in = [NSString stringWithCString:argv[1]];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileNames = [fm contentsOfDirectoryAtPath:in error:nil]; //Collect files into an NSArray
    for (NSString *str in fileNames) { //Go through files in the array one by one 
        printf([str UTF8String]); printf("\n"); //Print the file's name
        NSArray *name = [str componentsSeparatedByString:@"."]; //Get the name without the extension
        out = [out stringByAppendingString:@"%hook "]; //Append words to the writable string
        out = [out stringByAppendingString:[name objectAtIndex:0]];
        out = [out stringByAppendingString:@"\n"];
        NSString *fileContent = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@", in, str]]; //Get the file's content into a string
        NSArray *lines = [fileContent componentsSeparatedByString:@"\n"];
        printf("%%hook\n");
            for (NSString *line in lines) {
                if (([line rangeOfString:@"+"].location != NSNotFound || [line rangeOfString:@"-"].location != NSNotFound) && [line rangeOfString:@";"].location != NSNotFound) { //Check for '+' or '-' characters, and for the ';', to make sure, we are writing method names and not the variables
                    NSString *printable = @"";  //We have to make printable variable because, it depends on the return value of method
                    line = [line stringByReplacingOccurrencesOfString:@";" withString:@""]; //Delete the ';' from the end of the line
                    printf([line UTF8String]);  //Print the line without ';'
                        if ([line rangeOfString:@"void"].location == NSNotFound) { printable = @" { %log; return %orig; }\n"; printf(" { %%log; return %%orig; }\n"); } //Give a value to the printable
                        else { printable = @" { %log; %orig; }\n"; printf(" { %%log %%orig; }\n"); }
                    out = [out stringByAppendingString:line]; //Append line to the writable string
                    out = [out stringByAppendingString:printable];  //... and the printable (%log; and return %orig; or just %orig;)
                }
            }
        out = [out stringByAppendingString:@"%end\n\n"]; //End the hook
        printf("%%end\n\n");    //... and print it
        NSFileHandle *fh = [NSFileHandle fileHandleForWritingAtPath:[NSString  stringWithCString:argv[2]]]; //This needed to write into the file without reading it into the memory
        [fh seekToEndOfFile]; //Jump to the end of the file

        NSData *data = [out dataUsingEncoding:NSUTF8StringEncoding]; // Get NSDate from the 'out' string
        [fh writeData:data]; //Write it
        [fh closeFile]; //And don't forget to close!!!
        /* Thanks for H2CO3 for the tip about NSFileHandle! */
        out = @""; //Make the out variable "" before restarting the for with the next file!
    }
    [pool release];
	return 0;
}

//You can build this tool with theos