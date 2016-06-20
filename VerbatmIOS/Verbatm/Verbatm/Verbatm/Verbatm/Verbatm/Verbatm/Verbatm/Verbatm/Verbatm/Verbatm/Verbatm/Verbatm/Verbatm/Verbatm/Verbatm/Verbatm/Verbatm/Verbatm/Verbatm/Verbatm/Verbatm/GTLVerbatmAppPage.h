/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2016 Google Inc.
 */

//
//  GTLVerbatmAppPage.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   verbatmApp/v1
// Description:
//   This is an API
// Classes:
//   GTLVerbatmAppPage (0 custom class methods, 4 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLVerbatmAppPage
//

@interface GTLVerbatmAppPage : GTLObject

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (nonatomic, retain) NSNumber *identifier;  // longLongValue

@property (nonatomic, retain) NSArray *imageIds;  // of NSNumber (longLongValue)
@property (nonatomic, retain) NSNumber *indexInPOV;  // intValue
@property (nonatomic, retain) NSArray *videoIds;  // of NSNumber (longLongValue)
@end
