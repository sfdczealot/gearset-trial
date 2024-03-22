({
    construct: function (component, event, helper) {
        var oppId = component.get("v.recordId");
        var init0 = component.get("c.construct");
        init0.setParams({"oppId": oppId});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var oppTmp = response.getReturnValue();
                component.set("v.oppObj", oppTmp.oppObj);
                component.set("v.mapUpGradeOutside", oppTmp.mapUpGrade);
                component.set("v.mapDownGradeOutside", oppTmp.mapDownGrade);
                this.getDiscountInfo(component, event, oppTmp.oppObj);
            }
        });
        $A.enqueueAction(init0);
    },
    getDiscountInfo: function(component, event, oppObj) {
        var getDiscount = component.get("c.getListEligiblePromotion");
        getDiscount.setParams({"oppObj": oppObj});
        getDiscount.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                // CHECKPOINT 20190321: display renewal promo (upgrade/renewal) accordingly to the current subscription
                var listDiscountDetail = component.get("v.listDiscountDetail");
                var tmp;
                var conts = response.getReturnValue();
                for (var idx in conts) {
                    if (!conts[idx].IsTier) {
                        listDiscountDetail.push(conts[idx]);
                    }
                }
                component.set("v.listDiscountDetail", listDiscountDetail);
                
                    
                if (oppObj.Order_Type_Clone__c =='Contract - Renewal') {
                    var mapUpGrade = component.get('v.mapUpGradeOutside');
                    var mapDownGrade = component.get('v.mapDownGradeOutside');
                    var renewalDiscountInfo = component.get("c.getRenewalDiscountInfo");
                    console.log('oppObj.Account.Account_Rule_Code__c:'+oppObj.Account.Account_Rule_Code__c);
                    renewalDiscountInfo.setParams({"oppObj": oppObj, "listResult": listDiscountDetail
                                                   , "currentAccountRuleCode": oppObj.Account.Account_Rule_Code__c
                                                   , "mapUpgrade": mapUpGrade, "mapDowngrade": mapDownGrade});
                    renewalDiscountInfo.setCallback(this, function(response) {
                        conts = response.getReturnValue();
                        if (response.getState() === "SUCCESS") {
                            console.log(conts);
                            for (var idx in conts) {
                                console.log(conts[idx]);
                                listDiscountDetail.push(conts[idx]);
                            }
                            component.set("v.listDiscountDetail", listDiscountDetail);
                        }
                    });
                    $A.enqueueAction(renewalDiscountInfo);
                } else {
                    var getFirstTimerWinbackInfo = component.get("c.getFirstTimerWinbackInfo");
                    getFirstTimerWinbackInfo.setParams({
                        oppObj: oppObj,
                        listResult: listDiscountDetail
                    });
                    getFirstTimerWinbackInfo.setCallback(this, function(response) {
                        if (response.getState() === 'SUCCESS') {
                            listDiscountDetail = response.getReturnValue();
                            component.set("v.listDiscountDetail", listDiscountDetail);
                        }
                    });
                    $A.enqueueAction(getFirstTimerWinbackInfo);
                }
            }
        });
        $A.enqueueAction(getDiscount);
    },
})