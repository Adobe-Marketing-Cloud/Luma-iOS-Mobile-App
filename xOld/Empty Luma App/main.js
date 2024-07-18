// SEND PUSH NOTIFICATION
Parse.Cloud.define("pushiOS", function(request, response) {

  var user = request.user;
  var params = request.params;
  var userObjectID = params.userObjectID
  var data = params.data

  var recipientUser = new Parse.User();
  recipientUser.id = userObjectID;

  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo("userID", userObjectID);

  Parse.Push.send({
    where: pushQuery,
    data: data
  }, { success: function() {
      console.log("#### PUSH SENT!");
  }, error: function(error) {
      console.log("#### PUSH ERROR: " + error.message);
  }, useMasterKey: true});
  response.success('success');
});


// BLOCK A USER  ----------------------------------------
Parse.Cloud.define("reportUser", function(request, response) {

    var userId = request.params.userId;
    var reportMessage = request.params.reportMessage;

    var User = Parse.Object.extend('_User'),
    user = new User({ objectId: userId });

    user.set('isReported', true);
    user.set('reportMessage', reportMessage);

    Parse.Cloud.useMasterKey();
    user.save(null, { useMasterKey: true } ).then(function(user) {
        response.success(user);
    }, function(error) {
        response.error(error)
    });

});



// MUTE/UNMUTE A USER  ----------------------------------------
Parse.Cloud.define("muteUnmuteUser", function(request, response) {

    var userId = request.params.userId;
    var mutedBy = request.params.mutedBy;

    // Query
    var User = Parse.Object.extend('_User'),
    user = new User({ objectId: userId });
    user.set('mutedBy', mutedBy);

    Parse.Cloud.useMasterKey();
    user.save(null, { useMasterKey: true } ).then(function(user) {
        response.success(user);
    }, function(error) {
        response.error(error)
    });
});


// BLOCK/UNBLOCK A USER  ----------------------------------------
Parse.Cloud.define("blockUnblockUser", function(request, response) {

    var userId = request.params.userId;
    var blockedBy = request.params.blockedBy;

    // Query
    var User = Parse.Object.extend('_User'),
    user = new User({ objectId: userId });
    user.set('blockedBy', blockedBy);

    Parse.Cloud.useMasterKey();
    user.save(null, { useMasterKey: true } ).then(function(user) {
        response.success(user);
    }, function(error) {
        response.error(error)
    });
});


// SEND PUSH NOTIFICATION FOR ANDROID
Parse.Cloud.define("pushAndroid", function(request, response) {

  var user = request.user;
  var params = request.params;
  var userObjectID = params.userObjectID;
  var data = params.data;

  
  var recipientUser = new Parse.User();
  recipientUser.id = userObjectID;

  var pushQuery = new Parse.Query(Parse.Installation);
  pushQuery.equalTo("userID", userObjectID);


  Parse.Push.send({
    where: pushQuery, // Set our Installation query
    data: {
       alert: data
    }  
}, { success: function() {
      console.log("#### PUSH OK");
  }, error: function(error) {
      console.log("#### PUSH ERROR" + error.message);
  }, useMasterKey: true});

  response.success('success');
});
