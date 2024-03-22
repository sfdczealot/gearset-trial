({
    showToast : function(cmp, event, title, msg ) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type" : title,
            "title": title,
            "message": msg
        });
        toastEvent.fire();
    },
    getOliDataHelper : function(cmp,event,helper,type) {
        
        let action = cmp.get("c.oliAndDefaultPromoList");
        action.setParams({
            oppId : cmp.get("v.oppId"),
            quoteId : cmp.get("v.quoteId")
        });
        $A.util.removeClass(cmp.find('spinner'), 'slds-hide');
        action.setCallback(this, function(resp){
            let promoMap = [];
            let defaultPromoMap = [];
            let endOfWeek =[];
            var quoteObj = cmp.get("v.quoteObj");
            if(resp.getState() === 'SUCCESS') {
                let result = resp.getReturnValue();
                let oliArray = [];
                let sNO;
                for(let k in result.qliList){
                    if(result.qliList[k].Campaign__r != undefined && 
                       result.qliList[k].Campaign__r.Name != undefined && 
                       result.qliList[k].Campaign__r.Name != null){
                        result.qliList[k].disabled = true;
                        result.qliList[k].promoIdsValue = '';
                        result.qliList[k].campaignName = '';
                        result.qliList[k].discountPerUnit = 0;
                    }
                    else{
                        result.qliList[k].disabled = false; 
                    }
                    sNO = result.qliList[k].SNo__c;
                    result.qliList[k].toCheckWholeNo = (sNO != Math.floor(sNO));
                    // -1927-
                    result.qliList[k].Original_Price__c = result.qliList[k].ListPrice;
                    oliArray.push(result.qliList[k]);
                    
                    if(quoteObj.Quote_Type__c=='B2C - Upgrade'){
                        if( result.qliList[k].Pro_Rate_Amount__c != null && result.qliList[k].Pro_Rate_Amount__c !=undefined){
                            cmp.set("v.isProRate",true);
                        }
                    }
                }
                if(oliArray[0] != null && oliArray[0].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) {
                    cmp.set("v.IsDiscNotApplicable",true);
                } else {
                    cmp.set("v.IsDiscNotApplicable",false);
                }
                cmp.set("v.oliItems",oliArray);
                console.log('<?<?<?<?<?'+JSON.stringify(oliArray));
                for(let key in result.defaultProdIdVsPromoRecMap ) {
                    defaultPromoMap.push({
                        key: key,
                        value: result.defaultProdIdVsPromoRecMap[key]
                    });
                }
                cmp.set("v.defaultPromoMap",defaultPromoMap);
                for(let key in result.endOfWeek ) {
                    endOfWeek.push({
                        key: key,
                        value: result.endOfWeek[key]
                    });
                }  
                cmp.set("v.endDayForExisting",endOfWeek);
                //  cmp.set("v.promoMap",defaultPromoMap);
                if(cmp.get("v.promoMap") == undefined || cmp.get("v.promoMap") == null)
                    promoMap = [];
                else
                    promoMap = cmp.get("v.promoMap");
                for(let key in result.prodIdVsPromoRecMap ) {
                    if(key != null) {
                        promoMap.push({
                            key: key,
                            value: result.prodIdVsPromoRecMap[key]
                        });
                    }
                }
                cmp.set("v.promoMap",promoMap);
                
                if(quoteObj.Quote_Type__c=='B2C - Renewal'){
                    if (quoteObj.Status =='Proposal' && (quoteObj.Approval_Status__c == null || quoteObj.Approval_Status__c == '' || quoteObj.Approval_Status__c == 'Discount Approval Rejected')) {
                        helper.getRenewalButtons(cmp,event,helper);
                    }
                }
                // cmp.set("v.promoMap",promoMap);
                cmp.set("v.promoMapDisplay",defaultPromoMap);
                //cmp.set("v.promoMap",promoMap);
                this.calculateSubtotalHelper(cmp,event);
                //exclusion Map
                cmp.set('v.exclusionProductMap',result.mapOfPromoIdVSSetOfProductIds);
                $A.util.addClass(cmp.find('spinner'), 'slds-hide');
            }
            helper.getpickListValues(cmp,event);
        });
        $A.enqueueAction(action);
    },
    // show promo mechanic reords if quantity is present
    showPromoHelper : function(cmp,event) {
        //let index = +event.currentTarget.parentElement.dataset.rowIndex;
        let index =  event.target.getAttribute("data-row-index");
        let prodId = event.getSource().get("v.value");
        let promoToDisplay = [];
        let promoMap = cmp.get("v.promoMap");
        let oliList = cmp.get("v.oliItems");
        let renewPromoFilterMap = cmp.get("v.renewPromoFilterMap");
        if(oliList[index].Quantity == undefined || oliList[index].Quantity == '' || oliList[index].Quantity == null ) {
            this.showToast(cmp, event, 'Error', 'Please Enter Quantity');
            return;
        }
        promoMap.forEach(function(item){
            
            if(item.key == prodId) {
                var valueList=[];
                for(var val in item.value){
                    var singlelist= item.value[val];
                    if(item.value[val].Renewal_Type__c == undefined || item.value[val].Renewal_Type__c == '' || item.value[val].Renewal_Type__c == null){
                        valueList.push(
                            item.value[val]
                        );
                    }
                    else{
                        for(var rType in renewPromoFilterMap){
                            if(item.value[val].Renewal_Type__c == renewPromoFilterMap[rType].value && renewPromoFilterMap[rType].key == prodId ){
                                valueList.push(
                                    item.value[val]
                                );
                            }
                        }
                    }
                    
                    /*   if(item.value.Renewal_Type__c == undefined || item.value.Renewal_Type__c == '' || item.value.Renewal_Type__c == null){
                    promoToDisplay.push({
                        key: item.key,
                        value: item.value
                    });
                }else{
                    renewPromoFilterMap.forEach(function(renewKey){
                        if(renewKey.key == prodId) {
                            if(renewKey.value == item.value.Renewal_Type__c){
                                promoToDisplay.push({
                                    key: item.key,
                                    value: item.value
                            	});
                            }
                        }
                    });
                                     
                }*/
                    
                }
                if(valueList !=undefined && valueList !=null && valueList.length!=0){
                    promoToDisplay.push({
                        key: item.key,
                        value: valueList
                    });   
                }
            }
        });
        if(promoToDisplay.length > 0)
            cmp.set("v.promoMapDisplay", promoToDisplay);
        else{
            let noPromo = [];
            promoToDisplay = [];
            noPromo.push({
                Name: 'No Promo Available!'
            }); 
            promoToDisplay.push({
                key: 'noPromo',
                value: noPromo
            })
            cmp.set("v.promoMapDisplay", promoToDisplay);
        }
        cmp.set("v.oliSelectedIndex",index);
        document.getElementById('promos').scrollIntoView();
    },
    addOliHelper : function(cmp,event,productId,type) {
        
        cmp.set("v.productObj",{'sobjectType':'Product2',
                                'Name': null});
        //let index = +event.currentTarget.parentElement.dataset.rowIndex;
        let index = event.target.getAttribute("data-row-index");
        let prodList = cmp.get("v.productList");
        let oli = [];
        let oppObj = cmp.get("v.quoteObj");
        oli = cmp.get("v.oliItems");
        let newOli = {};
        newOli.Id;
        newOli.QuoteId = oppObj.Id;
        newOli.Product2Id = prodList[index].Product2Id;
        newOli.PricebookEntryId = prodList[index].Id;
        let prod = {};
        prod.Name = prodList[index].Product2.Name;
        prod.Id = prodList[index].Product2Id;
        prod.Product_Category__c = prodList[index].Product2.Product_Category__c;
        prod.CustItem_Validity_Value__c = prodList[index].Product2.CustItem_Validity_Value__c;
        prod.CustItem_Validity_Unit__c = prodList[index].Product2.CustItem_Validity_Unit__c;
        prod.SKU_Code__c = prodList[index].Product2.SKU_Code__c;
        prod.Multiple_Sale_Not_Allowed__c = prodList[index].Product2.Multiple_Sale_Not_Allowed__c;
        prod.Start_Date_Non_Editable__c = prodList[index].Product2.Start_Date_Non_Editable__c;
        prod.End_Date_Non_Editable__c = prodList[index].Product2.End_Date_Non_Editable__c;
        newOli.Product2 = prod;
        newOli.UnitPrice = prodList[index].UnitPrice ;
        newOli.Original_Price__c = newOli.UnitPrice==null||newOli.UnitPrice==undefined?0:newOli.UnitPrice;
        newOli.Quantity ;
        newOli.Discount_Amount__c ;
        newOli.Discount__c ;
        if(oppObj.Quote_Type__c == 'B2C - Renewal'){
            console.log('???---Today---??? ',this.getToday());
            console.log('???---Subscription End Date---??? ',oppObj.Account.Subscription_End_Date__c)
            console.log('???---Previous End Date---??? ',oppObj.Account.Previous_Acct_End_Date__c)
            if(oppObj.Country__c == 'Singapore'){
                if(this.getToday() <= oppObj.Account.Subscription_End_Date__c ){
                    newOli.Start_Date__c = this.methodToFormatDate(cmp,oppObj.Account.Subscription_End_Date__c);
                }else if(this.getToday() > oppObj.Account.Previous_Acct_End_Date__c){
                    newOli.Start_Date__c = this.getToday();
                }else{
                    newOli.Start_Date__c = this.getToday();
                }
            }else{
                if(oppObj.Account.Subscription_End_Date__c<this.getToday()){
                    newOli.Start_Date__c = this.getToday();
                }else{
                    newOli.Start_Date__c = this.methodToFormatDate(cmp,oppObj.Account.Subscription_End_Date__c);
                }
            }
        }else{
            newOli.Start_Date__c = this.getToday(); 
        }
        let curr = new Date( newOli.Start_Date__c); // get current date
        let first = curr.getDate() - curr.getDay() +1; // First day is the start of the week 
        let last = first + 6; // last day is the first day + 6
        
        let firstday = new Date(curr.setDate(first));
        let lastday = new Date(curr.setDate(last)).getTime();
        
        let endOfWeekTemp = cmp.get("v.endOfTheWeek");
        const endOfWeek = new Map();
        endOfWeek.set(newOli.Product2Id,lastday); 
        cmp.set("v.endOfTheWeek",endOfWeek);    
        
        if(prodList[index].Product2.CustItem_Validity_Value__c != null && prodList[index].Product2.CustItem_Validity_Value__c != undefined && prodList[index].Product2.CustItem_Validity_Unit__c != null && prodList[index].Product2.CustItem_Validity_Unit__c != undefined) {            
            newOli.End_Date__c = this.addMonths(newOli.Start_Date__c,prodList[index].Product2.CustItem_Validity_Value__c,prodList[index].Product2.CustItem_Validity_Unit__c);
        } else {
            newOli.End_Date__c = this.getNextYear(newOli.Start_Date__c);
        }
        newOli.PO__c = true;
        
        if (prodList[index].Product2.Tax_Code__c != null) {
            newOli.GST_VAT_Code__c = prodList[index].Product2.Tax_Code__c;
        } else {
            newOli.GST_VAT_Code__c = null;
        }
        
        if (prodList[index].Product2.Tax_Code__r != undefined) {
            newOli.GST_VAT_Rate__c = prodList[index].Product2.Tax_Code__r.Tax_Rate__c;
        } else {
            newOli.GST_VAT_Rate__c = 0;
        }
        newOli.Income_Account_Name__c = prodList[index].Product2.Income_Account_Name__c;
        newOli.Product_Category__c = prodList[index].Product2.Product_Category__c;
        let isBundle = prodList[index].Product2.Is_Bundle__c;
        if(prodList[index].Product2.Product_Category__c == 'Subscription') {
            newOli.Quantity = 1;
            prodList.splice(index, 1);
        }
        
        var unitPrice = newOli.UnitPrice==null?0:newOli.UnitPrice;
        var quantity = newOli.Quantity==null?0:newOli.Quantity;
        var totalPrice = unitPrice * quantity;
        let discountAmount = newOli.Discount_Amount__c;
        let discount = newOli.Discount__c;
        var discountedAmount = discountAmount!=null?unitPrice*quantity*discountAmount/100:discount;
        newOli.Amount__c = totalPrice-(isNaN(discountedAmount)?0:discountedAmount)-(isNaN(newOli.Pro_Rate_Amount__c)?0:
                                                                                    (totalPrice-(isNaN(discountedAmount)?0:discountedAmount)>=newOli.Pro_Rate_Amount__c?newOli.Pro_Rate_Amount__c:(totalPrice-(isNaN(discountedAmount)?0:discountedAmount))));
        newOli.Gross_Amount__c = newOli.Amount__c + ( newOli.Amount__c * (newOli.GST_VAT_Rate__c/100) );
        oli.push(newOli);
        cmp.set("v.oliItems",oli);
        cmp.set("v.productList", prodList);
        //alert('???'+JSON.stringify(prodList[index]));
        if (isBundle) {
            var parentIdx = oli==null?0:(oli.length==0?0:oli.length-1);
            if (oli[parentIdx].Parent__c!=null && oli[parentIdx].Parent__c!='null') { 
                --parentIdx;
            }
            this.addProductAct(cmp, event, oli, oppObj, newOli, parentIdx, oppObj.Id, null);
        }
        
        
        this.calculateSubtotalHelper(cmp,event);
        
    },
    closeModalHelper : function(cmp,event) {
        let navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": cmp.get("v.oppObj").Id,
            "slideDevName": "quote"
        });
        navEvt.fire();
    },
    calculateSubtotalHelper : function(cmp,event) {
        //alert('I am here')
        let subtotal = 0;
        let taxTotal = 0;
        let totalWHTtax = 0;
        let totalGrossAmount = 0;
        let totalAmountBeforeDiscount = 0
        let totalDiscountAmount = 0;
        let oli = cmp.get("v.oliItems");
        for(let val in oli) {
            //console.log('discountPerUnit>>><<<??? ',oli[val].discountPerUnit)
            var OLIAmount=0;
            if(oli[val].Quantity != undefined && oli[val].UnitPrice != undefined) {
                //PGAUTO-2371
                /* if(oli[val].Discount__c != undefined && oli[val].Discount__c != 0 && oli[val].Discount_Amount__c != undefined && oli[val].Discount_Amount__c != 0){
                       totalDiscountAmount +=  (oli[val].Quantity * oli[val].UnitPrice)*oli[val].Discount__c/100 + oli[val].Discount_Amount__c; 
                    }*/
                totalAmountBeforeDiscount += (oli[val].Quantity * oli[val].UnitPrice);
                
                if(oli[val].Discount__c != undefined && oli[val].Discount__c != 0 && oli[val].Discount_Amount__c != undefined && oli[val].Discount_Amount__c != 0){
                    totalDiscountAmount +=  (oli[val].Quantity * oli[val].UnitPrice)*oli[val].Discount__c/100 + oli[val].Discount_Amount__c; 
                    console.log('totalDiscountAmount00>>><<<??? ',oli[val].totalDiscountAmount);
                    OLIAmount=(oli[val].Quantity*oli[val].UnitPrice)-((oli[val].Discount__c/100)*oli[val].Quantity*oli[val].UnitPrice) - (oli[val].Discount_Amount__c) ;
                    subtotal += (oli[val].Quantity*oli[val].UnitPrice)-((oli[val].Discount__c/100)*oli[val].Quantity*oli[val].UnitPrice) - (oli[val].Discount_Amount__c) ;
                }
               /* else if(oli[val].Discount_Amount__c != undefined && oli[val].Discount_Amount__c != 0 && oli[val].discountPerUnit !=undefined && oli[val].discountPerUnit != 0){
                    OLIAmount = ((oli[val].Quantity*oli[val].UnitPrice)-(oli[val].Discount_Amount__c) - (oli[val].Quantity*oli[val].discountPerUnit));
                    subtotal += ((oli[val].Quantity*oli[val].UnitPrice)-(oli[val].Discount_Amount__c) - (oli[val].Quantity*oli[val].discountPerUnit));
                    totalDiscountAmount += (oli[val].Discount_Amount__c +(oli[val].Quantity*oli[val].discountPerUnit)) ;
                    console.log('discountPerUnit>>><<<??? ',oli[val].discountPerUnit);
                    console.log('Discount_Amount__c>>><<<??? ',oli[val].Discount_Amount__c);
                    console.log('Quantity>>><<<??? ',oli[val].Quantity);
                    console.log('Quantity*discountPerUnit>>><<<??? ',oli[val].Quantity*oli[val].discountPerUnit);
                    console.log('totalDiscountAmount0>>><<<??? ',oli[val].totalDiscountAmount);
                }*/
                    else if(oli[val].Discount__c != undefined && oli[val].Discount__c != 0){
                        subtotal += (oli[val].Quantity*oli[val].UnitPrice)-((oli[val].Discount__c/100)*oli[val].Quantity*oli[val].UnitPrice);
                        OLIAmount = (oli[val].Quantity*oli[val].UnitPrice)-((oli[val].Discount__c/100)*oli[val].Quantity*oli[val].UnitPrice);
                        totalDiscountAmount +=  (oli[val].Quantity * oli[val].UnitPrice)*oli[val].Discount__c/100;
                        console.log('totalDiscountAmount1>>><<<??? ',oli[val].totalDiscountAmount);
                    }
                        else if(oli[val].Discount_Amount__c != undefined && oli[val].Discount_Amount__c != 0 ){
                            OLIAmount = ((oli[val].Quantity*oli[val].UnitPrice)-(oli[val].Discount_Amount__c));
                            subtotal += ((oli[val].Quantity*oli[val].UnitPrice)-(oli[val].Discount_Amount__c));
                            totalDiscountAmount += oli[val].Discount_Amount__c;
                            console.log('totalDiscountAmount2>>><<<??? ',oli[val].totalDiscountAmount);
                        }/*else if(oli[val].discountPerUnit != undefined && oli[val].discountPerUnit != 0 ){
                            OLIAmount = ((oli[val].Quantity*oli[val].UnitPrice)-(oli[val].Quantity*oli[val].discountPerUnit));
                            subtotal += ((oli[val].Quantity*oli[val].UnitPrice)-(oli[val].Quantity*oli[val].discountPerUnit));
                            totalDiscountAmount += (oli[val].Quantity*oli[val].discountPerUnit);
                            console.log('totalDiscountAmount3>>><<<??? ',oli[val].totalDiscountAmount);
                        }*/
                
                            else {
                                OLIAmount =  (oli[val].Quantity*oli[val].UnitPrice);
                                subtotal += (oli[val].Quantity*oli[val].UnitPrice);
                            }
                if(oli[val].Pro_Rate_Amount__c != undefined && oli[val].Pro_Rate_Amount__c != 0){
                    subtotal -=oli[val].Pro_Rate_Amount__c;
                    OLIAmount -=  oli[val].Pro_Rate_Amount__c;
                }
                if(oli[val].WHT_Rate__c != undefined && oli[val].WHT_Rate__c != 0){
                    totalWHTtax += OLIAmount * oli[val].WHT_Rate__c/100;
                }
                console.log('GST Rate--->>> ',oli[val].GST_VAT_Rate__c);
                if(oli[val].GST_VAT_Rate__c != undefined && oli[val].GST_VAT_Rate__c != 0){
                    taxTotal +=OLIAmount * oli[val].GST_VAT_Rate__c/100;
                }
                /*if(oli[val].GST_VAT_Rate__c != undefined && oli[val].GST_VAT_Rate__c != 0){
                    totalGrossAmount += oli[val].GST_VAT_Rate__c/100;
                }*/
            }
        } 
        
        totalGrossAmount = subtotal + taxTotal;
        cmp.set('v.totalDiscountAmount',totalDiscountAmount);
        cmp.set('v.totalAmountBeforeDiscount',totalAmountBeforeDiscount);
        cmp.set('v.totalGrossAmount',totalGrossAmount);
        cmp.set("v.taxTotal",taxTotal);
        cmp.set("v.WHTTotal",totalWHTtax);
        cmp.set("v.subtotal",subtotal);
    },
    removePromoHelper : function(cmp,event, oliItems, oliIndex) {
        oliItems[oliIndex].isPackagePromoApplied = false;
        let updatedOliList = [];
        let oliList = oliItems;
        let index = oliIndex;
        let malaysiaPromoIds = cmp.get('v.Malaysia_MCO_Promos');
        let malaysiaPromoIdsList = malaysiaPromoIds.split(',');
        var quoteObj = cmp.get('v.oppObj');
        //let oliList = cmp.get("v.oliItems");
        //let index = Number(+event.currentTarget.parentElement.dataset.rowIndex);
        let promoMap = cmp.get("v.promoMap");
        let orgnlStartDate = cmp.get("v.originalStartDate");
        
        if(orgnlStartDate != null && orgnlStartDate != undefined) {
            oliList[index].Start_Date__c = orgnlStartDate;
        }
        //AUTOMATION-8897
        if(quoteObj.Country__c == 'Malaysia' && oliList.length > parseInt(index)+parseInt(1) && oliList[parseInt(index)+parseInt(1)].Campaign__c == undefined && oliList[parseInt(index)+parseInt(1)].Campaign__c == null && oliList[parseInt(index)+parseInt(1)].Parent_Id__c != null) {
            oliList.splice(parseInt(index)+parseInt(1),1);
        }
        
        for(let item in oliList) { 
            if(oliList[item].Parent_Id__c == undefined) {
                updatedOliList.push(oliList[item]);
            }else{
                if(quoteObj.Country__c == 'Malaysia' && oliList[item].Product2.SKU_Code__c == $A.get("$Label.c.SKUCODE_AD_CREDIT_MY") && oliList[index].Product2.Product_Category__c == 'Discretionary') {
                    if(oliList[index].Promo_Mechanic_Id__c.includes(oliList[item].Parent_Id__c) || oliList[item].Parent_Id__c == oliList[index].Id) { 
                        updatedOliList.push(oliList[item]);//AUTOMATION-8897
                    }
                    else {
                        updatedOliList.push(oliList[item]);
                    }
                } else {
                    if(oliList[index].Promo_Mechanic_Id__c.includes(oliList[item].Parent_Id__c) || oliList[item].Parent_Id__c == oliList[index].Id) { 	
                    
                    }	
                    else {
                        updatedOliList.push(oliList[item]);
                    }
                }
                
            }
        }
        
        //added for updating the end date as per the promo mechanic, PGAUTO-5323
        if(
            updatedOliList[index].Product2.CustItem_Validity_Value__c != null && 
            updatedOliList[index].Product2.CustItem_Validity_Value__c != undefined && 
            updatedOliList[index].Product2.CustItem_Validity_Unit__c != null && 
            updatedOliList[index].Product2.CustItem_Validity_Unit__c != undefined
        ) {
            updatedOliList[index].End_Date__c = this.addMonths(
                updatedOliList[index].Start_Date__c, 
                updatedOliList[index].Product2.CustItem_Validity_Value__c, 
                updatedOliList[index].Product2.CustItem_Validity_Unit__c
            );
        } else {
            updatedOliList[index].End_Date__c = this.getNextYear(updatedOliList[index].Start_Date__c);
        }
        
        let endDateForMY = false;
        for(let pmId in malaysiaPromoIdsList){
            if(malaysiaPromoIdsList[pmId] == oliList[index].Promo_Mechanic_Id__c){
                endDateForMY = true;
            }
        }
        if(endDateForMY){ 
            let today = new Date(oliList[index].End_Date__c);
            today.setDate(today.getDate());
            let dd = today.getDate();
            let mm = today.getMonth(); //January is 0!
            let yyyy = today.getFullYear();
            
            if(dd<10) {
                dd = '0'+dd
            } 
            
            if(mm<10) {
                mm = '0'+mm
            } 
            today = yyyy + '-' + mm + '-' + dd;
            updatedOliList[index].End_Date__c = today;
        }
        updatedOliList[index].Discount_Amount__c = undefined ;
        updatedOliList[index].Discount__c = undefined;
        delete updatedOliList[index].Campaign__r;
        updatedOliList[index].Campaign__c = undefined;
        updatedOliList[index].Promo_Mechanic_Id__c = undefined;
        updatedOliList[index].Parent_Id__c = undefined;
        updatedOliList[index].Discount_Reason__c = '';
        updatedOliList[index].disabled = false;
        updatedOliList[index].promoIdsValue = undefined;
        updatedOliList[index].campaignName = undefined;
        updatedOliList[index].CampaignId__c = undefined;
        updatedOliList[index].campaignName = undefined;
        updatedOliList[index].discountPerUnit = undefined;
        updatedOliList[index].Amount__c = updatedOliList[index].UnitPrice * updatedOliList[index].Quantity;
        updatedOliList[index].Gross_Amount__c = updatedOliList[index].UnitPrice * updatedOliList[index].Quantity;
         
        cmp.set("v.oliItems",updatedOliList);
        /*window.setTimeout(
            $A.getCallback(function() {
                
            }), 500
        );*/
        
        this.calculateSubtotalHelper(cmp,event);
        this.changeChildDate2(cmp,event);
    },
    getpickListValues : function(cmp,event) {
        var oliItems = cmp.get("v.oliItems");
        var quoteObj = cmp.get("v.quoteObj"); 
        var discountReasonForSelection =[];
        if(quoteObj.Country__c != undefined && (quoteObj.Country__c == 'Singapore' || quoteObj.Country__c == 'Thailand')) {
            discountReasonForSelection = [
                "Managerial Discount",
                "Technical issues",
                "Goodwill/ Relationship Building",
                "Others"
            ];
        } else if(quoteObj.Country__c != undefined && quoteObj.Country__c == 'Malaysia') {
                discountReasonForSelection = [
                "Managerial Discount",
                "Technical issues",
                "Goodwill/ Relationship Building",
                "Others",
                "Pioneer"
            ];
        }
        
        let action = cmp.get('c.getPickListValue');
        action.setParams({
            objectName : 'QuoteLineItem',
            fieldName : 'Discount_Reason__c'
        });
        action.setCallback(this,result=>{
            var itemList = result.getReturnValue();
            cmp.set('v.pickList',itemList);
            
            var removedItemList = [];
            for(var item in itemList){
            if(discountReasonForSelection.includes(itemList[item]))
            removedItemList.push(itemList[item]);
        }
            for(var oli in oliItems){
            if(oliItems[oli].Discount_Reason__c == 'Loyalty Discount' && !discountReasonForSelection.includes('Loyalty Discount')) {
                removedItemList.push(oliItems[oli].Discount_Reason__c);
            }
        }
            cmp.set('v.optimizedPickList',removedItemList);
        
    });
    $A.enqueueAction(action);
},
 getToday: function() {
    let today = new Date();
    let dd = today.getDate();
    let mm = today.getMonth()+1; //January is 0!
    let yyyy = today.getFullYear();
    
    if(dd<10) {
        dd = '0'+dd
    } 
    
    if(mm<10) {
        mm = '0'+mm
    } 
    
    today = yyyy + '-' + mm + '-' + dd;
    return today;
},
    getNextYear: function(today) {
        today = today.split('-');
        // Please pay attention to the month (parts[1]); JavaScript counts months from 0:
        // January - 0, February - 1, etc.
        let todayDate = new Date(today[0], today[1] - 1, today[2]); 
        
        let yesterday = new Date(todayDate);
        yesterday.setDate(todayDate.getDate() - 1); //setDate also supports negative values, which cause the month to rollover.
        
        let nextYear = new Date(yesterday.setFullYear(yesterday.getFullYear()+1));//new Date(new Date().setFullYear(new Date().getFullYear() + 1));
        let dd = nextYear.getDate();
        let mm = nextYear.getMonth()+1; //January is 0!
        let yyyy = nextYear.getFullYear();
        
        if(dd<10) {
            dd = '0'+dd
        } 
        
        if(mm<10) {
            mm = '0'+mm
        } 
        
        nextYear = yyyy + '-' + mm + '-' + dd;
        return nextYear;
    },
        getDiscountInfo: function(component, event, oppObj) {
            var getDiscount = component.get("c.getListEligiblePromotion");
            var eligibleVip = null;
            getDiscount.setParams({"oppObj": oppObj});
            getDiscount.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    var listDiscountDetail = component.get("v.listDiscountDetail");
                    var tmp;
                    var conts = response.getReturnValue();
                    for (var idx in conts) {
                        console.log(conts[idx]);
                        if (conts[idx].EligibleVip!=null) {
                            eligibleVip = conts[idx].EligibleVip;
                        }
                        listDiscountDetail.push(conts[idx]);
                    }
                    console.log('EligibleVip:'+eligibleVip);
                    component.set("v.EligibleVip", eligibleVip);
                    component.set("v.listDiscountDetail", listDiscountDetail);
                }
            });
            $A.enqueueAction(getDiscount);
        },
            setDiscountOnEdit: function (component, event, oppObj, listOppLine, oppLineIdx) {
                var oppLineObj = listOppLine[oppLineIdx];
                //oppLineObj.Original_Price__c = oppLineObj.UnitPrice;
                var listDiscountDetail = component.get("v.listDiscountDetail");
                var listDiscountDetail = component.get("v.listDiscountDetail");
                /* component.set("v.oppLineObj",{'sobjectType':'OpportunityLineItem',
                                      'Product2': null,
                                      'Product2Id': null,
                                      'Line_Description2__c': null,
                                      'UnitPrice': null,
                                      'Product_Type__c': null}); */
                var bonusItem = component.get("v.oppLineObj");
                var loyaltyUpgrade = component.get("v.loyaltyUpgrade");
                var isEligible = false;
                var loyaltyObj = null;
                component.set("v.campaignObj",{'sobjectType':'Campaign',
                                               'Name': null});
                var campaignObj = component.get("v.campaignObj");
                
                this.removeExistingDiscount(component, oppLineObj, listOppLine, oppLineIdx, null);
                this.removeExistingTierPricing(component, listOppLine[oppLineIdx]);
                
                console.log('listOppLine[oppLineIdx][1] '+JSON.stringify(listOppLine[oppLineIdx]));
                
                for (var idx in listDiscountDetail) {
                    if (listDiscountDetail[idx].ProductReference!=undefined) {
                        if (oppLineObj.Product2Id==listDiscountDetail[idx].ProductReference && !listDiscountDetail[idx].IsAny) {
                            if (!listDiscountDetail[idx].IsTier) {
                                if (listDiscountDetail[idx].Operator == '>' && oppLineObj.Quantity>listDiscountDetail[idx].Quantity && (listDiscountDetail[idx].MaxQuantity == undefined || isNaN(listDiscountDetail[idx].MaxQuantity) || (listDiscountDetail[idx].MaxQuantity != undefined && !isNaN(listDiscountDetail[idx].MaxQuantity) && oppLineObj.Quantity<=listDiscountDetail[idx].MaxQuantity))) {
                                    isEligible = true;
                                    this.discountAssignment(component, oppLineObj, listDiscountDetail[idx], bonusItem, listOppLine, oppLineIdx);
                                } else if (listDiscountDetail[idx].Operator == '≥' && oppLineObj.Quantity>=listDiscountDetail[idx].Quantity && (listDiscountDetail[idx].MaxQuantity == undefined || isNaN(listDiscountDetail[idx].MaxQuantity) || (listDiscountDetail[idx].MaxQuantity != undefined && !isNaN(listDiscountDetail[idx].MaxQuantity) && oppLineObj.Quantity<=listDiscountDetail[idx].MaxQuantity))) {
                                    isEligible = true;
                                    this.discountAssignment(component, oppLineObj, listDiscountDetail[idx], bonusItem, listOppLine, oppLineIdx);
                                } else if (listDiscountDetail[idx].Operator == '=' && oppLineObj.Quantity==listDiscountDetail[idx].Quantity && (listDiscountDetail[idx].MaxQuantity == undefined || isNaN(listDiscountDetail[idx].MaxQuantity) || (listDiscountDetail[idx].MaxQuantity != undefined && !isNaN(listDiscountDetail[idx].MaxQuantity) && oppLineObj.Quantity<=listDiscountDetail[idx].MaxQuantity))) {
                                    isEligible = true;
                                    this.discountAssignment(component, oppLineObj, listDiscountDetail[idx], bonusItem, listOppLine, oppLineIdx);
                                }
                            } else {
                                // Only proceed Tier Pricing if no Promotion/Discount already applied previously.
                                if (!isEligible && ((oppLineObj.Discount__c<=0 || oppLineObj.Discount__c==null) && (oppLineObj.Discount_Amount__c<=0 || oppLineObj.Discount_Amount__c==null))) {
                                    if (oppLineObj.Quantity%listDiscountDetail[idx].Denomination!=0) {
                                        // Only apply Tier Discount if Quantity is block of 100.
                                        this.removeExistingTierPricing(component, listOppLine[oppLineIdx]);
                                    } else if (listDiscountDetail[idx].MinQuantity != undefined && listDiscountDetail[idx].MaxQuantity != undefined && listDiscountDetail[idx].MinQuantity <= oppLineObj.Quantity && oppLineObj.Quantity <= listDiscountDetail[idx].MaxQuantity) {
                                        // Within particular range xxx - yyy
                                        isEligible = true;
                                        this.unitPriceAssignment(component, oppLineObj, listDiscountDetail[idx], listOppLine, oppLineIdx);
                                    } else if (listDiscountDetail[idx].MinQuantity != undefined && listDiscountDetail[idx].MaxQuantity == undefined && listDiscountDetail[idx].MinQuantity <= oppLineObj.Quantity) {
                                        // More than minimum range
                                        isEligible = true;
                                        this.unitPriceAssignment(component, oppLineObj, listDiscountDetail[idx], listOppLine, oppLineIdx);
                                    } else if (listDiscountDetail[idx].MinQuantity == undefined && listDiscountDetail[idx].MaxQuantity != undefined && oppLineObj.Quantity <= listDiscountDetail[idx].MaxQuantity) {
                                        // Less than maximum range
                                        isEligible = true;
                                        this.unitPriceAssignment(component, oppLineObj, listDiscountDetail[idx], listOppLine, oppLineIdx);
                                    } else {
                                    }
                                } else {
                                    
                                }
                            }
                        } else if (oppLineObj.Product2Id==listDiscountDetail[idx].ProductReference && listDiscountDetail[idx].IsAny) {
                            // Apply Marketing Promo discount if discount doesn't have any criteria (w/o condition)
                            isEligible = true;
                            this.discountAssignment(component, oppLineObj, listDiscountDetail[idx], bonusItem, listOppLine, oppLineIdx);
                        }
                    } else if (listDiscountDetail[idx].IsLoyalty!=undefined && listDiscountDetail[idx].IsLoyalty && oppLineObj.Product_Category__c=='Subscription') {
                        // Apply loyalty discount if loyalty & product is subscription
                        loyaltyObj = listDiscountDetail[idx];
                    }
                }
                
                console.log('listOppLine[oppLineIdx][2] '+JSON.stringify(listOppLine[oppLineIdx]));
                
                if (loyaltyObj != null) {
                    isEligible = true;
                    oppLineObj.Discount_Reason__c = loyaltyObj.DiscountReason;
                    oppLineObj.Discount__c = loyaltyObj.DiscountPercentage;
                    oppLineObj.OriginDiscountPercentage = oppLineObj.Discount__c;
                    oppLineObj.OriginDiscountAmount = null;
                    oppLineObj.Discount_Amount__c = null;
                    oppLineObj.Campaign__c = loyaltyObj.CampaignId;
                    oppLineObj.Campaign__r = campaignObj;
                    oppLineObj.Campaign__r.Name = loyaltyObj.Name;
                }
                if (bonusItem.Product2Id!=null) {
                    listOppLine.push(bonusItem);
                }
                component.set("v.noRecalculate", true);
                
                console.log('listOppLine[oppLineIdx][3] '+JSON.stringify(listOppLine[oppLineIdx]));
                
                console.log('oppLineObj[1] '+JSON.stringify(oppLineObj));
                
                // -1927-
                // only keep either discount or discount percentage
                if(listOppLine[oppLineIdx].Discount__c != undefined 
                   && listOppLine[oppLineIdx].Discount__c != 0) 
                    listOppLine[oppLineIdx].Discount_Amount__c = undefined;
                
                else if(listOppLine[oppLineIdx].Discount_Amount__c != undefined 
                        && listOppLine[oppLineIdx].Discount_Amount__c != 0)
                    listOppLine[oppLineIdx].Discount__c = undefined;
                
                listOppLine[oppLineIdx] = oppLineObj;
                component.set("v.oliItems",listOppLine);
                
                console.log('listOppLine[oppLineIdx][4]',JSON.stringify(listOppLine[oppLineIdx]));
                
                this.calculateTotalPrice(component, event, listOppLine, oppLineIdx, listOppLine[oppLineIdx].Discount__c, listOppLine[oppLineIdx].Discount_Amount__c);
            },
                unitPriceAssignment: function(component, oppLineObj, rowDiscountDetail, listOppLine, oppLineIdx) {
                    
                    component.set("v.campaignObj",{'sobjectType':'Campaign',
                                                   'Name': null});
                    var campaignObj = component.get("v.campaignObj");
                    if (rowDiscountDetail.DiscountPercentage!=undefined) {
                        oppLineObj.UnitPrice = oppLineObj.Original_Price__c - oppLineObj.Original_Price__c * rowDiscountDetail.DiscountPercentage/100;
                        oppLineObj.Discount_Remarks__c = 'Tier Pricing';
                        oppLineObj.Discount_Reason__c = 'Tier Pricing';
                        oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
                        oppLineObj.Campaign__r = campaignObj;
                        oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
                        
                    } else if (rowDiscountDetail.DiscountAmount!=undefined) {
                        oppLineObj.UnitPrice = oppLineObj.Original_Price__c - rowDiscountDetail.DiscountAmount;
                        oppLineObj.Discount_Remarks__c = 'Tier Pricing';
                        oppLineObj.Discount_Reason__c = 'Tier Pricing';
                        oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
                        oppLineObj.Campaign__r = campaignObj;
                        oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
                        
                    } else if (rowDiscountDetail.DiscountUnitPrice!=undefined) {
                        oppLineObj.UnitPrice = rowDiscountDetail.DiscountUnitPrice;
                        oppLineObj.Discount_Remarks__c = 'Tier Pricing';
                        oppLineObj.Discount_Reason__c = 'Tier Pricing';
                        oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
                        oppLineObj.Campaign__r = campaignObj;
                        oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
                        
                    }
                },
                    discountAssignment: function(component, oppLineObj, rowDiscountDetail, bonusItem, listOppLine, oppLineIdx) {
                        
                        component.set("v.campaignObj",{'sobjectType':'Campaign',
                                                       'Name': null});
                        
                        console.log('oppLineObj.Discount__c B'+oppLineObj.Discount__c);
                        console.log('rowDiscountDetail.DiscountPercentage'+rowDiscountDetail.DiscountPercentage);
                        
                        var campaignObj = component.get("v.campaignObj");
                        if (rowDiscountDetail.DiscountPercentage!=undefined && rowDiscountDetail.BonusProduct==undefined) {
                            this.removeExistingDiscount(component, oppLineObj, listOppLine, oppLineIdx, rowDiscountDetail);
                            oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
                            oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
                            if ((oppLineObj.Pro_Rate_Amount__c == null || oppLineObj.Pro_Rate_Amount__c == undefined || oppLineObj.Pro_Rate_Amount__c == 0) && (oppLineObj.Discount_Remarks__c!=undefined && oppLineObj.Discount_Remarks__c!=null && oppLineObj.Discount_Remarks__c.indexOf('Pro Rated Amount') == -1)) {
                                oppLineObj.Discount_Remarks__c = null;
                            }
                            oppLineObj.OriginDiscountPercentage = rowDiscountDetail.DiscountPercentage;
                            oppLineObj.Discount__c = rowDiscountDetail.DiscountPercentage;
                            oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
                            if (rowDiscountDetail.DiscountReason == 'Marketing Promo') {
                                oppLineObj.Campaign__r = campaignObj;
                                oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
                            }
                            oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
                        } else if (rowDiscountDetail.DiscountAmount!=undefined && rowDiscountDetail.BonusProduct==undefined) {
                            this.removeExistingDiscount(component, oppLineObj, listOppLine, oppLineIdx, rowDiscountDetail);
                            oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
                            oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
                            if ((oppLineObj.Pro_Rate_Amount__c == null || oppLineObj.Pro_Rate_Amount__c == undefined || oppLineObj.Pro_Rate_Amount__c == 0) && (oppLineObj.Discount_Remarks__c!=undefined && oppLineObj.Discount_Remarks__c!=null && oppLineObj.Discount_Remarks__c.indexOf('Pro Rated Amount') == -1)) {
                                oppLineObj.Discount_Remarks__c = null;
                            }
                            oppLineObj.OriginDiscountAmount = rowDiscountDetail.DiscountAmount;
                            oppLineObj.Discount_Amount__c = rowDiscountDetail.DiscountAmount;
                            oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
                            if (rowDiscountDetail.DiscountReason == 'Marketing Promo') {
                                oppLineObj.Campaign__r = campaignObj;
                                oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
                            }
                            oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
                        } else if (rowDiscountDetail.DiscountUnitPrice!=undefined && rowDiscountDetail.BonusProduct==undefined) {
                            this.removeExistingDiscount(component, oppLineObj, listOppLine, oppLineIdx, rowDiscountDetail);
                            oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
                            oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
                            if ((oppLineObj.Pro_Rate_Amount__c == null || oppLineObj.Pro_Rate_Amount__c == undefined || oppLineObj.Pro_Rate_Amount__c == 0) && (oppLineObj.Discount_Remarks__c!=undefined && oppLineObj.Discount_Remarks__c!=null && oppLineObj.Discount_Remarks__c.indexOf('Pro Rated Amount') == -1)) {
                                oppLineObj.Discount_Remarks__c = null;
                            }
                            oppLineObj.UnitPrice = rowDiscountDetail.DiscountUnitPrice;
                            oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
                            if (rowDiscountDetail.DiscountReason == 'Marketing Promo') {
                                oppLineObj.Campaign__r = campaignObj;
                                oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
                            }
                            oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
                        } else if (rowDiscountDetail.BonusProduct!=undefined && rowDiscountDetail.BonusQty!=undefined) {
                            this.removeExistingDiscount(component, oppLineObj, listOppLine, oppLineIdx, rowDiscountDetail);
                            component.set("v.productObj",{'sobjectType':'Product2',
                                                          'Name': null,
                                                          'Description': null,
                                                          'Product_Type__c': null});
                            var productObj = component.get("v.productObj");
                            if (rowDiscountDetail.DiscountReason!='Agent Referral: Referee') {
                                oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
                                oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
                            }
                            oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
                            if ((oppLineObj.Pro_Rate_Amount__c == null || oppLineObj.Pro_Rate_Amount__c == undefined || oppLineObj.Pro_Rate_Amount__c == 0) && (oppLineObj.Discount_Remarks__c!=undefined && oppLineObj.Discount_Remarks__c!=null && oppLineObj.Discount_Remarks__c.indexOf('Pro Rated Amount') == -1)) {
                                oppLineObj.Discount_Remarks__c = null;
                            }
                            bonusItem.Product2Id = rowDiscountDetail.BonusProduct;
                            bonusItem.Product2 = productObj;
                            bonusItem.Start_Date__c = oppLineObj.Start_Date__c;
                            bonusItem.End_Date__c = oppLineObj.End_Date__c;
                            bonusItem.PricebookEntryId = rowDiscountDetail.PricebookEntryId;
                            bonusItem.Product2.Name = rowDiscountDetail.BonusProductName;
                            if (rowDiscountDetail.ChildCategory!=undefined) {
                                bonusItem.Child_Category__c = rowDiscountDetail.ChildCategory;
                            }
                            bonusItem.Quantity = rowDiscountDetail.BonusQty;
                            bonusItem.Discount__c = rowDiscountDetail.DiscountPercentage;
                            bonusItem.UnitPrice = rowDiscountDetail.BonusPrice;
                            bonusItem.Line_Description2__c = rowDiscountDetail.ProductDescription;
                            bonusItem.Description = this.shortenDescription(bonusItem.Line_Description2__c);
                            bonusItem.Product_Type__c = rowDiscountDetail.ProductType;
                            bonusItem.Parent__c = oppLineIdx;
                            if (rowDiscountDetail.TaxCode!=null) {
                                bonusItem.GST_VAT_Rate__c = rowDiscountDetail.TaxRate;
                                bonusItem.GST_VAT_Code__c = rowDiscountDetail.TaxCode;
                            } else {
                                bonusItem.GST_VAT_Rate__c = 0;
                                bonusItem.GST_VAT_Code__c = null;
                            }
                            bonusItem.PO__c = true;
                            bonusItem.Complimentary__c = true;
                            if (rowDiscountDetail.DiscountReason == 'Marketing Promo' || rowDiscountDetail.DiscountReason == 'Agent Referral: Referee') {
                                component.set("v.campaignObj",{'sobjectType':'Campaign',
                                                               'Name': null});
                                oppLineObj.Campaign__r = component.get("v.campaignObj");
                                oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
                                
                                bonusItem.Campaign__c = rowDiscountDetail.CampaignId;
                                bonusItem.Campaign__r = component.get("v.campaignObj");
                                bonusItem.Campaign__r.Name = rowDiscountDetail.Name;
                                bonusItem.Discount_Reason__c = rowDiscountDetail.DiscountReason;
                            }
                        }
                        
                        console.log('oppLineObj.Discount__c A'+oppLineObj.Discount__c);
                    },
                        removeExistingTierPricing: function(component, oppLineObj) {
                            
                            oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
                            if ((oppLineObj.Pro_Rate_Amount__c == null || oppLineObj.Pro_Rate_Amount__c == undefined || oppLineObj.Pro_Rate_Amount__c == 0) && (oppLineObj.Discount_Remarks__c!=undefined && oppLineObj.Discount_Remarks__c!=null && oppLineObj.Discount_Remarks__c.indexOf('Pro Rated Amount') == -1)) {
                                oppLineObj.Discount_Remarks__c = null;
                            }
                            oppLineObj.Campaign__c = null;
                        },
                            removeExistingDiscount: function(component, oppLineObj, listOppLine, oppLineIdx, rowDiscountDetail) {
                                component.set("v.campaignObj",{'sobjectType':'Campaign',
                                                               'Name': null});
                                //oppLineObj.Campaign__r = component.get("v.campaignObj");;
                                oppLineObj.Campaign__c = null;
                                oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
                                oppLineObj.OriginDiscountPercentage = null;
                                oppLineObj.OriginDiscountAmount = null;
                                oppLineObj.Discount_Reason__c = null;
                                
                                if ((oppLineObj.Pro_Rate_Amount__c == null || oppLineObj.Pro_Rate_Amount__c == undefined || oppLineObj.Pro_Rate_Amount__c == 0) && (oppLineObj.Discount_Remarks__c!=undefined && oppLineObj.Discount_Remarks__c!=null && oppLineObj.Discount_Remarks__c.indexOf('Pro Rated Amount') == -1)) {
                                    oppLineObj.Discount_Remarks__c = null;
                                }
                                oppLineObj.Discount_Amount__c = 0;
                                oppLineObj.Discount__c = 0;
                                if (rowDiscountDetail!=null && rowDiscountDetail.DiscountPercentage!=undefined) {
                                } else if (rowDiscountDetail!=null && rowDiscountDetail.DiscountAmount!=undefined) {
                                }
                                var listRemoveChild = this.removeChildren(component, listOppLine, oppLineObj, oppLineIdx);
                                
                                if (listRemoveChild.length>0) {
                                    listOppLine = component.get("v.listOppLine");
                                    for (var idx in listRemoveChild) {
                                        if (listOppLine[listRemoveChild[idx]]!=undefined && listOppLine[listRemoveChild[idx]].Child_Category__c!=='Package') {
                                            if((listOppLine[listRemoveChild[idx]].Parent__c===listOppLine[listRemoveChild[idx]].Id || listOppLine[listRemoveChild[idx]].Parent__c===undefined || listOppLine[listRemoveChild[idx]].Parent__c===null || listOppLine[listRemoveChild[idx]].Parent__c==='' )) {
                                                listOppLine[listRemoveChild[idx]].Parent__c = null;
                                            } else {
                                                listOppLine.splice(listRemoveChild[idx], 1);
                                            }
                                        }
                                    }
                                }
                            },
                                handleBlur : function(cmp,event) {
                                    var oppObj = cmp.get("v.quoteObj");
                                    var listOppLine = cmp.get("v.oliItems");
                                    //var idx = +event.currentTarget.parentElement.dataset.rowIndex;
                                    var idx =  event.target.getAttribute("data-row-index");
                                    console.log('??????idx   '+idx)
                                    this.setDiscountOnEdit(cmp, event, oppObj, listOppLine, idx);
                                },
                                    calculateTotalPrice: function(component, event, listOppLine, idx, discount, discountAmount) {
                                        var unitPrice = listOppLine[idx].UnitPrice==null?0:listOppLine[idx].UnitPrice;
                                        var quantity = listOppLine[idx].Quantity==null?0:listOppLine[idx].Quantity;
                                        var complimentary = listOppLine[idx].Complimentary__c;
                                        var totalPrice = unitPrice * quantity;
                                        var oppObj = component.get("v.quoteObj");
                                        discount = discount==undefined?null:discount;
                                        discountAmount = discountAmount==undefined?null:discountAmount;
                                        var discountedAmount = discount!=null?unitPrice*quantity*discount/100:discountAmount;
                                        var noRecalculate = component.get("v.noRecalculate");
                                        
                                        if (discount==0) {
                                            listOppLine[idx].Discount__c = null;
                                        }
                                        if (discountAmount==0) {
                                            listOppLine[idx].Discount_Amount__c = null;
                                        }
                                        if (listOppLine[idx].Parent__c=='null' || listOppLine[idx].Parent__c==null) {
                                            listOppLine[idx].Parent__c = null;
                                        }
                                        console.log('component.get("v.resetAllRelatedBonus"):'+component.get("v.resetAllRelatedBonus"));
                                        if (component.get("v.resetAllRelatedBonus")) {
                                            component.set("v.resetAllRelatedBonus", false);
                                            component.set("v.campaignObj",{'sobjectType':'Campaign',
                                                                           'Name': null});
                                            listOppLine[idx].Campaign__r = component.get("v.campaignObj");
                                            listOppLine[idx].OriginDiscountPercentage = null;
                                            listOppLine[idx].OriginDiscountAmount = null;
                                            // -1927-
                                            // listOppLine[idx].Campaign__c = null;
                                            // PTYG01T-20: Changing discount manually is not reset Tier Price to Unit Price
                                            // listOppLine[idx].UnitPrice = listOppLine[idx].Original_Price__c;
                                            
                                            if ((listOppLine[idx].Pro_Rate_Amount__c == null || listOppLine[idx].Pro_Rate_Amount__c == undefined || listOppLine[idx].Pro_Rate_Amount__c == 0) && (listOppLine[idx].Discount_Remarks__c!=undefined && listOppLine[idx].Discount_Remarks__c!=null && listOppLine[idx].Discount_Remarks__c.indexOf('Pro Rated Amount') == -1)) {
                                                listOppLine[idx].Discount_Remarks__c = null;
                                            }
                                            unitPrice = listOppLine[idx].UnitPrice;
                                            discountedAmount = discount!=null?unitPrice*quantity*discount/100:discountAmount;
                                            totalPrice = unitPrice * quantity;
                                            listOppLine[idx].Amount__c = totalPrice-(isNaN(discountedAmount)?0:discountedAmount)-(isNaN(listOppLine[idx].Pro_Rate_Amount__c)?0:
                                                                                                                                  (totalPrice-(isNaN(discountedAmount)?0:discountedAmount)>=listOppLine[idx].Pro_Rate_Amount__c?listOppLine[idx].Pro_Rate_Amount__c:(totalPrice-(isNaN(discountedAmount)?0:discountedAmount))));
                                            if ((discount == 0 || discount == null) && discountAmount != 0 && discountAmount != null) {
                                                if (listOppLine[idx].Amount__c > 0) {
                                                    // -1927-
                                                    // listOppLine[idx].Discount_Reason__c = 'Managerial Discount';
                                                }
                                                listOppLine[idx].Discount__c = null;
                                                listOppLine[idx].OriginDiscountPercentage = null;
                                                listOppLine[idx].OriginDiscountAmount = listOppLine[idx].Discount_Amount__c;
                                            } else if (discount != 0 && discount != null && (discountAmount == 0 || discountAmount == null)) {
                                                if (listOppLine[idx].Amount__c > 0) {
                                                    // -1927-
                                                    //listOppLine[idx].Discount_Reason__c = 'Managerial Discount';
                                                }
                                                listOppLine[idx].Discount_Amount__c = null;
                                                listOppLine[idx].OriginDiscountAmount = null;
                                                listOppLine[idx].OriginDiscountPercentage = listOppLine[idx].Discount__c;
                                            } else {
                                                listOppLine[idx].Discount_Reason__c = null;
                                                var abc = this;
                                                setTimeout(function() {
                                                    abc.setDiscountOnEdit(component, event, oppObj, listOppLine, idx);
                                                }, 500);
                                            }
                                        } else if (discount != listOppLine[idx].OriginDiscountPercentage || discountAmount != listOppLine[idx].OriginDiscountAmount) {
                                            listOppLine[idx].OriginDiscountPercentage = null;
                                            listOppLine[idx].OriginDiscountAmount = null;
                                            // -1927-
                                            // listOppLine[idx].Campaign__c = null;
                                            // -1927-
                                            // listOppLine[idx].UnitPrice = listOppLine[idx].Original_Price__c;
                                            if ((listOppLine[idx].Pro_Rate_Amount__c == null || listOppLine[idx].Pro_Rate_Amount__c == undefined || listOppLine[idx].Pro_Rate_Amount__c == 0) && (listOppLine[idx].Discount_Remarks__c!=undefined && listOppLine[idx].Discount_Remarks__c!=null && listOppLine[idx].Discount_Remarks__c.indexOf('Pro Rated Amount') == -1)) {
                                                listOppLine[idx].Discount_Remarks__c = null;
                                            }
                                            unitPrice = listOppLine[idx].UnitPrice;
                                            discountedAmount = discount!=null?unitPrice*quantity*discount/100:discountAmount;
                                            totalPrice = unitPrice * quantity;
                                            listOppLine[idx].Amount__c = totalPrice-(isNaN(discountedAmount)?0:discountedAmount)-(isNaN(listOppLine[idx].Pro_Rate_Amount__c)?0:
                                                                                                                                  (totalPrice-(isNaN(discountedAmount)?0:discountedAmount)>=listOppLine[idx].Pro_Rate_Amount__c?listOppLine[idx].Pro_Rate_Amount__c:(totalPrice-(isNaN(discountedAmount)?0:discountedAmount))));
                                            if (noRecalculate==false && (discount==0 || discount==null) && (discountAmount==0 || discountAmount==null)) {
                                                listOppLine[idx].Discount_Reason__c = null;
                                                var abc = this;
                                                setTimeout(function() {
                                                    abc.setDiscountOnEdit(component, event, oppObj, listOppLine, idx);
                                                }, 500);
                                            } else if (listOppLine[idx].Amount__c > 0) {
                                                //listOppLine[idx].Discount_Reason__c = 'Managerial Discount';
                                            }
                                        } else {
                                            listOppLine[idx].Amount__c = totalPrice-(isNaN(discountedAmount)?0:discountedAmount)-(isNaN(listOppLine[idx].Pro_Rate_Amount__c)?0:
                                                                                                                                  (totalPrice-(isNaN(discountedAmount)?0:discountedAmount)>=listOppLine[idx].Pro_Rate_Amount__c?listOppLine[idx].Pro_Rate_Amount__c:(totalPrice-(isNaN(discountedAmount)?0:discountedAmount))));
                                        }
                                        
                                        if (listOppLine[idx].Amount__c==0) {
                                            listOppLine[idx].Complimentary__c = true;
                                            if (listOppLine[idx].Parent__c!=null) {
                                                listOppLine[idx].Discount__c = 100;
                                            }
                                        } else {
                                            listOppLine[idx].Complimentary__c = false;
                                        }
                                        
                                        listOppLine[idx].Gross_Amount__c = listOppLine[idx].Amount__c + ( listOppLine[idx].Amount__c * (listOppLine[idx].GST_VAT_Rate__c/100) );
                                        /*setTimeout(function() {
            component.set("v.listOppLine", null);
            component.set("v.listOppLine", listOppLine);
            component.set("v.sizeOppLineItem", listOppLine.length);
            component.set("v.Spinner", false);}, 500);*/
                                        
                                        component.set("v.noRecalculate", false);
                                    },
                                        removeChildren: function(component, listOppLine, oppLine, oppLineIdx) {
                                            var listOppLineDelete = component.get("v.listOppLineDelete");
                                            var listRemove = [];
                                            for (var idx = listOppLine.length-1; idx>=0; idx--) {
                                                if (listOppLine[idx].Parent__c!=undefined && listOppLine[idx].Parent__c!=null && ((isNaN(listOppLine[idx].Parent__c) && listOppLine[idx].Parent__c == oppLine.Id) || listOppLine[idx].Parent__c==oppLineIdx)) {
                                                    if (listOppLine[idx].Id!=undefined) {
                                                        // Only add to list for deletion if particular OpportunityLineItem has Id.
                                                        listOppLineDelete.push(listOppLine[idx]);
                                                    }
                                                    if (idx < listOppLine.length-1) {
                                                        // Only proceed adjust parent index if rowIndex < listOppLine.length-1
                                                        this.adjustParentIndex(component, listOppLine, idx);
                                                    }
                                                    listRemove.push(idx);
                                                }
                                            }
                                            if (listRemove.length>0) {
                                                component.set("v.listOppLineDelete", listOppLineDelete);
                                            }
                                            return listRemove;
                                        },
                                            adjustParentIndex: function(component, listOppLine, rowIndex) {
                                                var tmpIdx;
                                                for (var idx = listOppLine.length-1; idx>rowIndex; idx--) {
                                                    if (listOppLine[idx].Parent__c!=undefined && !isNaN(listOppLine[idx].Parent__c)) {
                                                        tmpIdx = listOppLine[idx].Parent__c*1;
                                                        if (tmpIdx>rowIndex) {
                                                            listOppLine[idx].Parent__c = --tmpIdx;
                                                        }
                                                    }
                                                }
                                            },
                                                getDataList : function(cmp,event,fieldName,ObjectName,defaultResourceList) {
                                                    
                                                    let picklist = cmp.get("c.getListData");
                                                    picklist.setParams({
                                                        idx : 'Id',
                                                        namex : fieldName,
                                                        objectx : ObjectName
                                                    });
                                                    picklist.setCallback(this, function(response) {
                                                        if (response.getState() === "SUCCESS") {
                                                            let conts = response.getReturnValue();
                                                            let resourceList = [defaultResourceList];
                                                            for (let key in conts) {
                                                                resourceList.push(conts[key]);
                                                            }
                                                            cmp.set('v.listTaxCode', resourceList);
                                                        }
                                                    });
                                                    $A.enqueueAction(picklist);
                                                },
                                                    addProductAct: function(component, event, resourceList, oppObj, oppLineItem, rowIndex, oppId, bonusItem) {
                                                        console.log('rowIndex:'+rowIndex);
                                                        var getChild = component.get("c.getChild");
                                                        
                                                        getChild.setParams({"priceBookId": oppObj.Pricebook2Id, "parentProductId": oppLineItem.Product2Id});
                                                        getChild.setCallback(this, function(response) {
                                                            if (response.getState() === "SUCCESS") {
                                                                var conts = response.getReturnValue();
                                                                for (var key in conts) {
                                                                    var oppLineObj = {};
                                                                    this.newLineAssignment(component, oppLineObj, rowIndex, conts[key].Parent, conts[key], conts[key].Quantity, conts[key].Line_Description2, conts[key].Complimentary, null, false,oppLineItem);
                                                                    console.log('conts[key].Quantity>>> ',JSON.stringify(conts[key].Quantity));
                                                                    resourceList.push(oppLineObj);
                                                                }
                                                                
                                                                if (bonusItem!=null) {
                                                                    resourceList.push(bonusItem);
                                                                }
                                                                component.set("v.oliItems", resourceList);
                                                                //console.log('>>>>>><<< '+JSON.stringify(component.get("v.oliItems")));
                                                                
                                                            }
                                                        });
                                                        $A.enqueueAction(getChild);
                                                    },
                                                        newLineAssignment: function(component, oppLineObj, parentIdx, parent, productRow, quantity, description, complimentary, orderType, isBundle, oppLineItem) {
                                                            component.set("v.productObj",{'sobjectType':'Product2',
                                                                                          'Name': null,
                                                                                          'Description': null,
                                                                                          'Product_Type__c': null});
                                                            var oppObj = component.get("v.quoteObj");
                                                            var productObj = component.get("v.productObj");
                                        
                                                            //var today = oppObj.netsuite_conn__Order_Type__c == 'Contract - Renewal'?oppObj.CloseDate:this.getToday();
                                                            //var nextYear = oppObj.netsuite_conn__Order_Type__c == 'Contract - Renewal'?this.getNextYear(oppObj.CloseDate):this.getNextYear(today);
                                                            var today = oppObj.Opportunity_Type__c == 'B2C - Renewal'?oppObj.CloseDate:this.getToday();	
                                                            var nextYear = oppObj.Opportunity_Type__c == 'B2C - Renewal'?this.getNextYear(oppObj.CloseDate):this.getNextYear(today);
                                                            //alert('1');
                                                            oppLineObj.Product2 = productObj;
                                                            //alert(productRow.Product2.Name);
                                                            oppLineObj.PricebookEntryId = productRow.Id;
                                                            oppLineObj.QuoteId = oppObj.Id;
                                                            oppLineObj.Parent__c = parentIdx;
                                                            oppLineObj.Parent = parent;
                                                            oppLineObj.Product2Id = productRow.Product2Id;
                                                            //alert('2');
                                                            oppLineObj.Product2.Name = productRow.Product2.Name;
                                                            oppLineObj.Line_Description2__c = description;
                                                            oppLineObj.Product_Category__c = productRow.Product2.Product_Category__c;
                                                            oppLineObj.Product2.SKU_Code__c = productRow.Product2.SKU_Code__c;
                                                            //oppLineObj.UnitPrice = productRow.UnitPrice;
                                                            oppLineObj.UnitPrice = 0;
                                                            oppLineObj.Original_Price__c = oppLineObj.UnitPrice==null||oppLineObj.UnitPrice==undefined?0:oppLineObj.UnitPrice;
                                                            oppLineObj.Description = this.shortenDescription(oppLineObj.Line_Description2__c);
                                                            //alert('3')
                                                            oppLineObj.Product_Type__c = productRow.Product_Type;
                                                            oppLineObj.Quantity = quantity;
                                                            oppLineObj.Complimentary__c = complimentary;
                                                            oppLineObj.Push_to_NetSuite__c = productRow.Push_to_NetSuite;
                                                            if(productRow.Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_MONTHLY_AC") && 
                                                               oppLineItem.Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) {
                                                                var adCreditIndex = component.get("v.adCreditIndex")==undefined?0:component.get("v.adCreditIndex");
                                                                if(adCreditIndex == 0) {
                                                                    oppLineObj.Start_Date__c = oppLineItem.Start_Date__c;
                                                                } else {
                                                                    var startDate = this.addMonths(oppLineItem.Start_Date__c,parseInt(adCreditIndex),'Months');
                                                                oppLineObj.Start_Date__c =  this.addMonths(startDate,2,'Days');
                                                                }
                                                                adCreditIndex = adCreditIndex+1;
                                                                component.set("v.adCreditIndex",adCreditIndex);
                                                                oppLineObj.End_Date__c =   this.addMonths(oppLineItem.Start_Date__c,parseInt(adCreditIndex),'Months');
                                                            } else {
                                                                component.set("v.adCreditIndex",0);
                                                                oppLineObj.Start_Date__c = oppLineItem.Start_Date__c;
                                                                oppLineObj.End_Date__c = oppLineItem.End_Date__c;
                                                            }
                                                            if (productRow.ChildCategory!=undefined) {
                                                                oppLineObj.Child_Category__c = productRow.ChildCategory;
                                                            }
                                                            //alert('4');
                                                            if (productRow.Product2.Tax_Code__c != null) {
                                                                oppLineObj.GST_VAT_Code__c = productRow.Product2.Tax_Code__c;
                                                            } else {
                                                                oppLineObj.GST_VAT_Code__c = null;
                                                            }
                                                            //alert('5');
                                                            if (productRow.Product2.Tax_Code__r != undefined) {
                                                                oppLineObj.GST_VAT_Rate__c = productRow.Product2.Tax_Code__r.Tax_Rate__c;
                                                            } else {
                                                                oppLineObj.GST_VAT_Rate__c = 0;
                                                            }
                                                            oppLineObj.Income_Account_Name__c = productRow.Product2.Income_Account_Name__c;
                                                            oppLineObj.Order_Type__c = orderType;
                                                            oppLineObj.PO__c = true;
                                                            
                                                        },
                                                            shortenDescription: function(originalDesc) {
                                                                var result = (originalDesc!=null && originalDesc!=undefined && originalDesc.length>30)?(originalDesc.substr(0, 30)+'...'):originalDesc;
                                                                return result;
                                                            },
                                                                addMonths: function(today,addValue,addType) {
                                                                    today = today.split('-');
                                                                    // Please pay attention to the month (parts[1]); JavaScript counts months from 0:
                                                                    // January - 0, February - 1, etc.
                                                                    let todayDate = new Date(today[0], today[1] - 1, today[2]); 
                                                                    
                                                                    let yesterday = new Date(todayDate);
                                                                    yesterday.setDate(todayDate.getDate() - 1); //setDate also supports negative values, which cause the month to rollover.
                                                                    
                                                                    let endDate = new Date(yesterday);
                                                                    if(addType == 'Years'){
                                                                        endDate.setMonth(yesterday.getMonth() + addValue*12);
                                                                    }else if(addType == 'Months'){
                                                                        endDate.setMonth(yesterday.getMonth() + addValue);
                                                                    }else if(addType == 'Weeks'){
                                                                        endDate.setDate(yesterday.getDate() + addValue*7);
                                                                    }else if(addType == 'Days'){
                                                                        endDate.setDate(yesterday.getDate() + addValue);
                                                                    }
                                                                    
                                                                    let dd = endDate.getDate();
                                                                    let mm = endDate.getMonth()+1; //January is 0!
                                                                    let yyyy = endDate.getFullYear();
                                                                    
                                                                    if(dd<10) {
                                                                        dd = '0'+dd
                                                                    } 
                                                                    
                                                                    if(mm<10) {
                                                                        mm = '0'+mm
                                                                    } 
                                                                    
                                                                    endDate = yyyy + '-' + mm + '-' + dd;
                                                                    return endDate;
                                                                    
                                                                    //return endDate;
                                                                },
                                                                    validateFields: function(cmp, listOppLine,country) {
                                                                        
                                                                        let resultVal = false;
                                                                        if(country == 'Singapore'){
                                                                            resultVal = this.validateFieldsForSG(cmp, listOppLine); 
                                                                        } 
                                                                        if(country == 'Malaysia' || country == 'Thailand'){
                                                                            resultVal = this.validateFieldsForMY(cmp, listOppLine);
                                                                        } 
                                                                        return resultVal;
                                                                    },
                                                                        validateFieldsForSG: function (cmp, listOppLine) {
                                                                            var listRequired = ['oppStartDate', 'oppEndDate', 'oppQuantity', 'oppUnitPrice'];
                                                                            var discountReason = cmp.find('discountReason');
                                                                            var startDateField = cmp.find('oppStartDate');
                                                                            var endDateField = cmp.find('oppEndDate');

                                                                            //var startDateField = cmp.find('oppStartDate');
                                                                            //var endDateField = cmp.find('oppEndDate');
                                                                            var oppObj = cmp.get("v.oppObj");
                                                                            var EligibleVip = cmp.get("v.EligibleVip");
                                                                            //Added VIP Relationship in the list to avoid 100% discount error
                                                                            var listDiscountReasonNot100 = {'Loyalty Discount': true, 'Managerial Discount': true, 'Marketing Promo': true, 'First-Timer Discount': true, 'Agent Referral: Referee': true, 'Cash Voucher': true, 'Renewal Promotion' : true, 'Renewal Bonus' : true, 'VIP (Relationship)' : true};
                                                                            var currField, result=true, rowResult, discountReasonValue ,prodCategory ;
                                                                            var hasFoc = false, hasVip = false, hasManagerial = false;
                                                                            var exprVip = /VIP/, exprManagerial = /Managerial/, exprVipSpending = /Advance|Premier/;
                                                                            var productName;
                                                                            let endOfWeekTemp = cmp.get("v.endOfTheWeek");
                                                                            let endOfWeekExisting = cmp.get("v.endDayForExisting");
                                                                            console.log('test2222');
                                                                            console.log(endOfWeekExisting);
                                                                            const endOfWeek = new Map();
                                                                            for(var rType in endOfWeekExisting){
                                                                                endOfWeek.set(endOfWeekExisting[rType].key,endOfWeekExisting[rType].value);
                                                                            }
                                                                            
                                                                            //Added length check on array (VIP Relationship changes)
                                                                            if (Array.isArray(discountReason) && discountReason.length>1) {
                                                                                for (var oppLineIdx in listOppLine) {
                                                                                    
                                                                                    let endDay = new Date();
                                                                                    if(oppObj.Opportunity_Type__c ==  'B2C - Upgrade'){
                                                                                        
                                                                                        if(listOppLine[oppLineIdx].Id ==null || listOppLine[oppLineIdx].Id ==''){
                                                                                            endDay = endOfWeekTemp.get(listOppLine[oppLineIdx].Product2Id);  
                                                                                        }else{
                                                                                            endDay =  endOfWeek.get(listOppLine[oppLineIdx].Id);     
                                                                                        }
                                                                                    }else{
                                                                                        endDay = '';
                                                                                    }
                                                                                    
                                                                                    productName = listOppLine[oppLineIdx].Product2.Name;
                                                                                    prodCategory = listOppLine[oppLineIdx].Product2.Product_Category__c;
                                                                                    for (var idx in listRequired) {
                                                                                        /*var tempCurrField = cmp.find(listRequired[idx]);
                                                                                        if(Array.isArray(tempCurrField)) {
                                                                                            currField = tempCurrField[0];
                                                                                        } else {
                                                                                            currField = tempCurrField;
                                                                                        }*/
                                                                                        
                                                                                        currField = cmp.find(listRequired[idx]);
                                                                                        if (!currField[oppLineIdx].get('v.value') && currField[oppLineIdx].get('v.required')) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Field is required.');
                                                                                            result &= false;
                                                                                        }
                                                                                    }
                                                                                    // Changed to get value of discount reason (VIP Relationship changes)
                                                                                    //discountReasonValue = discountReason[oppLineIdx].get('v.value');
                                                                                    discountReasonValue = listOppLine[oppLineIdx].Discount_Reason__c;
                                                                                    if(((listOppLine[oppLineIdx].Parent__c == undefined || listOppLine[oppLineIdx].Parent__c == null) && (listOppLine[oppLineIdx].Parent_Id__c == undefined || listOppLine[oppLineIdx].Parent_Id__c == null))){
                                                                                        
                                                                                        if (!discountReasonValue && (!isNaN(listOppLine[oppLineIdx].Discount__c) && listOppLine[oppLineIdx].Discount__c>0 || !isNaN(listOppLine[oppLineIdx].Discount_Amount__c) && listOppLine[oppLineIdx].Discount_Amount__c>0)){
                                                                                            this.showToast(cmp, event, 'ERROR', 'Discount Reason is mandatory.');
                                                                                            result &= false;
                                                                                        } else if (discountReasonValue == 'Marketing Promo' && (listOppLine[oppLineIdx].Campaign__c==null || listOppLine[oppLineIdx].Campaign__c==undefined)) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                            result &= false;
                                                                                        } else if (discountReasonValue == 'Loyalty Discount' && (listOppLine[oppLineIdx].Campaign__c==null || listOppLine[oppLineIdx].Campaign__c==undefined)) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                            result &= false;
                                                                                        } else if (discountReasonValue == 'Managerial Discount' && listOppLine[oppLineIdx].Amount__c==0) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Managerial Discount cannot have 100% discount.');
                                                                                            result &= false;
                                                                                        } else if (discountReasonValue == 'First-Timer Discount' && (listOppLine[oppLineIdx].Campaign__c==null || listOppLine[oppLineIdx].Campaign__c==undefined)) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                            result &= false;
                                                                                        } else if (discountReasonValue == 'Agent Referral: Referee' && (listOppLine[oppLineIdx].Campaign__c==null || listOppLine[oppLineIdx].Campaign__c==undefined)) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Agent not eligible for Referral Entitlement.');
                                                                                            result &= false;
                                                                                        } else if (discountReasonValue != null && discountReasonValue != undefined && discountReasonValue != '' && listDiscountReasonNot100[discountReasonValue] == undefined && (listOppLine[oppLineIdx].Amount__c > 0 || listOppLine[oppLineIdx].Amount__c == undefined)) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Selected Discount Reason must have 100% Discount.');
                                                                                            result &= false;
                                                                                        }else if (discountReasonValue != null && discountReasonValue != '' && discountReasonValue != undefined && prodCategory != undefined && prodCategory !='' && prodCategory != null && discountReasonValue=='Managerial Discount' && prodCategory=='Subscription' ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Managerial Discount is not applicable for Subscription product.');
                                                                                            result &= false;
                                                                                        }
                                                                                            else if (discountReasonValue == 'Renewal Promotion' && (listOppLine[oppLineIdx].Campaign__c==null || listOppLine[oppLineIdx].Campaign__c==undefined) && prodCategory=='Subscription') {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Invalid Discount reason.');
                                                                                                result &= false;
                                                                                            }
                                                                                    }
                                                                                    
                                                                                    
                                                                                    if (discountReasonValue != '' && discountReasonValue != null) {
                                                                                        if (discountReasonValue.search(exprVip)) {
                                                                                            hasVip &= true;
                                                                                        } else if (discountReasonValue.search(exprManagerial)) {
                                                                                            hasManagerial &= true;
                                                                                        } else if (discountReasonValue != 'Loyalty Discount' && discountReasonValue != 'Marketing Promo') {
                                                                                            hasFoc = true;
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    if (hasVip && hasManagerial) {
                                                                                        this.showToast(cmp, event, 'Cannot have both VIP & Managerial Discount Reason at once. Please separate into different Opportunity.');
                                                                                        result &= false;
                                                                                    } else if (hasFoc && hasManagerial) {
                                                                                        this.showToast(cmp, event, 'Cannot have both FOC & Managerial Discount Reason at once. Please separate into different Opportunity.');
                                                                                        result &= false;
                                                                                    }
                                                                                    
                                                                                    rowResult = this.proceedValidateStartEndDate(startDateField[oppLineIdx].get('v.value'), endDateField[oppLineIdx].get('v.value'), oppObj, listOppLine[oppLineIdx],endDay);
                                                                                    if (!rowResult.result) {
                                                                                        result &= false;
                                                                                        if(rowResult.startDateMessage){
                                                                                            this.showToast(cmp, event, 'ERROR', rowResult.startDateMessage);
                                                                                        }
                                                                                        this.showToast(cmp, event, 'ERROR', rowResult.endDateMessage);
                                                                                        
                                                                                    } 
                                                                                }
                                                                            } else {
                                                                                let endDay = new Date();
                                                                                if(oppObj.Opportunity_Type__c ==  'B2C - Upgrade'){
                                                                                    
                                                                                    if(listOppLine[0].Id ==null || listOppLine[0].Id ==''){
                                                                                        endDay = endOfWeekTemp.get(listOppLine[0].Product2Id);  
                                                                                    }else{
                                                                                        endDay =  endOfWeek.get(listOppLine[0].Id);     
                                                                                    }
                                                                                }else{
                                                                                    endDay = '';
                                                                                }
                                                                                
                                                                                for (var idx in listRequired) {
                                                                                    var tempCurrField = cmp.find(listRequired[idx]);
                                                                                        if(Array.isArray(tempCurrField)) {
                                                                                            currField = tempCurrField[0];
                                                                                        } else {
                                                                                            currField = tempCurrField;
                                                                                        }

                                                                                    //currField = cmp.find(listRequired[idx]);
                                                                                    if (!currField.get('v.value') && currField.get('v.required')) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Field is required.');
                                                                                        result &= false;
                                                                                    } 
                                                                                }
                                                                                
                                                                                // Changed to get value of discount reason (VIP Relationship changes)
                                                                                // discountReasonValue = discountReason.get('v.value');
                                                                                discountReasonValue = listOppLine[0].Discount_Reason__c;
                                                                                prodCategory = listOppLine[0].Product_Category__c;
                                                                                
                                                                                if( ((listOppLine[0].Parent__c == undefined || listOppLine[0].Parent__c == null) && (listOppLine[0].Parent_Id__c == undefined || listOppLine[0].Parent_Id__c == null))){
                                                                                    if (!discountReasonValue && (!isNaN(listOppLine[0].Discount__c) && listOppLine[0].Discount__c>0 || !isNaN(listOppLine[0].Discount_Amount__c) && listOppLine[0].Discount_Amount__c>0))  {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Discount Reason is mandatory.');
                                                                                        result &= false;
                                                                                    } else if (discountReasonValue == 'Marketing Promo' && (listOppLine[0].Campaign__c==null || listOppLine[0].Campaign__c==undefined)) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                        result &= false;
                                                                                    } else if (discountReasonValue == 'Loyalty Discount' && (listOppLine[0].Campaign__c==null || listOppLine[0].Campaign__c==undefined)) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                        result &= false;
                                                                                    } else if (discountReasonValue == 'Managerial Discount' && listOppLine[0].Amount__c==0) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Managerial Discount cannot have 100% discount.');
                                                                                        result &= false;
                                                                                    } else if (discountReasonValue == 'First-Timer Discount' && (listOppLine[0].Campaign__c==null || listOppLine[0].Campaign__c==undefined)) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                        result &= false;
                                                                                    } else if (discountReasonValue == 'Agent Referral: Referee' && (listOppLine[0].Campaign__c==null || listOppLine[0].Campaign__c==undefined)) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Agent not eligible for Referral Entitlement.');
                                                                                        result &= false;
                                                                                    } else if (discountReasonValue != null && discountReasonValue != '' && discountReasonValue != undefined && listDiscountReasonNot100[discountReasonValue] == undefined && (listOppLine[0].Amount__c > 0 || listOppLine[0].Amount__c == undefined)) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Selected Discount Reason must have 100% Discount.');
                                                                                        result &= false;
                                                                                    } else if (discountReasonValue != null && discountReasonValue != '' && discountReasonValue != undefined && prodCategory != undefined && prodCategory !='' && prodCategory != null && discountReasonValue=='Managerial Discount' && prodCategory=='Subscription' ) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Managerial Discount is not applicable for Subscription product.');
                                                                                        result &= false;
                                                                                    }else if (discountReasonValue == 'Renewal Promotion' && (listOppLine[0].Campaign__c==null || listOppLine[0].Campaign__c==undefined) && prodCategory=='Subscription' ) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Invalid Discount reason.');
                                                                                        result &= false;
                                                                                    } 
                                                                                }
                                                                                
                                                                                
                                                                                
                                                                                if (discountReasonValue != null && discountReasonValue != '') {
                                                                                    if (discountReasonValue.search(exprVip)) {
                                                                                        hasVip = true;
                                                                                    } else if (discountReasonValue.search(exprManagerial)) {
                                                                                        hasManagerial = true;
                                                                                    } else if (discountReasonValue != 'Loyalty Discount' && discountReasonValue != 'Marketing Promo') {
                                                                                        hasFoc = true;
                                                                                    }
                                                                                }
                                                                                if (hasVip && hasManagerial) {
                                                                                    this.showToast(cmp, event, 'ERROR','Cannot have both VIP & Managerial Discount Reason at once. Please separate into different Opportunity.');
                                                                                    result &= false;
                                                                                } else if (hasFoc && hasManagerial) {
                                                                                    this.showToast(cmp, event, 'ERROR','Cannot have both FOC & Managerial Discount Reason at once. Please separate into different Opportunity.');
                                                                                    result &= false;
                                                                                }
                                                                                var tempStartDateField;
                                                                                var tempEndDateField;
                                                                                if(Array.isArray(startDateField)) {
                                                                                    tempStartDateField = startDateField[0];
                                                                                } else {
                                                                                    tempStartDateField = startDateField;
                                                                                }
                                                                                if(Array.isArray(endDateField)) {
                                                                                    tempEndDateField = endDateField[0];
                                                                                } else {
                                                                                    tempEndDateField = endDateField;
                                                                                }
                                                                                rowResult = this.proceedValidateStartEndDate(tempStartDateField.get('v.value'), tempEndDateField.get('v.value'), oppObj, listOppLine[0],endDay);
                                                                                
                                                                                
                                                                                if (!rowResult.result) {
                                                                                    result &= false;
                                                                                    if(rowResult.startDateMessage){
                                                                                        this.showToast(cmp, event, 'ERROR', rowResult.startDateMessage);
                                                                                    }
                                                                                    this.showToast(cmp, event, 'ERROR', rowResult.endDateMessage);
                                                                                } 
                                                                            }
                                                                            return result;
                                                                        },
                                                                            validateFieldsForMY : function(cmp, listOppLine) {
                                                                                var listRequired = [
                                                                                    "oppStartDate",
                                                                                    "oppEndDate",
                                                                                    "oppQuantity",
                                                                                    "oppUnitPrice"
                                                                                ];
                                                                                var discountReason = cmp.find("discountReason");
                                                                                var startDateField = cmp.find("oppStartDate");
                                                                                var endDateField = cmp.find("oppEndDate");
                                                                                var oppObj = cmp.get("v.oppObj");
                                                                                var EligibleVip = cmp.get("v.EligibleVip");
                                                                                
                                                                                let endOfWeekTemp = cmp.get("v.endOfTheWeek");
                                                                                let endOfWeekExisting = cmp.get("v.endDayForExisting");
                                                                                console.log('test2222');
                                                                                console.log(endOfWeekTemp);
                                                                                const endOfWeek = new Map();
                                                                                for(var rType in endOfWeekExisting){
                                                                                    endOfWeek.set(endOfWeekExisting[rType].key,endOfWeekExisting[rType].value);
                                                                                }
                                                                                
                                                                                //Added VIP Relationship in the list to avoid 100% discount error
                                                                                var listDiscountReasonNot100 = {
                                                                                    "Loyalty Discount": true,
                                                                                    "Managerial Discount": true,
                                                                                    "Marketing Promo": true,
                                                                                    "First-Timer Discount": true,
                                                                                    "Agent Referral: Referee": true,
                                                                                    Pioneer: true,
                                                                                    "Bulk Purchase": true,
                                                                                    "Cash Voucher": true,
                                                                                    "Renewal Promotion": true,
                                                                                    "Renewal Bonus": true,
                                                                                    "VIP (Relationship)":true
                                                                                };
                                                                                var currField,
                                                                                    result = true,
                                                                                    rowResult,
                                                                                    discountReasonValue;
                                                                                var hasFoc = false,
                                                                                    hasVip = false,
                                                                                    hasManagerial = false;
                                                                                var exprVip = /VIP/,
                                                                                    exprManagerial = /Managerial/,
                                                                                    exprVipSpending = /Advance|Premier/;
                                                                                var productName;
                                                                                var prodCategory;
                                                                                
                                                                                //Added length check on array (VIP Relationship changes)
                                                                                if (Array.isArray(discountReason) && discountReason.length>1) {
                                                                                    for (var oppLineIdx in listOppLine) {
                                                                                        
                                                                                        let endDay = new Date();
                                                                                        if(oppObj.Opportunity_Type__c ==  'B2C - Upgrade'){
                                                                                            
                                                                                            if(listOppLine[oppLineIdx].Id ==null || listOppLine[oppLineIdx].Id ==''){
                                                                                                endDay = endOfWeekTemp.get(listOppLine[oppLineIdx].Product2Id);  
                                                                                            }else{
                                                                                                endDay =  endOfWeek.get(listOppLine[oppLineIdx].Id);     
                                                                                            }
                                                                                        }else{
                                                                                            endDay = '';
                                                                                        }
                                                                                        
                                                                                        productName = listOppLine[oppLineIdx].Product2.Name;
                                                                                        prodCategory = listOppLine[oppLineIdx].Product2.Product_Category__c;
                                                                                        for (var idx in listRequired) {
                                                                                            currField = cmp.find(listRequired[idx]);
                                                                                            if (
                                                                                                !currField[oppLineIdx].get("v.value") &&
                                                                                                currField[oppLineIdx].get("v.required")
                                                                                            ) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Field is required.');
                                                                                                result &= false;
                                                                                            }
                                                                                        }
                                                                                        
                                                                                        // Changed to get value of discount reason (VIP Relationship changes)
                                                                                        //discountReasonValue = discountReason[oppLineIdx].get("v.value");
                                                                                        discountReasonValue = listOppLine[oppLineIdx].Discount_Reason__c;
                                                                                        if(((listOppLine[oppLineIdx].Parent__c == undefined || listOppLine[oppLineIdx].Parent__c == null) && (listOppLine[oppLineIdx].Parent_Id__c == undefined || listOppLine[oppLineIdx].Parent_Id__c == null))){
                                                                                            if (
                                                                                                !discountReasonValue &&
                                                                                                ((!isNaN(listOppLine[oppLineIdx].Discount__c) &&
                                                                                                  listOppLine[oppLineIdx].Discount__c > 0) ||
                                                                                                 (!isNaN(listOppLine[oppLineIdx].Discount_Amount__c) &&
                                                                                                  listOppLine[oppLineIdx].Discount_Amount__c > 0))
                                                                                            ) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Discount Reason is mandatory.');
                                                                                                result &= false;
                                                                                            } else if (
                                                                                                discountReasonValue == "Marketing Promo" &&
                                                                                                (listOppLine[oppLineIdx].Campaign__c == null ||
                                                                                                 listOppLine[oppLineIdx].Campaign__c == undefined)
                                                                                            ) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Invalid Reason.'); 
                                                                                                result &= false;
                                                                                            } else if (
                                                                                                discountReasonValue == "Loyalty Discount" &&
                                                                                                (listOppLine[oppLineIdx].Campaign__c == null ||
                                                                                                 listOppLine[oppLineIdx].Campaign__c == undefined)
                                                                                            ) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Invalid Reason.'); 
                                                                                                result &= false;
                                                                                            } else if (
                                                                                                discountReasonValue == "Managerial Discount" &&
                                                                                                listOppLine[oppLineIdx].Amount__c == 0
                                                                                            ) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Managerial Discount cannot have 100% discount.'); 
                                                                                                result &= false;
                                                                                            } else if (
                                                                                                discountReasonValue == "First-Timer Discount" &&
                                                                                                (listOppLine[oppLineIdx].Campaign__c == null ||
                                                                                                 listOppLine[oppLineIdx].Campaign__c == undefined)
                                                                                            ) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Invalid Reason.'); 
                                                                                                result &= false;
                                                                                            } else if (
                                                                                                discountReasonValue == "Agent Referral: Referee" &&
                                                                                                (listOppLine[oppLineIdx].Campaign__c == null ||
                                                                                                 listOppLine[oppLineIdx].Campaign__c == undefined)
                                                                                            ) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Agent not eligible for Referral Entitlement.'); 
                                                                                                result &= false;
                                                                                            } else if (
                                                                                                discountReasonValue != null &&
                                                                                                discountReasonValue != undefined &&
                                                                                                discountReasonValue != "" &&
                                                                                                listDiscountReasonNot100[discountReasonValue] == undefined &&
                                                                                                (listOppLine[oppLineIdx].Amount__c > 0 || listOppLine[oppLineIdx].Amount__c == undefined)
                                                                                            ) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Selected Discount Reason must have 100% Discount.'); 
                                                                                                result &= false;
                                                                                            }else if (discountReasonValue == 'Renewal Promotion' && (listOppLine[oppLineIdx].Campaign__c==null || listOppLine[oppLineIdx].Campaign__c==undefined) && prodCategory=='Subscription') {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Invalid Discount reason.');
                                                                                                result &= false;
                                                                                            } 
                                                                                        }
                                                                                        if (discountReasonValue != "" && discountReasonValue != null) {
                                                                                            if (discountReasonValue.search(exprVip)) {
                                                                                                console.log("vip:" + discountReasonValue);
                                                                                                hasVip = true;
                                                                                            } else if (discountReasonValue.search(exprManagerial)) {
                                                                                                console.log("managerial:" + discountReasonValue);
                                                                                                hasManagerial = true;
                                                                                            } else if (
                                                                                                discountReasonValue != "Loyalty Discount" &&
                                                                                                discountReasonValue != "Marketing Promo"
                                                                                            ) {
                                                                                                console.log("foc:" + discountReasonValue);
                                                                                                hasFoc = true;
                                                                                            }
                                                                                        }
                                                                                        
                                                                                        if (hasVip && hasManagerial) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Cannot have both VIP & Managerial Discount Reason at once. Please separate into different Opportunity.'); 
                                                                                            result &= false;
                                                                                        } else if (hasFoc && hasManagerial) {
                                                                                            this.showToast(cmp, event, 'ERROR','Cannot have both FOC & Managerial Discount Reason at once. Please separate into different Opportunity.');
                                                                                            result &= false;
                                                                                        }
                                                                                        rowResult = this.proceedValidateStartEndDate(
                                                                                            startDateField[oppLineIdx].get("v.value"),
                                                                                            endDateField[oppLineIdx].get("v.value"),
                                                                                            oppObj,
                                                                                            listOppLine[oppLineIdx],
                                                                                            endDay
                                                                                        );  
                                                                                        
                                                                                        
                                                                                        
                                                                                        if (!rowResult.result) {
                                                                                            result &= false;
                                                                                            if(rowResult.startDateMessage){
                                                                                                this.showToast(cmp, event, 'ERROR', rowResult.startDateMessage);
                                                                                            }
                                                                                            this.showToast(cmp, event, 'ERROR', rowResult.endDateMessage);
                                                                                        } 
                                                                                    }
                                                                                } else {
                                                                                    for (var idx in listRequired) {
                                                                                        currField = cmp.find(listRequired[idx]);
                                                                                        console.log('currentField'+currField);
                                                                                        if(Array.isArray(currField)) {
                                                                                            for(var eachData in currField) {
                                                                                                if (!currField[eachData].get("v.value") && currField[eachData].get("v.required")) {
                                                                                                    this.showToast(cmp, event, 'ERROR', 'Field is required.');
                                                                                                    result &= false;
                                                                                                }
                                                                                            }
                                                                                        } else {
                                                                                            if (!currField.get("v.value") && currField.get("v.required")) {
                                                                                                this.showToast(cmp, event, 'ERROR', 'Field is required.');
                                                                                                result &= false;
                                                                                            }
                                                                                        }
                                                                                    }
                                                                                    
                                                                                    // Changed to get value of discount reason (VIP Relationship changes)
                                                                                    //discountReasonValue = discountReason.get("v.value");
                                                                                    discountReasonValue = listOppLine[0].Discount_Reason__c;
                                                                                    prodCategory = listOppLine[0].Product_Category__c;
                                                                                    if(((listOppLine[0].Parent__c == undefined || listOppLine[0].Parent__c == null) && (listOppLine[0].Parent_Id__c == undefined || listOppLine[0].Parent_Id__c == null))){
                                                                                        if (
                                                                                            !discountReasonValue &&
                                                                                            ((!isNaN(listOppLine[0].Discount__c) &&
                                                                                              listOppLine[0].Discount__c > 0) ||
                                                                                             (!isNaN(listOppLine[0].Discount_Amount__c) &&
                                                                                              listOppLine[0].Discount_Amount__c > 0))
                                                                                        ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Discount Reason is mandatory.');
                                                                                            result &= false;
                                                                                        } else if (
                                                                                            discountReasonValue == "Marketing Promo" &&
                                                                                            (listOppLine[0].Campaign__c == null ||
                                                                                             listOppLine[0].Campaign__c == undefined)
                                                                                        ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                            result &= false;
                                                                                        } else if (
                                                                                            discountReasonValue == "Loyalty Discount" &&
                                                                                            (listOppLine[0].Campaign__c == null ||
                                                                                             listOppLine[0].Campaign__c == undefined)
                                                                                        ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                            result &= false;
                                                                                        } else if (
                                                                                            discountReasonValue == "Managerial Discount" &&
                                                                                            listOppLine[0].Amount__c == 0
                                                                                        ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Managerial Discount cannot have 100% discount.');
                                                                                            result &= false;
                                                                                        } else if (
                                                                                            discountReasonValue == "First-Timer Discount" &&
                                                                                            (listOppLine[0].Campaign__c == null ||
                                                                                             listOppLine[0].Campaign__c == undefined)
                                                                                        ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Invalid Reason.');
                                                                                            result &= false;
                                                                                        } else if (
                                                                                            discountReasonValue == "Agent Referral: Referee" &&
                                                                                            (listOppLine[0].Campaign__c == null ||
                                                                                             listOppLine[0].Campaign__c == undefined)
                                                                                        ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Agent not eligible for Referral Entitlement.'); 
                                                                                            result &= false;
                                                                                        } else if (
                                                                                            discountReasonValue != null &&
                                                                                            discountReasonValue != "" &&
                                                                                            discountReasonValue != undefined &&
                                                                                            listDiscountReasonNot100[discountReasonValue] == undefined &&
                                                                                            (listOppLine[0].Amount__c > 0 || listOppLine[0].Amount__c == undefined)
                                                                                        ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Selected Discount Reason must have 100% Discount.'); 
                                                                                            result &= false;
                                                                                        }else if (discountReasonValue == 'Renewal Promotion' && (listOppLine[0].Campaign__c==null || listOppLine[0].Campaign__c==undefined) && prodCategory=='Subscription' ) {
                                                                                            this.showToast(cmp, event, 'ERROR', 'Invalid Discount reason.');
                                                                                            result &= false;
                                                                                        }  
                                                                                        
                                                                                        
                                                                                    }
                                                                                    
                                                                                    if (discountReasonValue != null && discountReasonValue != "") {
                                                                                        if (discountReasonValue.search(exprVip)) {
                                                                                            hasVip = true;
                                                                                        } else if (discountReasonValue.search(exprManagerial)) {
                                                                                            hasManagerial = true;
                                                                                        } else if (
                                                                                            discountReasonValue != "Loyalty Discount" &&
                                                                                            discountReasonValue != "Marketing Promo"
                                                                                        ) {
                                                                                            hasFoc = true;
                                                                                        }
                                                                                    }
                                                                                    if (hasVip && hasManagerial) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Cannot have both VIP & Managerial Discount Reason at once. Please separate into different Opportunity.'); 
                                                                                        result &= false;
                                                                                    } else if (hasFoc && hasManagerial) {
                                                                                        this.showToast(cmp, event, 'ERROR', 'Cannot have both FOC & Managerial Discount Reason at once. Please separate into different Opportunity.');
                                                                                        result &= false;
                                                                                    }
                                                                                    let endDay = new Date();
                                                                                    if(oppObj.Opportunity_Type__c ==  'B2C - Upgrade'){
                                                                                        
                                                                                        if(listOppLine[0].Id ==null || listOppLine[0].Id ==''){
                                                                                            endDay = endOfWeekTemp.get(listOppLine[0].Product2Id);  
                                                                                        }else{
                                                                                            endDay =  endOfWeek.get(listOppLine[0].Id);     
                                                                                        }
                                                                                    }else{
                                                                                        endDay = '';
                                                                                    }
                                                                                    var tempStartDateField;
                                                                                    var tempEndDateField;
                                                                                    if(Array.isArray(startDateField)) {
                                                                                        tempStartDateField = startDateField[0];
                                                                                    } else {
                                                                                        tempStartDateField = startDateField;
                                                                                    }
                                                                                    if(Array.isArray(endDateField)) {
                                                                                        tempEndDateField = endDateField[0];
                                                                                    } else {
                                                                                        tempEndDateField = endDateField;
                                                                                    }
                                                                                    rowResult = this.proceedValidateStartEndDate(
                                                                                        tempStartDateField.get("v.value"),
                                                                                        tempEndDateField.get("v.value"),
                                                                                        oppObj,
                                                                                        listOppLine[0],
                                                                                        endDay
                                                                                    );   
                                                                                    
                                                                                    
                                                                                    if (!rowResult.result) {
                                                                                        result &= false;
                                                                                        if(rowResult.startDateMessage){
                                                                                            this.showToast(cmp, event, 'ERROR', rowResult.startDateMessage);
                                                                                        }
                                                                                        this.showToast(cmp, event, 'ERROR', rowResult.endDateMessage);
                                                                                    } 
                                                                                }
                                                                                return result;
                                                                            },
                                                                                getRenewalButtons:function(component,event,helper){
                                                                                    $A.util.removeClass(component.find('spinnerProd'), 'slds-hide');
                                                                                    var getButtons = component.get("c.getRenewalOptions");
                                                                                    var btn=[];
                                                                                    console.log('getButtons8798'+JSON.stringify(component.get("c.getRenewalOptions")));
                                                                                    getButtons.setParams({"quoteID": component.get("v.quoteObj").Id});
                                                                                    getButtons.setCallback(this, function(response) {
                                                                                        if (response.getState() === "SUCCESS") {
                                                                                            var PkgDetails=[];
                                                                                            for(var level in response.getReturnValue()){
                                                                                                for(var key in response.getReturnValue()[level])
                                                                                                    btn.push({key:key,
                                                                                                              entry:response.getReturnValue()[level][key]});
                                                                                                console.log('btns==>'+JSON.stringify(btn));
                                                                                                if(key.includes('Downgrade')){
                                                                                                    PkgDetails.push({key:response.getReturnValue()[level][key].Product2Id,
                                                                                                                     value:'Downgrade'});
                                                                                                }else if(key.includes('Upgrade')){
                                                                                                    PkgDetails.push({key:response.getReturnValue()[level][key].Product2Id,
                                                                                                                     value:'Upgrade'});
                                                                                                }else if(key.includes('Renew')){
                                                                                                    PkgDetails.push({key:response.getReturnValue()[level][key].Product2Id,
                                                                                                                     value:'Renew'});
                                                                                                }
                                                                                                
                                                                                            }
                                                                                            
                                                                                            component.set('v.renewPromoFilterMap',PkgDetails);  
                                                                                            component.set('v.renewBtn',btn);  
                                                                                            $A.util.addClass(component.find('spinnerProd'), 'slds-hide');
                                                                                        }
                                                                                    });
                                                                                    $A.enqueueAction(getButtons);
                                                                                },
                                                                                    addOliRenewHelper : function(cmp,event,productId,type) {
                                                                                        
                                                                                        cmp.set("v.productObj",{'sobjectType':'Product2',
                                                                                                                'Name': null});
                                                                                        //let index = +event.currentTarget.parentElement.dataset.rowIndex;
                                                                                        let index =  event.target.getAttribute("data-row-index");
                                                                                        let prodList = cmp.get("v.renewBtn");
                                                                                        let oli = [];
                                                                                        let oppObj = cmp.get("v.quoteObj");
                                                                                        oli = cmp.get("v.oliItems");
                                                                                        
                                                                                        let newOli = {};
                                                                                        newOli.Id;
                                                                                        newOli.QuoteId = oppObj.Id;
                                                                                        newOli.Product2Id = prodList[index].entry.Product2Id;
                                                                                        newOli.PricebookEntryId = prodList[index].entry.Id;
                                                                                        let prod = {};
                                                                                        prod.Name = prodList[index].entry.Product2.Name;
                                                                                        prod.Id = prodList[index].entry.Product2Id;
                                                                                        prod.Product_Category__c = prodList[index].entry.Product2.Product_Category__c;
                                                                                        prod.CustItem_Validity_Value__c = prodList[index].entry.Product2.CustItem_Validity_Value__c;
                                                                                        prod.CustItem_Validity_Unit__c = prodList[index].entry.Product2.CustItem_Validity_Unit__c;
                                                                                        prod.SKU_Code__c = prodList[index].entry.Product2.SKU_Code__c;
                                                                                        newOli.Product2 = prod;
                                                                                        
                                                                                        newOli.UnitPrice = prodList[index].entry.UnitPrice ;
                                                                                        newOli.Original_Price__c = newOli.UnitPrice==null||newOli.UnitPrice==undefined?0:newOli.UnitPrice;
                                                                                        newOli.Quantity ;
                                                                                        newOli.Discount_Amount__c ;
                                                                                        newOli.Discount__c ;
                                                                                        
                                                                                        if(oppObj.Quote_Type__c == 'B2C - Renewal'){
                                                                                            console.log('<<<---Today--->>> ',this.getToday())
                                                                                            console.log('<<<---Subscription End Date--->>> ',oppObj.Account.Subscription_End_Date__c)
                                                                                            console.log('<<<--Previous End Date--->>> ',oppObj.Account.Previous_Acct_End_Date__c)
                                                                                            if(oppObj.Country__c == 'Singapore'){
                                                                                                if(this.getToday() <= oppObj.Account.Subscription_End_Date__c ){
                                                                                                    newOli.Start_Date__c = this.methodToFormatDate(cmp,oppObj.Account.Subscription_End_Date__c);
                                                                                                }else if(this.getToday() > oppObj.Account.Previous_Acct_End_Date__c){
                                                                                                    newOli.Start_Date__c = this.getToday();
                                                                                                }else{
                                                                                                    newOli.Start_Date__c = this.getToday();
                                                                                                }
                                                                                            }else{
                                                                                                if(oppObj.Account.Subscription_End_Date__c<this.getToday()){
                                                                                                    newOli.Start_Date__c = this.getToday();
                                                                                                }else{
                                                                                                    newOli.Start_Date__c = this.methodToFormatDate(cmp,oppObj.Account.Subscription_End_Date__c);
                                                                                                }
                                                                                            }
                                                                                        }else{
                                                                                            newOli.Start_Date__c = this.getToday(); 
                                                                                        }
                                                                                        
                                                                                        
                                                                                        if(prodList[index].entry.Product2.CustItem_Validity_Value__c != null && prodList[index].entry.Product2.CustItem_Validity_Value__c != undefined && prodList[index].entry.Product2.CustItem_Validity_Unit__c != null && prodList[index].entry.Product2.CustItem_Validity_Unit__c != undefined)
                                                                                            newOli.End_Date__c = this.addMonths(newOli.Start_Date__c,prodList[index].entry.Product2.CustItem_Validity_Value__c,prodList[index].entry.Product2.CustItem_Validity_Unit__c)
                                                                                            else
                                                                                                newOli.End_Date__c = this.getNextYear(newOli.Start_Date__c);
                                                                                        
                                                                                        newOli.PO__c = true;
                                                                                        
                                                                                        if (prodList[index].entry.Product2.Tax_Code__c != null) {
                                                                                            newOli.GST_VAT_Code__c = prodList[index].entry.Product2.Tax_Code__c;
                                                                                        } else {
                                                                                            newOli.GST_VAT_Code__c = null;
                                                                                        }
                                                                                        
                                                                                        if (prodList[index].entry.Product2.Tax_Code__r != undefined) {
                                                                                            newOli.GST_VAT_Rate__c = prodList[index].entry.Product2.Tax_Code__r.Tax_Rate__c;
                                                                                        } else {
                                                                                            newOli.GST_VAT_Rate__c = 0;
                                                                                        }
                                                                                        newOli.Income_Account_Name__c = prodList[index].entry.Product2.Income_Account_Name__c;
                                                                                        newOli.Product_Category__c = prodList[index].entry.Product2.Product_Category__c;
                                                                                        let isBundle = prodList[index].entry.Product2.Is_Bundle__c;
                                                                                        if(prodList[index].entry.Product2.Product_Category__c == 'Subscription') {
                                                                                            newOli.Quantity = 1;
                                                                                            //prodList.splice(index, 1);
                                                                                        }
                                                                                        oli.push(newOli);
                                                                                        cmp.set("v.oliItems",oli);
                                                                                        //cmp.set("v.productList", prodList);
                                                                                        
                                                                                        //alert('???'+JSON.stringify(prodList[index].entry));
                                                                                        if (isBundle) {
                                                                                            var parentIdx = oli==null?0:(oli.length==0?0:oli.length-1);
                                                                                            if (oli[parentIdx].Parent__c!=null && oli[parentIdx].Parent__c!='null') {
                                                                                                --parentIdx;
                                                                                            }
                                                                                            this.addProductAct(cmp, event, oli, oppObj, newOli, parentIdx, oppObj.Id, null);
                                                                                        }
                                                                                        $A.util.addClass(cmp.find('spinnerProd'), 'slds-hide');
                                                                                        
                                                                                        this.calculateSubtotalHelper(cmp,event);
                                                                                        
                                                                                    },
                                                                                        methodToFormatDate : function(cmp,dateValue){
                                                                                            
                                                                                            let today = new Date(dateValue);
                                                                                            today.setDate(today.getDate() + 1);
                                                                                            let dd = today.getDate();
                                                                                            let mm = today.getMonth()+1; //January is 0!
                                                                                            let yyyy = today.getFullYear();
                                                                                            
                                                                                            if(dd<10) {
                                                                                                dd = '0'+dd
                                                                                            } 
                                                                                            
                                                                                            if(mm<10) {
                                                                                                mm = '0'+mm
                                                                                            } 
                                                                                            
                                                                                            today = yyyy + '-' + mm + '-' + dd;
                                                                                            return today;
                                                                                            
                                                                                        },
                                                                                            changeChildDate2: function(cmp, event, helper) {
                                                                                                let listOppLine = cmp.get("v.oliItems");
                                                                                                let idx = 0;
                                                                                                if(!listOppLine[idx].Start_Date__c){
                                                                                                    return;
                                                                                                }
                                                                                                let currId = (listOppLine[idx].Promo_Mechanic_Id__c!=undefined && listOppLine[idx].Promo_Mechanic_Id__c.length > 0) ? listOppLine[idx].Promo_Mechanic_Id__c : idx;
                                                                                                let childcurrId = (listOppLine[idx].Id!=undefined && listOppLine[idx].Id.length > 0) ? listOppLine[idx].Id : idx;
                                                                                                let anyUpdate = false;
                                                                                                let quoteObj = cmp.get('v.quoteObj');
                                                                                                let malaysiaPromoIds = cmp.get('v.Malaysia_MCO_Promos');
                                                                                                let malaysiaPromoIdsList = malaysiaPromoIds.split(',');
                                                                                                console.log('Event',event.getSource().getLocalId());
                                                                                                if (event.getSource().getLocalId()=='oppStartDate') {
                                                                                                    // Adjust End Date to be 1 year after
                                                                                                    if(listOppLine[idx].Product2.CustItem_Validity_Value__c != null && listOppLine[idx].Product2.CustItem_Validity_Value__c != undefined && listOppLine[idx].Product2.CustItem_Validity_Unit__c != null && listOppLine[idx].Product2.CustItem_Validity_Unit__c != undefined)
                                                                                                        listOppLine[idx].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c)
                                                                                                        else
                                                                                                            listOppLine[idx].End_Date__c = helper.getNextYear(listOppLine[idx].Start_Date__c);
                                                                                                    
                                                                                                    let endDateForMY = false;
                                                                                                    for(let pmId in malaysiaPromoIdsList){
                                                                                                        if(malaysiaPromoIdsList[pmId] == listOppLine[idx].Promo_Mechanic_Id__c){
                                                                                                            endDateForMY = true;
                                                                                                        }
                                                                                                    }
                                                                                                    
                                                                                                    if(endDateForMY){
                                                                                                        let today = listOppLine[idx].Start_Date__c;
                                                                                                        today = today.split('-');
                                                                                                        let todayDate = new Date(today[0], today[1] - 1, today[2]); 
                                                                                                        
                                                                                                        let yesterday = new Date(todayDate);
                                                                                                        yesterday.setDate(todayDate.getDate() - 1);
                                                                                                        
                                                                                                        let nextYear = new Date(yesterday.setFullYear(yesterday.getFullYear()+1));
                                                                                                        let dd = nextYear.getDate();
                                                                                                        let mm = nextYear.getMonth()+2;
                                                                                                        let yyyy = nextYear.getFullYear();
                                                                                                        
                                                                                                        if(dd<10) {
                                                                                                            dd = '0'+dd
                                                                                                        } 
                                                                                                        
                                                                                                        if(mm<10) {
                                                                                                            mm = '0'+mm
                                                                                                        } 
                                                                                                        
                                                                                                        nextYear = yyyy + '-' + mm + '-' + dd; 
                                                                                                        listOppLine[idx].End_Date__c = nextYear;
                                                                                                    }
                                                                                                    
                                                                                                    anyUpdate = true;
                                                                                                }
                                                                                                
                                                                                                if(quoteObj.Quote_Type__c != 'B2C - Upgrade' && (quoteObj.Status == 'Proposal' && (quoteObj.Approval_Status__c == 'Discount Approval Recalled' || quoteObj.Approval_Status__c == 'Discount Approval Approved' ||
                                                                                                                                                                                   quoteObj.Approval_Status__c == null)) ||
                                                                                                   (quoteObj.Status == 'Pending Online Payment' && quoteObj.Agent_Accepted_Time__c == null) ||
                                                                                                   (quoteObj.Status == 'Pending OMC Approval' && (quoteObj.Approval_Status__c == 'OMC Approval Recalled' || quoteObj.Approval_Status__c == 'OMC Approval Rejected'))){
                                                                                                    listOppLine.find((item,index)=>{
                                                                                                        if (listOppLine[index].Parent_Id__c!=undefined && currId >0 &&  currId.includes(listOppLine[index].Parent_Id__c)) {
                                                                                                        listOppLine[index].Start_Date__c = listOppLine[idx].Start_Date__c;
                                                                                                        listOppLine[index].End_Date__c = listOppLine[idx].End_Date__c;
                                                                                                        anyUpdate = true;
                                                                                                    } else if(listOppLine[index].Parent__c!=undefined && listOppLine[index].Parent__c==childcurrId){
                                                                                                        listOppLine[index].Start_Date__c = listOppLine[idx].Start_Date__c;
                                                                                                        listOppLine[index].End_Date__c = listOppLine[idx].End_Date__c;
                                                                                                        anyUpdate = true;
                                                                                                    }
                                                                                                })        
                                                                                            }

