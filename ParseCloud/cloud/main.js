require("cloud/app.js");

var twilioAccountSid = 'AC3c9e28981c3e0a9d39ea4c2420b7474c';
var twilioAuthToken = '31499c1d4a9065dd07c6512ebd8d7855';
var twilioPhoneNumber = '4259708446';
var secretPasswordToken = 'dQg7cZKt5O8F6VNRbdjW';

var language = "en";
var languages = ["en", "es", "ja", "kr", "pt-BR"];

var twilio = require('twilio')(twilioAccountSid, twilioAuthToken);

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
var ChannelClass = Parse.Object.extend("ChannelClass");
var BlockClass = Parse.Object.extend("BlockClass");

// NOTIFICATIONS - PUSH

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
      return;
    }
	var query = new Parse.Query(NotificationClass);
	var notificationSender = request.object.get("NotificationSender");
	var notificationReceiver = request.object.get("NotificationReceiver");
	query.equalTo("NotificationSender", notificationSender);
	query.equalTo("NotificationReceiver", notificationReceiver);
	var notificationType = request.object.get("NotificationType");
	query.equalTo("NotificationType", notificationType);
	// If this is a like or a share notification
	if (notificationType == 2) {
		query.equalTo("NotificationPost", request.object.get("NotificationPost"));
	}
	query.first().then(function(existingObject) {
	    if (existingObject && (notificationType == 1 || notificationType == 2 
	    	|| notificationType == 4 || notificationType == 16)) {
	        response.error("Existing notification");
	    } else { 
	      	// Send a push notification
	      	notificationSender.fetch().then(function(fetchedUser) {
	      		var notificationSenderName = fetchedUser.get("VerbatmName");
			  	var pushQuery = new Parse.Query(Parse.Installation);
			  	// pushQuery.equalTo('deviceType', 'ios');
			  	var targetUser = new Parse.User();
				targetUser.id = notificationReceiver.id;
			  	pushQuery.equalTo('user', targetUser);
			    var notificationText = "";
			    if (notificationType == 1) {
			    	notificationText =  notificationSenderName + " is now following you!";
			    } else if (notificationType == 2) {
			    	notificationText = notificationSenderName + " liked your post!";
			    } else if (notificationType == 4) {
			    	notificationText = "Your friend " + notificationSenderName + " just joined Verbatm!";
			    } else if (notificationType == 8) {
			    	notificationText = notificationSenderName + " shared your post on social media!";
			    } else if (notificationType == 16) {
			    	notificationText = notificationSenderName + " just created their first Verbatm post";
			    } else if (notificationType == 32) {
			    	notificationText = notificationSenderName + " reblogged your post!";
			    } else if (notificationType == 64) {
			    	notificationText = notificationSenderName + " commented on your post!";
			    } else if (notificationType == 128) {
			    	notificationText = notificationSenderName + " replied to your comment!";
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
				      response.error("Got an error " + error.code + " : " + error.message);
				    }
				});
	      	});
	    }
    });
});

// Send push notification when someone posts
Parse.Cloud.beforeSave("PostChannelActivityClass", function(request, response) {
	if (!request.object.isNew()) {
		response.success();
		return;
	}
	var userWhoPosted = request.object.get("RelationshipOwner");
	var channelPostedIn = request.object.get("PostChannelActivityChannelPosted");
	userWhoPosted.fetch().then(function(fetchedUser) {
  		var notificationSenderName = fetchedUser.get("VerbatmName");
  		var query = new Parse.Query(FollowClass);
  		query.equalTo("ChannelFollowed", channelPostedIn);
  		query.find({
		  success: function(results) {
		  	var promises = [];
		    for (var i = 0; i < results.length; i++) {
		    	var followObject = results[i];
		    	var userFollowing = followObject.get("UserFollowing");
		    	var pushQuery = new Parse.Query(Parse.Installation);
			  	// pushQuery.equalTo('deviceType', 'ios');
			  	var targetUser = new Parse.User();
				targetUser.id = userFollowing.id;
			  	pushQuery.equalTo('user', targetUser);
			  	var notificationText = notificationSenderName + " just posted in their Verbatm blog!";
		    	promises.push(Parse.Push.send({
				    where: pushQuery, // Set our Installation query
				    data: {
				      alert: notificationText,
				      notificationType: 20
				    }
				}, {
				    success: function() {
				      //do nothing
				    },
				    error: function(error) {
				      console.log(error);
				    }
				}));
		    }
		    Parse.Promise.when(promises).then(function(results) {
				console.log(results); 
				response.success(); 
			});
		  },

		  error: function(error) {
		    response.error("Got an error " + error.code + " : " + error.message);
		  }
		});
  	});
});

