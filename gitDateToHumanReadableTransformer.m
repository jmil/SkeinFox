//
//  gitDateToHumanReadableTransformer.m
//  SkeinFox
//
//  Created by Jordan on 10/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "gitDateToHumanReadableTransformer.h"


@implementation gitDateToHumanReadableTransformer


+ (Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}


- (id)transformedValue:(id)value
{
    return @"hello";
}



@end
