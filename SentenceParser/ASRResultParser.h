//
//  ASRResultParser.h
//  SentenceParser
//
//  Created by VintonLiu on 2019/8/8.
//  Copyright © 2019 刘文昌. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASRResultParser : NSObject
@property (nonatomic, retain) NSString* _refText;
@property (nonatomic, assign) int _overall;

- (NSString*) parse: (int) source result:(NSString*) result;
@end

NS_ASSUME_NONNULL_END
