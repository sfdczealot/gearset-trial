({
        doInit : function(component, event, helper) {
                helper.construct(component, event, helper);
                helper.checkProfilePermission(component, event);
        },
    searchEvents: function(component, event, helper) {
        if(event.getParams().keyCode == 13){
            helper.searchProduct(component, event);
        }
    },
    search : function(component, event, helper) {
        helper.searchProduct(component, event);
    },
    addProduct : function(component, event, helper) {
        //-- Variable Initialization --
        var rowIndex = event.target.getAttribute("data-row-index");
        var listAvailableProduct = component.get("v.listProdAvailable");
        var oppObj = component.get("v.oppObj");
        var listOppLine = component.get("v.listOppLine");
        if (listOppLine == null) {
            component.set("v.listEmpty", []);
            listOppLine = component.get("v.listEmpty");
        }
        var currLength = listOppLine.length;
        /* ORION-751 20181106: Duplicate SKU validation was removed.*/
        
        component.set("v.oppLineObj",{'sobjectType':'OpportunityLineItem',
                                      'OpportunityId': oppObj.Id,
                                      'Product2': null,
                                      'Product2Id': null,
                                      'Line_Description2__c': null,
                                      'UnitPrice': null,
                                      'Product_Type__c': null});
        var oppLineObj = component.get("v.oppLineObj");
        helper.newLineAssignment(component, oppLineObj, null, null, listAvailableProduct[rowIndex], 1, listAvailableProduct[rowIndex].Line_Description2, false, null, listAvailableProduct[rowIndex].Product2.Is_Bundle__c);
        var bonusItem = helper.setDiscountOnAdd(component, event, oppObj, listOppLine, oppLineObj, true);
        if (listAvailableProduct[rowIndex].Product2.Is_Bundle__c) {
            var parentIdx = listOppLine==null?0:(listOppLine.length==0?0:listOppLine.length-1);
            if (listOppLine[parentIdx].Parent__c!=null && listOppLine[parentIdx].Parent__c!='null') {
                --parentIdx;
            }
            helper.addProductAct(component, event, listOppLine, oppObj, oppLineObj, parentIdx, oppObj.Id, bonusItem);
		}
        // PTYG01T-2 20181106: Bonus item must appear only after child product (if any)
        else if (bonusItem!=null) {
            listOppLine.push(bonusItem);
            component.set("v.listOppLine", listOppLine);
            component.set("v.sizeOppLineItem", listOppLine.length);
            component.set("v.Spinner", false);
        }
        listAvailableProduct.splice(rowIndex, 1);
        component.set("v.listProdAvailable", listAvailableProduct);
        var discount = listOppLine[currLength].Discount__c==0||listOppLine[currLength].Discount__c==undefined?null:listOppLine[currLength].Discount__c;
        var discountAmount = discount!=null?null:(listOppLine[currLength].Discount_Amount__c==0||listOppLine[currLength].Discount_Amount__c==undefined?null:listOppLine[currLength].Discount_Amount__c);
        console.log('discount:'+discount);
        console.log('discountAmount:'+discountAmount);
        helper.calculateTotalPrice(component, event, listOppLine, currLength, discount, discountAmount);
    },
    removeOppLineItem : function(component, event, helper) {
        var rowIndex = event.target.getAttribute("data-row-index");
        var listOppLine = component.get("v.listOppLine");
        var oppLine = listOppLine[rowIndex];
        var idx;
        var oppLineLength;
        if (listOppLine == null) {
            component.set("v.listEmpty", []);
            listOppLine = component.get("v.listEmpty");
        }
        var listRemoveChildren = helper.removeChildren(component, listOppLine, oppLine, rowIndex);
        
        if (listOppLine[rowIndex].Id!=undefined) {
            var listOppLineDelete = component.get("v.listOppLineDelete");
                listOppLineDelete.push(listOppLine[rowIndex]);
            component.set("v.listOppLineDelete", listOppLineDelete);
        }
        if (rowIndex < listOppLine.length-1) {
            // Only proceed adjust parent index if rowIndex < listOppLine.length-1
            helper.adjustParentIndex(component, listOppLine, rowIndex);
        }
        if (listRemoveChildren.length>0) {
            listRemoveChildren.push(rowIndex);
            for (var idx in listRemoveChildren) {
                // Removing multi-line at once (somehow) cannot be done without delay.
                setTimeout(function() {
                    if (listOppLine.length>1) {
                        listOppLine.splice(listRemoveChildren[idx], 1);
                        if (listOppLine == null) {
                            listOppLine = component.get("v.listEmpty");
                        }
                        oppLineLength = listOppLine.length;
                    } else {
                        listOppLine = null;
                        oppLineLength = 0;
                    }
                    component.set("v.listOppLine", null);
                    component.set("v.listOppLine", listOppLine);
                    component.set("v.sizeOppLineItem", oppLineLength);
                }, 1000);
            }
        } else {
            if (listOppLine == null) {
                component.set("v.listEmpty", []);
                listOppLine = component.get("v.listEmpty");
            }
            if (listOppLine.length>1) {
                listOppLine.splice(rowIndex, 1);
                oppLineLength = listOppLine.length;
            } else {
                listOppLine = null;
                oppLineLength = 0;
            }
            component.set("v.listOppLine", null);
            setTimeout(function() {
                component.set("v.listOppLine", listOppLine);
                component.set("v.sizeOppLineItem", oppLineLength);
            }, 200);
            
        }
    },
    handleBlur : function(component, event, helper) {
        var oppObj = component.get("v.oppObj");
        var listOppLine = component.get("v.listOppLine");
        var idx = event.getSource().get("v.label");
        helper.setDiscountOnEdit(component, event, oppObj, listOppLine, idx);
    },
    submit: function(component, event, helper) {
        var saveBtn = component.find("saveBtn");
        saveBtn.set("v.disabled", true);
        component.set('v.Spinner', true);
        setTimeout(function() {helper.submitForm(component, event);}, 1000);
    },
    removeAllSelected: function(component, event, helper) {
        var listOppLine = component.get("v.listOppLine");
        var listOppLineDelete = component.get("v.listOppLineDelete");
        if (listOppLine != null && listOppLine.length>0) {
            for (var idx=listOppLine.length-1; idx>=0; idx--) {
                if (listOppLine[idx].Id!=undefined) {
                    listOppLineDelete.push(listOppLine[idx]);
                }
            }
            component.set("v.listOppLine", null);
            component.set("v.sizeOppLineItem", 0);
            component.set("v.listOppLineDelete", listOppLineDelete);
        }
    },
    addRenewalPackage: function(component, event, helper) {
        var oppObj = component.get("v.oppObj");
        if (oppObj.Account.Account_Rule_Code__c==null || oppObj.Account.Account_Rule_Code__c==undefined || oppObj.Account.Account_Rule_Code__c=='') {
            alert(oppObj.Account.Name + ' doesn\'t have any Subscription yet.');
            return false;
        } else if (oppObj.Account.Status__c=='Expired') {
            alert(oppObj.Account.Name + '\'s Subscription is expired already. Cannot select renewal package.');
            return false;
        }
        helper.addRenewalPackageAct(component, event, oppObj);
    },
    changeDiscount: function(component, event, helper) {
        var listOppLine = component.get("v.listOppLine");
        var idx = event.getSource().get("v.label");
        var discount = (listOppLine[idx].Discount__c==null||listOppLine[idx].Discount__c==undefined)?0:listOppLine[idx].Discount__c;
        var originDiscountPercentage = (listOppLine[idx].OriginDiscountPercentage==null||listOppLine[idx].OriginDiscountPercentage==undefined)?0:listOppLine[idx].OriginDiscountPercentage;
        if (discount != originDiscountPercentage) {
                component.set("v.resetAllRelatedBonus", true);
            helper.calculateTotalPrice(component, event, listOppLine, idx, discount, null);
        }
    },
    changeDiscountAmount: function(component, event, helper) {
        var listOppLine = component.get("v.listOppLine");
        var idx = event.getSource().get("v.label");
        var discountAmount = (listOppLine[idx].Discount_Amount__c==null||listOppLine[idx].Discount_Amount__c==undefined)?0:listOppLine[idx].Discount_Amount__c;
        var originDiscountAmount = (listOppLine[idx].OriginDiscountAmount==null||listOppLine[idx].OriginDiscountAmount==undefined)?0:listOppLine[idx].OriginDiscountAmount;
        if (discountAmount  != originDiscountAmount) {
                component.set("v.resetAllRelatedBonus", true);
            helper.calculateTotalPrice(component, event, listOppLine, idx, null, discountAmount);
        }
    },
    changePrice: function(component, event, helper) {
        var listOppLine = component.get("v.listOppLine");
        var idx = event.getSource().get("v.label");
        helper.calculateTotalPrice(component, event, listOppLine, idx, listOppLine[idx].Discount__c, listOppLine[idx].Discount_Amount__c);
    },
    changeChildPO: function(component, event, helper) {
        var listOppLine = component.get("v.listOppLine");
        var idx = event.getSource().get("v.label");
        var currId = (listOppLine[idx].Id!=undefined && listOppLine[idx].Id.length > 0) ? listOppLine[idx].Id : idx;
        
        for (var i in listOppLine) {
            if (listOppLine[i].Parent__c!=undefined && listOppLine[i].Parent__c==currId) {
                listOppLine[i].PO__c = listOppLine[idx].PO__c;
            }
        }
        component.set("v.listOppLine", listOppLine);
    },
    changeChildDate: function(component, event, helper) {
        var listOppLine = component.get("v.listOppLine");
        var idx = event.getSource().get("v.label");
        var currId = (listOppLine[idx].Id!=undefined && listOppLine[idx].Id.length > 0) ? listOppLine[idx].Id : idx;
        var anyUpdate = false;
        
        if (event.getSource().getLocalId()=='oppStartDate') {
            // Adjust End Date to be 1 year after
            listOppLine[idx].End_Date__c = helper.getNextYear(listOppLine[idx].Start_Date__c);
            anyUpdate = true;
        }
        
        for (var i in listOppLine) {
            if (listOppLine[i].Parent__c!=undefined && listOppLine[i].Parent__c==currId) {
                listOppLine[i].Start_Date__c = listOppLine[idx].Start_Date__c;
                listOppLine[i].End_Date__c = listOppLine[idx].End_Date__c;
                anyUpdate = true;
            }
        }
        if (anyUpdate) {
            component.set("v.listOppLine", listOppLine);
        }
    },
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
})