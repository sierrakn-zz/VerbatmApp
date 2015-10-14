/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLVerbatmAppImage.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   verbatmApp/v1
// Description:
//   This is an API
// Classes:
//   GTLVerbatmAppImage (0 custom class methods, 6 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

// ----------------------------------------------------------------------------
//
//   GTLVerbatmAppImage
//

@interface GTLVerbatmAppImage : GTLObject

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (nonatomic, retain) NSNumber *identifier;  // longLongValue

@property (nonatomic, retain) NSNumber *indexInPage;  // intValue
@property (nonatomic, copy) NSString *servingUrl;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) NSNumber *textYPosition;  // doubleValue
@property (nonatomic, retain) NSNumber *userKey;  // longLongValue
@end
