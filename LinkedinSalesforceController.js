({
    init : function(component, event, helper){
        var action = component.get("c.doGetAuthorizationCodevf");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                console.log('===storeResponse==='+storeResponse);
                // set current user information on userInfo attribute
                component.set("v.userInfo", storeResponse);
            }
        });
        $A.enqueueAction(action);
    }
      
})