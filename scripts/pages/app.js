//initialize an ember app
Piccee = Em.Application.create({
    ready: function() {
        this._super();
    }
});

//initialize the connection to parse
// Piccee-Dev
var appId = 'yyQt1Xp0x9mKj5dAcmIZampwn3G4MC3iYawdDF9g';
var jsKey = 'NWAbLes61CspfaPCEe8RPAnFAamdk3PYEAmYjbCy';

Parse.initialize(appId, jsKey);