if (anyUpdate) {
    cmp.set("v.oliItems", listOppLine);
}

},
    proceedValidateStartEndDate : function(startDate, endDate, oppObj, oppLineItem,endOfWeek) {
        
        let result = true, startDateMessage = null, endDateMessage = null;
        if (!oppLineItem.Complimentary__c) {
            if (startDate==null) {
                result &= false;
                startDateMessage = 'Start Date cannot be empty';
            }
            if (endDate==null) {
                result &= false;
                endDateMessage = 'End Date cannot be empty';
            }
            
            
            if (result) {
                let x = new Date(startDate).getTime();
                let y = new Date(endDate).getTime();
                let today = new Date(this.getToday()).getTime();
                
                // Added validation :Oli Start date cannot be greater than accSubEndDate AM+1 (PGAUTO-5211)
                let oppCreatedDateTime = new Date(oppObj.CreatedDate); // PGAUTO-5446
                if(oppCreatedDateTime.getFullYear() >= 2021 && oppCreatedDateTime.getMonth()>= 5){
                    if(oppObj.Account.Subscription_End_Date__c != undefined && 
                       oppObj.Opportunity_Type__c == 'B2C - Renewal' && 
                       oppObj.Country__c == 'Singapore'){
                        
                        let accSubEndDate,cutOffDate,firstDayOfAMPlus1;
                        accSubEndDate = new Date(oppObj.Account.Subscription_End_Date__c);
                        
                        if(accSubEndDate.getMonth() == "11"){
                            cutOffDate = new Date((accSubEndDate.getFullYear()+1)+"-01-02").getTime();
                            firstDayOfAMPlus1 = "02/01/"+(accSubEndDate.getFullYear()+1);
                        }
                        
                        else {
                            cutOffDate = new Date(accSubEndDate.getFullYear()+"-"+(accSubEndDate.getMonth()+2)+"-02").getTime();
                            firstDayOfAMPlus1 = "02/"+(accSubEndDate.getMonth()+2)+"/"+accSubEndDate.getFullYear();
                        }
                        
                        if(x >= cutOffDate){
                            result &= false;
                            startDateMessage = 'The start date should be before ' + firstDayOfAMPlus1;
                        }
                    }
                }
                
                let timeDiff = Math.abs(x - today);
                let diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
                let startEndDiff = Math.ceil((Math.abs(y-x)) / (1000 * 3600 * 24));
                
                if (x < today) {
                    result &= false;
                    startDateMessage = 'Start Date cannot be in the past.';
                }
                
                if( oppObj.Opportunity_Type__c ==  'B2C - Upgrade'){
                    debugger;
                    var temporaryCutOffDate = $A.get("$Label.c.UPGRADE_OPP_CUTOFF_DATE");
                    if((temporaryCutOffDate == 'NULL' && oppObj.Country__c == 'Singapore')) {
                        let endDateOfWeek = new Date(endOfWeek).getTime();
                        if(x > endDateOfWeek){
                            result &= false;
                            startDateMessage = "Start Date should be of the current week";  
                        } 
                    } else {
                        let cutOffStartDate = new Date(temporaryCutOffDate).getTime();
                        if(x > cutOffStartDate){
                            result &= false;
                            startDateMessage = "Start Date can not exceed " + temporaryCutOffDate;  
                        } 
                    }
                } 
                
                if (y <= x) {
                    result &= false;
                    endDateMessage = 'End Date must be after Start Date.';
                }
            }
        }    
        return {'result': result, 'startDateMessage': startDateMessage, 'endDateMessage': endDateMessage};
    }
})