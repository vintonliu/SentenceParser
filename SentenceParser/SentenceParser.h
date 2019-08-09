//
//  SentenceParser.h
//  SentenceParser
//
//  Created by VintonLiu on 2019/8/4.
//  Copyright © 2019 VintonLiu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SentenceParser : NSObject
+ (NSString*)parse:(NSString*)sentence;
@end

NS_ASSUME_NONNULL_END
