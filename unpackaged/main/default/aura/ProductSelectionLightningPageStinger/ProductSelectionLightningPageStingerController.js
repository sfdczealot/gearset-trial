({
    //get oli data and default promo mechanic for opportunity on initialization
    init : function(cmp, event, helper) {
        debugger;
        var mcoPromos = $A.get("$Label.c.Malaysia_MCO_Promos");
        cmp.set("v.Malaysia_MCO_Promos", mcoPromos);
        var init0 = cmp.get("c.getUserInfoAndOppRecord");
        init0.setParams({"oppId": cmp.get("v.quoteId")});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var quoteObj = response.getReturnValue().quo;
                cmp.set("v.quoteObj", quoteObj);
                cmp.set("v.oppObj", response.getReturnValue().opp);
                //cmp.set("v.userProfile", response.getReturnValue().userProfile);
                //PGAUtO-2879 show final payment amounts
                if(response.getReturnValue().paymentAmt!=undefined)
                    cmp.set("v.balanceAmt",response.getReturnValue().paymentAmt);
                else
                    cmp.set("v.balanceAmt",0);
                
            }
        });
        $A.enqueueAction(init0);
            helper.getOliDataHelper(cmp,event,helper,'show');
        //helper.getpickListValues(cmp,event);
        let oppObj = cmp.get("v.oppObj");
        helper.getDiscountInfo(cmp, event, oppObj);
        helper.getDataList(cmp,event,'Name','Tax_Code__c',{Id: null, Name: null});
        let quoteObj = cmp.get('v.quoteObj');
        if (!(quoteObj.Status =='Proposal') || !(quoteObj.Approval_Status__c == null || quoteObj.Approval_Status__c == '' || quoteObj.Approval_Status__c == 'Discount Approval Rejected')) {
            cmp.set('v.isMsg',true);       
        }
        
    },
    
    //get product and promo mechanic data when search is clicked
    searchBtnClicked : function(cmp, event, helper) {
        let searchKey = cmp.find("searchProd").get("v.value");
        let oppObj = cmp.get("v.quoteObj");
        let oliList = [];
        let prodList = [];
        //exclusion 
        let exclusionproductIdsList = [];
        let exclusionProductMap = cmp.get('v.exclusionProductMap');
        
        /*for(let item in cmp.get("v.oliItems"))
            oliList.push(cmp.get("v.oliItems")[item].Product2.Id);*/
        
        //exclusion
        cmp.get("v.oliItems").find((item,index)=>{
            
            oliList.push(cmp.get("v.oliItems")[index].Product2.Id);
            if(item.Promo_Mechanic_Id__c != undefined && item.Promo_Mechanic_Id__c != null && item.Promo_Mechanic_Id__c != '' && exclusionProductMap[item.Promo_Mechanic_Id__c] != undefined){
            exclusionProductMap[item.Promo_Mechanic_Id__c].find(eachExclProdId=>{
            exclusionproductIdsList.push(eachExclProdId);
        })
        }
        })
            
            if(searchKey.length >2) {
            let action = cmp.get("c.getAvailableProductAndPromo");
            action.setParams({
            priceBookId : oppObj.Pricebook2Id, 
            currencyCode : oppObj.CurrencyIsoCode,
            searchKey : searchKey,
            oppId : cmp.get("v.oppId"),
            quoteID: cmp.get("v.quoteObj").Id
        });
        $A.util.removeClass(cmp.find('spinnerProd'), 'slds-hide');
        action.setCallback(this, function(resp){
            if(resp.getState() === 'SUCCESS') {
                if(resp.getReturnValue().prodList.length > 0) {
                    let result = resp.getReturnValue();
                    if(oliList.length >0) {
                        for(let item in result.prodList) {
                            //exclusion
                            if(!exclusionproductIdsList.includes(result.prodList[item].Product2Id)){
                                if(result.prodList[item].Product2.Product_Category__c == 'Subscription') { 
                                    if(!oliList.includes(result.prodList[item].Product2.Id) ) {
                                        prodList.push(result.prodList[item]);  
                                    }
                                }
                                else 
                                    prodList.push(result.prodList[item]); 
                            }
                            
                        }
                        cmp.set("v.productList", prodList);  
                    }
                    else
                        cmp.set("v.productList", result.prodList);
                    let productMap = [];
                    for(let item in result.prodList ) {
                        productMap.push({
                            key: result.prodList[item].Product2Id,
                            value: result.prodList[item]
                        });
                    }
                    cmp.set("v.productMap",productMap);
                    let prodVsPromoMap = [];
                    for(let key in result.prodIdVsPromoMap){
                        prodVsPromoMap.push({
                            key: key,
                            value: result.prodIdVsPromoMap[key]
                        });
                    }
                    cmp.set("v.promoMap", prodVsPromoMap);
                    cmp.set("v.promoMapDisplay",cmp.get("v.defaultPromoMap"));
                }
                else {
                    helper.showToast(cmp,event,'ERROR', 'NO Product Found!');
                    let noProdList = [];
                    cmp.set("v.productList", noProdList);
                    cmp.set("v.promoMapDisplay",cmp.get("v.defaultPromoMap"));
                }
            }
            $A.util.addClass(cmp.find('spinnerProd'), 'slds-hide');
        });
        $A.enqueueAction(action);
    }
    else{
    //helper.showToast(cmp,event,'ERROR', 'Please enter atleast 4 characters!');
    cmp.set("v.productList", []); 
}
 },
 //when add button on product is clicked, remove product from the list, add to oli table(oli is not saved), 
 addProdClicked : function(cmp, event, helper) {
    var discretionaryProdPresent = false;
    var sumOfQuantity = 0;
    var adCreditMY = false;
    var multipleSaleNotAllowed = false;
    var subscriptionPresent = false;
    var oliList = cmp.get("v.oliItems");
    var quoteObj = cmp.get('v.oppObj');
    for(let item in oliList) {
        if(oliList[item].Product2.Product_Category__c == 'Subscription') {
            subscriptionPresent = true;
        } else if(oliList[item].Product2.Product_Category__c == 'Discretionary' && !oliList[item].Parent__c) {
            discretionaryProdPresent = true;
        }
        if(oliList[item].Product2.Multiple_Sale_Not_Allowed__c == true) {
            multipleSaleNotAllowed = true;
            //AUTOMATION-8897
            if(oliList[item].Product2.SKU_Code__c == $A.get("$Label.c.SKUCODE_AD_CREDIT_MY") && quoteObj.Country__c == 'Malaysia') {
                adCreditMY = true;
                if(oliList[item].Campaign__c != null){
                    sumOfQuantity += parseInt(oliList[item].Quantity);
                } 
            }
        }
    }
    cmp.set("v.sumOfQLIQuantity",sumOfQuantity); //
    
    document.getElementById('olis').scrollIntoView();
    let prodList = cmp.get("v.productList");
    //let index = +event.currentTarget.parentElement.dataset.rowIndex;
    let index = event.target.getAttribute("data-row-index");
    let prodId = prodList[index].Product2.Id;
    if(prodList[index].Product2.Product_Category__c == 'Subscription' && subscriptionPresent) {
        helper.showToast(cmp,event,'ERROR', 'Only one Subscription Product can be added.');
        return;
    }
    if(prodList[index].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) {
        cmp.set("v.IsDiscNotApplicable",true);
    } else {
        cmp.set("v.IsDiscNotApplicable",false);
    }
    if(prodList[index].Product2.Multiple_Sale_Not_Allowed__c == true &&
       multipleSaleNotAllowed == true && adCreditMY == false){
        helper.showToast(cmp,event,'ERROR', $A.get("$Label.c.ADD_PROD_ERROR_DUPLICATE")); 
        return;
    }
    
    //One product category type can be selected at time
    //PGAUTO-5244
    if(quoteObj.Country__c == 'Singapore') {
        if(prodList[index].Product2.Product_Category__c == 'Subscription' && discretionaryProdPresent) {
            helper.showToast(cmp,event,'ERROR', $A.get("$Label.c.ADD_PROD_ERROR_SUBS"));
            return;
        } else if(prodList[index].Product2.Product_Category__c == 'Discretionary' && subscriptionPresent) {
            helper.showToast(cmp,event,'ERROR', $A.get("$Label.c.ADD_PROD_ERROR_DISCR"));
            return;
        }
    }
    helper.addOliHelper(cmp,event,prodId,'add'); 
    //cmp.set("v.promoMapDisplay",cmp.get("v.defaultPromoMap"));
},
    //remove oli form the table, add product to display product list(productList), calculate subtotal again
    removeOliBtn : function(cmp,event,helper) {
        let updatedOliList = [];
        let prodList = [];
        prodList = cmp.get("v.productList");
        //let index = +event.currentTarget.parentElement.dataset.rowIndex;
        let index = event.target.getAttribute("data-row-index");
        let oliList = cmp.get("v.oliItems");
        let prodId = cmp.get("v.oliItems")[index].Product2Id;
        let selectedOli = oliList[index];
        var currentValue = cmp.get("v.sumOfQLIQuantity");
        var quoteObj = cmp.get('v.oppObj');
        //AUTOMATION-8897
        if(quoteObj.Country__c == 'Malaysia' && currentValue != undefined && currentValue != null && currentValue > 0 && selectedOli != undefined && selectedOli != null) {
            var updatedQuantity = parseInt(currentValue) - parseInt(selectedOli.Quantity);
        }
        
        cmp.set("v.sumOfQLIQuantity",updatedQuantity);
        
        if((selectedOli.Parent != undefined && selectedOli.Parent != '') || selectedOli.Parent__c != undefined && selectedOli.Parent__c != ''){
            //alert('working now');
            return;
            
        }
        
        if(cmp.get("v.productMap") != null && cmp.get("v.productMap").length >0) {
            cmp.get("v.productMap").forEach(function(item){
                if(item.key == prodId && !prodList.includes(item.value))
                    prodList.push(item.value);
            });
            cmp.set("v.productList", prodList);
        }
        //AUTOMATION-8897
        if(quoteObj.Country__c == 'Malaysia') {
            if(selectedOli.Campaign__c == undefined && selectedOli.Campaign__c == null) {
                oliList.splice(index, 1);
            }else {
                oliList.splice(index, 1);
                oliList.splice(index, 1);
            }
        } else {
            oliList.splice(index, 1);
        }
        
        
        for(let item in oliList) {
            
            if(oliList[item].Parent_Id__c == undefined && oliList[item].Parent__c == undefined) {
                updatedOliList.push(oliList[item]);
                
            }else{
                if(quoteObj.Country__c == 'Malaysia' && oliList[item].Product2.SKU_Code__c == $A.get("$Label.c.SKUCODE_AD_CREDIT_MY") && selectedOli.Product2.Product_Category__c == 'Discretionary') {
                    if((selectedOli.Promo_Mechanic_Id__c != undefined && selectedOli.Promo_Mechanic_Id__c.includes(oliList[item].Parent_Id__c) && oliList[item].Parent_Id__c != undefined && oliList[item].Parent_Id__c != '') ||  (oliList[item].Parent__c == selectedOli.Id || ( oliList[item].Parent__c == index))) { 
                        updatedOliList.push(oliList[item]); //AUTOMATION-8897
                    } else {
                        updatedOliList.push(oliList[item]);
                    }
                } else {
                    if((selectedOli.Promo_Mechanic_Id__c != undefined && selectedOli.Promo_Mechanic_Id__c.includes(oliList[item].Parent_Id__c) && oliList[item].Parent_Id__c != undefined && oliList[item].Parent_Id__c != '') ||  (oliList[item].Parent__c == selectedOli.Id || ( oliList[item].Parent__c == index))) { 
                        
                    } else {
                        updatedOliList.push(oliList[item]);
                    }
                }
                
            }
        }
        
        cmp.set("v.oliItems",updatedOliList);
        helper.calculateSubtotalHelper(cmp,event);
    },
        saveBtnClicked : function(cmp,event, helper) {
            let quoteObj = cmp.get('v.oppObj');
            let quObj = cmp.get('v.quoteObj');
            let startDateField = cmp.find('oppStartDate');
            let endDateField = cmp.find('oppEndDate');
            let listOppline = cmp.get("v.oliItems");
            //alert(JSON.stringify(listOppline));
            let bool = "false";
            let rowResult;
            let malaysiaPromoIds = cmp.get('v.Malaysia_MCO_Promos');
            let malaysiaPromoIdsList = malaysiaPromoIds.split(',');
            
            let discountPercentage = cmp.find('discountPer');
            
            /*if(discountPercentage != undefined && discountPercentage != null){
                if(!Array.isArray(discountPercentage)){
                if(discountPercentage.get('v.value') != null && discountPercentage.get('v.value') != undefined  && discountPercentage.get('v.value')<0){
                    discountPercentage.setCustomValidity("Discount should be greater than 0");
                    discountPercentage.reportValidity();
                    return;
                }else{
                    discountPercentage.setCustomValidity("");
                    discountPercentage.reportValidity();
                }
            }else{
                for(let k=0;k<discountPercentage.length;k++){
                    if(discountPercentage[k].get('v.value') != null && discountPercentage[k].get('v.value') != undefined  && discountPercentage[k].get('v.value')<0){
                        discountPercentage[k].setCustomValidity("Discount should be greater than 0");
                        discountPercentage[k].reportValidity();
                        return;
                    }else{
                        discountPercentage[k].setCustomValidity("");
                        discountPercentage[k].reportValidity();
                    } 
                }
            }
        }*/ 
            
            
            let discountAmount = cmp.find('discountAmt');
            if(discountAmount != undefined && discountAmount != null){
                if(!Array.isArray(discountAmount)){
                    if(discountAmount.get('v.value') != null && discountAmount.get('v.value') != undefined  && discountAmount.get('v.value')<0){
                        discountAmount.setCustomValidity("Discount Amount should be greater than 0");
                        discountAmount.reportValidity();
                        return;
                    }else{
                        discountAmount.setCustomValidity("");
                        discountAmount.reportValidity();
                    }
                }else{
                    for(let k=0;k<discountAmount.length;k++){
                        if(discountAmount[k].get('v.value') != null && discountAmount[k].get('v.value') != undefined  && discountAmount[k].get('v.value')<0){
                            discountAmount[k].setCustomValidity("Discount Amount should be greater than 0");
                            discountAmount[k].reportValidity();
                            return;
                        }else{
                            discountAmount[k].setCustomValidity("");
                            discountAmount[k].reportValidity();
                        } 
                    }
                }
            }
            
            let WthRateAmt = cmp.find('WHTRateAmt');
            if(quObj.Country__c == 'Thailand' && quoteObj.Account.Tax_Reg_Number__c != undefined && quoteObj.Account.Tax_Reg_Number__c != '' && WthRateAmt != undefined && WthRateAmt != null){
                if(!Array.isArray(WthRateAmt)){
                    if(WthRateAmt.get('v.value') != null && WthRateAmt.get('v.value') != undefined  && WthRateAmt.get('v.value')<0){
                        WthRateAmt.setCustomValidity("WHT Rate should be greater than 0");
                        WthRateAmt.reportValidity();
                        return;
                    }else{
                        WthRateAmt.setCustomValidity("");
                        WthRateAmt.reportValidity();
                    }
                }else{
                    for(let k=0;k<WthRateAmt.length;k++){
                        if(WthRateAmt[k].get('v.value') != null && WthRateAmt[k].get('v.value') != undefined  && WthRateAmt[k].get('v.value')<0){
                            WthRateAmt[k].setCustomValidity("WHT Rate should be greater than 0");
                            WthRateAmt[k].reportValidity();
                            return;
                        }else{
                            WthRateAmt[k].setCustomValidity("");
                            WthRateAmt[k].reportValidity();
                        } 
                    }
                }
            }
            
            for(let item in listOppline) {
                let endDateForMY = false;
                for(let pmId in malaysiaPromoIdsList){
                    if(malaysiaPromoIdsList[pmId] == listOppline[item].Promo_Mechanic_Id__c){
                        endDateForMY = true;
                    }
                }
                
                if(startDateField[item] != undefined && startDateField[item] != null && startDateField[item].get('v.value') != undefined &&
                   startDateField[item].get('v.value') != null && endDateField[item] != undefined && endDateField[item] != null && startDateField[item].get('v.value') != undefined &&
                   endDateField[item].get('v.value') != null){
                    listOppline[item].endDate = helper.addMonths(startDateField[item].get('v.value'),listOppline[item].Product2.CustItem_Validity_Value__c,listOppline[item].Product2.CustItem_Validity_Unit__c);
                    if(listOppline[item].endDate != endDateField[item].get('v.value') && !endDateForMY){
                        
                        let getStartDate = startDateField[item].get('v.value').split('-');
                        let getStartDateDay =new Date(getStartDate[0], getStartDate[1] - 1, getStartDate[2]); 
                        let getEndDate = endDateField[item].get('v.value').split('-');
                        let getEndDateDay = new Date(getEndDate[0], getEndDate[1] - 1, getEndDate[2]);
                        let expectedEndDate = new Date(getStartDateDay);
                        
                        
                        if(listOppline[item].Product2.CustItem_Validity_Unit__c == 'Weeks'){
                            let durationWeeks = listOppline[item].Product2.CustItem_Validity_Value__c*7;
                            expectedEndDate.setDate(getStartDateDay.getDate() + durationWeeks);
                            
                            if(((listOppline[item].Parent__c == undefined || listOppline[item].Parent__c == null) && (listOppline[item].Parent_Id__c == undefined || listOppline[item].Parent_Id__c == null)) && getEndDateDay>expectedEndDate || getEndDateDay.toString().substring(0,15) == expectedEndDate.toString().substring(0,15)){
                                helper.showToast(cmp, event, 'ERROR', 'Start Date and End Date difference cannot be more than '+listOppline[item].Product2.CustItem_Validity_Value__c+' '+listOppline[item].Product2.CustItem_Validity_Unit__c+'.');
                                return;
                            }
                            
                            
                        }
                        if(listOppline[item].Product2.CustItem_Validity_Unit__c == 'Years'){
                            let durationYears = listOppline[item].Product2.CustItem_Validity_Value__c;
                            expectedEndDate.setFullYear(getStartDateDay.getFullYear() + durationYears);
                            
                            if(((listOppline[item].Parent__c == undefined || listOppline[item].Parent__c == null) && (listOppline[item].Parent_Id__c == undefined || listOppline[item].Parent_Id__c == null)) && getEndDateDay>expectedEndDate || getEndDateDay.toString().substring(0,15) == expectedEndDate.toString().substring(0,15)){
                                helper.showToast(cmp, event, 'ERROR', 'Start Date and End Date difference cannot be more than '+listOppline[item].Product2.CustItem_Validity_Value__c+' '+listOppline[item].Product2.CustItem_Validity_Unit__c+'.');
                                return;
                            }
                            
                        }
                        if(listOppline[item].Product2.CustItem_Validity_Unit__c == 'Months'){
                            let durationMonths = listOppline[item].Product2.CustItem_Validity_Value__c;
                            expectedEndDate.setMonth( getStartDateDay.getMonth() + durationMonths );
                            
                            if(((listOppline[item].Parent__c == undefined || listOppline[item].Parent__c == null) && (listOppline[item].Parent_Id__c == undefined || listOppline[item].Parent_Id__c == null)) && getEndDateDay>expectedEndDate || getEndDateDay.toString().substring(0,15) == expectedEndDate.toString().substring(0,15)){
                                helper.showToast(cmp, event, 'ERROR', 'Start Date and End Date difference cannot be more than '+listOppline[item].Product2.CustItem_Validity_Value__c+' '+listOppline[item].Product2.CustItem_Validity_Unit__c+'.');
                                return;
                            }
                            
                        }
                        
                    }
                }
                
                if(listOppline[item].Quantity == undefined || listOppline[item].Quantity == '')
                    bool ="true";
                
                if(((listOppline[item].Parent__c == undefined || listOppline[item].Parent__c == null) && (listOppline[item].Parent_Id__c == undefined || listOppline[item].Parent_Id__c == null)) && quoteObj.Country__c == 'Singapore' && !(listOppline[item].Discount_Amount__c || listOppline[item].Discount__c) && listOppline[item].Discount_Reason__c == 'Managerial Discount'){
                    helper.showToast(cmp, event, 'ERROR', 'Discount/Discount amount can not be blank when discount reason is Managerial Discount.');
                    return; 
                }
                
            }
            
            if(!Array.isArray(startDateField) || !Array.isArray(endDateField)){
                if(startDateField != undefined && startDateField != null && startDateField.get('v.value') != undefined &&
                   startDateField.get('v.value') != null && endDateField != undefined && endDateField != null && startDateField.get('v.value') != undefined &&
                   endDateField.get('v.value') != null){
                    listOppline[0].endDate = helper.addMonths(startDateField.get('v.value'),listOppline[0].Product2.CustItem_Validity_Value__c,listOppline[0].Product2.CustItem_Validity_Unit__c);
                    let endDateForMY = false;
                    for(let pmId in malaysiaPromoIdsList){
                        if(malaysiaPromoIdsList[pmId] == listOppline[0].Promo_Mechanic_Id__c){
                            endDateForMY = true;
                        }
                    }
                    if(!listOppline[0].endDate != endDateField.get('v.value') && !endDateForMY){
                        
                        let getStartDate = startDateField.get('v.value').split('-');
                        let getStartDateDay =new Date(getStartDate[0], getStartDate[1] - 1, getStartDate[2]); 
                        let getEndDate = endDateField.get('v.value').split('-');
                        let getEndDateDay = new Date(getEndDate[0], getEndDate[1] - 1, getEndDate[2]);
                        let expectedEndDate = new Date(getStartDateDay);
                        
                        
                        if(listOppline[0].Product2.CustItem_Validity_Unit__c == 'Weeks'){
                            let durationWeeks = listOppline[0].Product2.CustItem_Validity_Value__c*7;
                            expectedEndDate.setDate(getStartDateDay.getDate() + durationWeeks);
                            
                            if(((listOppline[0].Parent__c == undefined || listOppline[0].Parent__c == null) && (listOppline[0].Parent_Id__c == undefined || listOppline[0].Parent_Id__c == null)) && getEndDateDay>expectedEndDate || getEndDateDay.toString().substring(0,15) == expectedEndDate.toString().substring(0,15)){
                                helper.showToast(cmp, event, 'ERROR', 'Start Date and End Date difference cannot be more than '+listOppline[0].Product2.CustItem_Validity_Value__c+' '+listOppline[0].Product2.CustItem_Validity_Unit__c+'.');
                                return;
                            }
                            
                            
                        }
                        if(listOppline[0].Product2.CustItem_Validity_Unit__c == 'Years'){
                            let durationYears = listOppline[0].Product2.CustItem_Validity_Value__c;
                            expectedEndDate.setFullYear(getStartDateDay.getFullYear() + durationYears);
                            
                            if(((listOppline[0].Parent__c == undefined || listOppline[0].Parent__c == null) && (listOppline[0].Parent_Id__c == undefined || listOppline[0].Parent_Id__c == null)) && getEndDateDay>expectedEndDate || getEndDateDay.toString().substring(0,15) == expectedEndDate.toString().substring(0,15)){
                                helper.showToast(cmp, event, 'ERROR', 'Start Date and End Date difference cannot be more than '+listOppline[0].Product2.CustItem_Validity_Value__c+' '+listOppline[0].Product2.CustItem_Validity_Unit__c+'.');
                                return;
                            }
                            
                        }
                        if(listOppline[0].Product2.CustItem_Validity_Unit__c == 'Months'){
                            let durationMonths = listOppline[0].Product2.CustItem_Validity_Value__c;
                            expectedEndDate.setMonth( getStartDateDay.getMonth() + durationMonths );
                            
                            if(((listOppline[0].Parent__c == undefined || listOppline[0].Parent__c == null) && (listOppline[0].Parent_Id__c == undefined || listOppline[0].Parent_Id__c == null)) && getEndDateDay>expectedEndDate || getEndDateDay.toString().substring(0,15) == expectedEndDate.toString().substring(0,15)){
                                helper.showToast(cmp, event, 'ERROR', 'Start Date and End Date difference cannot be more than '+listOppline[0].Product2.CustItem_Validity_Value__c+' '+listOppline[0].Product2.CustItem_Validity_Unit__c+'.');
                                return;
                            }
                        }
                    }
                } 
            }
            
            if(bool == "true"){
                helper.showToast(cmp, event, 'ERROR', 'Please fill the Quantity.');
                return; 
            }
            
            if(listOppline != null && listOppline.length>0 ){
                let result = true;
                result = helper.validateFields(cmp,listOppline,quoteObj.Country__c);
                if(!result){
                    return;
                }
            }
            
            if ((quObj.Status!='Proposal' || quObj.Status != 'Pending OMC Approval') && !(quObj.Approval_Status__c == null || quObj.Approval_Status__c == '' || quObj.Approval_Status__c == 'Discount Approval Rejected' || quObj.Approval_Status__c == 'OMC Approval Rejected' || quObj.Approval_Status__c == 'OMC Approval Recalled')) {
                helper.showToast(cmp, event, 'ERROR', 'Quote is Locked.');
                return;
            }
            
            cmp.set("v.saveBtnStatus", true);
            let action = cmp.get("c.saveQliData");
            
            action.setParams({
                quoteId : cmp.get("v.quoteId"),
                qliRec : cmp.get("v.oliItems"),
                priceBookId:cmp.get("v.quoteObj").Pricebook2Id,
                quoteCurrency:cmp.get("v.quoteObj").CurrencyIsoCode
            });
            $A.util.removeClass(cmp.find('spinnerOli'), 'slds-hide');
            action.setCallback(this,function(resp){
                if(resp.getState()) {
                    $A.util.addClass(cmp.find('spinnerOli'), 'slds-hide');
                    if(resp.getState() === 'SUCCESS') {
                        
                        helper.showToast(cmp, event, 'SUCCESS', 'Record is saved !');
                        $A.get('e.force:refreshView').fire();
                        
                        /*window.setTimeout(
                    $A.getCallback(function() {
                        helper.closeModalHelper(cmp,event);
                    }), 1000
                );*/
                }
                
                else if(resp.getState() === 'ERROR'){
                    
                    helper.showToast(cmp, event, 'ERROR', 'Error in saving record');
                }
                
                
            }
        });
            $A.enqueueAction(action);
        },
            closeModal : function(cmp,event,helper) {
                helper.closeModalHelper(cmp,event);
            },
                //get subtotal on initialization, change in quantity, price and/or discount
                getSubtotal : function(cmp,event,helper) {
                    cmp.set("v.promoMapDisplay",'');
                    helper.calculateSubtotalHelper(cmp,event);
                },
                    //only for discounts
                    applyManualDiscountPercentage : function(cmp,event,helper) {
                        
                        //let index = +event.currentTarget.parentElement.dataset.rowIndex;
                        let index = event.target.getAttribute("data-row-index");
                        
                        let updatedOliList = [];
                        let oliList = cmp.get("v.oliItems");
                        let discount = event.getSource().get('v.value')
                        let promoMap = cmp.get("v.promoMap");
                        for(let item in oliList) { 
                            if(oliList[item].Parent_Id__c == undefined) {
                                updatedOliList.push(oliList[item]);
                            }else{
                                if(oliList[item].Parent_Id__c == oliList[index].Promo_Mechanic_Id__c || oliList[item].Parent_Id__c == oliList[index].Id) { 
                                }
                                else
                                    updatedOliList.push(oliList[item]);
                            }
                        }
                        updatedOliList[index].Discount_Amount__c = undefined ;
                        updatedOliList[index].Discount__c = discount;
                        delete updatedOliList[index].Campaign__r;
                        updatedOliList[index].Campaign__c = undefined;
                        updatedOliList[index].CampaignId__c = undefined;
                        updatedOliList[index].campaignName = undefined;
                        updatedOliList[index].discountPerUnit = undefined;
                        updatedOliList[index].Promo_Mechanic_Id__c = undefined;
                        updatedOliList[index].Parent_Id__c = undefined;
                        updatedOliList[index].Discount_Reason__c = 'Managerial Discount';
                        updatedOliList[index].disabled = false;
                        
                        var unitPrice = updatedOliList[index].UnitPrice==null?0:updatedOliList[index].UnitPrice;
                        var quantity = updatedOliList[index].Quantity==null?0:updatedOliList[index].Quantity;
                        var totalPrice = unitPrice * quantity;
                        let discountAmount = 0; 
                        var discountedAmount = discount!=null?unitPrice*quantity*discount/100:discountAmount;
                        updatedOliList[index].Amount__c = totalPrice-(isNaN(discountedAmount)?0:discountedAmount)-(isNaN(updatedOliList[index].Pro_Rate_Amount__c)?0:
                                                                                                                   (totalPrice-(isNaN(discountedAmount)?0:discountedAmount)>=updatedOliList[index].Pro_Rate_Amount__c?updatedOliList[index].Pro_Rate_Amount__c:(totalPrice-(isNaN(discountedAmount)?0:discountedAmount))));
                        updatedOliList[index].Gross_Amount__c = updatedOliList[index].Amount__c + ( updatedOliList[index].Amount__c * (updatedOliList[index].GST_VAT_Rate__c/100) );
                        cmp.set("v.oliItems",updatedOliList);
                        helper.calculateSubtotalHelper(cmp,event);
                    },
                        applyManualDiscountAmount : function(cmp,event,helper) {
                            
                            
                            //let index = +event.currentTarget.parentElement.dataset.rowIndex;
                            let index = event.target.getAttribute("data-row-index");
                            
                            let updatedOliList = [];
                            let oliList = cmp.get("v.oliItems");
                            let tempDiscount = event.getSource().get('v.value');
                            let discount = 0;
                            if(tempDiscount!= undefined && tempDiscount!='') {
                                discount = parseInt(tempDiscount);
                            }
                            let promoMap = cmp.get("v.promoMap");
                            for(let item in oliList) { 
                                if(oliList[item].Parent_Id__c == undefined) {
                                    updatedOliList.push(oliList[item]);
                                }else{
                                    if(oliList[item].Parent_Id__c == oliList[index].Promo_Mechanic_Id__c || oliList[item].Parent_Id__c == oliList[index].Id) { 
                                    }
                                    else
                                        updatedOliList.push(oliList[item]);
                                }
                            }
                            updatedOliList[index].Discount_Amount__c = discount ;
                            updatedOliList[index].discountPerUnit = undefined;
                            updatedOliList[index].Discount__c = undefined;
                            delete updatedOliList[index].Campaign__r;
                            updatedOliList[index].Campaign__c = undefined;
                            updatedOliList[index].CampaignId__c = undefined;
                            updatedOliList[index].campaignName = undefined;
                            updatedOliList[index].Promo_Mechanic_Id__c = undefined;
                            updatedOliList[index].Parent_Id__c = undefined;
                            updatedOliList[index].Discount_Reason__c = 'Managerial Discount';
                            updatedOliList[index].disabled = false;
                            
                            var unitPrice = updatedOliList[index].UnitPrice==null?0:updatedOliList[index].UnitPrice;
                            var quantity = updatedOliList[index].Quantity==null?0:updatedOliList[index].Quantity;
                            var totalPrice = unitPrice * quantity;
                            let discountAmount = null
                            var discountedAmount = discountAmount!=null?unitPrice*quantity*discountAmount/100:discount;
                            updatedOliList[index].Amount__c = totalPrice-(isNaN(discountedAmount)?0:discountedAmount)-(isNaN(updatedOliList[index].Pro_Rate_Amount__c)?0:
                                                                                                                       (totalPrice-(isNaN(discountedAmount)?0:discountedAmount)>=updatedOliList[index].Pro_Rate_Amount__c?updatedOliList[index].Pro_Rate_Amount__c:(totalPrice-(isNaN(discountedAmount)?0:discountedAmount))));
                            updatedOliList[index].Gross_Amount__c = updatedOliList[index].Amount__c + ( updatedOliList[index].Amount__c * (updatedOliList[index].GST_VAT_Rate__c/100) );
                            cmp.set("v.oliItems",updatedOliList);
                            //helper.removePromoHelper(cmp,event, oliList, index);
                            helper.calculateSubtotalHelper(cmp,event);
                        },
                            applyManagerialDiscount : function(cmp,event,helper) {
                                
                                //let index = Number(+event.currentTarget.parentElement.dataset.rowIndex);
                                let index =  event.target.getAttribute("data-row-index");
                                let updatedOliList = [];
                                let oliList = cmp.get("v.oliItems");
                                //let discount = event.getSource().get('v.value')
                                let promoMap = cmp.get("v.promoMap");
                                
                                if(oliList[index].Discount_Reason__c != 'Managerial Discount')
                                    return;
                                for(let item in oliList) { 
                                    if(oliList[item].Parent_Id__c == undefined) {
                                        updatedOliList.push(oliList[item]);
                                    }else{
                                        if(oliList[item].Parent_Id__c == oliList[index].Promo_Mechanic_Id__c || oliList[item].Parent_Id__c == oliList[index].Id) { 
                                        }
                                        else
                                            updatedOliList.push(oliList[item]);
                                    }
                                }
                                //updatedOliList[index].Discount_Amount__c = discount ;
                                //updatedOliList[index].Discount__c = undefined;
                                delete updatedOliList[index].Campaign__r;
                                updatedOliList[index].Campaign__c = undefined;
                                updatedOliList[index].Promo_Mechanic_Id__c = undefined;
                                updatedOliList[index].Parent_Id__c = undefined;
                                updatedOliList[index].Discount_Reason__c = 'Managerial Discount';
                                updatedOliList[index].disabled = false;
                                
                                cmp.set("v.oliItems",updatedOliList);
                                helper.calculateSubtotalHelper(cmp,event);
                            },
                                //show promo button related to product
                                showPromoButton : function(cmp,event,helper) {
                                    helper.showPromoHelper(cmp,event);
                                },
                                    //add promo to oli
                                    addPromoButton : function(cmp, event, helper) {
                                        let temIds = []; 
                                        let promoId = event.getSource().get("v.value");
                                        let promoMapDisplayed = cmp.get("v.promoMapDisplay");
                                        let oliList = cmp.get("v.oliItems");
                                        let oliIndex = cmp.get("v.oliSelectedIndex");
                                        //exclusion
                                        let productList = cmp.get('v.productList');
                                        let exclusionproductIdsList = [];
                                        let exclusionProductMap = cmp.get('v.exclusionProductMap');
                                        if(oliList[oliIndex] === undefined)
                                            return;
                                        let discountPerUnit = 0;
                                        let quoteObj = cmp.get('v.quoteObj');
                                        let malaysiaPromoIds = cmp.get('v.Malaysia_MCO_Promos');
                                        let malaysiaPromoIdsList = malaysiaPromoIds.split(',');
                                        //let index = +event.currentTarget.parentElement.dataset.rowIndex;
                                        let index =  event.target.getAttribute("data-row-index");
                                        let totalQuantity = cmp.get("v.sumOfQLIQuantity");
                                        
                                        if(exclusionProductMap !=undefined && exclusionProductMap != null && promoId != undefined && promoId != null && promoId != '' && exclusionProductMap[promoId] != undefined){
                                            exclusionProductMap[promoId].find(eachExclProdId=>{
                                                exclusionproductIdsList.push(eachExclProdId);
                                            })
                                            }
                                                
                                                for(let key in promoMapDisplayed) {
                                                //AUTOMATION-8897
                                                //if(quoteObj.Country__c == 'Malaysia' && oliList[oliIndex].Quantity != undefined && oliList[oliIndex].Quantity != null && (totalQuantity >= 3000 || (parseInt(oliList[oliIndex].Quantity) + parseInt(totalQuantity)) > 3000)) {                
                                                //helper.showToast(cmp, event, 'ERROR', 'Promo Code can not be applied as it has reached its maximum limit');
                                                //return;  
                                                //}
                                                if((oliList[oliIndex].Quantity != undefined && oliList[oliIndex].Quantity != null && promoMapDisplayed[key].value[index].Denomination__c != undefined && promoMapDisplayed[key].value[index].Denomination__c != null && (oliList[oliIndex].Quantity % promoMapDisplayed[key].value[index].Denomination__c != 0)) || (quoteObj.Quote_Type__c != undefined && quoteObj.Quote_Type__c != null && promoMapDisplayed[key].value[index].Opportunity_Type__c != undefined  && promoMapDisplayed[key].value[index].Opportunity_Type__c != null && (quoteObj.Quote_Type__c != promoMapDisplayed[key].value[index].Opportunity_Type__c))){
                                                helper.showToast(cmp, event, 'ERROR', 'Promo Code Not Applicable.');
                                                return;
                                            }
                                                if(promoMapDisplayed[key].value[index].Usage__c != undefined && promoMapDisplayed[key].value[index].Usage__c != null && promoMapDisplayed[key].value[index].Usage__c != ''){
                                                if(promoMapDisplayed[key].value[index].Usage__c == -1){
                                                if(oliList[oliIndex].Promo_Mechanic_Id__c != undefined && oliList[oliIndex].Promo_Mechanic_Id__c != null && oliList[oliIndex].Promo_Mechanic_Id__c != '' && oliList[oliIndex].Promo_Mechanic_Id__c.includes(promoId)){
                                                helper.showToast(cmp, event, 'ERROR', 'Promo already applied.');
                                                return;
                                            }
                                            }
                                                else{
                                                let isReturn = false;
                                                oliList.find(item=>{
                                                if(item.Promo_Mechanic_Id__c != undefined && item.Promo_Mechanic_Id__c != null && item.Promo_Mechanic_Id__c.includes(promoId)){
                                                helper.showToast(cmp, event, 'ERROR', 'Promo is already apply.');
                                                isReturn = true;
                                            }
                                            })
                                                if(isReturn){
                                                return; 
                                            }
                                            }
                                            }
                                                
                                                for(let val in promoMapDisplayed[key].value) {
                                                oliList[oliIndex].disabled = true;
                                                if(promoMapDisplayed[key].value[val].Discount_Reason__c != undefined && promoMapDisplayed[key].value[val].Id == promoId) {
                                                oliList[oliIndex].Discount_Reason__c = promoMapDisplayed[key].value[val].Discount_Reason__c;
                                            }
                                                if(promoMapDisplayed[key].value[val].Entitlement_Product__r != undefined && oliIndex != null && oliIndex != undefined) {
                                                if(promoMapDisplayed[key].value[val].Id == promoId && oliList[oliIndex].Quantity != null && oliList[oliIndex].Quantity >= promoMapDisplayed[key].value[val].Min_Qty__c && oliList[oliIndex].Quantity != undefined && oliList[oliIndex].Quantity <= promoMapDisplayed[key].value[val].Max_Qty__c) {
                                                if(oliList[oliIndex].promoIdsValue == undefined && oliList[oliIndex].Promo_Mechanic_Id__c == undefined){
                                                oliList[oliIndex].promoIdsValue = '';
                                                oliList[oliIndex].Promo_Mechanic_Id__c = '';
                                            }
                                                oliList[oliIndex].promoIdsValue += ','+promoId; 
                                                oliList[oliIndex].Promo_Mechanic_Id__c = oliList[oliIndex].promoIdsValue.substring(1);
                                                if(promoMapDisplayed[key].value[val].Campaign_Eligibility__r != undefined && promoMapDisplayed[key].value[val].Campaign_Eligibility__r.Campaign__r != undefined) {
                                                oliList[oliIndex].Campaign__c = promoMapDisplayed[key].value[val].Campaign_Eligibility__r.Campaign__r.Id;
                                                let campaign = {};
                                                if(oliList[oliIndex].CampaignId__c == undefined && oliList[oliIndex].campaignName == undefined){
                                                oliList[oliIndex].CampaignId__c = '';
                                                oliList[oliIndex].campaignName = '';
                                            }
                                                oliList[oliIndex].campaignName = promoMapDisplayed[key].value[val].Campaign_Eligibility__r.Campaign__r.Name;
                                                oliList[oliIndex].CampaignId__c = oliList[oliIndex].campaignName;
                                                campaign.Name = promoMapDisplayed[key].value[val].Campaign_Eligibility__r.Campaign__r.Name;
                                                campaign.Id = promoMapDisplayed[key].value[val].Campaign_Eligibility__r.Campaign__r.Id;
                                                oliList[oliIndex].Campaign__r = campaign;
                                            }
                                                
                                                let isBool = false;
                                                oliList.find((item,index)=>{
                                                if(exclusionproductIdsList.includes(oliList[index].Product2Id)){
                                                helper.showToast(cmp, event, 'ERROR', 'Can not apply exclusion');
                                                isBool = true;
                                            }
                                            })
                                                if(isBool){
                                                return;
                                            }
                                                // exclusion : Remove products from available list
                                                productList.find((item,index)=>{
                                                if(exclusionproductIdsList.includes(productList[index]))
                                                productList.splice(index,1);
                                            })
                                                for(let k in promoMapDisplayed[key].value[val].Entitlement_Product__r){
                                                //PGAUTO-2371
                                                if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount_per_unit__c != undefined &&  promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c != undefined) {
                                                if(oliList[oliIndex].Discount_Amount__c == undefined){
                                                oliList[oliIndex].Discount_Amount__c = 0;
                                            } 
                                                oliList[oliIndex].Discount_Amount__c += promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c;
                                                if(oliList[oliIndex].discountPerUnit == undefined){
                                                oliList[oliIndex].discountPerUnit = 0;
                                            }
                                                oliList[oliIndex].discountPerUnit += promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount_per_unit__c;
                                            }
                                                else if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount_per_unit__c != undefined){
                                                if(oliList[oliIndex].discountPerUnit == undefined){
                                                oliList[oliIndex].Discount__c = undefined;
                                                oliList[oliIndex].Discount_Amount__c = undefined;
                                                oliList[oliIndex].discountPerUnit = 0;
                                            }
                                                oliList[oliIndex].discountPerUnit += promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount_per_unit__c;
                                            }
                                                else if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount__c != undefined &&  promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c != undefined) {
                                                if(oliList[oliIndex].Discount_Amount__c == undefined){
                                                oliList[oliIndex].Discount_Amount__c = 0;
                                            }
                                                oliList[oliIndex].Discount_Amount__c += promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c;
                                                if(oliList[oliIndex].Discount__c == undefined){
                                                oliList[oliIndex].Discount__c = 0;
                                            }
                                                oliList[oliIndex].Discount__c += promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount__c;
                                                
                                            } else if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c != undefined){
                                                if(oliList[oliIndex].Discount_Amount__c == undefined){
                                                oliList[oliIndex].Discount_Amount__c = 0;
                                            }
                                                oliList[oliIndex].Discount_Amount__c += promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c;
                                            }
                                                else if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__c == null) {
                                                if((promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount__c != null) || 
                                                (promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c != null) || 
                                                (promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount_per_unit__c != null)){
                                                if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount__c != undefined) {
                                                oliList[oliIndex].Discount__c = 0;
                                                oliList[oliIndex].Discount_Amount__c = undefined;
                                                oliList[oliIndex].Discount__c += promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount__c;
                                            }
                                                if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Is_Promo_Start_Date_Editable__c) {
                                                oliList[oliIndex].isPackagePromoApplied = true;
                                                cmp.set("v.originalStartDate",oliList[oliIndex].Start_Date__c);
                                            } 
                                                for(let oli in oliList) {
                                                if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != undefined && 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != null && 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != undefined &&
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != null) {
                                                if((oliList[oli].Parent__c != null && oliList[oli].Parent__c != undefined) || 
                                                (oliList[oli].Promo_Mechanic_Id__c != null && oliList[oli].Promo_Mechanic_Id__c != undefined &&
                                                oliList[oli].Promo_Mechanic_Id__c == promoMapDisplayed[key].value[val].Id)) {
                                                oliList[oli].End_Date__c = helper.addMonths(
                                                oliList[oli].Start_Date__c, 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c, 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c);
                                            }   
                                            }
                                            } 
                                            }
                                            }
                                                else if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c != undefined) {
                                                oliList[oliIndex].Discount_Amount__c = 0;
                                                oliList[oliIndex].Discount__c = undefined;
                                                oliList[oliIndex].Discount_Amount__c += promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c;
                                                
                                            } else {
                                                let newOli = {};
                                                newOli.Id;
                                                newOli.QuoteId = cmp.get("v.quoteObj").Id;
                                                newOli.Product2Id = promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.Id;
                                                let prod = {};
                                                prod.Name = promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.Name;
                                                prod.Id = promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.Id;
                                                prod.CustItem_Validity_Unit__c = promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.CustItem_Validity_Unit__c;
                                                prod.CustItem_Validity_Value__c = promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.CustItem_Validity_Value__c;
                                                
                                                temIds.push(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Id);
                                                cmp.set("v.listOfChildProduct",temIds);
                                                newOli.Product2 = prod;
                                                newOli.UnitPrice = 0 ;
                                                newOli.Quantity = promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Quantity__c;
                                                newOli.AddOn = true;
                                                newOli.Parent_Id__c = promoId;
                                                newOli.Discount_Reason__c = oliList[oliIndex].Discount_Reason__c;
                                                newOli.PO__c = oliList[oliIndex].PO__c; 
                                                
                                                if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Is_Promo_Start_Date_Editable__c) {
                                                newOli.isPromoApplied = true;
                                                newOli.Start_Date__c = helper.getToday();
                                            } else {
                                                newOli.Start_Date__c = oliList[oliIndex].Start_Date__c;
                                            }
                                                newOli.PricebookEntryId = oliList[oliIndex].PricebookEntryId;
                                                if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != undefined && 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != null && 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != undefined &&
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != null) {
                                                newOli.End_Date__c = helper.addMonths(
                                                newOli.Start_Date__c, 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c, 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c);
                                            } else {
                                                newOli.End_Date__c = oliList[oliIndex].End_Date__c;
                                            }
                                                newOli.Push_to_NetSuite__c = false;
                                                if (promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.Tax_Code__c != null) {
                                                newOli.GST_VAT_Code1__c = promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.Tax_Code__c;
                                            }
                                                else {
                                                newOli.GST_VAT_Code1__c = null;
                                            }
                                                if (promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.Tax_Code__r != undefined) {
                                                newOli.GST_VAT_Rate__c = promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__r.Tax_Code__r.Tax_Rate__c;
                                            }
                                                else{
                                                newOli.GST_VAT_Rate__c = 0;
                                            }
                                                newOli.isEntitlementPromo = true;
                                                let curr = new Date( newOli.Start_Date__c); // get current date
                                                let first = curr.getDate() - curr.getDay() +1; // First day is the start of the week 
                                                let last = first + 6; // last day is the first day + 6
                                                
                                                let firstday = new Date(curr.setDate(first));
                                                let lastday = new Date(curr.setDate(last)).getTime();
                                                
                                                let endOfWeekTemp = cmp.get("v.endOfTheWeek");
                                                const endOfWeek = new Map();
                                                endOfWeek.set(newOli.Product2Id,lastday); 
                                                cmp.set("v.endOfTheWeek",endOfWeek); 
                                                oliList.push(newOli);
                                            }
                                            }
                                                var unitPrice = oliList[oliIndex].UnitPrice==null?0:oliList[oliIndex].UnitPrice;
                                                var quantity = oliList[oliIndex].Quantity==null?0:oliList[oliIndex].Quantity;
                                                var totalPrice = unitPrice * quantity;
                                                let discount = oliList[oliIndex].Discount__c==null?0:oliList[oliIndex].Discount__c;
                                                let discountAmount = oliList[oliIndex].Discount_Amount__c==null?0:oliList[oliIndex].Discount_Amount__c;
                                                var discountedAmount = unitPrice*quantity*discount/100;
                                                let perUnitDiscount = oliList[oliIndex].discountPerUnit==null?0:oliList[oliIndex].discountPerUnit;
                                                oliList[oliIndex].Amount__c = totalPrice - (perUnitDiscount * quantity) - discountAmount - discountedAmount;
                                                if(perUnitDiscount!=undefined && perUnitDiscount>0) {
                                                oliList[oliIndex].Discount_Amount__c = perUnitDiscount * quantity;
                                            }
                                                                              oliList[oliIndex].Gross_Amount__c = oliList[oliIndex].Amount__c + ( oliList[oliIndex].Amount__c * (oliList[oliIndex].GST_VAT_Rate__c/100) );
                                            let endDateForMY = false;
                                            for(let pmId in malaysiaPromoIdsList){
                                                if(malaysiaPromoIdsList[pmId] == promoId){
                                                    endDateForMY = true;
                                                }
                                            }
                                            if(endDateForMY){                                   
                                                let today = new Date(oliList[oliIndex].End_Date__c);
                                                today.setDate(today.getDate());
                                                let dd = today.getDate();
                                                let mm = today.getMonth()+2; //January is 0!
                                                let yyyy = today.getFullYear();
                                                if(dd<10) {
                                                    dd = '0'+dd
                                                } 
                                                if(mm<10) {
                                                    mm = '0'+mm
                                                } 
                                                today = yyyy + '-' + mm + '-' + dd;
                                                oliList[oliIndex].End_Date__c = today;
                                            }
                                            
                                            //added for updating the end date as per the promo mechanic, PGAUTO-6553
                                            let tempList = cmp.get("v.listOfChildProduct");
                                            if(promoMapDisplayed[key].value[val].Override_End_Date__c != undefined && oliList[oliIndex].Start_Date__c != undefined){
                                                oliList[oliIndex].End_Date__c = promoMapDisplayed[key].value[val].Override_End_Date__c;
                                            }
                                            //added for updating the end date as per the promo mechanic, PGAUTO-5323
                                            else if(promoMapDisplayed[key].value[val].Override_Duration_Value__c != undefined && promoMapDisplayed[key].value[val].Override_Duration_Unit__c != undefined && oliList[oliIndex].Start_Date__c != undefined){
                                                oliList[oliIndex].End_Date__c = helper.addMonths(
                                                    oliList[oliIndex].Start_Date__c,
                                                    promoMapDisplayed[key].value[val].Override_Duration_Value__c,
                                                    promoMapDisplayed[key].value[val].Override_Duration_Unit__c
                                                );
                                            }
                                            cmp.set("v.oliItems",oliList); 
                                            cmp.set("v.promoMapDisplay",'');
                                            document.getElementById('olis').scrollIntoView();
                                        } 
                                        else if(promoMapDisplayed[key].value[val].Id == promoId){
                                            helper.showToast(cmp, event, 'ERROR', 'Promo Code Not Applicable.');
                                        }   
                                    }
} 
}
cmp.set("v.oliItems",cmp.get("v.oliItems"));
window.setTimeout(
    $A.getCallback(function() {
        helper.calculateSubtotalHelper(cmp,event);
        //helper.changeChildDate2(cmp,event,helper);
    }), 1000
);  
},
    
    removePromoButton : function(cmp, event, helper) {
        let oliList = cmp.get("v.oliItems");
        //let index = +event.currentTarget.parentElement.dataset.rowIndex;
        let index =  event.target.getAttribute("data-row-index");
        helper.removePromoHelper(cmp,event, oliList, index);
    },
        onchangeQuantity : function(cmp, event, helper) {
            //alert('Hello');
            let oliList = cmp.get("v.oliItems");
            //let index = +event.currentTarget.parentElement.dataset.rowIndex;
            let index =  event.target.getAttribute("data-row-index");
            let promoMap = cmp.get("v.promoMap");
            let quantity = event.getSource().get("v.value");
            var sumOfNewQuantity = 0;
            let quoteObj = cmp.get('v.quoteObj');
            
            //AUTOMATION-8897
            for(let item in oliList) {
                if(quoteObj.Country__c == 'Malaysia' && oliList[item].Product2.Multiple_Sale_Not_Allowed__c == true) {
                    if(oliList[item].Product2.SKU_Code__c == $A.get("$Label.c.SKUCODE_AD_CREDIT_MY")) {
                        if(oliList[item].Campaign__c != null){
                            sumOfNewQuantity += parseInt(oliList[item].Quantity);
                        } 
                    }
                }
            }
            cmp.set("v.sumOfQLIQuantity",sumOfNewQuantity);
            if(quantity != '' && quantity != null && quantity != undefined) {
                //helper.removePromoHelper(cmp,event, oliList, index);
                for(let key in promoMap) {
                    for(let val in promoMap[key].value) {
                        
                        if(promoMap[key].value[val] != null && promoMap[key].value[val] != undefined && index != null && index != undefined &&
                           oliList[index].Promo_Mechanic_Id__c != null && oliList[index].Promo_Mechanic_Id__c != undefined) {
                            if(promoMap[key].value[val].Id == oliList[index].Promo_Mechanic_Id__c && oliList[index].Promo_Mechanic_Id__c != null &&
                               oliList[index].Promo_Mechanic_Id__c != undefined && promoMap[key].value[val].Id != null && promoMap[key].value[val].Id != undefined /*&&
                               (quantity < promoMap[key].value[val].Min_Qty__c || quantity > promoMap[key].value[val].Max_Qty__c)*/) {
                                cmp.set("v.promoMapDisplay",'');
                                helper.removePromoHelper(cmp,event, oliList, index);
                            }
                        }
                    }
                }
                helper.handleBlur(cmp,event);
                helper.calculateSubtotalHelper(cmp,event);
                
                var unitPrice = oliList[index].UnitPrice==null?0:oliList[index].UnitPrice;
                var totalPrice = unitPrice * quantity;
                let discountAmount = oliList[index].Discount_Amount__c;
                let discount = oliList[index].Discount__c;
                var discountedAmount = discountAmount!=null?unitPrice*quantity*discountAmount/100:discount;
                oliList[index].Amount__c = totalPrice-(isNaN(discountedAmount)?0:discountedAmount)-(isNaN(oliList[index].Pro_Rate_Amount__c)?0:
                                                                                                    (totalPrice-(isNaN(discountedAmount)?0:discountedAmount)>=updatedOliList[index].Pro_Rate_Amount__c?oliList[index].Pro_Rate_Amount__c:(totalPrice-(isNaN(discountedAmount)?0:discountedAmount))));
                oliList[index].Gross_Amount__c = oliList[index].Amount__c + ( oliList[index].Amount__c * (oliList[index].GST_VAT_Rate__c/100) );
                cmp.set("v.oliItems",oliList);
            }
        },
            changeChildPO: function(cmp, event, helper) {
                let listOppLine = cmp.get("v.oliItems");
                //let idx = +event.currentTarget.parentElement.dataset.rowIndex;
                let idx =  event.target.getAttribute("data-row-index");
                let currId = (listOppLine[idx].Promo_Mechanic_Id__c!=undefined && listOppLine[idx].Promo_Mechanic_Id__c.length > 0) ? listOppLine[idx].Promo_Mechanic_Id__c : idx;
                let childcurrId = (listOppLine[idx].Id!=undefined && listOppLine[idx].Id.length > 0) ? listOppLine[idx].Id : idx;
                
                let quoteObj = cmp.get('v.quoteObj');
                if((quoteObj.Status == 'Proposal' && (quoteObj.Approval_Status__c == 'Discount Approval Recalled' || quoteObj.Approval_Status__c == 'Discount Approval Approved' ||
                                                      quoteObj.Approval_Status__c == null)) ||
                   (quoteObj.Status == 'Pending Online Payment' && quoteObj.Agent_Accepted_Time__c == null) ||
                   (quoteObj.Status == 'Pending OMC Approval' && (quoteObj.Approval_Status__c == 'OMC Approval Recalled' || quoteObj.Approval_Status__c == 'OMC Approval Rejected'))){
                    listOppLine.find((item,index)=>{
                        if (listOppLine[index].Parent_Id__c!=undefined && currId.includes(listOppLine[index].Parent_Id__c)) {
                        listOppLine[index].PO__c = listOppLine[idx].PO__c;
                    }else if (listOppLine[index].Parent__c!=undefined && listOppLine[index].Parent__c==childcurrId) {
                        listOppLine[index].PO__c = listOppLine[idx].PO__c;
                    }
                })
            }
cmp.set("v.oliItems", listOppLine);
},
    changeChildDate: function(cmp, event, helper) {
        let listOppLine = cmp.get("v.oliItems");
        let lastIndex = listOppLine.length - 1;
        let promoMapDisplayed = cmp.get("v.promoMap");
        //let idx = +event.currentTarget.parentElement.dataset.rowIndex;
        let idx =  event.target.getAttribute("data-row-index");
        if(!listOppLine[idx].Start_Date__c){
            return;
        }
        
        
        let promoMechanicIds = cmp.get("v.listOfChildProduct");
        let currId = (listOppLine[idx].Promo_Mechanic_Id__c!=undefined && listOppLine[idx].Promo_Mechanic_Id__c.length > 0) ? listOppLine[idx].Promo_Mechanic_Id__c : idx;
        let childcurrId = (listOppLine[idx].Id!=undefined && listOppLine[idx].Id.length > 0) ? listOppLine[idx].Id : idx;
        let anyUpdate = false;
        let quoteObj = cmp.get('v.quoteObj');
        let malaysiaPromoIds = cmp.get('v.Malaysia_MCO_Promos');
        let malaysiaPromoIdsList = malaysiaPromoIds.split(',');
        var advancePlus = false;
        
        if (event.getSource().getLocalId()=='oppStartDate') {
            // Adjust End Date to be 1 year after
            if(promoMapDisplayed != null && promoMapDisplayed.length >0){
                for(let key in promoMapDisplayed) {
                    for(let val in promoMapDisplayed[key].value) {
                        for(let k in promoMapDisplayed[key].value[val].Entitlement_Product__r) {  
                            
                            if(listOppLine[idx].Product2.CustItem_Validity_Value__c != null && listOppLine[idx].Product2.CustItem_Validity_Value__c != undefined && listOppLine[idx].Product2.CustItem_Validity_Unit__c != null && listOppLine[idx].Product2.CustItem_Validity_Unit__c != undefined){
                                if((listOppLine[idx].Promo_Mechanic_Id__c != null && listOppLine[idx].Promo_Mechanic_Id__c == promoMapDisplayed[key].value[val].Id) || (listOppLine[idx].Parent_Id__c != null && promoMapDisplayed[key].value[val].Id == listOppLine[idx].Parent_Id__c)){
                                    if(!promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Is_Promo_Start_Date_Editable__c) {
                                        if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__c != null && listOppLine[lastIndex].Parent__c == undefined && listOppLine[lastIndex].Parent_Id__c != undefined ) {
                                            listOppLine[lastIndex].Start_Date__c = listOppLine[idx].Start_Date__c;
                                            if(listOppLine[lastIndex].Promo_Mechanic_Id__c == null &&
                                               promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != undefined && 
                                               promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != null && 
                                               promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != undefined &&
                                               promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != null) {
                                                listOppLine[lastIndex].End_Date__c = helper.addMonths(
                                                    listOppLine[lastIndex].Start_Date__c, 
                                                    promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c, 
                                                    promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c);
                                                listOppLine[idx].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c)
                                                
                                            }else {
                                                listOppLine[lastIndex].End_Date__c = helper.addMonths(listOppLine[lastIndex].Start_Date__c,listOppLine[lastIndex].Product2.CustItem_Validity_Value__c,listOppLine[lastIndex].Product2.CustItem_Validity_Unit__c)
                                            }
                                        }else {
                                            if(((promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount__c != null) || 
                                                (promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c != null) || 
                                                (promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount_per_unit__c != null)) &&
                                               listOppLine[idx].Parent_Id__c == null){
                                                if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != undefined && 
                                                   promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != null && 
                                                   promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != undefined &&
                                                   promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != null) {
                                                    listOppLine[idx].End_Date__c = helper.addMonths(
                                                        listOppLine[idx].Start_Date__c, 
                                                        promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c, 
                                                        promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c);
                                                }else{
                                                    listOppLine[idx].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c)
                                                }
                                            }/*else{
                                            listOppLine[idx].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c)
                                        }*/
                                    }
                                } else {
                                    if(((promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount__c != null) || 
                                        (promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discounted_amt__c != null) || 
                                        (promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Discount_per_unit__c != null)) && 
                                       listOppLine[idx].Parent_Id__c == null ){
                                        if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != undefined && 
                                           promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != null && 
                                           promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != undefined &&
                                           promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != null) {
                                            listOppLine[idx].End_Date__c = helper.addMonths(
                                                listOppLine[idx].Start_Date__c, 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c, 
                                                promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c);
                                        }else{
                                            listOppLine[idx].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c)
                                        } 
                                    } else if(promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Entitlement_Product__c != null &&
                                              listOppLine[idx].Promo_Mechanic_Id__c == null &&
                                              promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != undefined && 
                                              promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c != null && 
                                              promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != undefined &&
                                              promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c != null){ 
                                        listOppLine[idx].End_Date__c = helper.addMonths(
                                            listOppLine[idx].Start_Date__c, 
                                            promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration__c, 
                                            promoMapDisplayed[key].value[val].Entitlement_Product__r[k].Duration_Term__c);
                                        
                                    }else if (listOppLine[idx].Promo_Mechanic_Id__c != null ){
                                        listOppLine[idx].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c)
                                    } 
                                }
                                } else if(listOppLine[idx].Promo_Mechanic_Id__c == null && listOppLine[idx].Parent_Id__c == null){
                                    listOppLine[idx].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c);
                                }  
                            if(listOppLine[idx].Product2.SKU_Code__c ==  $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS") && advancePlus == false) {
                                for(let i = 1; i <= lastIndex; i++) {
                                    if(listOppLine[i].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_MONTHLY_AC")) {
                                        var indexofAC = cmp.get("v.onChangeACIndex");
                                        var adCreditIndex = indexofAC==undefined?0:indexofAC;
                                        if(adCreditIndex == 0) {
                                            listOppLine[i].Start_Date__c = listOppLine[idx].Start_Date__c;
                                        } else {
                                            var startDate = helper.addMonths(listOppLine[idx].Start_Date__c,parseInt(adCreditIndex),'Months');
                                            listOppLine[i].Start_Date__c =  helper.addMonths(startDate,2,'Days');
                                        }
                                        adCreditIndex = adCreditIndex+1;
                                        cmp.set("v.onChangeACIndex",adCreditIndex);
                                        listOppLine[i].End_Date__c =   helper.addMonths(listOppLine[idx].Start_Date__c,parseInt(adCreditIndex),'Months');
                                    } else {
                                        cmp.set("v.onChangeACIndex",adCreditIndex);
                                        listOppLine[i].Start_Date__c = listOppLine[idx].Start_Date__c;
                                        listOppLine[i].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c)
                                    }
                                }
                                advancePlus = true;
                            }
                        }  else {
                            listOppLine[idx].End_Date__c = helper.getNextYear(listOppLine[idx].Start_Date__c);
                        }
                    }
                }
            }
             } else {
                 if(listOppLine[idx].Product2.CustItem_Validity_Value__c != null && listOppLine[idx].Product2.CustItem_Validity_Value__c != undefined && listOppLine[idx].Product2.CustItem_Validity_Unit__c != null && listOppLine[idx].Product2.CustItem_Validity_Unit__c != undefined){
                     listOppLine[idx].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c);
                     if(listOppLine[idx].Product2.SKU_Code__c ==  $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS") && advancePlus == false) {
                         for(let i = 1; i <= lastIndex; i++) {
                             if(listOppLine[i].Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_MONTHLY_AC")) {
                                 var indexofAC = cmp.get("v.onChangeACIndex");
                                 var adCreditIndex = indexofAC==undefined?0:indexofAC;
                                 if(adCreditIndex == 0) {
                                     listOppLine[i].Start_Date__c = listOppLine[idx].Start_Date__c;
                                 } else {
                                     var startDate = helper.addMonths(listOppLine[idx].Start_Date__c,parseInt(adCreditIndex),'Months');
                                     listOppLine[i].Start_Date__c =  helper.addMonths(startDate,2,'Days');
                                 }
                                 adCreditIndex = adCreditIndex+1;
                                 cmp.set("v.onChangeACIndex",adCreditIndex);
                                 listOppLine[i].End_Date__c =   helper.addMonths(listOppLine[idx].Start_Date__c,parseInt(adCreditIndex),'Months');
                             } else {
                                 cmp.set("v.onChangeACIndex",adCreditIndex);
                                 listOppLine[i].Start_Date__c = listOppLine[idx].Start_Date__c;
                                 listOppLine[i].End_Date__c = helper.addMonths(listOppLine[idx].Start_Date__c,listOppLine[idx].Product2.CustItem_Validity_Value__c,listOppLine[idx].Product2.CustItem_Validity_Unit__c)
                             }
                         }
                         advancePlus = true;
                     }
                 }else {
                     listOppLine[idx].End_Date__c = helper.getNextYear(listOppLine[idx].Start_Date__c);
                 }
             }    
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
        
        //added for updating the end date as per the promo mechanic, PGAUTO-5323
        let promoMap = cmp.get("v.promoMap");
        for(let key in promoMap) {
            for(let val in promoMap[key].value) {
                //added for updating the end date as per the promo mechanic, PGAUTO-6553
                if(promoMap[key].value[val].Id == currId &&
                   promoMap[key].value[val].Override_End_Date__c != undefined &&
                   listOppLine[idx].Start_Date__c != undefined
                  ) {
                    listOppLine[idx].End_Date__c = promoMap[key].value[val].Override_End_Date__c;
                    anyUpdate = true;
                }
                else if(
                    promoMap[key].value[val].Id == currId &&
                    promoMap[key].value[val].Override_Duration_Value__c != undefined &&
                    promoMap[key].value[val].Override_Duration_Unit__c != undefined &&
                    listOppLine[idx].Start_Date__c != undefined
                ) {
                    listOppLine[idx].End_Date__c = helper.addMonths(
                        listOppLine[idx].Start_Date__c,
                        promoMap[key].value[val].Override_Duration_Value__c,
                        promoMap[key].value[val].Override_Duration_Unit__c
                    );
                    anyUpdate = true;
                }
                
            }
        }
        if(((quoteObj.Status == 'Proposal' && (quoteObj.Approval_Status__c == 'Discount Approval Recalled' || quoteObj.Approval_Status__c == 'Discount Approval Approved' ||
                                               quoteObj.Approval_Status__c == null)) || (quoteObj.Status == 'Pending Online Payment' && quoteObj.Agent_Accepted_Time__c == null) ||
            (quoteObj.Status == 'Pending OMC Approval' && (quoteObj.Approval_Status__c == 'OMC Approval Recalled' || quoteObj.Approval_Status__c == 'OMC Approval Rejected'))) && advancePlus == false){
            listOppLine.find((item,index)=>{
                debugger;
                if(listOppLine[index].isEntitlementPromo == undefined){
                if (listOppLine[index].Parent_Id__c!=undefined && currId.includes(listOppLine[index].Parent_Id__c)) {
                listOppLine[index].Start_Date__c = listOppLine[idx].Start_Date__c;
                listOppLine[index].End_Date__c = listOppLine[idx].End_Date__c;
                anyUpdate = true;
            }
                else if(listOppLine[index].Parent__c!=undefined && listOppLine[index].Parent__c==childcurrId){
                listOppLine[index].Start_Date__c = listOppLine[idx].Start_Date__c;
                listOppLine[index].End_Date__c = listOppLine[idx].End_Date__c;
                anyUpdate = true;
            }
                else if(listOppLine[index].IsDiscretionaryAC__c == true) {
                listOppLine[index].Start_Date__c = listOppLine[idx].Start_Date__c;
                anyUpdate = true;
            }
            }
            })        
            }
                
                
                if (anyUpdate) {
                cmp.set("v.oliItems", listOppLine);
            }
                
                
            },
                addProdClickedRenew : function(cmp, event, helper) {
                    var quoteObj = cmp.get("v.quoteObj");
                    $A.util.removeClass(cmp.find('spinnerProd'), 'slds-hide');
                    var discretionaryProdPresent = false;
                    var subscriptionPresent = false;
                    var oliList = cmp.get("v.oliItems");
                    for(let item in oliList) {
                        if(oliList[item].Product2.Product_Category__c == 'Subscription') {
                            subscriptionPresent = true;
                        } else if(oliList[item].Product2.Product_Category__c == 'Discretionary' && !oliList[item].Parent__c) {
                            discretionaryProdPresent = true;
                        }
                    }
                    document.getElementById('olis').scrollIntoView();
                    let prodList = cmp.get("v.renewBtn");
                    //let index = +event.currentTarget.parentElement.dataset.rowIndex;
                    let index =  event.target.getAttribute("data-row-index");
                    let button = event.getSource().get("v.name");
                    let prodId = prodList[index].entry.Product2.Id;
                    if((quoteObj.Account.Account_Rule_Code__c == $A.get("$Label.c.ADVANCEPLUS_RENEW_EXCEPTION") || 
                       quoteObj.Account.Account_Rule_Code__c.toLowerCase() == $A.get("$Label.c.SG_STANDARD_PACKAGE").toLowerCase()) &&
                       prodList[index].entry.Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_STANDARD")) {
                        $A.util.addClass(cmp.find('spinnerProd'), 'slds-hide');
                        helper.showToast(cmp,event,'WARNING', 'If you are downgrading from Advance Plus Package or Renewing Standard Package, You can not upgrade to Advance Plus in future!');
                    }
                    if(quoteObj.Account.Account_Rule_Code__c.toLowerCase() == $A.get("$Label.c.SG_STANDARD_PACKAGE").toLowerCase() &&
                       quoteObj.Account.IsAdvance_Plus_Downgrade__c == true &&
                       prodList[index].entry.Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) {
                        $A.util.addClass(cmp.find('spinnerProd'), 'slds-hide');
                        helper.showToast(cmp,event,'ERROR', 'Upgrade is not Allowed as you have already downgraded from advance plus');
                        return;
                    }
                    
                    /*if(prodList[index].entry.Product2.SKU_Code__c == $A.get("$Label.c.SKU_CODE_ADVANCE_PLUS")) {
                        cmp.set("v.IsDiscNotApplicable",true);
                    } else {
                        cmp.set("v.IsDiscNotApplicable",false);
                    }*/
                    if(prodList[index].entry.Product2.Product_Category__c == 'Subscription' && subscriptionPresent){
                        $A.util.addClass(cmp.find('spinnerProd'), 'slds-hide');
                        helper.showToast(cmp,event,'ERROR', 'Only one Subscription Product can be added.');
                        return;
                    }
                    //One product category type can be selected at time
                    //PGAUTO-5244
                    var oppObj=cmp.get('v.oppObj');
                    if(
                        oppObj.Country__c == 'Singapore' && 
                        prodList[index].entry.Product2.Product_Category__c == 'Subscription' && 
                        discretionaryProdPresent
                    ) {
                        $A.util.addClass(cmp.find('spinnerProd'), 'slds-hide');
                        helper.showToast(cmp,event,'ERROR', $A.get("$Label.c.ADD_PROD_ERROR_SUBS"));
                        return;
                    }
                    
                    /*****************************************/
                    let action = cmp.get("c.getAvailableProductAndPromo");
                    action.setParams({
                        priceBookId : oppObj.Pricebook2Id, 
                        currencyCode : oppObj.CurrencyIsoCode,
                        searchKey :  prodList[index].entry.Product2.Name,
                        oppId : cmp.get("v.oppId"),
                        quoteID: cmp.get("v.quoteObj").Id
                    });
                    $A.util.removeClass(cmp.find('spinnerProd'), 'slds-hide');
                    action.setCallback(this, function(resp){
                        if(resp.getState() === 'SUCCESS') {
                            if(resp.getReturnValue().prodList.length > 0) {
                                let result = resp.getReturnValue();
                                /*if(oliList.length >0) {
                            for(let item in result.prodList) {
                                //exclusion
                           
                                 
                            	}
		
                        }*/
                    
                    let productMap = [];
                    for(let item in result.prodList ) {
                        productMap.push({
                            key: result.prodList[item].Product2Id,
                            value: result.prodList[item]
                        });
                    }
                    cmp.set("v.productMap",productMap);
                    let prodVsPromoMap = [];
                    for(let key in result.prodIdVsPromoMap){
                        prodVsPromoMap.push({
                            key: key,
                            value: result.prodIdVsPromoMap[key]
                        });
                    }
                    cmp.set("v.promoMap", prodVsPromoMap);
                    cmp.set("v.promoMapDisplay",cmp.get("v.defaultPromoMap"));
                }
                else {
                    helper.showToast(cmp,event,'ERROR', 'NO Product Found!');
                    let noProdList = [];
                    
                    cmp.set("v.promoMapDisplay",cmp.get("v.defaultPromoMap"));
                }
            }
            $A.util.addClass(cmp.find('spinnerProd'), 'slds-hide');
        });
        $A.enqueueAction(action); 
        
        
        /*****************************************/
        
        
        helper.addOliRenewHelper(cmp,event,prodId,'add'); 
        cmp.set("v.promoMapDisplay",cmp.get("v.defaultPromoMap"));
    }
            })