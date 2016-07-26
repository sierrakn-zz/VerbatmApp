require("cloud/app.js");

var twilioAccountSid = 'AC3c9e28981c3e0a9d39ea4c2420b7474c';
var twilioAuthToken = '31499c1d4a9065dd07c6512ebd8d7855';
var twilioPhoneNumber = '4259708446';
var secretPasswordToken = 'dQg7cZKt5O8F6VNRbdjW';

var language = "en";
var languages = ["en", "es", "ja", "kr", "pt-BR"];

var twilio = require('twilio')(twilioAccountSid, twilioAuthToken);

Parse.Cloud.define("sendCode", function(req, res) {
	var phoneNumber = req.params.phoneNumber;
	phoneNumber = phoneNumber.replace(/\D/g, '');

	var lang = req.params.language;
  if(lang !== undefined && languages.indexOf(lang) != -1) {
		language = lang;
	}

	if (!phoneNumber || (phoneNumber.length != 10 && phoneNumber.length != 11)) return res.error('Invalid Parameters');
	Parse.Cloud.useMasterKey();
	var query = new Parse.Query(Parse.User);
	query.equalTo('username', phoneNumber + "");
	query.first().then(function(result) {
		var min = 1000; var max = 9999;
		var num = Math.floor(Math.random() * (max - min + 1)) + min;

		if (result) {
			result.setPassword(secretPasswordToken + num);
			result.set("language", language);
			result.save().then(function() {
				return sendCodeSms(phoneNumber, num, language);
			}).then(function() {
				res.success({});
			}, function(err) {
				res.error(err);
			});
		} else {
			var user = new Parse.User();
			user.setUsername(phoneNumber);
			user.setPassword(secretPasswordToken + num);
			user.set("language", language);
			user.setACL({});
			user.save().then(function(a) {
				return sendCodeSms(phoneNumber, num, language);
			}).then(function() {
				res.success({});
			}, function(err) {
				res.error(err);
			});
		}
	}, function (err) {
		res.error(err);
	});
});

Parse.Cloud.define("logIn", function(req, res) {
	Parse.Cloud.useMasterKey();

	var phoneNumber = req.params.phoneNumber;
	phoneNumber = phoneNumber.replace(/\D/g, '');

	if (phoneNumber && req.params.codeEntry) {
		Parse.User.logIn(phoneNumber, secretPasswordToken + req.params.codeEntry).then(function (user) {
			res.success(user.getSessionToken());
		}, function (err) {
			res.error(err);
		});
	} else {
		res.error('Invalid parameters.');
	}
});

// Sets default values to num follows and num following
Parse.Cloud.beforeSave("ChannelClass", function(request, response) {
  if (!request.object.get("ChannelNumFollows")) {
    request.object.set("ChannelNumFollows", 0);
  }
  if (!request.object.get("ChannelNumFollowing")) {
  	request.object.set("ChannelNumFollowing", 0);
  }
  if (!request.object.get("Featured")) {
  	request.object.set("Featured", false);
  }
  response.success();
});

// Do not allow duplicate follows, likes, or notifications
var NotificationClass = Parse.Object.extend("NotificationClass");
var LikeClass = Parse.Object.extend("LikeClass");
var FollowClass = Parse.Object.extend("FollowClass");

/*
NewFollower = 1 << 0, 			// 1
Like = 1 << 1, 					// 2
FriendJoinedVerbatm = 1 << 2, 	// 4
Share = 1 << 3, 				// 8
FriendsFirstPost = 1 << 4, 		// 16
Reblog = 1 << 5 				// 32
*/

