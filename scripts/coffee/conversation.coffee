GetConversations = ->
  htmlConversations = ""
  htmlMessages = ""
  username = ""
  userIDs = new Array()
  userNames = new Array()
  conversations = new Array()
  conversationIDs = new Array()
  currentIndex = 0
  counter = 0
  talkingTo = ""
  talkingTo2 = ""
  UserConversation = Parse.Object.extend("UserConversation")
  con1 = new Parse.Query(UserConversation)
  con2 = new Parse.Query(UserConversation)
  con1.equalTo "initiator",
    __type: "Pointer"
    className: "_User"
    objectId: initiator

  con2.equalTo "participant",
    __type: "Pointer"
    className: "_User"
    objectId: initiator

  
  #We only want to display one conversation so
  #make sure we only get the latest conversation.
  query = new Parse.Query.or(con1, con2)
  query.descending "updatedAt"
  query.find
    success: (convers) ->
      for i of convers
        
        #Extract the person we are conversating with...
        talkingTo = (if initiator is convers[i].attributes.initiator.id then convers[i].attributes.participant.id else convers[i].attributes.initiator.id)
        
        #Curious why the user object isn't available in the initiator or participator
        #since it isn't just work with the User ID (ObjectID).                                                        
        #Don't add duplicates.
        if $.inArray(talkingTo, userIDs) < 0
          userIDs[counter] = talkingTo
          conversations[counter] = convers[i]
          counter++
      
      #Now that we have all the users we need to get the name.
      #----------------------------------------------------------------------------------------
      User = Parse.Object.extend("User")
      userQuery = new Parse.Query(User)
      userQuery.containedIn "objectId", userIDs
      userQuery.find
        success: (friends) ->
          for f of friends
            currentIndex = $.inArray(friends[f].id, userIDs)
            userNames[currentIndex] = friends[f].attributes.firstName  if currentIndex >= 0
          
          #htmlConversations += "<div>UserID: " + userIDs[currentIndex] + " Username: " + userNames[currentIndex] + " ConversationID: " + conversations[currentIndex].id + "</div>";
          
          #$("#myConversations").html(htmlConversations);
          
          #Finally get the latest messages.
          #--------------------------------------------------------------------------------
          UserMessage = Parse.Object.extend("UserMessage")
          userMessageQuery = new Parse.Query(UserMessage)
          userMessageQuery.descending "updatedAt"
          userMessageQuery.containedIn "userConversation", conversations
          counter = 0
          userMessageQuery.find
            success: (msgs) ->
              for m of msgs
                
                #htmlMessages += "<div>ConversationID: " + msgs[m].attributes.userConversation.id + " MessageID: " + msgs[m].id + " Message: " + msgs[m].attributes.message + "</div>";
                backcolor = "red"
                if counter % 2 is 0
                  backcolor = "blue"
                else
                  backcolor = "red"
                
                #Only add in the latest message.
                if $.inArray(msgs[m].attributes.userConversation.id, conversationIDs) is -1
                  htmlConversations += "<div onclick='GetConversation(this);' id='" + msgs[m].attributes.userConversation.id + "' class='conversationContainer' style=" + "\"background-color: " + backcolor + "\"" + "><div class='userPic'></div><div class='participantInfo'>" + userNames[counter] + "</div/><div class='latestMessage'>" + msgs[m].attributes.message + "</div><div class='msgTimeFrame'></div></div>"
                  conversationIDs[counter] = msgs[m].attributes.userConversation.id
                  counter++
              $("#myConversations").html htmlConversations

            
            #$("#activeConversation").html(htmlMessages);
            error: (object, error) ->
              alert "An error occurred"
              
        error: (object, error) ->
          alert "An error occurred"
              
    #----------------------------------------------------------------------------------------
    error: (object, error) ->
      alert "An error occurred"




GetConversation = (item) ->
  conversationID = $(item).attr("id")
  UserConversation = Parse.Object.extend("UserConversation")
  query = new Parse.Query(UserConversation)
  htmlMessages = ""
  conversation = undefined
  communicatingWith = undefined
  pics = new Array()
  counter = 0
  
  query.equalTo "objectId", conversationID
  query.find
    success: (convers) ->
      conversation = convers[0]
      
      #Get the info of the person we are conversating with...
      if conversation.attributes.initiator.id is initiator
        communicatingWith = conversation.attributes.participant
      else
        communicatingWith = conversation.attributes.initiator

      User = Parse.Object.extend("User")
      userQuery = new Parse.Query(User)
      userQuery.get communicatingWith.id,
        success: (user) ->
          communicatingWith = user
          Message = Parse.Object.extend("UserMessage")
          Photo = Parse.Object.extend("UserPhoto")
          innerQuery = new Parse.Query(Message)
          innerQuery.equalTo "userConversation", conversation
          relQuery = new Parse.Query(Photo)
          relQuery.matchesQuery "userPhoto", innerQuery
          relQuery.find success: (retrievedMsgs) ->
            alert "got it!"

          UserMessage = Parse.Object.extend("UserMessage")
          msgQuery = new Parse.Query(UserMessage)
          msgQuery.descending "updatedAt"
          msgQuery.equalTo "userConversation", conversation
          
          #Get all the messages for the queried conversation.
          msgQuery.find
            success: (msgs) ->
              for i of msgs
                
                #Get an array of all the pictures in the retrieved messages.
                if msgs[i].attributes.userPhoto?
                  pics[counter] = msgs[i].attributes.userPhoto
                  counter++
                UserPhoto = Parse.Object.extend("UserPhoto")
                photoQuery = new Parse.Query(UserPhoto)
                photoQuery.containedIn()
                
                #Extract the messages...
                htmlMessages += "<div>" + communicatingWith.attributes.firstName + " MessageID: " + msgs[i].id + " Message: " + msgs[i].attributes.message + "</div>"
              $("#activeConversation").html htmlMessages

            error: (object, error) ->
              alert "An error occurred"


        error: (object, error) ->
          alert "An error occurred"


    error: (object, error) ->
      alert "An error occurred"
