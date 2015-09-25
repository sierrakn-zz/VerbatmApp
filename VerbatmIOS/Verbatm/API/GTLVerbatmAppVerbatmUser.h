/* This file was generated by the ServiceGenerator.
 * The ServiceGenerator is Copyright (c) 2015 Google Inc.
 */

//
//  GTLVerbatmAppVerbatmUser.h
//

// ----------------------------------------------------------------------------
// NOTE: This file is generated from Google APIs Discovery Service.
// Service:
//   verbatmApp/v1
// Description:
//   This is an API
// Classes:
//   GTLVerbatmAppVerbatmUser (0 custom class methods, 5 custom properties)

#if GTL_BUILT_AS_FRAMEWORK
  #import "GTL/GTLObject.h"
#else
  #import "GTLObject.h"
#endif

@class GTLVerbatmAppEmail;
@class GTLVerbatmAppPhoneNumber;

// ----------------------------------------------------------------------------
//
//   GTLVerbatmAppVerbatmUser
//

@interface GTLVerbatmAppVerbatmUser : GTLObject
@property (nonatomic, retain) GTLVerbatmAppEmail *email;

// identifier property maps to 'id' in JSON (to avoid Objective C's 'id').
@property (nonatomic, retain) NSNumber *identifier;  // longLongValue

@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) GTLVerbatmAppPhoneNumber *phoneNumber;
@property (nonatomic, retain) NSNumber *profilePhotoImageID;  // longLongValue
@end
