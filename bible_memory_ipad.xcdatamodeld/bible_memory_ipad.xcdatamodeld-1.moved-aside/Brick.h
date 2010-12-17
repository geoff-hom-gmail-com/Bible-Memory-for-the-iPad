//
//  Brick.h
//  bible-memory-ipad
//
//  Created by Geoffrey Hom on 12/2/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Passage;

@interface Brick :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * startingIndex;
@property (nonatomic, retain) Passage * passage;

@end



