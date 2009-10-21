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
    
    if (value == nil) return nil;

    
    // assume default behavior set for class using
    // [NSDateFormatter setDefaultFormatterBehavior:NSDateFormatterBehavior10_4];
    NSDateFormatter *dateFormatter =
    [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterMediumStyle];
    NSDate *date = [NSDate dateWithString:value];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    //NSLog(@"formattedDateString for locale %@: %@", [[dateFormatter locale] localeIdentifier], formattedDateString);
    // Output: formattedDateString for locale en_US: Jan 2, 2001
    
    
    return formattedDateString;
    
}



@end
