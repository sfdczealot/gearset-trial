({
    construct: function(component, event, helper) {
        
        var alertMsg = component.find("errorAlert");
        var saveBtn = component.find("saveBtn");
        $A.util.addClass(alertMsg, "slds-hide");
        var accId = component.get("v.recordId");
        var init0 = component.get("c.constructUpgrade");  
        var errors = [];
        var msg = "";
        
        init0.setParams({ accId: accId });
        init0.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                
                // For weekly calculation (Singapore)
                var jsonResult = response.getReturnValue();

                var parsedJSON = JSON.parse(jsonResult);
        
                var result = parsedJSON[0].result;
                var wrapResponseSG;
     
                if(result.agentObj.Country__c == 'Singapore'){
                    wrapResponseSG = parsedJSON[0].wrapResSG;
                    component.set("v.resultData",result);
                    component.set("v.wrapResponseSG",wrapResponseSG);
                    component.set("v.currentPackageAC",wrapResponseSG.currentPackageAC);
                    component.set("v.currentPackagePC",wrapResponseSG.currentPackagePC);
                }
                
                // Added To Restrict Opp Creation Based On Renewal and Upgrade (PGAUTO-5237 and PGAUTO-5245)
                if(result.oppObj.Opportunity_Type__c != undefined)
                {
                    var errMsg;
                    
                    if(result.oppObj.Opportunity_Type__c == 'B2C - Upgrade')
                    {
                        errMsg = $A.get("$Label.c.RESTRICT_OPP_UPGRADE") +' '+ result.oppObj.Opportunity_Number__c;
                    }
                    
                    else if (result.oppObj.Opportunity_Type__c == 'B2C - Renewal')
                    {
                        errMsg = $A.get("$Label.c.RESTRICT_OPP_RENEWAL") +' '+ result.oppObj.Opportunity_Number__c;
                    }
                    
                    component.set("v.showErrorOnExistingOpp",true);
                    component.set("v.errorMsgOnExistingOpp",errMsg);
                    
                }
                
                var resourceList = [{ Product2: { Id: null }, Label: null }];
                var mapPackage = {};
                for (var key in result.listPbEntry) {
                    result.listPbEntry[key].Label =
                        result.listPbEntry[key].Product2.SKU_Code__c +
                        " - " +
                        result.listPbEntry[key].Name +
                        " (" +
                        result.listPbEntry[key].UnitPrice.toLocaleString("en") +
                        ")";
                    resourceList.push(result.listPbEntry[key]);
                    mapPackage[result.listPbEntry[key].Id] = result.listPbEntry[key];
                }
                component.set("v.agentObj", result.agentObj);
                component.set("v.previousProRate", result.agentObj.Pro_Rate_Amount__c);
                component.set("v.loyaltyDetail", result.loyaltyDetail);
                component.set("v.monthUtilised", result.monthUtilised);
                component.set("v.dayUtilised", result.dayUtilised);
                component.set("v.upgradeStartDate", result.upgradeStartDate);
                component.set("v.newPackageStartDate", result.upgradeStartDate);
                component.set("v.listAvailablePackage", resourceList);
                component.set("v.mapPackage", mapPackage);
                component.set("v.totalAmountAfterDiscount", 0);
                
                if (result.agentObj.Country__c == "Thailand") {
                    var duration = component.get("c.getProductDurationvalue");
                    duration.setParams({ accStr: JSON.stringify(result.agentObj) });
                    duration.setCallback(this, function(res) {
                        if (res.getState() === "SUCCESS") {
                            component.set(
                                "v.currentProductUnit",
                                res.getReturnValue().CustItem_Duration_Unit__c
                            );
                            component.set(
                                "v.currentProductValue",
                                res.getReturnValue().CustItem_Duration_Value__c
                            );
                        }
                    });
                    $A.enqueueAction(duration);
                }
                // For weekly calculation (Singapore)
                if(result.agentObj.Country__c == 'Singapore')
                {
                    component.set("v.weekUtilized",wrapResponseSG.weekUtilized);
                    setTimeout(function() {
                        helper.calculateProRateForSGHelper(component);
                    }, 500);
                }
                else{
                    setTimeout(function() {
                        helper.calculateProRateHelper(component);
                    }, 500);
                }
                
                if(result.agentObj.Country__c == 'Singapore') {
                    helper.getAdCredit(component,event,result.agentObj);
                    helper.getPrimeCredit(component,event,result.agentObj);
                }
            } else {
                errors = response.getError();
                for (var i in errors) {
                    msg += "<li>" + errors[i].message + "</li>";
                }
                component.set("v.error", "<ul>" + msg + "</ul>");
                component.set("v.failedInit", true);
                $A.util.removeClass(alertMsg, "slds-hide");
            }
         
        });
        $A.enqueueAction(init0);
    },
    calculateProRateHelper: function(component,event) {
        
        /*
         Account_Rule_Code__c=='LITE'
          Pro Rate = Current Package Cost (Amount Collected + Pro-rate amount) / Lite Period (6) * (Lite Period-Month Utilised)
         ELSE
          Pro Rate = Current Package Cost (Amount Collected + Pro-rate amount) / Normal Period (12) * (Normal Period-Month Utilised)
        */
        var agentObj = component.get("v.agentObj");
        var monthUtilised = component.get("v.monthUtilised");
        var previousProRate = component.get("v.previousProRate");
        var dayUtilised = component.get("v.dayUtilised");
        var period;
        var result;
        var selectedPackage = component.get("v.selectedPackage");
        var mapPackage = component.get("v.mapPackage");
        var loyaltyDetail = component.get("v.loyaltyDetail");
        var totalAmountAfterDiscount;
        
        
        agentObj.Current_Subscription_Spending_Amount__c = isNaN(
            agentObj.Current_Subscription_Spending_Amount__c
        )
        ? 0
        : agentObj.Current_Subscription_Spending_Amount__c;
        monthUtilised = isNaN(monthUtilised) ? 0 : monthUtilised;
        previousProRate = isNaN(previousProRate) ? 0 : previousProRate;
        if (agentObj.Country__c == "Thailand") {
            /*if (agentObj.Account_Rule_Code__c == "PPL3") {
        period = 3;
         } else if (agentObj.Account_Rule_Code__c == "LITE") {
        period = 6;
      }
        else {
        period = 12;
      }*/
            
            var durationUnit = component.get("v.currentProductUnit");
            var durationValue = component.get("v.currentProductValue");
            if (durationUnit == "Years") {
                period = durationValue * 12;
            } else if (durationUnit == "Weeks") {
                period = durationValue / 4.345;
            } else if (durationUnit == "Months") {
                period = durationValue;
            }
            
            result =
                ((agentObj.Current_Subscription_Spending_Amount__c + previousProRate) /
                 period) *
                (period - monthUtilised);
            totalAmountAfterDiscount =
                selectedPackage == undefined
            ? 0
            : mapPackage[selectedPackage].UnitPrice - result;
        } else {
            if (agentObj.Account_Rule_Code__c == "LITE") {
                period = 6;
            } else {
                period = 12;
            }
            
            console.log(
                "(" +
                agentObj.Current_Subscription_Spending_Amount__c +
                "+" +
                previousProRate +
                ") / " +
                period +
                "*" +
                "(" +
                period +
                " - " +
                monthUtilised +
                ")"
            );
            result =
                ((agentObj.Current_Subscription_Spending_Amount__c + previousProRate) /
                 period) *
                (period - monthUtilised);
            /*if (dayUtilised > 60) {
            result = 0;
        }*/
            totalAmountAfterDiscount =
                selectedPackage == undefined
            ? 0
            : mapPackage[selectedPackage].UnitPrice * 1 -
                (loyaltyDetail == undefined || loyaltyDetail.DiscountPercentage == undefined
                 ? 0
                 : (mapPackage[selectedPackage].UnitPrice *
                    1 *
                    loyaltyDetail.DiscountPercentage) /
                 100) -
                result;
        }
        component.set("v.totalAmountAfterDiscount", totalAmountAfterDiscount);
        component.set("v.currentProRate", result);
    },
    
    // For weekly calculation (Singapore)
    calculateProRateForSGHelper: function (component,wrapResponseSG){
        
        var wrapResponseSG = component.get("v.wrapResponseSG");
        var agentObj = component.get("v.agentObj");
        var selectedPackage = component.get("v.selectedPackage");
        var mapPackage = component.get("v.mapPackage");
        var listOfForecast = wrapResponseSG.listForecast;
        var upgradeStartDate = component.get("v.upgradeStartDate");
        
        var DateToday = new Date(
            this.getToday().substr(0, 4) * 1,
            this.getToday().substr(5, 2) * 1 - 1,
            this.getToday().substr(8) * 1
        ); //yyyy, mm, dd
        
        var upgradeStartDateTime = new Date(
            upgradeStartDate.substr(0, 4) * 1,
            upgradeStartDate.substr(5, 2) * 1 - 1,
            upgradeStartDate.substr(8) * 1
        ); //yyyy, mm, dd
        
        if(upgradeStartDate > agentObj.Subscription_End_Date__c)
        {
            upgradeStartDate = agentObj.Subscription_End_Date__c;
        }
        
        
        if(selectedPackage == undefined)
        { 
            component.set("v.totalAmountAfterDiscount", 0);
            component.set("v.currentProRate", 0);
            component.set("v.weekUtilized",wrapResponseSG.weekUtilized);
            component.set("v.upgPackageAC",0);
            component.set("v.proRatedAC",0);
            component.set("v.upgPackagePC",0);
            component.set("v.proRatedPC",0);
         
            if(upgradeStartDateTime < DateToday)
            {
                component.set("v.weekUtilized",0);
            }
        }
        else
        {
            for(var idx in listOfForecast)
            {   var forecast = listOfForecast[idx];
                if(mapPackage[selectedPackage].Name == forecast.packageName &&
                   upgradeStartDate >= forecast.startDate && upgradeStartDate <= forecast.endDate )
                {
                    component.set("v.totalAmountAfterDiscount", forecast.totalAmount);
                    component.set("v.currentProRate", forecast.currentProRate);
                    component.set("v.weekUtilized",forecast.currentWeekUtilized);
                    component.set("v.upgPackageAC",forecast.upgradePackageAC);
                    component.set("v.upgPackagePC",forecast.upgradePackagePC);
                    this.calculateProRatedACEntitlement(component,event);
                    this.calculateProRatedPCEntitlement(component,event);
                    break;
                }
                else {
                    component.set("v.totalAmountAfterDiscount", 0);
                    component.set("v.currentProRate", 0);
                    component.set("v.weekUtilized",0);
                    component.set("v.upgPackageAC",0);
                    component.set("v.proRatedAC",0);
                    component.set("v.upgPackagePC",0);
                    component.set("v.proRatedPC",0);
                }
                
            }
            
        }
        
    },
    
    getAdCredit: function(component,event,agentObj) {
        var action = component.get("c.getConsumedAdCredit");
        var existingErrorMsg = component.get("v.errorMsgOnExistingOpp");
        action.setParams({ agentStr: JSON.stringify(agentObj),
                           accessToken: null,
                           oppId: null,
                           mapOfOppIdVsInternalId:null,
                           productCode : $A.get("$Label.c.AD_CREDIT_PRODUCTCODE")
                         });
        action.setCallback(this, function(res) {
            var errorMsg = "ERROR!!! ";
            if (res.getState() === "SUCCESS") {
                var result = res.getReturnValue();
                if(result.isSuccess) {
                    for(var key in result.responseCredit) {
                        if(result.response == 'No record found in response.') {
                        component.set("v.consumedAC",component.get("v.currentPackageAC"));  
                        }else if(key == 'utilizedQuantity') {
                           component.set("v.consumedAC", result.responseCredit[key]);  
                        } else if (key == 'balanceQuantity') {
                           component.set("v.balanceAC", result.responseCredit[key]);   
                        }
                    }
                    /*if(result.response == 'No record found in response.') {
                        component.set("v.consumedAC",component.get("v.currentPackageAC"));  
                    } else {
                        component.set("v.consumedAC", result.response);
                    }*/
                   this.calculateProRatedACEntitlement(component,event);
                   component.set("v.showCalloutError",false);
                }
                else {
                    errorMsg = errorMsg + result.response;
                    component.set("v.showCalloutError",true);
                    if(existingErrorMsg == undefined || existingErrorMsg == '') {
                        component.set("v.errorMsgOnExistingOpp",errorMsg);
                    }
                }
            } else {
                var errors = [];
                errors = res.getError();
                    for (var i in errors) {
                        errorMsg = errorMsg + errors[i].message;
                    }
                if(existingErrorMsg == undefined || existingErrorMsg == '') {
                    component.set("v.errorMsgOnExistingOpp",errorMsg);
                }
                component.set("v.showCalloutError",true);
            }
            component.set("v.refreshStatus","");
        });
        $A.enqueueAction(action);
    },
    getPrimeCredit: function(component,event,agentObj) {
        var action = component.get("c.getConsumedAdCredit");
        var existingErrorMsg = component.get("v.errorMsgOnExistingOpp");
        action.setParams({ agentStr: JSON.stringify(agentObj),
                           accessToken: null,
                           oppId: null,
                           mapOfOppIdVsInternalId:null,
                           productCode: $A.get("$Label.c.PRIME_CREDIT_PRODUCTCODE")
                         });
        action.setCallback(this, function(res) {
            var errorMsg = "ERROR!!! ";
            if (res.getState() === "SUCCESS") {
                var result = res.getReturnValue();
                if(result.isSuccess) {
                    for(var key in result.responseCredit) {
                        if(result.response == 'No record found in response.') {
                        component.set("v.consumedPC",component.get("v.currentPackagePC"));  
                        }else if(key == 'utilizedQuantity') {
                           component.set("v.consumedPC", result.responseCredit[key]);  
                        } else if (key == 'balanceQuantity') {
                           component.set("v.balancePC", result.responseCredit[key]);   
                        }
                    }
                   this.calculateProRatedPCEntitlement(component,event);
                   component.set("v.showCalloutError",false);
                }
                else {
                    errorMsg = errorMsg + result.response;
                    component.set("v.showCalloutError",true);
                    if(existingErrorMsg == undefined || existingErrorMsg == '') {
                        component.set("v.errorMsgOnExistingOpp",errorMsg);
                    }
                }
            } else {
                var errors = [];
                errors = res.getError();
                    for (var i in errors) {
                        errorMsg = errorMsg + errors[i].message;
                    }
                if(existingErrorMsg == undefined || existingErrorMsg == '') {
                    component.set("v.errorMsgOnExistingOpp",errorMsg);
                }
                component.set("v.showCalloutError",true);
            }
            component.set("v.refreshStatus","");
        });
        $A.enqueueAction(action);
    },
    
    calculateProRatedACEntitlement: function(component,event) {
        debugger;
        var wrapResponseSG = component.get("v.wrapResponseSG");
        var currentAdCredit = component.get("v.currentPackageAC");
        var usedAdCredit = component.get("v.consumedAC");
        var weekUtilized = component.get("v.weekUtilized");
        var upgradePackageAC = component.get("v.upgPackageAC");
        var selectedPackage = component.get("v.selectedPackage");
        var proRatedAdCredit = 0;
        var balanceAC = component.get("v.balanceAC");
        var prodData = component.get("v.resultData");
        var mapPackage = component.get("v.mapPackage");
        var agentObj = component.get("v.agentObj");
        var isAdvancePlus = false;
        if(agentObj.Account_Rule_Code__c.toLowerCase() == $A.get("$Label.c.SG_STANDARD_PACKAGE").toLowerCase() &&
           agentObj.IsAdvance_Plus_Downgrade__c == true  &&  selectedPackage != undefined && mapPackage[selectedPackage] != undefined &&
           mapPackage[selectedPackage].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) {
            this.showToast(component,event,'ERROR', 'Upgrade is not Allowed as you have already downgraded from advance plus')
            return;
        }
        if(selectedPackage != undefined) {
            if(usedAdCredit > currentAdCredit) {
                usedAdCredit = currentAdCredit;
            }
                if(((agentObj.Account_Rule_Code__c.toLowerCase() == $A.get("$Label.c.SG_STANDARD_PACKAGE").toLowerCase() ||
                    agentObj.Account_Rule_Code__c.toLowerCase() == $A.get("$Label.c.ADVANCE_RENEW_EXCEPTION").toLowerCase()) &&
                    mapPackage[selectedPackage].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) ||
                   (agentObj.Account_Rule_Code__c == $A.get("$Label.c.ADVANCEPLUS_RENEW_EXCEPTION") &&
                   (mapPackage[selectedPackage].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_PREMIER") ||
                   mapPackage[selectedPackage].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_BUSINESS")))) {
                    proRatedAdCredit = Math.ceil(upgradePackageAC);
                } else {
                    proRatedAdCredit = Math.ceil(upgradePackageAC-currentAdCredit+(currentAdCredit*weekUtilized/wrapResponseSG.totalWeeks));
                }
        }
            component.set("v.proRatedAC",proRatedAdCredit);
        var conversionMsg = $A.get("$Label.c.PG_Label_AdvPlusConversionHeaderMessage");
        if(selectedPackage != undefined && mapPackage[selectedPackage] != undefined &&
           agentObj.Account_Rule_Code__c.toLowerCase() == $A.get("$Label.c.ADVANCE_RENEW_EXCEPTION").toLowerCase() &&
           mapPackage[selectedPackage].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) {
            component.set("v.advToAdvPlusConversion", true);
            component.set("v.advancePlusConversionMsg",conversionMsg);
            component.set("v.entitlementAC",'AC Entitlement');
            component.set("v.entitlementPC",'PC Entitlement');
        } else {
            component.set("v.advToAdvPlusConversion", false);
            component.set("v.entitlementAC",'Pro-Rated AC Entitlement');
            component.set("v.entitlementPC",'Offset PC Entitlement');
        }
        if(agentObj.Account_Rule_Code__c == $A.get("$Label.c.ADVANCEPLUS_RENEW_EXCEPTION")){
           component.set("v.isAdvancePlus", true);
        } else {
            var proRatedDiscAC = Math.ceil(balanceAC); 
        }
           component.set("v.proRatedDiscAC",proRatedDiscAC);
    },
    calculateProRatedPCEntitlement: function(component,event) {
        debugger;
        var wrapResponseSG = component.get("v.wrapResponseSG");
        var currentPrimeCredit = component.get("v.currentPackagePC");
        var usedPrimeCredit = component.get("v.consumedPC");
        var weekUtilized = component.get("v.weekUtilized");
        var upgradePackagePC = component.get("v.upgPackagePC");
        var selectedPackage = component.get("v.selectedPackage");
        var agentObj = component.get("v.agentObj");
        var proRatedPrimeCredit = 0;
        var mapPackage = component.get("v.mapPackage");
        var balancePC = component.get("v.balancePC");
        if(selectedPackage != undefined) {
            if(usedPrimeCredit > currentPrimeCredit) {
                usedPrimeCredit = currentPrimeCredit;
            }
            //proRatedPrimeCredit = Math.ceil(upgradePackagePC-currentPrimeCredit+(currentPrimeCredit*weekUtilized/wrapResponseSG.totalWeeks));
            if(upgradePackagePC != 0 && upgradePackagePC != null && upgradePackagePC >= currentPrimeCredit){
                if(selectedPackage != undefined && mapPackage[selectedPackage] != undefined &&
                   agentObj.Account_Rule_Code__c.toLowerCase() == $A.get("$Label.c.ADVANCE_RENEW_EXCEPTION").toLowerCase() &&
                   mapPackage[selectedPackage].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) {
                    proRatedPrimeCredit = Math.ceil(upgradePackagePC);
                    //proRatedPrimeCredit = upgradePackagePC;
                }/* else if (agentObj.Account_Rule_Code__c == $A.get("$Label.c.ADVANCEPLUS_RENEW_EXCEPTION") &&
                           agentObj.Previous_Account_Rule__c == $A.get("$Label.c.ADVANCE_RENEW_EXCEPTION").toUpperCase()) {
                    proRatedPrimeCredit = Math.ceil(upgradePackagePC - (currentPrimeCredit+(Math.ceil(balancePC))));
                    proRatedPrimeCredit = Math.ceil(upgradePackagePC - currentPrimeCredit);
                }*/ else {
                    proRatedPrimeCredit = Math.ceil(upgradePackagePC-currentPrimeCredit);
                    //proRatedPrimeCredit = upgradePackagePC-currentPrimeCredit;
                }
            }
        }
            component.set("v.proRatedPC",proRatedPrimeCredit);
            //var proRatedDiscPC = Math.ceil(balancePC);
            var proRatedDiscPC = balancePC;
            component.set("v.proRatedDiscPC",proRatedDiscPC);
    },
    
    submitForm: function(component, event) {
        var alertMsg = component.find("errorAlert");
        var saveBtn = component.find("saveBtn");
        var cancelBtn = component.find("cancelBtn");
        $A.util.addClass(alertMsg, "slds-hide");
        var agentObj = component.get("v.agentObj");
        var loyaltyDetail = component.get("v.loyaltyDetail");
        var selectedPackage = component.get("v.selectedPackage");
        var mapPackage = component.get("v.mapPackage");
        var upgradeStartDate = component.get("v.upgradeStartDate");
        var previousProRate = component.get("v.previousProRate");
        var currentProRate = component.get("v.currentProRate");
        var currentAdCredit = component.get("v.currentPackageAC");
        var currentPrimeCredit = component.get("v.currentPackagePC");
        var dayUtilised = component.get("v.dayUtilised");
        var saveForm = component.get("c.saveUpgrade");
        var msg = "";
        var errors = [];
        var campaignId;
        var discountPercentage;
        var discountReason;
        if (loyaltyDetail == undefined) {
            campaignId = null;
            discountPercentage = null;
            discountReason = null;
        } else {
            campaignId = loyaltyDetail.CampaignId;
            discountPercentage = loyaltyDetail.DiscountPercentage;
            discountReason = loyaltyDetail.DiscountReason;
        }
        
        if (this.validateFields(component)) {
            saveBtn.set("v.disabled", true);
            cancelBtn.set("v.disabled", true);
            var list = [];
            var msg = "";
            var proRatedAC = component.get("v.proRatedAC");
            var consumedAC = component.get("v.consumedAC");
            var proRatedDiscAC = component.get("v.proRatedDiscAC");
            var proRatedPC = component.get("v.proRatedPC");
            var consumedPC = component.get("v.consumedPC");
            var proRatedDiscPC = component.get("v.proRatedDiscPC");
            
            // For weekly calculation (Singapore)
            if(mapPackage[selectedPackage].Label) {
                delete mapPackage[selectedPackage].Label;
            }
            saveForm.setParams({
                agentObjStr: JSON.stringify(agentObj),
                pbEntryStr: JSON.stringify(mapPackage[selectedPackage]),
                CampaignId: campaignId,
                DiscountPercentage: discountPercentage,
                DiscountReason: discountReason,
                UpgradeStartDateString: upgradeStartDate,
                PreviousProRate: previousProRate,
                CurrentProRate: currentProRate,
                UpgradePackageMap: null,
                proRatedAdCredit: proRatedAC,
                usedAC:consumedAC,
                proRatedDiscAdCredit:proRatedDiscAC,
                currentPackageAdCredit:currentAdCredit,
                proRatedPrimeCredit: proRatedPC,
                usedPC:consumedPC,
                proRatedDiscPrimeCredit:proRatedDiscPC,
                currentPackagePrimeCredit:currentPrimeCredit
            });
            saveForm.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var result = response.getReturnValue();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        recordId: result
                        //"slideDevName": "related"
                    });
                    navEvt.fire();
                } else {
                    errors = response.getError();
                    for (var i in errors) {
                        msg += "<li>" + errors[i].message + "</li>";
                    }
                    component.set("v.error", "<ul>" + msg + "</ul>");
                    $A.util.removeClass(alertMsg, "slds-hide");
                }
                saveBtn.set("v.disabled", false);
                cancelBtn.set("v.disabled", false);
            });
            $A.enqueueAction(saveForm);
        }
        component.set("v.Spinner", false);
    },
    getToday: function() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth() + 1; //January is 0!
        var yyyy = today.getFullYear();
        
        if (dd < 10) {
            dd = "0" + dd;
        }
        
        if (mm < 10) {
            mm = "0" + mm;
        }
        
        today = yyyy + "-" + mm + "-" + dd;
        return today;
    },
    validateFields: function(component) {
        var listRequired = ["upgradeStartDate", "selectedPackage"];
        var currField,
            result = true;
        var selectedPackage = component.get("v.selectedPackage");
        var upgradeStartDate = component.get("v.upgradeStartDate");
        var DateToday = new Date(
            this.getToday().substr(0, 4) * 1,
            this.getToday().substr(5, 2) * 1 - 1,
            this.getToday().substr(8) * 1
        ); //yyyy, mm, dd
        upgradeStartDate = new Date(
            upgradeStartDate.substr(0, 4) * 1,
            upgradeStartDate.substr(5, 2) * 1 - 1,
            upgradeStartDate.substr(8) * 1
        ); //yyyy, mm, dd
        
        if (selectedPackage == null) {
            result &= false;
            alert("Please select Upgrade Package accordingly.");
        }
        if (upgradeStartDate < DateToday) {
            result &= false;
            alert("Backdated start of Upgrade not allowed.");
        }
        
        for (var idx in listRequired) {
            currField = component.find(listRequired[idx]);
            if (!currField.get("v.value") && currField.get("v.required")) {
                currField.set("v.errors", [{ message: "Field is required" }]);
                result &= false;
            } else {
                currField.set("v.errors", null);
            }
        }
        return result;
    },
    showToast : function(cmp, event, title, msg ) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : title,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    }
});