Parse.Cloud.beforeSave("NotificationClass", function(request, response) {
	// Let existing object updates go through
	if (!request.object.isNew()) {
      response.success();
    }
	var query = new Parse.Query(NotificationClass);
	var notificationSender = request.object.get("NotificationSender");
	var notificationReceiver = request.object.get("NotificationReceiver");
	query.equalTo("NotificationSender", notificationSender);
	query.equalTo("NotificationReceiver", notificationReceiver);
	var notificationType = request.object.get("NotificationType");
	query.equalTo("NotificationType", notificationType);
	// If this is a like or a share notification
	if (notificationType == 2 || notificationType == 8 || notificationType == 32) {
		query.equalTo("NotificationPost", request.object.get("NotificationPost"));
	}
	query.first().then(function(existingObject) {
      if (existingObject) {
        response.error("Existing notification");
      } else { 
      	// Send a push notification
      	notificationSender.fetch().then(function(fetchedUser) {
      		var notificationSenderName = fetchedUser.get("VerbatmName");
		  	var pushQuery = new Parse.Query(Parse.Installation);
		  	// pushQuery.equalTo('deviceType', 'ios');
		  	pushQuery.equalTo('user', notificationReceiver);
		    var notificationText = "";
		    if (notificationType == 1) {
		    	notificationText =  notificationSenderName + " is now following you!";
		    } else if (notificationType == 2) {
		    	notificationText = notificationSenderName + " has liked your post!";
		    } else if (notificationType == 4) {
		    	notificationText = "Your friend " + notificationSenderName + " has joined Verbatm";
		    } else if (notificationType == 8) {
		    	notificationText = notificationSenderName + " shared your post on social media!";
		    } else if (notificationType == 16) {
		    	notificationText = notificationSenderName + " just created their first Verbatm post";
		    } else if (notificationType == 32) {
		    	notificationText = notificationSenderName + " reblogged your post!";
		    }
			  Parse.Push.send({
			    where: pushQuery, // Set our Installation query
			    data: {
			      alert: notificationText,
			      notificationType: notificationType
			    }
			  }, {
			    success: function() {
			      response.success();
			    },
			    error: function(error) {
			      throw "Got an error " + error.code + " : " + error.message;
			    }
			  });
      	});
      }
    });
});

Parse.Cloud.beforeSave("LikeClass", function(request, response) {
	// Let existing object updates go through
	if (!request.object.isNew()) {
      response.success();
    }
	var query = new Parse.Query(LikeClass);
	query.equalTo("UserLiking", request.object.get("UserLiking"));
	query.equalTo("PostLiked", request.object.get("PostLiked"));
	query.first().then(function(existingObject) {
      if (existingObject) {
        response.error("Existing like");
      } else {
        response.success();
      }
    });
});

Parse.Cloud.beforeSave("FollowClass", function(request, response) {
	// Let existing object updates go through
	if (!request.object.isNew()) {
      response.success();
    }
	var query = new Parse.Query(FollowClass);
	query.equalTo("ChannelFollowed", request.object.get("ChannelFollowed"));
	query.equalTo("UserFollowing", request.object.get("UserFollowing"));
	query.first().then(function(existingObject) {
      if (existingObject) {
        response.error("Existing follow object");
      } else {
        response.success();
      }
    });
});

function sendCodeSms(phoneNumber, code, language) {
	var prefix = "+1";
	if(typeof language !== undefined && language == "ja") {
		prefix = "+81";
	} else if (typeof language !== undefined && language == "kr") {
		prefix = "+82";
		phoneNumber = phoneNumber.substring(1);
	} else if (typeof language !== undefined && language == "pt-BR") {
		prefix = "+55";
  }

	var promise = new Parse.Promise();
	twilio.sendSms({
		to: prefix + phoneNumber.replace(/\D/g, ''),
		from: twilioPhoneNumber.replace(/\D/g, ''),
		body: 'Your login code for Verbatm is ' + code
	}, function(err, responseData) {
		if (err) {
			console.log(err);
			promise.reject(err.message);
		} else {
			promise.resolve();
		}
	});
	return promise;
}

Parse.Cloud.define("sendPushToUser", function(request, response) {
  var senderUser = request.user;
  var recipientUserId = request.params.recipientId;
  var message = request.params.message;

  // Validate that the sender is allowed to send to the recipient. todo when privacy

  // Validate the message text.
  // For example make sure it is under 140 characters
  if (message.length > 140) {
  // Truncate and add a ...
    message = message.substring(0, 137) + "...";
  }

  // Send the push.
  // Find devices associated with the recipient user
  var recipientUser = new Parse.User();
  recipientUser.id = recipientUserId;
  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo("user", recipientUser);
 
  // Send the push notification to results of the query
  Parse.Push.send({
    where: pushQuery,
    data: {
      alert: message
    }
  }).then(function() {
      response.success("Push was sent successfully.")
  }, function(error) {
      response.error("Push failed to send with error: " + error.message);
  });
});
