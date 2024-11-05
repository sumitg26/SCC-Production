({
    doInit : function(component, event, helper) {
        console.log('do init')
        var objRecordId = component.get("v.recordId");
        console.log('objRecordId= '+objRecordId);
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(function(position) {
                
                //Comment out for temporarily deactivate the GPS functionality and have only the timestamp captured.
           		// Dt - 20/08/2024
           		
               /* var lat = position.coords.latitude;
                var lon = position.coords.longitude;
                component.set("v.lat",position.coords.latitude);
                component.set("v.lon",position.coords.longitude);
                console.log('latitude = '+lat);
                console.log('longitude  = '+lon);*/
                var action = component.get("c.checkOut");
                console.log('action '+action);
                action.setParams({
                  //  "latitude": lat,
                  //  "longitude": lon,
                    "recId": objRecordId
                });
                action.setCallback(this,function(response){
                    var state = response.getState();
                    console.log('state of callback = '+state);
                    if(state === 'SUCCESS'){
                        $A.get("e.force:closeQuickAction").fire();
                        $A.get('e.force:refreshView').fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": 'success',
                            "message": "Check out Successful."
                        });
                        toastEvent.fire();
                    }
                });
                $A.enqueueAction(action);
            });
            
        } else {
            console.log('Your browser does not support GeoLocation');
        }
    }
    
})