// DON'T SAVE MULTIPLE LIKE OR FOLLOWS

Parse.Cloud.beforeSave("LikeClass", function(request, response) {
	// Let existing object updates go through
	if (!request.object.isNew()) {
      response.success();
      return;
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
      return;
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

// DEFAULT PUBLIC READ FOR USER

Parse.Cloud.beforeSave(Parse.User, function(request, response) {
  	var newACL = new Parse.ACL();
  	newACL.setPublicReadAccess(true);
 	request.object.setACL(newACL);
 	response.success();
});

Parse.Cloud.define("notifyFacebookFriends", function(req, res) {
	var user = new Parse.User();
	user.id = req.params.userId;
	user.fetch().then(function(user) {
		console.log("Fetched user");
	  	var notificationSenderName = user.get("VerbatmName");
		var promise = getFacebookFriends(user);
	    promise.then(function(friends) {
		    for (var i = 0; i < friends.length; i++) {
		    	var friend = friends[i];
		    	console.log("Friend: " + friend);
		    	var notification = new NotificationClass();
		    	notification.set("IsNewNotification", true);
		    	notification.set("NotificationSender", user);
		    	notification.set("NotificationReceiver", friend);
		    	notification.set("NotificationType", 4); // friend joined verbatm
		    	notification.save(null,null);
		    }
			res.success(); 
			
		}, function(err) {
			res.error(err);
		});
	});
});

// GET DISCOVER CHANNELS

// Pass a user id
Parse.Cloud.define("getFacebookFriends", function(req, res) {
	var user = new Parse.User();
	user.id = req.params.userId;
	user.fetch().then(function(user) {
        var promise = getFacebookFriends(user);
        promise.then(function(friends) {
			res.success(friends);
		}, function(err) {
			res.error(err);
		});
    },
    function(error) {
        res.error(error);
    });
});

// Returns a promise that resolves to an array of fb friends of user 
// as User objects, if they are logged in with Facebook. Otherwise 
// rejects with an error or null.
function getFacebookFriends(user) {
	var promise = new Parse.Promise();
	if (Parse.FacebookUtils.isLinked(user)) {
	    Parse.Cloud.httpRequest({
	        url:'https://graph.facebook.com/me/friends?fields=id,name&access_token='+user.get('authData').facebook.access_token,
	        success:function(httpResponse) {
	        	var friendObjects = httpResponse.data.data;
	        	var friendIds = [];
	        	for (var i = 0; i < friendObjects.length; i++) {
		    		var friendObject = friendObjects[i];
	        		friendIds.push(friendObject["id"]);
	        	}
	        	var friendQuery = new Parse.Query(Parse.User);
	        	friendQuery.containedIn("FbID", friendIds);
	        	friendQuery.limit = 1000;
	        	friendQuery.find({
				  success: function(results) {
				  	promise.resolve(results);
				  },

				  error: function(error) {
				    console.error(httpResponse);
				    promise.reject(error);
				  }
				});
	        },
	        error:function(httpResponse) {
	        	console.error(httpResponse);
	        	promise.reject(httpResponse);
	        }
	    });
	} else {
		console.log("New user not linked to facebook.");
		promise.reject(null);
	}
	return promise;
}

Parse.Cloud.define("getPhoneContactsChannels", function(req, res) {
	var phoneNumbers = req.params.phoneNumbers;
	var promise = getPhoneContacts(phoneNumbers);
	promise.then(function(friends) {
		res.success(friends);
	}, function(err) {
		res.error(err);
	});
});

// Returns a promise that resolves to an array of PFUsers,
// or an error.
function getPhoneContacts(phoneNumbers) {
	var promise = new Parse.Promise();
	var friendQuery = new Parse.Query(Parse.User);
	friendQuery.containedIn("username", phoneNumbers);
	friendQuery.limit = 1000;
	friendQuery.find({
	  success: function(results) {
	  	promise.resolve(results);
	  },

	  error: function(error) {
	    console.error(httpResponse);
	    promise.reject(error);
	  }
	});
	return promise;
}

function getUsersWhoHaveBlockedUser(user) {
	var promise = new Parse.Promise();
	var blockQuery = new Parse.Query(BlockClass);
	blockQuery.equalTo("BlockUserBlocked", user);
	blockQuery.limit(1000);
	blockQuery.find({
		  success: function(results) {
		  	var usersWhoBlocked = [];
		    for (var i = 0; i < results.length; i++) {
		    	var blockObject = results[i];
		    	var userBlocking = blockObject.get("BlockUserBlocking");
		    	usersWhoBlocked.push(userBlocking);
		    }
		    promise.resolve(usersWhoBlocked);
		  },

		  error: function(error) {
		    promise.reject(error);
		  }
		});
	return promise;
}

function getChannelsFromUsers(users, usersWhoBlocked, channelsFollowed) {
	var promise = new Parse.Promise();
	var channelsQuery = new Parse.Query(ChannelClass);
	channelsQuery.containedIn("ChannelCreator", users);
	channelsQuery.notContainedIn("ChannelCreator", usersWhoBlocked);
	channelsQuery.notContainedIn("objectId", channelsFollowed);
	channelsQuery.limit = 1000;
	channelsQuery.find({
	  success: function(results) {
	  	promise.resolve(results);
	  },

	  error: function(error) {
	    console.error(error);
	    promise.reject(error);
	  }
	});
	return promise;
}

Parse.Cloud.define("getFriendsChannels", function(req, res) {
	var user = new Parse.User();
	user.id = req.params.userID;
	var phoneNumbers = req.params.phoneNumbers;
	var data = {};
	user.fetch().then(function(user) {
		return getUsersWhoHaveBlockedUser(user);
	}).then(function(usersWhoBlocked) {
		data.usersWhoBlocked = usersWhoBlocked;
		return getChannelsFollowed(user);
	}).then(function(channelsFollowed) {
		data.channelsFollowedIds = [];
		for (var i = 0; i < channelsFollowed.length; i++) {
		    var channel = channelsFollowed[i];
		    data.channelsFollowedIds.push(channel.id);
		}
		return getPhoneContacts(phoneNumbers);
	}).then(function(phoneContactFriends) {
		data.phoneContactFriends = phoneContactFriends;
		return getFacebookFriends(user);
	}).then(function(facebookFriends) {
		var friends = data.phoneContactFriends.concat(facebookFriends);
		return getChannelsFromUsers(friends, data.usersWhoBlocked, data.channelsFollowedIds);
	}).then(function(channels) {
		res.success(channels);
	}, function(err) {
		res.error(err);
	});
});

Parse.Cloud.define("getDiscoverChannels", function(req, res) {
	var user = new Parse.User();
	user.id = req.params.userID;
	var phoneNumbers = req.params.phoneNumbers;
	var skip = req.params.skip;
	var data = {};
	user.fetch().then(function(user) {
		return getUsersWhoHaveBlockedUser(user);
	}).then(function(usersWhoBlocked) {
		data.usersToFilter = usersWhoBlocked;
		data.usersToFilter.push(user);
		return getChannelsFollowed(user);
	}).then(function(channelsFollowed) {
		data.channelsFollowedIds = [];
		for (var i = 0; i < channelsFollowed.length; i++) {
		    var channel = channelsFollowed[i];
		    data.channelsFollowedIds.push(channel.id);
		}
		return getPhoneContacts(phoneNumbers);
	}).then(function(phoneContactFriends) {
		data.usersToFilter = data.usersToFilter.concat(phoneContactFriends);
		return getFacebookFriends(user);
	}).then(function(facebookFriends) {
		data.usersToFilter = data.usersToFilter.concat(facebookFriends);
		return getExploreChannels(data.usersToFilter, data.channelsFollowedIds, skip);
	}).then(function(channels) {
		res.success(channels);
	}, function(err) {
		res.error(err);
	});
});

function getExploreChannels(usersToFilter, channelsFollowed, skip) {
	var promise = new Parse.Promise();
	var channelsQuery = new Parse.Query(ChannelClass);
	channelsQuery.notContainedIn("ChannelCreator", usersToFilter);
	console.log("channels followed: " + channelsFollowed);
	channelsQuery.notContainedIn("objectId", channelsFollowed);
	channelsQuery.limit(30);
	channelsQuery.exists("ChannelLatestPostDate");
	channelsQuery.skip(skip);
	channelsQuery.descending("ChannelNumFollows");
	channelsQuery.find({
	  success: function(results) {
	  	promise.resolve(results);
	  },

	  error: function(error) {
	    console.error(httpResponse);
	    promise.reject(error);
	  }
	});
	return promise;
}

// CHANNELS FOR LIKES/SHARES

Parse.Cloud.define("getChannelsForLikes", function(req, res) {

});

Parse.Cloud.define("getChannelsForShares", function(req, res) {

});

// CHANNELS FOLLOWED/FOLLOWING

Parse.Cloud.define("getChannelsFollowed", function(req, res) {
	var user = new Parse.User();
	user.id = req.params.userID;
	user.fetch().then(function(user) {
		var promise = getChannelsFollowed(user);
		promise.then(function(channels) {
			res.success(channels);
		}, function(err) {
			res.error(err);
		});
	},
    function(error) {
        res.error(error);
    });
});

function getChannelsFollowed(user) {
	var promise = new Parse.Promise();
	var query = new Parse.Query(FollowClass);
	query.equalTo("UserFollowing", user);
	query.limit(1000);
	query.find({
		  success: function(results) {
		  	var channelsFollowed = [];
		    for (var i = 0; i < results.length; i++) {
		    	var followObject = results[i];
		    	var channel = followObject.get("ChannelFollowed");
		    	channelsFollowed.push(channel);
		    }
		    promise.resolve(channelsFollowed);
		  },

		  error: function(error) {
		    promise.reject(error);
		  }
		});
	return promise;
}

Parse.Cloud.define("getChannelFollowers", function(req, res) {
	var channel = new ChannelClass();
	channel.id = req.params.channelID;
	var query = new Parse.Query(FollowClass);
	query.equalTo("ChannelFollowed", channel);
	query.limit(1000);
	query.find({
		  success: function(results) {
		  	var usersFollowing = [];
		    for (var i = 0; i < results.length; i++) {
		    	var followObject = results[i];
		    	var userFollowing = followObject.get("UserFollowing");
		    	usersFollowing.push(userFollowing);
		    }
		    var query = new Parse.Query(ChannelClass);
		    query.containedIn("ChannelCreator", usersFollowing);
		    query.limit(1000);
		    query.find({
		    	success: function(results) {
		    		res.success(results);
		    	},
		    	error: function(error) {
					res.error("Got an error " + error.code + " : " + error.message);
				}
		    });
		  },

		  error: function(error) {
		    res.error("Got an error " + error.code + " : " + error.message);
		  }
		});
});

// PHONE LOGIN

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

Parse.Cloud.define("deleteCreatedUser", function(req, res) {
	var phoneNumber = req.params.phoneNumber;
	Parse.Cloud.useMasterKey();
	var query = new Parse.Query(Parse.User);
	query.equalTo('username', phoneNumber + "");
	query.first().then(function(user) {
		if (user) {
			user.destroy();
			res.success();
		} else {
			res.error("No user with that phone number found");
		}
	});
});
