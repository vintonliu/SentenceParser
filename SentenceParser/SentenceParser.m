//
//  SentenceParser.m
//  SentenceParser
//
//  Created by VintonLiu 2019/8/4.
//  Copyright © 2019 VintonLiu. All rights reserved.
//

#import "SentenceParser.h"

@implementation SentenceParser
+ (NSString*)parse:(NSString*)sentence {
//    NSLog(@"%@", sentence);
//    if ([sentence containsString:@"+"]) {
//        return sentence;
//    }
    
    // replace "\t, \r, \n, ^, chinese( [^\x20-\x7e]* )" to null
    sentence = [sentence stringByReplacingOccurrencesOfString:@"\\^|\\\\t|\\\\r|\\\\n|[^\\x20-\\x7e]*"
                                                             withString:@""
                                                                options:NSRegularExpressionSearch
                                                                  range:NSMakeRange(0, sentence.length)];
//    NSLog(@"%@", sentence);
    
    // replace "-, (, )" to space
    sentence = [sentence stringByReplacingOccurrencesOfString:@"[-()]"
                                                   withString:@" "
                                                      options:NSRegularExpressionSearch
                                                        range:NSMakeRange(0, sentence.length)];
//    NSLog(@"%@", sentence);
    
    /* process pattern "A a" return "A" */
    NSArray* words = [sentence componentsSeparatedByString:@" "];
    if ((words.count == 2) &&
        ([[words objectAtIndex:0] caseInsensitiveCompare:[words objectAtIndex:1]] == NSOrderedSame)) {
        return [[words objectAtIndex:0] uppercaseString];
    }
    
    /* process pattern {a # b $ c} */
    int choiceSize = [SentenceParser checkChoiceSentence:sentence];
    if (choiceSize > 0) {
//        NSLog(@"choiceSize = %d", choiceSize);
        sentence = [SentenceParser parseChoiceSentence:sentence];
    }
    
    // replace multi spaces to one space
    sentence = [sentence stringByReplacingOccurrencesOfString:@"[  ]+"
                                                   withString:@" "
                                                      options:NSRegularExpressionSearch
                                                        range:NSMakeRange(0, sentence.length)];
//    NSLog(@"%@", sentence);
    return sentence;
}

+ (int) checkChoiceSentence: (NSString*) sentence {
    int openCount = 0;
    int closeCount = 0;
    NSString* tempStr = sentence;
    int openIndex = 0, closeIndex = 0;
    
    while ((openIndex = (int)[tempStr rangeOfString:@"{"].location) >= 0) {
        ++openCount;
        
        if ((closeIndex = (int)[tempStr rangeOfString:@"}"].location) > openIndex) {
            ++closeCount;
        } else {
            break;
        }
        
        tempStr = [tempStr substringFromIndex:(closeIndex + 1)];
    }
    
    if (openCount != closeCount) {
        return -1;
    }
    
    return openCount;
}

+ (NSString*) parseChoiceSentence: (NSString*) sentence {
    NSMutableArray *originList = [[NSMutableArray alloc] init];
    NSMutableArray *choiceList = [[NSMutableArray alloc] init];
    NSMutableDictionary *choiceSentences = [[NSMutableDictionary alloc] init];
    
    NSString* tempStr = sentence;
    int openIndex = 0, closeIndex = 0;
    while ((openIndex = (int)[tempStr rangeOfString:@"{"].location) >= 0) {
        closeIndex = (int)[tempStr rangeOfString:@"}"].location;
        [originList addObject:[tempStr substringToIndex:openIndex]];
        
        NSString *choice = [tempStr substringWithRange:NSMakeRange(openIndex + 1, (closeIndex - 1 - openIndex))];
        if ([choice containsString:@"#"]) {
            NSArray* words = [choice componentsSeparatedByString:@"#"];
            if ((words.count == 2) &&
                ([[words objectAtIndex:0] length] > 0) &&
                ([[words objectAtIndex:1] length] > 0)) {
                NSString *key = [words objectAtIndex:0];
                [choiceList addObject:key];
                
                NSArray * choices = [[words objectAtIndex:1] componentsSeparatedByString:@"$"];
                [choiceSentences setObject:choices forKey:key];
            }
        }
        
        tempStr = [tempStr substringFromIndex:closeIndex + 1];
    }
    // last partial if have
    if ([tempStr length] > 0) {
        [originList addObject:[tempStr substringFromIndex:0]];
    }
    
    /* Combine all possibilities sentence */
    NSMutableArray *sentences = [[NSMutableArray alloc] init];
    for (int i = 0; i < originList.count; ++i) {
        if (i == 0) {
            [sentences addObject:[originList objectAtIndex:i]];
        } else {
            for (int j = 0; j < sentences.count; ++j) {
                NSString* sent = [[sentences objectAtIndex:j] stringByAppendingString:[originList objectAtIndex:i]];
                [sentences replaceObjectAtIndex:j withObject:sent];
            }
        }
        
        if (i < choiceList.count) {
            NSString *key = [choiceList objectAtIndex:i];
            NSArray *choices = [choiceSentences objectForKey:key];
            
            NSMutableArray* tmpSents = [sentences mutableCopy];
            [sentences removeAllObjects];
            
            for (NSString* choice in choices) {
                for (NSString* sent in tmpSents) {
                    [sentences addObject:[sent stringByAppendingString:choice]];
                }
            }
        }
    }
    
    
    sentence = [sentences componentsJoinedByString:@"|"];
    
    return sentence;
}
@end
