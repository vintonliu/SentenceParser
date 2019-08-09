//
//  ASRResultParser.m
//  SentenceParser
//
//  Created by VintonLiu on 2019/8/8.
//  Copyright © 2019 刘文昌. All rights reserved.
//

#import "ASRResultParser.h"

@interface Word : NSObject
@property (nonatomic, retain) NSString* word;
@property (nonatomic, assign) int score;
@end

@implementation Word

- (id) initWith: (NSString *) word andScore:(int) score {
    self = [super init];
    if (self) {
        self.word = word;
        self.score = score;
    }
    return self;
}

@end

@implementation ASRResultParser
{
    int _source;
    NSString *_recordId;
    NSMutableArray *_words;
}

- (id) init {
    self = [super init];
    if (self) {
        _source = 0;
        self._overall = 0;
        self._refText = @"";
        _recordId = nil;
        _words = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (nonnull NSString *)parse:(int)source result:(nonnull NSString *)result {
    [self reset];
    
    _source = source;
    
    if (source == 2) {
        [self parseSkegnResult:result];
    } else if (source == 3) {
        [self parseVqdResult:result];
    }
    
    return [self buildUnifiedResult];
}

- (void) reset {
    _source = 0;
    self._overall = 0;
    self._refText = @"";
    _recordId = nil;
    [_words removeAllObjects];
}

- (void) parseSkegnResult: (const NSString *) result {
    NSData *rootData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *rootDict = [NSJSONSerialization JSONObjectWithData:rootData options:NSJSONReadingMutableLeaves error:nil];
    if ([[rootDict allKeys] containsObject:@"refText"]) {
        self._refText = [rootDict objectForKey:@"refText"];
    }
    
    if ([[rootDict allKeys] containsObject:@"recordId"]) {
        _recordId = [rootDict objectForKey:@"recordId"];
    }
    
    if ([[rootDict allKeys] containsObject:@"result"]) {
        NSDictionary* resDict = [rootDict objectForKey:@"result"];
        if ([[resDict allKeys] containsObject:@"overall"]) {
            self._overall = [[resDict objectForKey:@"overall"] intValue];
        } else if ([[resDict allKeys] containsObject:@"confidence"]) {
            self._overall = [[resDict objectForKey:@"confidence"] intValue];
        }
        
        if ([[resDict allKeys] containsObject:@"words"]) {
            NSArray *wordsArr = [resDict objectForKey:@"words"];
            if (wordsArr.count > 0) {
                for (NSDictionary* wordObj in wordsArr) {
                    NSString* word = [wordObj objectForKey:@"word"];
                    int score = 0;
                    if ([[wordObj allKeys] containsObject:@"scores"]) {
                        NSDictionary* wordDict = [wordObj objectForKey:@"scores"];
                        score = [[wordDict objectForKey:@"overall"] intValue];
                    } else if ([[wordObj allKeys] containsObject:@"confidence"]) {
                        score = [[wordObj objectForKey:@"confidence"] intValue];
                    }
                    
                    [_words addObject:[[Word alloc] initWith:word andScore:score]];
                }
            }
        }
    }
}

- (void) parseVqdResult: (const NSString *) result {
    NSData *resData = [result dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resDict = [NSJSONSerialization JSONObjectWithData:resData options:NSJSONReadingMutableLeaves error:nil];
    
    self._overall = [[resDict objectForKey:@"overall"] intValue];
    self._refText = [resDict objectForKey:@"refText"];
}

- (NSString *) buildUnifiedResult {
    NSMutableArray *wordsArr = [[NSMutableArray alloc] init];
    for (Word *word in _words) {
        [wordsArr addObject:@{
                              @"word": word.word,
                              @"score": @(word.score)}];
    }
    
    NSMutableDictionary *resultDict = [[NSMutableDictionary alloc] init];
    [resultDict setObject:@(_source) forKey:@"source"];
    [resultDict setObject:self._refText forKey:@"refText"];
    [resultDict setObject:@(self._overall) forKey:@"overall"];
    if (_recordId != nil) {
        [resultDict setObject:_recordId forKey:@"recordId"];
    }
    
    if (wordsArr.count > 0) {
        [resultDict setObject:wordsArr forKey:@"words"];
    }
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:resultDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return result;
}
@end
