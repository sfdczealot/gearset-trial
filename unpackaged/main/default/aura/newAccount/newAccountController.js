({
  doInit: function(component, event, helper) {
    var action = component.get("c.getDetails");
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state == "SUCCESS") {
        var output = response.getReturnValue();
        var query = location.search.substr(1);
        var result = {};
        query.split("&").forEach(function(part) {
          var item = part.split("=");
          result[item[0]] = decodeURIComponent(item[1]);
        });
        console.log(result);

        var params = {};
        var vars = query.split("&");
        var recTypeId = vars[0].split('=');
        var agentRecTypeId = $A.get("$Label.c.PG_Label_Agent_RecordType_Id");
          
        for (var i = 0; i < vars.length; i++) {
          var pair = vars[i].split("=");
          params[pair[0]] = decodeURIComponent(pair[1]);
        }
        var pageRef = component.get("v.pageReference");
        console.log(JSON.stringify(pageRef));
        var state = pageRef.state;
        // state holds any query params
        console.log("state = " + JSON.stringify(state));
        var base64Context = state.inContextOfRef;
        console.log("base64Context = " + base64Context);
        if (!$A.util.isUndefinedOrNull(base64Context)) {
          if (base64Context.startsWith("1.")) {
            base64Context = base64Context.substring(2);
            console.log("base64Context = " + base64Context);
          }

          var addressableContext = JSON.parse(window.atob(base64Context));

          console.log(
            "addressableContext = " + JSON.stringify(addressableContext)
          );
        }
        var navigationLocation = "";
        if (!$A.util.isUndefinedOrNull(addressableContext)) {
          if (
            !$A.util.isUndefinedOrNull(
              addressableContext["attributes"]["recordId"]
            ) &&
            addressableContext["attributes"]["objectApiName"] == "Account"
          ) {
            navigationLocation =
              "RELATED_LIST&uid=1587035153529&backgroundContext=%2Flightning%2Fr%2F" +
              addressableContext["attributes"]["recordId"] +
              "%2Frelated%2FAgency__r%2Fview";
          } else {
            navigationLocation =
              "LIST_VIEW&backgroundContext=%2Flightning%2Fo%2FAccount%2Flist%3FfilterName%3DRecent";
          }
        } else {
          navigationLocation =
            "LIST_VIEW&backgroundContext=%2Flightning%2Fo%2FAccount%2Flist%3FfilterName%3DRecent";
        }

        var currentURL =
          "lightning/o/Account/new?count=2&nooverride=1&useRecordTypeCheck=1&navigationLocation=" +
          navigationLocation;
        //'&recordTypeId='+result["recordTypeId"]+'&additionalParams'+result["additionalParams"];
        if (!$A.util.isUndefinedOrNull(result["recordTypeId"])) {
          currentURL += "&recordTypeId=" + result["recordTypeId"];
        } else if (!$A.util.isUndefinedOrNull(output.recordType)) {
          currentURL += "&recordTypeId=" + output.recordType;
        }
        if (output.profileName == "System Administrator" ||
            output.profileName == "Delegated System Administrator" ||
            output.profileName == "API User Profile") {
            if(recTypeId[1] == agentRecTypeId)
          currentURL += "&&defaultFieldValues=LastName=last,FirstName=first";
          if (
            !$A.util.isUndefinedOrNull(
              addressableContext["attributes"]["recordId"]
            ) &&
            addressableContext["attributes"]["objectApiName"] == "Account"
          ) {
            currentURL +=
              ",Agency__c=" + addressableContext["attributes"]["recordId"];
          }
        }

        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
          url: "/" + currentURL
        });
        console.log(currentURL);

        window.open(
          "https://" + window.location.hostname + "/" + currentURL,
          "_self"
        );
        // urlEvent.fire();
      }
    });
    $A.enqueueAction(action);
  }
});