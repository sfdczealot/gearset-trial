({
    construct: function (component, event, helper) {
        var alertMsg = component.find("errorAlert");
        var saveBtn = component.find("saveBtn");
        $A.util.addClass(alertMsg, 'slds-hide');
        var accId = component.get("v.recordId");
        var init0 = component.get("c.constructUpgrade");
        var errors = [];
        var msg = '';
        
        init0.setParams({"accId": accId});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                
                var jsonResult = response.getReturnValue();
                var parsedJSON = JSON.parse(jsonResult);
                var result = parsedJSON[0].result;
                
                component.set("v.agentObj", result.agentObj);
                component.set("v.dayUtilised", result.dayUtilised);
                component.set("v.upgradeStartDate", result.upgradeStartDate);
                component.set("v.totalAmountAfterDiscount", 0);
                component.set("v.previousProRate", result.agentObj.Pro_Rate_Amount__c);
                var upgradeMapping = component.get("c.getUpgradeMapping");
                upgradeMapping.setParams({"agentStr": JSON.stringify(result.agentObj), "listPbEntryStr": JSON.stringify(result.listPbEntry)});
                upgradeMapping.setCallback(this, function(responseUpgradeMap) {
                    var resultUpgradeMap = responseUpgradeMap.getReturnValue();
                    var resourceList = [{Product2: {Id: null}, Label: null}];
                    var mapPackage = {};
                    for (var key in resultUpgradeMap.listPbEntry) {
                        var displayPrice = '';
                        if(resultUpgradeMap.listPbEntry[key].Display_Price__c){
                            displayPrice = resultUpgradeMap.listPbEntry[key].Display_Price__c.toLocaleString('en');
                        }
                        resultUpgradeMap.listPbEntry[key].Label = resultUpgradeMap.listPbEntry[key].Product2.SKU_Code__c + ' - ' + resultUpgradeMap.listPbEntry[key].Name + ' ('+displayPrice+')';
                        resourceList.push(resultUpgradeMap.listPbEntry[key]);
                        mapPackage[resultUpgradeMap.listPbEntry[key].Id] = resultUpgradeMap.listPbEntry[key];
                    }
                    
                    component.set("v.listAvailablePackage", resourceList);
                    component.set("v.mapPackage", mapPackage);
                    component.set("v.mapUpgradePackage", resultUpgradeMap.mapUpgradePackage);
                    setTimeout(function() {helper.calculatePriceHelper(component);}, 500);
                });
                $A.enqueueAction(upgradeMapping);
            } else {
                errors = response.getError();
                for (var i in errors) {
                    msg += '<li>'+errors[i].message+'</li>';
                }console.log(msg);
                component.set("v.error", '<ul>'+msg+'</ul>');
                component.set("v.failedInit", true);
                $A.util.removeClass(alertMsg, 'slds-hide');
            }
        });
        $A.enqueueAction(init0);
    },
    calculatePriceHelper: function(component) {
        var result;
        var agentObj = component.get("v.agentObj");
        var dayUtilised = component.get("v.dayUtilised");
        var selectedPackage = component.get("v.selectedPackage");
        var mapPackage = component.get("v.mapPackage");
        var loyaltyDetail = component.get("v.loyaltyDetail");
        var previousProRate = component.get("v.previousProRate");
        previousProRate = isNaN(previousProRate)?0:previousProRate;
        var totalAmountAfterDiscount;
        agentObj.Current_Subscription_Spending_Amount__c = isNaN(agentObj.Current_Subscription_Spending_Amount__c)?0:agentObj.Current_Subscription_Spending_Amount__c;
        
        result = agentObj.Current_Subscription_Spending_Amount__c + previousProRate;
        console.log('mapPackage[selectedPackage]:'+mapPackage[selectedPackage]);
        console.log('selectedPackage:'+selectedPackage);
        totalAmountAfterDiscount = selectedPackage==undefined?0:(mapPackage[selectedPackage].UnitPrice * 1)-result;
        component.set("v.currentProRate", result);
        component.set("v.totalAmountAfterDiscount", totalAmountAfterDiscount);
    },
    submitForm: function(component, event) {
        var alertMsg = component.find("errorAlert");
        var saveBtn = component.find("saveBtn");
        var cancelBtn = component.find("cancelBtn");
        $A.util.addClass(alertMsg, 'slds-hide');
        var agentObj = component.get("v.agentObj");
        var loyaltyDetail = null;
        var selectedPackage = component.get("v.selectedPackage");
        var mapPackage = component.get("v.mapPackage");
        var upgradeStartDate = component.get("v.upgradeStartDate");
        var mapUpgradePackage = component.get("v.mapUpgradePackage");
        var previousProRate = component.get("v.previousProRate");
        var currentProRate = component.get("v.currentProRate");
        var dayUtilised = component.get("v.dayUtilised");
        var saveForm = component.get("c.saveUpgrade");
        var msg = '';
        var errors = [];
        var campaignId = null;
        var discountPercentage = null;
        var discountReason = null;
        
        if (this.validateFields(component)) {
            saveBtn.set("v.disabled", true);
            cancelBtn.set("v.disabled", true);
            var list = [];
            var msg = '';
            if(mapPackage[selectedPackage].Label) {
                delete mapPackage[selectedPackage].Label;
            }
            console.log('----selectedPackage: '+selectedPackage);
            console.log('mapPackage[selectedPackage].Product2.SKU_Code__c: '+mapPackage[selectedPackage].Product2.SKU_Code__c);
            console.log('mapUpgradePackage[mapPackage[selectedPackage].Product2.SKU_Code__c]: '+mapUpgradePackage[mapPackage[selectedPackage].Product2.SKU_Code__c]);
            saveForm.setParams({"agentObjStr": JSON.stringify(agentObj), "pbEntryStr": JSON.stringify(mapPackage[selectedPackage]), "CampaignId": campaignId
                                , "DiscountPercentage": discountPercentage, "DiscountReason": discountReason
                                , "UpgradeStartDateString": upgradeStartDate, "PreviousProRate": previousProRate
                                , "CurrentProRate": currentProRate, "UpgradePackageMap": mapUpgradePackage[mapPackage[selectedPackage].Product2.SKU_Code__c]
                                ,  "proRatedAdCredit": 0, "usedAC": 0, "proRatedDiscAdCredit": 0, "currentPackageAdCredit": 0});
            saveForm.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var result = response.getReturnValue();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result,
                        //"slideDevName": "related"
                    });
                    navEvt.fire();
                    
                } else {
                    errors = response.getError();
                    for (var i in errors) {
                        msg += '<li>'+errors[i].message+'</li>';
                    }
                    component.set("v.error", '<ul>'+msg+'</ul>');
                    $A.util.removeClass(alertMsg, 'slds-hide');
                }
                saveBtn.set("v.disabled", false);
                cancelBtn.set("v.disabled", false);
            });
            $A.enqueueAction(saveForm);
        }
        component.set('v.Spinner', false);
    },
    getToday: function() {
        var today = new Date();
        var dd = today.getDate();
        var mm = today.getMonth()+1; //January is 0!
        var yyyy = today.getFullYear();
        
        if(dd<10) {
            dd = '0'+dd
        } 
        
        if(mm<10) {
            mm = '0'+mm
        } 
        
        today = yyyy + '-' + mm + '-' + dd;
        return today;
    },
    validateFields: function (component) {
        var listRequired = ['upgradeStartDate', 'selectedPackage'];
        var currField, result=true;
        var selectedPackage = component.get("v.selectedPackage");
        var upgradeStartDate = component.get("v.upgradeStartDate");
        var DateToday = new Date(this.getToday().substr(0, 4)*1, (this.getToday().substr(5, 2)*1)-1, this.getToday().substr(8)*1);//yyyy, mm, dd
        upgradeStartDate = new Date(upgradeStartDate.substr(0, 4)*1, (upgradeStartDate.substr(5, 2)*1)-1, upgradeStartDate.substr(8)*1);//yyyy, mm, dd
        
        
        if (selectedPackage == null) {
            result &= false;
            alert('Please select Upgrade Package accordingly.');
        }
        if (upgradeStartDate < DateToday){
            result &= false;
            alert('Backdated start of Upgrade not allowed.');
        }
        
        for (var idx in listRequired) {
            currField = component.find(listRequired[idx]);
            if (!currField.get('v.value') && currField.get('v.required')) {
                currField.set("v.errors", [{message:"Field is required"}]);
                result &= false;
            } else {
                currField.set("v.errors", null);
            }
        }
        return result;
    }
})