({
  construct: function(component, event, helper) {
    var oppId = component.get("v.recordId");
    var init0 = component.get("c.construct");
    var alertMsg = component.find("errorAlert");
    this.fetchPickListVal(
      component,
      component.get("v.oppLineObj"),
      "Discount_Reason__c",
      "v.listDiscountReason"
    );
    init0.setParams({ oppId: oppId });
    init0.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        var oppTmp = response.getReturnValue();
        component.set("v.oppObj", oppTmp.oppObj);
        component.set("v.mapDownGradeOutside", oppTmp.mapDownGrade);
        component.set("v.mapUpGradeOutside", oppTmp.mapUpGrade);
        component.set("v.loyaltyUpgrade", oppTmp.loyaltyUpgrade);
        component.set(
          "v.currentSubscriptionOutside",
          oppTmp.currentSubscription
        );
        if (
          !(
            oppTmp.oppObj.StageName == "New" ||
            oppTmp.oppObj.StageName == "Proposal"
          ) ||
          !(
            oppTmp.oppObj.Approval_Status__c == null ||
            oppTmp.oppObj.Approval_Status__c == "" ||
            oppTmp.oppObj.Approval_Status__c == "Discount Approval Rejected"
          )
        ) {
          alertMsg.set("v.title", "Information");
          component.set("v.error", "<ul>Opportunity is locked.</ul>");
          $A.util.removeClass(alertMsg, "slds-hide");
        }

        var selectedProduct = component.get("c.getSelectedProduct");
        selectedProduct.setParams({ oppId: oppTmp.oppObj.Id });
        selectedProduct.setCallback(this, function(response) {
          if (response.getState() === "SUCCESS") {
            var conts = response.getReturnValue();
            var sNO;
            var resourceList = [];

            for (var key in conts) {
              sNO = conts[key].SNo__c;
              conts[key].OriginDiscountPercentage = conts[key].Discount__c;
              conts[key].OriginDiscountAmount = conts[key].Discount_Amount__c;
              conts[key].Description = this.shortenDescription(
                conts[key].Line_Description2__c
              );
              conts[key].OldStartDate = conts[key].Start_Date__c;
              conts[key].OldEndDate = conts[key].End_Date__c;
              conts[key].toCheckWholeNo = sNO != Math.floor(sNO);
              console.log("toCheckWholeNo ", conts[key].toCheckWholeNo);
              resourceList.push(conts[key]);
            }
            component.set("v.sizeOppLineItem", resourceList.length);
            component.set("v.listOppLine", resourceList);
          }
        });
        $A.enqueueAction(selectedProduct);

        this.getPicklist(
          component,
          "v.listPricebook",
          { idx: "Id", namex: "Name", objectx: "Pricebook2" },
          { Id: null, Name: null }
        );
        this.getPicklist(
          component,
          "v.listTaxCode",
          { idx: "Id", namex: "Name", objectx: "Tax_Code__c" },
          { Id: null, Name: null }
        );

        this.getDiscountInfo(component, event, oppTmp.oppObj);
      }
    });
    $A.enqueueAction(init0);
  },
  shortenDescription: function(originalDesc) {
    var result =
      originalDesc != null &&
      originalDesc != undefined &&
      originalDesc.length > 30
        ? originalDesc.substr(0, 30) + "..."
        : originalDesc;
    return result;
  },
  getPicklist: function(component, auraComponent, params, defaultResourceList) {
    var picklist = component.get("c.getListData");
    picklist.setParams(params);
    picklist.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        var conts = response.getReturnValue();
        var resourceList = [defaultResourceList];
        for (var key in conts) {
          resourceList.push(conts[key]);
        }
        component.set(auraComponent, resourceList);
      }
    });
    $A.enqueueAction(picklist);
  },
  searchProduct: function(component, event) {
    var oppObj = component.get("v.oppObj");
    var searchKey = component.get("v.searchKey");
    var availableProduct = component.get("c.getListAvailableProduct");
    if (searchKey != null && searchKey != "") {
      availableProduct.setParams({
        priceBookId: oppObj.Pricebook2Id,
        currencyCode: oppObj.CurrencyIsoCode,
        searchKey: searchKey.trim()
      });
      availableProduct.setCallback(this, function(response) {
        if (response.getState() === "SUCCESS") {
          var conts = response.getReturnValue();
          var resourceList = [];
          for (var key in conts) {
            resourceList.push(conts[key]);
          }
          component.set("v.listProdAvailable", resourceList);
          if (resourceList.length == 0) {
            alert("Cannot find " + searchKey + " product.");
          }
        }
      });
      $A.enqueueAction(availableProduct);
    } else {
      alert("Please put in some keyword.");
    }
  },
  addProductAct: function(
    component,
    event,
    resourceList,
    oppObj,
    oppLineItem,
    rowIndex,
    oppId,
    bonusItem
  ) {
    console.log("rowIndex:" + rowIndex);
    var getChild = component.get("c.getChild");
    var oppLineObj = component.get("v.oppLineObj");
    var productObj = component.get("v.productObj");
    getChild.setParams({
      priceBookId: oppObj.Pricebook2Id,
      parentProductId: oppLineItem.Product2Id
    });
    getChild.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        var conts = response.getReturnValue();
        for (var key in conts) {
          component.set("v.oppLineObj", {
            sobjectType: "OpportunityLineItem",
            OpportunityId: oppId,
            Product2: null,
            Product2Id: null,
            Line_Description2__c: null,
            UnitPrice: null,
            Product_Type__c: null
          });

          oppLineObj = component.get("v.oppLineObj");
          this.newLineAssignment(
            component,
            oppLineObj,
            rowIndex,
            conts[key].Parent,
            conts[key],
            conts[key].Quantity,
            conts[key].Line_Description2,
            conts[key].Complimentary,
            null,
            false
          );

          resourceList.push(oppLineObj);
        }
        component.set("v.listOppLine", null);
        component.set("v.listOppLine", resourceList);
        component.set("v.sizeOppLineItem", resourceList.length);
        component.set("v.Spinner", false);

        if (bonusItem != null) {
          // PTYG01T-2 20181106: Bonus item must appear only after child product (if any)
          setTimeout(function() {
            console.log(bonusItem);
            resourceList = component.get("v.listOppLine");
            resourceList.push(bonusItem);
            component.set("v.listOppLine", null);
            component.set("v.listOppLine", resourceList);
            component.set("v.sizeOppLineItem", resourceList.length);
          }, 500);
        }
      }
    });
    $A.enqueueAction(getChild);
  },
  newLineAssignment: function(
    component,
    oppLineObj,
    parentIdx,
    parent,
    productRow,
    quantity,
    description,
    complimentary,
    orderType,
    isBundle
  ) {
    component.set("v.productObj", {
      sobjectType: "Product2",
      Name: null,
      Description: null,
      Product_Type__c: null
    });
    var oppObj = component.get("v.oppObj");
    var productObj = component.get("v.productObj");
    var today = null;
    var nextYear = null;
    if (oppObj.Order_Type_Clone__c == "Contract - Renewal") {
      var PrevEndDate = oppObj.Account.Previous_Acct_End_Date__c;
      var CurEndDate = oppObj.Account.Subscription_End_Date__c;
      if (oppObj.Country__c == "Singapore") {
        if (oppObj.Account.Status__c == "Active") {
          if (this.getToday() <= CurEndDate) {
            today = this.getNextDay(CurEndDate);
          }
        } else {
          if (this.getToday() > PrevEndDate) {
            today = this.getToday();
          }
        }
      } else if (oppObj.Country__c == "Malaysia") {
        if (oppObj.Account.Status__c == "Active") {
          if (this.getToday() <= CurEndDate) {
            today = this.getNextDay(CurEndDate);
          }
        } else {
          if (this.getToday() > CurEndDate) {
            today = this.getToday();
          }
        }
      }
      nextYear = this.getNextYear(today);
    } else {
      today = this.getToday();
      nextYear = this.getNextYear(today);
    }
    oppLineObj.Product2 = productObj;
    oppLineObj.PricebookEntryId = productRow.Id;
    oppLineObj.Parent__c = parentIdx;
    oppLineObj.Parent = parent;
    oppLineObj.Product2Id = productRow.Product2Id;
    oppLineObj.Product2.Name = productRow.Product2.Name;
    oppLineObj.Line_Description2__c = description;
    oppLineObj.Product_Category__c = productRow.Product2.Product_Category__c;
    oppLineObj.UnitPrice = productRow.UnitPrice;
    oppLineObj.Original_Price__c =
      oppLineObj.UnitPrice == null || oppLineObj.UnitPrice == undefined
        ? 0
        : oppLineObj.UnitPrice;
    oppLineObj.Description = this.shortenDescription(
      oppLineObj.Line_Description2__c
    );
    oppLineObj.Product_Type__c = productRow.Product_Type;
    oppLineObj.Quantity = quantity;
    oppLineObj.Complimentary__c = complimentary;
    oppLineObj.Push_to_NetSuite__c = productRow.Push_to_NetSuite;
    oppLineObj.Start_Date__c = today;
    oppLineObj.End_Date__c = nextYear;
    if (productRow.ChildCategory != undefined) {
      oppLineObj.Child_Category__c = productRow.ChildCategory;
    }
    if (productRow.Product2.Tax_Code__c != null) {
      oppLineObj.GST_VAT_Code__c = productRow.Product2.Tax_Code__c;
    } else {
      oppLineObj.GST_VAT_Code__c = null;
    }
    if (productRow.Product2.Tax_Code__r != undefined) {
      oppLineObj.GST_VAT_Rate__c = productRow.Product2.Tax_Code__r.Tax_Rate__c;
    } else {
      oppLineObj.GST_VAT_Rate__c = 0;
    }
    oppLineObj.Order_Type__c = orderType;
    oppLineObj.PO__c = true;
    oppLineObj.Product2.Is_Bundle__c = isBundle;
    var mapDownGradeOutside = component.get("v.mapDownGradeOutside");
    var mapUpGradeOutside = component.get("v.mapUpGradeOutside");
    var oppObj = component.get("v.oppObj");
    if (
      oppLineObj.Order_Type__c == null &&
      oppLineObj.Product_Category__c == "Subscription"
    ) {
      console.log(
        "productRowProductSKU_Code:" + productRow.Product2.SKU_Code__c
      );
      for (var idx in mapDownGradeOutside) {
        if (mapDownGradeOutside[idx] == productRow.Product2.SKU_Code__c) {
          console.log("considered downgrade");
          oppLineObj.Order_Type__c = "Downgrade";
        }
      }

      for (var idx in mapUpGradeOutside) {
        if (mapUpGradeOutside[idx] == productRow.Product2.SKU_Code__c) {
          console.log("considered upgrade");
          oppLineObj.Order_Type__c = "Upgrade";
        }
      }

      // If still null
      if (oppLineObj.Order_Type__c == null) {
        if (
          component.get("v.currentSubscriptionOutside") ==
          productRow.Product2.SKU_Code__c
        ) {
          console.log("considered renew");
          oppLineObj.Order_Type__c = "Renew";
        } else {
          console.log("considered new");
          oppLineObj.Order_Type__c = "New";
        }
      }
    }
  },
  addRenewalPackageAct: function(component, event, oppObj) {
    var availableProduct = component.get("c.getRenewalProductList");
    var errors,
      msg = "";
    var listOppLine = component.get("v.listOppLine");
    if (listOppLine == null) {
      listOppLine = component.get("v.listEmpty");
    }
    var currLength = listOppLine.length;
    availableProduct.setParams({ agentObj: oppObj.Account, oppObj: oppObj });
    availableProduct.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        var conts = response.getReturnValue();
        if (conts.length == 0) {
          alert(
            "Cannot find Renewal for " + oppObj.Account.Account_Rule_Code__c
          );
        } else {
          var listOppLine = component.get("v.listOppLine");
          if (listOppLine == null) {
            component.set("v.listEmpty", []);
            listOppLine = component.get("v.listEmpty");
          }
          /* ORION-751 20181106: Duplicate SKU validation was removed.
                    if (!this.validateDuplicate(component, listOppLine, conts[0].Product2.Id)) {
                        return false;
                    }
                    */

          this.registerNewLine(
            component,
            event,
            listOppLine,
            conts[0],
            oppObj,
            "Renew",
            currLength
          );
          /*var abc = this;
                    setTimeout(function() {
                        //abc.calculateTotalPrice(component, event, listOppLine, currLength, discount, discountAmount);
                    }, 1000);*/
        }
      } else {
        errors = response.getError();
        for (var i in errors) {
          msg += errors[i].message;
        }
        alert(msg);
      }
    });
    $A.enqueueAction(availableProduct);
  },
  registerNewLine: function(
    component,
    event,
    listOppLine,
    selectedProduct,
    oppObj,
    orderType,
    currLength
  ) {
    component.set("v.oppLineObj", {
      sobjectType: "OpportunityLineItem",
      OpportunityId: oppObj.Id,
      Product2: null,
      Product2Id: null,
      Line_Description2__c: null,
      UnitPrice: null,
      Product_Type__c: null
    });
    var oppLineObj = component.get("v.oppLineObj");
    var discount, discountAmount;
    var abc = this;
    this.newLineAssignment(
      component,
      oppLineObj,
      null,
      null,
      selectedProduct,
      1,
      selectedProduct.Product2.Description,
      false,
      orderType,
      selectedProduct.Product2.Is_Bundle__c
    );

    var bonusItem = this.setDiscountOnAdd(
      component,
      event,
      oppObj,
      listOppLine,
      oppLineObj,
      true
    );
    if (selectedProduct.Product2.Is_Bundle__c) {
      var parentIdx =
        listOppLine == null
          ? 0
          : listOppLine.length == 0
          ? 0
          : listOppLine.length - 1;
      if (
        listOppLine[parentIdx].Parent__c != null &&
        listOppLine[parentIdx].Parent__c != "null"
      ) {
        --parentIdx;
      }
      this.addProductAct(
        component,
        event,
        listOppLine,
        oppObj,
        oppLineObj,
        parentIdx,
        oppObj.Id,
        bonusItem != null ? bonusItem : null
      );
    }

    setTimeout(function() {
      listOppLine = component.get("v.listOppLine");
      discount =
        listOppLine[currLength].Discount__c == 0 ||
        listOppLine[currLength].Discount__c == undefined
          ? null
          : listOppLine[currLength].Discount__c;
      discountAmount =
        discount != null
          ? null
          : listOppLine[currLength].Discount_Amount__c == 0 ||
            listOppLine[currLength].Discount_Amount__c == undefined
          ? null
          : listOppLine[currLength].Discount_Amount__c;
      abc.calculateTotalPrice(
        component,
        event,
        listOppLine,
        currLength,
        discount,
        discountAmount
      );
    }, 1000);
  },
  fetchPickListVal: function(component, objName, fieldName, elementName) {
    var action = component.get("c.getSelectOptions");
    action.setParams({
      objObject: objName,
      fld: fieldName
    });
    var opts = [];
    action.setCallback(this, function(response) {
      if (response.getState() == "SUCCESS") {
        var allValues = response.getReturnValue();

        if (allValues != undefined && allValues.length > 0) {
          opts.push({
            class: "optionClass",
            label: "",
            value: ""
          });
        }
        for (var i = 0; i < allValues.length; i++) {
          opts.push({
            class: "optionClass",
            label: allValues[i],
            value: allValues[i]
          });
        }
        component.set(elementName, opts);
      }
    });
    $A.enqueueAction(action);
  },
  getDiscountInfo: function(component, event, oppObj) {
    var getDiscount = component.get("c.getListEligiblePromotion");
    var eligibleVip = null;
    getDiscount.setParams({ oppObj: oppObj });
    getDiscount.setCallback(this, function(response) {
      if (response.getState() === "SUCCESS") {
        var listDiscountDetail = component.get("v.listDiscountDetail");
        var tmp;
        var conts = response.getReturnValue();
        for (var idx in conts) {
          console.log(conts[idx]);
          if (conts[idx].EligibleVip != null) {
            eligibleVip = conts[idx].EligibleVip;
          }
          listDiscountDetail.push(conts[idx]);
        }
        console.log("EligibleVip:" + eligibleVip);
        component.set("v.EligibleVip", eligibleVip);
        component.set("v.listDiscountDetail", listDiscountDetail);
        console.log("before renewal");
        if (oppObj.Order_Type_Clone__c == "Contract - Renewal") {
          var mapUpGrade = component.get("v.mapUpGradeOutside");
          var mapDownGrade = component.get("v.mapDownGradeOutside");

          var renewalDiscountInfo = component.get("c.getRenewalDiscountInfo");
          renewalDiscountInfo.setParams({
            oppObj: oppObj,
            listResult: listDiscountDetail,
            currentAccountRuleCode: oppObj.Account.Account_Rule_Code__c,
            mapUpgrade: mapUpGrade,
            mapDowngrade: mapDownGrade
          });
          renewalDiscountInfo.setCallback(this, function(response) {
            conts = response.getReturnValue();
            if (response.getState() === "SUCCESS") {
              console.log(conts);
              for (var idx in conts) {
                listDiscountDetail.push(conts[idx]);
              }
              component.set("v.listDiscountDetail", listDiscountDetail);
            }
          });
          $A.enqueueAction(renewalDiscountInfo);
        } else {
          var getFirstTimerWinbackInfo = component.get(
            "c.getFirstTimerWinbackInfo"
          );
          getFirstTimerWinbackInfo.setParams({
            oppObj: oppObj,
            listResult: listDiscountDetail
          });
          getFirstTimerWinbackInfo.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
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
  setDiscountOnAdd: function(
    component,
    event,
    oppObj,
    listOppLine,
    oppLineObj,
    returnBonusItem
  ) {
    var oppId = component.get("v.recordId");
    var listDiscountDetail = component.get("v.listDiscountDetail");
    var currentLength = listOppLine.length;
    var loyaltyUpgrade = component.get("v.loyaltyUpgrade");
    component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
    var campaignObj = component.get("v.campaignObj");
    component.set("v.oppLineObj", {
      sobjectType: "OpportunityLineItem",
      OpportunityId: oppId,
      Product2: null,
      Product2Id: null,
      Line_Description2__c: null,
      UnitPrice: null,
      Product_Type__c: null
    });
    var bonusItem = component.get("v.oppLineObj");
    console.log("setting discount detail " + listDiscountDetail.length);
    var loyaltyObj = null;
    for (var idx in listDiscountDetail) {
      if (listDiscountDetail[idx].ProductReference != undefined) {
        // NEED TIER PRICING FOR ANY QUANTITY HERE : 21062018
        if (
          oppLineObj.Product2Id == listDiscountDetail[idx].ProductReference &&
          (listDiscountDetail[idx].IsAny ||
            (listDiscountDetail[idx].Quantity == 1 &&
              (listDiscountDetail[idx].Operator == "≥" ||
                listDiscountDetail[idx].Operator == "=")))
        ) {
          if (listDiscountDetail[idx].IsTier) {
            // Apply Tier Pricing if doesn't have quantity range (w/o condition)
            this.unitPriceAssignment(
              component,
              oppLineObj,
              listDiscountDetail[idx],
              listOppLine,
              currentLength
            );
          } else {
            // Apply Marketing Promo discount if discount doesn't have any criteria (w/o condition)
            //console.log('--discountAssignment called--'+oppLineObj.UnitPrice);
            this.discountAssignment(
              component,
              oppObj,
              oppLineObj,
              listDiscountDetail[idx],
              bonusItem,
              listOppLine,
              currentLength
            );
          }
        }
      } else if (
        listDiscountDetail[idx].IsLoyalty != undefined &&
        listDiscountDetail[idx].IsLoyalty &&
        oppLineObj.Product_Category__c == "Subscription"
      ) {
        // Apply loyalty discount if loyalty & product is subscription
        loyaltyObj = listDiscountDetail[idx];
      }
    }
    if (loyaltyObj != null) {
      oppLineObj.Discount_Reason__c = loyaltyObj.DiscountReason;
      oppLineObj.Discount__c = loyaltyObj.DiscountPercentage;
      oppLineObj.OriginDiscountPercentage = oppLineObj.Discount__c;
      oppLineObj.OriginDiscountAmount = null;
      oppLineObj.Discount_Amount__c = null;
      oppLineObj.Campaign__c = loyaltyObj.CampaignId;
      oppLineObj.Campaign__r = campaignObj;
      oppLineObj.Campaign__r.Name = loyaltyObj.Name;
    }
    listOppLine.push(oppLineObj);
    if (bonusItem.Product2Id != null && !returnBonusItem) {
      listOppLine.push(bonusItem);
    }
    component.set("v.listOppLine", listOppLine);
    component.set("v.sizeOppLineItem", listOppLine.length);

    if (returnBonusItem) {
      if (bonusItem.Product2Id != null) {
        return bonusItem;
      } else {
        return null;
      }
    }
  },
  setDiscountOnEdit: function(
    component,
    event,
    oppObj,
    listOppLine,
    oppLineIdx
  ) {
    var oppLineObj = listOppLine[oppLineIdx];
    var listDiscountDetail = component.get("v.listDiscountDetail");
    component.set("v.oppLineObj", {
      sobjectType: "OpportunityLineItem",
      Product2: null,
      Product2Id: null,
      Line_Description2__c: null,
      UnitPrice: null,
      Product_Type__c: null
    });
    var bonusItem = component.get("v.oppLineObj");
    var loyaltyUpgrade = component.get("v.loyaltyUpgrade");
    var isEligible = false;
    var loyaltyObj = null;
    component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
    var campaignObj = component.get("v.campaignObj");

    this.removeExistingDiscount(
      component,
      oppLineObj,
      listOppLine,
      oppLineIdx,
      null
    );
    this.removeExistingTierPricing(component, listOppLine[oppLineIdx]);
    for (var idx in listDiscountDetail) {
      if (listDiscountDetail[idx].ProductReference != undefined) {
        if (
          oppLineObj.Product2Id == listDiscountDetail[idx].ProductReference &&
          !listDiscountDetail[idx].IsAny
        ) {
          if (!listDiscountDetail[idx].IsTier) {
            if (
              listDiscountDetail[idx].Operator == ">" &&
              oppLineObj.Quantity > listDiscountDetail[idx].Quantity &&
              (listDiscountDetail[idx].MaxQuantity == undefined ||
                isNaN(listDiscountDetail[idx].MaxQuantity) ||
                (listDiscountDetail[idx].MaxQuantity != undefined &&
                  !isNaN(listDiscountDetail[idx].MaxQuantity) &&
                  oppLineObj.Quantity <= listDiscountDetail[idx].MaxQuantity))
            ) {
              isEligible = true;
              this.discountAssignment(
                component,
                oppObj,
                oppLineObj,
                listDiscountDetail[idx],
                bonusItem,
                listOppLine,
                oppLineIdx
              );
            } else if (
              listDiscountDetail[idx].Operator == "≥" &&
              oppLineObj.Quantity >= listDiscountDetail[idx].Quantity &&
              (listDiscountDetail[idx].MaxQuantity == undefined ||
                isNaN(listDiscountDetail[idx].MaxQuantity) ||
                (listDiscountDetail[idx].MaxQuantity != undefined &&
                  !isNaN(listDiscountDetail[idx].MaxQuantity) &&
                  oppLineObj.Quantity <= listDiscountDetail[idx].MaxQuantity))
            ) {
              isEligible = true;
              this.discountAssignment(
                component,
                oppObj,
                oppLineObj,
                listDiscountDetail[idx],
                bonusItem,
                listOppLine,
                oppLineIdx
              );
            } else if (
              listDiscountDetail[idx].Operator == "=" &&
              oppLineObj.Quantity == listDiscountDetail[idx].Quantity &&
              (listDiscountDetail[idx].MaxQuantity == undefined ||
                isNaN(listDiscountDetail[idx].MaxQuantity) ||
                (listDiscountDetail[idx].MaxQuantity != undefined &&
                  !isNaN(listDiscountDetail[idx].MaxQuantity) &&
                  oppLineObj.Quantity <= listDiscountDetail[idx].MaxQuantity))
            ) {
              isEligible = true;
              this.discountAssignment(
                component,
                oppObj,
                oppLineObj,
                listDiscountDetail[idx],
                bonusItem,
                listOppLine,
                oppLineIdx
              );
            }
          } else {
            // Only proceed Tier Pricing if no Promotion/Discount already applied previously.
            if (
              !isEligible &&
              (oppLineObj.Discount__c <= 0 || oppLineObj.Discount__c == null) &&
              (oppLineObj.Discount_Amount__c <= 0 ||
                oppLineObj.Discount_Amount__c == null)
            ) {
              if (
                oppLineObj.Quantity % listDiscountDetail[idx].Denomination !=
                0
              ) {
                // Only apply Tier Discount if Quantity is block of 100.
                this.removeExistingTierPricing(
                  component,
                  listOppLine[oppLineIdx]
                );
              } else if (
                listDiscountDetail[idx].MinQuantity != undefined &&
                listDiscountDetail[idx].MaxQuantity != undefined &&
                listDiscountDetail[idx].MinQuantity <= oppLineObj.Quantity &&
                oppLineObj.Quantity <= listDiscountDetail[idx].MaxQuantity
              ) {
                // Within particular range xxx - yyy
                isEligible = true;
                this.unitPriceAssignment(
                  component,
                  oppLineObj,
                  listDiscountDetail[idx],
                  listOppLine,
                  oppLineIdx
                );
              } else if (
                listDiscountDetail[idx].MinQuantity != undefined &&
                listDiscountDetail[idx].MaxQuantity == undefined &&
                listDiscountDetail[idx].MinQuantity <= oppLineObj.Quantity
              ) {
                // More than minimum range
                isEligible = true;
                this.unitPriceAssignment(
                  component,
                  oppLineObj,
                  listDiscountDetail[idx],
                  listOppLine,
                  oppLineIdx
                );
              } else if (
                listDiscountDetail[idx].MinQuantity == undefined &&
                listDiscountDetail[idx].MaxQuantity != undefined &&
                oppLineObj.Quantity <= listDiscountDetail[idx].MaxQuantity
              ) {
                // Less than maximum range
                isEligible = true;
                this.unitPriceAssignment(
                  component,
                  oppLineObj,
                  listDiscountDetail[idx],
                  listOppLine,
                  oppLineIdx
                );
              } else {
              }
            } else {
            }
          }
        } else if (
          oppLineObj.Product2Id == listDiscountDetail[idx].ProductReference &&
          listDiscountDetail[idx].IsAny
        ) {
          // Apply Marketing Promo discount if discount doesn't have any criteria (w/o condition)
          isEligible = true;
          this.discountAssignment(
            component,
            oppObj,
            oppLineObj,
            listDiscountDetail[idx],
            bonusItem,
            listOppLine,
            oppLineIdx
          );
        }
      } else if (
        listDiscountDetail[idx].IsLoyalty != undefined &&
        listDiscountDetail[idx].IsLoyalty &&
        oppLineObj.Product_Category__c == "Subscription"
      ) {
        // Apply loyalty discount if loyalty & product is subscription
        loyaltyObj = listDiscountDetail[idx];
      }
    }
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
    if (bonusItem.Product2Id != null) {
      listOppLine.push(bonusItem);
    }
    component.set("v.noRecalculate", true);
    this.calculateTotalPrice(
      component,
      event,
      listOppLine,
      oppLineIdx,
      listOppLine[oppLineIdx].Discount__c,
      listOppLine[oppLineIdx].Discount_Amount__c
    );
  },
  unitPriceAssignment: function(
    component,
    oppLineObj,
    rowDiscountDetail,
    listOppLine,
    oppLineIdx
  ) {
    if (rowDiscountDetail.renewalType != oppLineObj.Order_Type__c) return;

    component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
    var campaignObj = component.get("v.campaignObj");
    if (rowDiscountDetail.DiscountPercentage != undefined) {
      oppLineObj.UnitPrice =
        oppLineObj.Original_Price__c -
        (oppLineObj.Original_Price__c * rowDiscountDetail.DiscountPercentage) /
          100;
      oppLineObj.Discount_Remarks__c = "Tier Pricing";
      oppLineObj.Discount_Reason__c = null;
      oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      oppLineObj.Campaign__r = campaignObj;
      oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
    } else if (rowDiscountDetail.DiscountAmount != undefined) {
      oppLineObj.UnitPrice =
        oppLineObj.Original_Price__c - rowDiscountDetail.DiscountAmount;
      oppLineObj.Discount_Remarks__c = "Tier Pricing";
      oppLineObj.Discount_Reason__c = null;
      oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      oppLineObj.Campaign__r = campaignObj;
      oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
    } else if (rowDiscountDetail.DiscountUnitPrice != undefined) {
      oppLineObj.UnitPrice = rowDiscountDetail.DiscountUnitPrice;
      oppLineObj.Discount_Remarks__c = "Tier Pricing";
      oppLineObj.Discount_Reason__c = null;
      oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      oppLineObj.Campaign__r = campaignObj;
      oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
    }
  },
  discountAssignment: function(
    component,
    oppObj,
    oppLineObj,
    rowDiscountDetail,
    bonusItem,
    listOppLine,
    oppLineIdx
  ) {
    component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
    var campaignObj = component.get("v.campaignObj");

    // FOR RENEWAL PROMOTION MY
    if (
      rowDiscountDetail.recordType == "Renewal Promotion" &&
      oppObj.Order_Type_Clone__c == "Contract - Renewal" &&
      (oppLineObj.Order_Type__c == "Upgrade" ||
        oppLineObj.Order_Type__c == "Renew" ||
        oppLineObj.Order_Type__c == "Downgrade")
    ) {
      //Return if order type is not matched for renewal promotion
      if (rowDiscountDetail.renewalType != oppLineObj.Order_Type__c) {
        return;
      }

      this.removeExistingDiscount(
        component,
        oppLineObj,
        listOppLine,
        oppLineIdx,
        rowDiscountDetail
      );
      component.set("v.productObj", {
        sobjectType: "Product2",
        Name: null,
        Description: null,
        Product_Type__c: null
      });
      console.log(
        "--rowDiscountDetail.DiscountAmount--" +
          rowDiscountDetail.DiscountAmount
      );
      var productObj = component.get("v.productObj");
      oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
      oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      if (!$A.util.isUndefinedOrNull(rowDiscountDetail.Name)) {
        oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
      }
      if (!$A.util.isUndefinedOrNull(rowDiscountDetail.DiscountAmount)) {
        oppLineObj.OriginDiscountAmount = rowDiscountDetail.DiscountAmount;
      }
      if (!$A.util.isUndefinedOrNull(rowDiscountDetail.discount)) {
        oppLineObj.OriginDiscountPercentage = rowDiscountDetail.discount;
      }
      //oppLineObj.Discount_Amount__c = oppLineObj.UnitPrice-rowDiscountDetail.DiscountUnitPrice;
      //oppLineObj.UnitPrice = rowDiscountDetail.DiscountUnitPrice;
      oppLineObj.Discount_Amount__c = rowDiscountDetail.DiscountAmount;
      component.set("v.RenewDisValue", rowDiscountDetail.DiscountAmount);
      oppLineObj.Discount_Remarks__c = null;
      if (
        rowDiscountDetail.BonusQty != null &&
        rowDiscountDetail.BonusQty != undefined &&
        rowDiscountDetail.BonusQty > 0
      ) {
        bonusItem.Product2Id = rowDiscountDetail.BonusProduct;
        bonusItem.Product2 = productObj;
        bonusItem.Start_Date__c = oppLineObj.Start_Date__c;
        bonusItem.End_Date__c = oppLineObj.End_Date__c;
        bonusItem.PricebookEntryId = rowDiscountDetail.PricebookEntryId;
        bonusItem.Product2.Name = rowDiscountDetail.BonusProductName;
        if (rowDiscountDetail.ChildCategory != undefined) {
          bonusItem.Child_Category__c = rowDiscountDetail.ChildCategory;
        }
        bonusItem.Quantity = rowDiscountDetail.BonusQty;
        bonusItem.Discount__c = rowDiscountDetail.DiscountPercentage;
        bonusItem.UnitPrice = rowDiscountDetail.BonusPrice;
        bonusItem.Line_Description2__c = rowDiscountDetail.ProductDescription;
        bonusItem.Description = this.shortenDescription(
          bonusItem.Line_Description2__c
        );
        bonusItem.Product_Type__c = rowDiscountDetail.ProductType;
        bonusItem.Parent__c = oppLineIdx;
        if (rowDiscountDetail.TaxCode != null) {
          bonusItem.GST_VAT_Rate__c = rowDiscountDetail.TaxRate;
          bonusItem.GST_VAT_Code__c = rowDiscountDetail.TaxCode;
        } else {
          bonusItem.GST_VAT_Rate__c = 0;
          bonusItem.GST_VAT_Code__c = null;
        }
        bonusItem.PO__c = true;
        bonusItem.Complimentary__c = true;
        bonusItem.Amount__c = 0;
        bonusItem.Gross_Amount__c = 0;

        component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
        bonusItem.Campaign__c = rowDiscountDetail.CampaignId;
        bonusItem.Campaign__r = component.get("v.campaignObj");
        bonusItem.Campaign__r.Name = rowDiscountDetail.Name;
        bonusItem.Discount_Reason__c =
          rowDiscountDetail.DiscountReasonChild != null &&
          rowDiscountDetail.DiscountReasonChild != undefined
            ? rowDiscountDetail.DiscountReasonChild
            : rowDiscountDetail.DiscountReason;
      }
    } else if (rowDiscountDetail.recordType == "First-Timer Winback") {
      // For First-Timer Winback
      this.removeExistingDiscount(
        component,
        oppLineObj,
        listOppLine,
        oppLineIdx,
        rowDiscountDetail
      );
      component.set("v.productObj", {
        sobjectType: "Product2",
        Name: null,
        Description: null,
        Product_Type__c: null
      });

      var productObj = component.get("v.productObj");
      component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
      oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
      oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      oppLineObj.Campaign__r = component.get("v.campaignObj");
      oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
      oppLineObj.Discount_Remarks__c = null;
      oppLineObj.Discount_Amount__c = rowDiscountDetail.DiscountAmount;
      oppLineObj.OriginDiscountAmount = rowDiscountDetail.DiscountAmount;

      if (
        rowDiscountDetail.BonusQty != null &&
        rowDiscountDetail.BonusQty != undefined &&
        rowDiscountDetail.BonusQty > 0
      ) {
        bonusItem.Product2Id = rowDiscountDetail.BonusProduct;
        bonusItem.Product2 = productObj;
        bonusItem.Start_Date__c = oppLineObj.Start_Date__c;
        bonusItem.End_Date__c = oppLineObj.End_Date__c;
        bonusItem.PricebookEntryId = rowDiscountDetail.PricebookEntryId;
        bonusItem.Product2.Name = rowDiscountDetail.BonusProductName;
        if (rowDiscountDetail.ChildCategory != undefined) {
          bonusItem.Child_Category__c = rowDiscountDetail.ChildCategory;
        }
        bonusItem.Quantity = rowDiscountDetail.BonusQty;
        bonusItem.Discount__c = 100;
        bonusItem.UnitPrice = rowDiscountDetail.BonusPrice;
        bonusItem.Line_Description2__c = rowDiscountDetail.ProductDescription;
        bonusItem.Description = this.shortenDescription(
          bonusItem.Line_Description2__c
        );
        bonusItem.Product_Type__c = rowDiscountDetail.ProductType;
        bonusItem.Parent__c = oppLineIdx;
        if (rowDiscountDetail.TaxCode != null) {
          bonusItem.GST_VAT_Rate__c = rowDiscountDetail.TaxRate;
          bonusItem.GST_VAT_Code__c = rowDiscountDetail.TaxCode;
        } else {
          bonusItem.GST_VAT_Rate__c = 0;
          bonusItem.GST_VAT_Code__c = null;
        }
        bonusItem.PO__c = true;
        bonusItem.Complimentary__c = true;
        bonusItem.Amount__c = 0;
        bonusItem.Gross_Amount__c = 0;

        bonusItem.Campaign__c = rowDiscountDetail.CampaignId;
        bonusItem.Campaign__r = component.get("v.campaignObj");
        bonusItem.Campaign__r.Name = rowDiscountDetail.Name;
        bonusItem.Discount_Reason__c = rowDiscountDetail.DiscountReason;
      }
    } else if (
      rowDiscountDetail.DiscountPercentage != undefined &&
      rowDiscountDetail.BonusProduct == undefined
    ) {
      this.removeExistingDiscount(
        component,
        oppLineObj,
        listOppLine,
        oppLineIdx,
        rowDiscountDetail
      );
      oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
      oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
      if (
        (oppLineObj.Pro_Rate_Amount__c == null ||
          oppLineObj.Pro_Rate_Amount__c == undefined ||
          oppLineObj.Pro_Rate_Amount__c == 0) &&
        oppLineObj.Discount_Remarks__c != undefined &&
        oppLineObj.Discount_Remarks__c != null &&
        oppLineObj.Discount_Remarks__c.indexOf("Pro Rated Amount") == -1
      ) {
        oppLineObj.Discount_Remarks__c = null;
      }
      oppLineObj.OriginDiscountPercentage =
        rowDiscountDetail.DiscountPercentage;
      oppLineObj.Discount__c = rowDiscountDetail.DiscountPercentage;
      oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      if (rowDiscountDetail.DiscountReason == "Marketing Promo") {
        oppLineObj.Campaign__r = campaignObj;
        oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
      }
    } else if (
      rowDiscountDetail.DiscountAmount != undefined &&
      rowDiscountDetail.BonusProduct == undefined
    ) {
      this.removeExistingDiscount(
        component,
        oppLineObj,
        listOppLine,
        oppLineIdx,
        rowDiscountDetail
      );
      oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
      oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
      if (
        (oppLineObj.Pro_Rate_Amount__c == null ||
          oppLineObj.Pro_Rate_Amount__c == undefined ||
          oppLineObj.Pro_Rate_Amount__c == 0) &&
        oppLineObj.Discount_Remarks__c != undefined &&
        oppLineObj.Discount_Remarks__c != null &&
        oppLineObj.Discount_Remarks__c.indexOf("Pro Rated Amount") == -1
      ) {
        oppLineObj.Discount_Remarks__c = null;
      }
      oppLineObj.OriginDiscountAmount = rowDiscountDetail.DiscountAmount;
      oppLineObj.Discount_Amount__c = rowDiscountDetail.DiscountAmount;
      oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      if (rowDiscountDetail.DiscountReason == "Marketing Promo") {
        oppLineObj.Campaign__r = campaignObj;
        oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
      }
    } else if (
      rowDiscountDetail.DiscountUnitPrice != undefined &&
      rowDiscountDetail.BonusProduct == undefined
    ) {
      this.removeExistingDiscount(
        component,
        oppLineObj,
        listOppLine,
        oppLineIdx,
        rowDiscountDetail
      );
      oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
      oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
      if (
        (oppLineObj.Pro_Rate_Amount__c == null ||
          oppLineObj.Pro_Rate_Amount__c == undefined ||
          oppLineObj.Pro_Rate_Amount__c == 0) &&
        oppLineObj.Discount_Remarks__c != undefined &&
        oppLineObj.Discount_Remarks__c != null &&
        oppLineObj.Discount_Remarks__c.indexOf("Pro Rated Amount") == -1
      ) {
        oppLineObj.Discount_Remarks__c = null;
      }
      oppLineObj.UnitPrice = rowDiscountDetail.DiscountUnitPrice;
      oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      if (rowDiscountDetail.DiscountReason == "Marketing Promo") {
        oppLineObj.Campaign__r = campaignObj;
        oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;
      }
    } else if (
      rowDiscountDetail.BonusProduct != undefined &&
      rowDiscountDetail.BonusQty != undefined
    ) {
      this.removeExistingDiscount(
        component,
        oppLineObj,
        listOppLine,
        oppLineIdx,
        rowDiscountDetail
      );
      component.set("v.productObj", {
        sobjectType: "Product2",
        Name: null,
        Description: null,
        Product_Type__c: null
      });
      var productObj = component.get("v.productObj");
      if (rowDiscountDetail.DiscountReason != "Agent Referral: Referee") {
        oppLineObj.Discount_Reason__c = rowDiscountDetail.DiscountReason;
        oppLineObj.Campaign__c = rowDiscountDetail.CampaignId;
      }
      oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
      if (
        (oppLineObj.Pro_Rate_Amount__c == null ||
          oppLineObj.Pro_Rate_Amount__c == undefined ||
          oppLineObj.Pro_Rate_Amount__c == 0) &&
        oppLineObj.Discount_Remarks__c != undefined &&
        oppLineObj.Discount_Remarks__c != null &&
        oppLineObj.Discount_Remarks__c.indexOf("Pro Rated Amount") == -1
      ) {
        oppLineObj.Discount_Remarks__c = null;
      }
      bonusItem.Product2Id = rowDiscountDetail.BonusProduct;
      bonusItem.Product2 = productObj;
      bonusItem.Start_Date__c = oppLineObj.Start_Date__c;
      bonusItem.End_Date__c = oppLineObj.End_Date__c;
      bonusItem.PricebookEntryId = rowDiscountDetail.PricebookEntryId;
      bonusItem.Product2.Name = rowDiscountDetail.BonusProductName;
      if (rowDiscountDetail.ChildCategory != undefined) {
        bonusItem.Child_Category__c = rowDiscountDetail.ChildCategory;
      }
      bonusItem.Quantity = rowDiscountDetail.BonusQty;
      bonusItem.Discount__c = rowDiscountDetail.DiscountPercentage;
      bonusItem.UnitPrice = rowDiscountDetail.BonusPrice;
      bonusItem.Line_Description2__c = rowDiscountDetail.ProductDescription;
      bonusItem.Description = this.shortenDescription(
        bonusItem.Line_Description2__c
      );
      bonusItem.Product_Type__c = rowDiscountDetail.ProductType;
      bonusItem.Parent__c = oppLineIdx;
      if (rowDiscountDetail.TaxCode != null) {
        bonusItem.GST_VAT_Rate__c = rowDiscountDetail.TaxRate;
        bonusItem.GST_VAT_Code__c = rowDiscountDetail.TaxCode;
      } else {
        bonusItem.GST_VAT_Rate__c = 0;
        bonusItem.GST_VAT_Code__c = null;
      }
      bonusItem.PO__c = true;
      bonusItem.Complimentary__c = true;
      if (
        rowDiscountDetail.DiscountReason == "Marketing Promo" ||
        rowDiscountDetail.DiscountReason == "Agent Referral: Referee"
      ) {
        component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
        oppLineObj.Campaign__r = component.get("v.campaignObj");
        oppLineObj.Campaign__r.Name = rowDiscountDetail.Name;

        bonusItem.Campaign__c = rowDiscountDetail.CampaignId;
        bonusItem.Campaign__r = component.get("v.campaignObj");
        bonusItem.Campaign__r.Name = rowDiscountDetail.Name;
        bonusItem.Discount_Reason__c = rowDiscountDetail.DiscountReason;
      }
    }
  },
  removeExistingTierPricing: function(component, oppLineObj) {
    oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
    if (
      (oppLineObj.Pro_Rate_Amount__c == null ||
        oppLineObj.Pro_Rate_Amount__c == undefined ||
        oppLineObj.Pro_Rate_Amount__c == 0) &&
      oppLineObj.Discount_Remarks__c != undefined &&
      oppLineObj.Discount_Remarks__c != null &&
      oppLineObj.Discount_Remarks__c.indexOf("Pro Rated Amount") == -1
    ) {
      oppLineObj.Discount_Remarks__c = null;
    }
    oppLineObj.Campaign__c = null;
  },
  removeExistingDiscount: function(
    component,
    oppLineObj,
    listOppLine,
    oppLineIdx,
    rowDiscountDetail
  ) {
    component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
    oppLineObj.Campaign__r = component.get("v.campaignObj");
    oppLineObj.Campaign__c = null;
    oppLineObj.UnitPrice = oppLineObj.Original_Price__c;
    oppLineObj.OriginDiscountPercentage = null;
    oppLineObj.OriginDiscountAmount = null;
    oppLineObj.Discount_Reason__c = null;

    if (
      (oppLineObj.Pro_Rate_Amount__c == null ||
        oppLineObj.Pro_Rate_Amount__c == undefined ||
        oppLineObj.Pro_Rate_Amount__c == 0) &&
      oppLineObj.Discount_Remarks__c != undefined &&
      oppLineObj.Discount_Remarks__c != null &&
      oppLineObj.Discount_Remarks__c.indexOf("Pro Rated Amount") == -1
    ) {
      oppLineObj.Discount_Remarks__c = null;
    }
    oppLineObj.Discount_Amount__c = null;
    oppLineObj.Discount__c = null;
    if (
      rowDiscountDetail != null &&
      rowDiscountDetail.DiscountPercentage != undefined
    ) {
    } else if (
      rowDiscountDetail != null &&
      rowDiscountDetail.DiscountAmount != undefined
    ) {
    }
    var listRemoveChild = this.removeChildren(
      component,
      listOppLine,
      oppLineObj,
      oppLineIdx
    );

    if (listRemoveChild.length > 0) {
      listOppLine = component.get("v.listOppLine");
      for (var idx in listRemoveChild) {
        if (
          listOppLine[listRemoveChild[idx]] != undefined &&
          listOppLine[listRemoveChild[idx]].Child_Category__c !== "Package"
        ) {
          if (
            listOppLine[listRemoveChild[idx]].Parent__c ===
              listOppLine[listRemoveChild[idx]].Id ||
            listOppLine[listRemoveChild[idx]].Parent__c === undefined ||
            listOppLine[listRemoveChild[idx]].Parent__c === null ||
            listOppLine[listRemoveChild[idx]].Parent__c === ""
          ) {
            listOppLine[listRemoveChild[idx]].Parent__c = null;
          } else {
            listOppLine.splice(listRemoveChild[idx], 1);
          }
        }
      }
    }
  },
  removeChildrenAct: function(component, listOppLine, idxSrc) {
    for (var idx = listOppLine.length - 1; idx >= 0; idx--) {
      if (
        listOppLine[idx] !== undefined &&
        listOppLine[idx].Child_Category__c !== "Package"
      ) {
        if (
          listOppLine[idx].Parent__c === listOppLine[idx].Id ||
          listOppLine[idx].Parent__c === undefined ||
          listOppLine[idx].Parent__c === null ||
          listOppLine[idx].Parent__c === ""
        ) {
          listOppLine[idx].Parent__c = null;
        } else if (
          listOppLine[idx].Parent__c == listOppLine[idxSrc].Id ||
          listOppLine[idx].Parent__c == idxSrc
        ) {
          listOppLine.splice(idx, 1);
        }
      }
    }
    setTimeout(function() {
      component.set("v.listOppLine", null);
      component.set("v.listOppLine", listOppLine);
      component.set("v.sizeOppLineItem", listOppLine.length);
    }, 300);
  },
  removeChildren: function(component, listOppLine, oppLine, oppLineIdx) {
    var listOppLineDelete = component.get("v.listOppLineDelete");
    var listRemove = [];
    for (var idx = listOppLine.length - 1; idx >= 0; idx--) {
      if (
        listOppLine[idx].Parent__c != undefined &&
        listOppLine[idx].Parent__c != null &&
        ((isNaN(listOppLine[idx].Parent__c) &&
          listOppLine[idx].Parent__c == oppLine.Id) ||
          listOppLine[idx].Parent__c == oppLineIdx)
      ) {
        if (listOppLine[idx].Id != undefined) {
          // Only add to list for deletion if particular OpportunityLineItem has Id.
          listOppLineDelete.push(listOppLine[idx]);
        }
        if (idx < listOppLine.length - 1) {
          // Only proceed adjust parent index if rowIndex < listOppLine.length-1
          this.adjustParentIndex(component, listOppLine, idx);
        }
        listRemove.push(idx);
      }
    }
    if (listRemove.length > 0) {
      component.set("v.listOppLineDelete", listOppLineDelete);
    }
    return listRemove;
  },
  submitForm: function(component, event) {
    var alertMsg = component.find("errorAlert");
    var saveBtn = component.find("saveBtn");
    $A.util.addClass(alertMsg, "slds-hide");
    var oppObj = component.get("v.oppObj");
    var listOppLine = component.get("v.listOppLine");
    var listOppLineDelete = component.get("v.listOppLineDelete");
    var saveForm = component.get("c.saveForm");
    var msg = "";
    var errors = [];
    if (listOppLine != null && listOppLine.length > 0) {
      if (this.validateFields(component, listOppLine)) {
        var list = [];
        var msg = "";
        for (var i in listOppLine) {
          if (!isNaN(listOppLine[i].Parent__c)) {
            listOppLine[i].Parent__c = listOppLine[i].Parent__c + "";
          }
          listOppLine[i].sobjectType = "OpportunityLineItem";
        }

        saveForm.setParams({
          opp: oppObj,
          listOppLine: listOppLine,
          listOppLineDelete: listOppLineDelete
        });
        saveForm.setCallback(this, function(response) {
          if (response.getState() === "SUCCESS") {
            var result = response.getReturnValue();
            var sNO;
            for (var idx in result) {
              result[idx].Product2 = listOppLine[idx].Product2;
              result[idx].Product2.Name = listOppLine[idx].Product2.Name;
              result[idx].Campaign__r = listOppLine[idx].Campaign__r;
              if (result[idx].Campaign__r != null) {
                result[idx].Campaign__r.Name =
                  listOppLine[idx].Campaign__r.Name;
              }
              result[idx].OriginDiscountPercentage = result[idx].Discount__c;
              result[idx].OriginDiscountAmount = result[idx].Discount_Amount__c;
              result[idx].OldStartDate = result[idx].Start_Date__c;
              result[idx].OldEndDate = result[idx].End_Date__c;
              sNO = result[idx].SNo__c;
              result[idx].toCheckWholeNo = sNO != Math.floor(sNO);
            }
            component.set("v.listOppLine", result);
            if (listOppLine.length > 1) {
              msg = "Products have been saved successfuly.";
            } else {
              msg = "Product has been saved successfuly.";
            }
            component.set("v.listOppLineDelete", []);
            $A.get("e.force:refreshView").fire();
            alert(msg);
            component.set("v.Spinner", false);
          } else {
            errors = response.getError();
            for (var i in errors) {
              msg += "<li>" + errors[i].message + "</li>";
            }
            component.set("v.error", "<ul>" + msg + "</ul>");
            $A.util.removeClass(alertMsg, "slds-hide");
            component.set("v.Spinner", false);
            $A.get("e.force:refreshView").fire();
          }
        });
        $A.enqueueAction(saveForm);
      }
    } else {
      alert("Please add at least 1 product.");
    }
    component.set("v.Spinner", false);
    saveBtn.set("v.disabled", false);
    setTimeout(function() {
      component.set("v.Spinner", false);
    }, 3000);
  },
  validateFields: function(component, listOppLine) {
    var listRequired = [
      "oppStartDate",
      "oppEndDate",
      "oppQuantity",
      "oppUnitPrice"
    ];
    var discountReason = component.find("discountReason");
    var startDateField = component.find("oppStartDate");
    var endDateField = component.find("oppEndDate");
    var oppObj = component.get("v.oppObj");
    var EligibleVip = component.get("v.EligibleVip");
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
      "Renewal Bonus": true
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

    if (Array.isArray(discountReason)) {
      for (var oppLineIdx in listOppLine) {
        productName = listOppLine[oppLineIdx].Product2.Name;
        for (var idx in listRequired) {
          currField = component.find(listRequired[idx]);
          if (
            !currField[oppLineIdx].get("v.value") &&
            currField[oppLineIdx].get("v.required")
          ) {
            currField[oppLineIdx].set("v.errors", [
              { message: "Field is required" }
            ]);
            result &= false;
          } else {
            currField[oppLineIdx].set("v.errors", null);
          }
        }

        discountReasonValue = discountReason[oppLineIdx].get("v.value");
        if (
          !discountReasonValue &&
          ((!isNaN(listOppLine[oppLineIdx].Discount__c) &&
            listOppLine[oppLineIdx].Discount__c > 0) ||
            (!isNaN(listOppLine[oppLineIdx].Discount_Amount__c) &&
              listOppLine[oppLineIdx].Discount_Amount__c > 0))
        ) {
          discountReason[oppLineIdx].set("v.errors", [
            { message: "Discount Reason is mandatory" }
          ]);
          result &= false;
        } else if (
          discountReasonValue == "Marketing Promo" &&
          (listOppLine[oppLineIdx].Campaign__c == null ||
            listOppLine[oppLineIdx].Campaign__c == undefined)
        ) {
          discountReason[oppLineIdx].set("v.errors", [
            { message: "Invalid Reason" }
          ]);
          result &= false;
        } else if (
          discountReasonValue == "Loyalty Discount" &&
          (listOppLine[oppLineIdx].Campaign__c == null ||
            listOppLine[oppLineIdx].Campaign__c == undefined)
        ) {
          discountReason[oppLineIdx].set("v.errors", [
            { message: "Invalid Reason" }
          ]);
          result &= false;
        } else if (
          discountReasonValue == "Managerial Discount" &&
          listOppLine[oppLineIdx].Amount__c == 0
        ) {
          discountReason[oppLineIdx].set("v.errors", [
            { message: "Managerial Discount cannot have 100% discount." }
          ]);
          result &= false;
        } else if (
          discountReasonValue == "First-Timer Discount" &&
          (listOppLine[oppLineIdx].Campaign__c == null ||
            listOppLine[oppLineIdx].Campaign__c == undefined)
        ) {
          discountReason[oppLineIdx].set("v.errors", [
            { message: "Invalid Reason" }
          ]);
          result &= false;
        } else if (
          discountReasonValue == "Agent Referral: Referee" &&
          (listOppLine[oppLineIdx].Campaign__c == null ||
            listOppLine[oppLineIdx].Campaign__c == undefined)
        ) {
          discountReason[oppLineIdx].set("v.errors", [
            { message: "Agent not eligible for Referral Entitlement" }
          ]);
          result &= false;
        } else if (
          discountReasonValue != null &&
          discountReasonValue != undefined &&
          discountReasonValue != "" &&
          listDiscountReasonNot100[discountReasonValue] == undefined &&
          listOppLine[oppLineIdx].Amount__c > 0
        ) {
          discountReason[oppLineIdx].set("v.errors", [
            { message: "Selected Discount Reason must have 100% Discount" }
          ]);
          result &= false;
        } else {
          discountReason[oppLineIdx].set("v.errors", null);
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
          alert(
            "Cannot have both VIP & Managerial Discount Reason at once. Please separate into different Opportunity."
          );
          result &= false;
        } else if (hasFoc && hasManagerial) {
          alert(
            "Cannot have both FOC & Managerial Discount Reason at once. Please separate into different Opportunity."
          );
          result &= false;
        }

        rowResult = this.proceedValidateStartEndDate(
          startDateField[oppLineIdx].get("v.value"),
          endDateField[oppLineIdx].get("v.value"),
          oppObj,
          listOppLine[oppLineIdx]
        );
        if (!rowResult.result) {
          result &= false;
          startDateField[oppLineIdx].set(
            "v.errors",
            rowResult.startDateMessage == null
              ? null
              : [{ message: rowResult.startDateMessage }]
          );
          endDateField[oppLineIdx].set(
            "v.errors",
            rowResult.endDateMessage == null
              ? null
              : [{ message: rowResult.endDateMessage }]
          );
        } else {
          startDateField[oppLineIdx].set("v.errors", null);
          endDateField[oppLineIdx].set("v.errors", null);
        }
      }
    } else {
      for (var idx in listRequired) {
        currField = component.find(listRequired[idx]);
        if (!currField.get("v.value") && currField.get("v.required")) {
          currField.set("v.errors", [{ message: "Field is required" }]);
          result &= false;
        } else {
          currField.set("v.errors", null);
        }
      }

      discountReasonValue = discountReason.get("v.value");
      if (
        !discountReasonValue &&
        ((!isNaN(listOppLine[0].Discount__c) &&
          listOppLine[0].Discount__c > 0) ||
          (!isNaN(listOppLine[0].Discount_Amount__c) &&
            listOppLine[0].Discount_Amount__c > 0))
      ) {
        discountReason.set("v.errors", [
          { message: "Discount Reason is mandatory" }
        ]);
        result &= false;
      } else if (
        discountReasonValue == "Marketing Promo" &&
        (listOppLine[0].Campaign__c == null ||
          listOppLine[0].Campaign__c == undefined)
      ) {
        discountReason.set("v.errors", [{ message: "Invalid Reason" }]);
        result &= false;
      } else if (
        discountReasonValue == "Loyalty Discount" &&
        (listOppLine[0].Campaign__c == null ||
          listOppLine[0].Campaign__c == undefined)
      ) {
        discountReason.set("v.errors", [{ message: "Invalid Reason" }]);
        result &= false;
      } else if (
        discountReasonValue == "Managerial Discount" &&
        listOppLine[0].Amount__c == 0
      ) {
        discountReason.set("v.errors", [
          { message: "Managerial Discount cannot have 100% discount." }
        ]);
        result &= false;
      } else if (
        discountReasonValue == "First-Timer Discount" &&
        (listOppLine[0].Campaign__c == null ||
          listOppLine[0].Campaign__c == undefined)
      ) {
        discountReason.set("v.errors", [{ message: "Invalid Reason" }]);
        result &= false;
      } else if (
        discountReasonValue == "Agent Referral: Referee" &&
        (listOppLine[0].Campaign__c == null ||
          listOppLine[0].Campaign__c == undefined)
      ) {
        discountReason.set("v.errors", [
          { message: "Agent not eligible for Referral Entitlement" }
        ]);
        result &= false;
      } else if (
        discountReasonValue != null &&
        discountReasonValue != "" &&
        discountReasonValue != undefined &&
        listDiscountReasonNot100[discountReasonValue] == undefined &&
        listOppLine[0].Amount__c > 0
      ) {
        discountReason.set("v.errors", [
          { message: "Selected Discount Reason must have 100% Discount" }
        ]);
        result &= false;
      } else {
        discountReason.set("v.errors", null);
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
        alert(
          "Cannot have both VIP & Managerial Discount Reason at once. Please separate into different Opportunity."
        );
        result &= false;
      } else if (hasFoc && hasManagerial) {
        alert(
          "Cannot have both FOC & Managerial Discount Reason at once. Please separate into different Opportunity."
        );
        result &= false;
      }

      rowResult = this.proceedValidateStartEndDate(
        startDateField.get("v.value"),
        endDateField.get("v.value"),
        oppObj,
        listOppLine[0]
      );
      if (!rowResult.result) {
        result &= false;
        startDateField.set(
          "v.errors",
          rowResult.startDateMessage == null
            ? null
            : [{ message: rowResult.startDateMessage }]
        );
        endDateField.set(
          "v.errors",
          rowResult.endDateMessage == null
            ? null
            : [{ message: rowResult.endDateMessage }]
        );
      } else {
        startDateField.set("v.errors", null);
        endDateField.set("v.errors", null);
      }
    }
    return result;
  },
  proceedValidateStartEndDate: function(
    startDate,
    endDate,
    oppObj,
    oppLineItem
  ) {
    var result = true,
      startDateMessage = null,
      endDateMessage = null;
    if (!oppLineItem.Complimentary__c) {
      if (startDate == null) {
        result &= false;
        startDateMessage = "Start Date cannot be empty";
      }
      if (endDate == null) {
        result &= false;
        endDateMessage = "End Date cannot be empty";
      }
      if (oppObj.Order_Type_Clone__c == "Contract - Upgrade") {
        var strtDate = new Date(startDate);
        var EndDate = new Date(endDate);
        strtDate = strtDate.toISOString().substring(0, 10);
        EndDate = EndDate.toISOString().substring(0, 10);
        var ostrtDate = new Date(oppLineItem.OldStartDate);
        var oEndDate = new Date(oppLineItem.OldEndDate);
        ostrtDate = ostrtDate.toISOString().substring(0, 10);
        oEndDate = oEndDate.toISOString().substring(0, 10);

        if (strtDate != ostrtDate) {
          result &= false;
          startDateMessage =
            "Modification of Start Date Field of an Upgrade Opportunity is not allowed.";
        }
        if (EndDate != oEndDate) {
          if (strtDate == ostrtDate) {
            if (oppObj.Country__c == "Malaysia") {
              if (oppLineItem.Product_Category__c == "Subscription") {
                result &= false;
                endDateMessage =
                  "Modification of End Date Field of an MY Upgrade Opportunity is not allowed";
              }
            }
          }
        }
      }
      if (result) {
        var x = new Date(startDate).getTime();
        var y = new Date(endDate).getTime();
        var today = new Date(this.getToday()).getTime();

        var timeDiff = Math.abs(x - today);
        var diffDays = Math.ceil(timeDiff / (1000 * 3600 * 24));
        var startEndDiff = Math.ceil(Math.abs(y - x) / (1000 * 3600 * 24));
        
        if (x < today) {
          result &= false;
          startDateMessage = "Start Date cannot be in the past.";
        } else if (
          /* 30 days validation removed because of ORION-224*/
          startEndDiff > 365 ||
          (startEndDiff == 365 &&
            startDate.substring(4) == endDate.substring(4))
        ) {
          /*
           * PTYG01T-8 : Salesforce Standard Validation Rule causing issue, datepicker not working
           * Move the validation rule here.
           */
          result &= false;
          endDateMessage =
            "Start Date and End Date difference cannot be more than 12 months.";
        }

        if (y <= x) {
          result &= false;
          endDateMessage = "End Date must be after Start Date.";
        }
      }
    }
    return {
      result: result,
      startDateMessage: startDateMessage,
      endDateMessage: endDateMessage
    };
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
  getNextYear: function(today) {
    today = today.split("-");
    // Please pay attention to the month (parts[1]); JavaScript counts months from 0:
    // January - 0, February - 1, etc.
    var todayDate = new Date(today[0], today[1] - 1, today[2]);

    var yesterday = new Date(todayDate);
    yesterday.setDate(todayDate.getDate() - 1); //setDate also supports negative values, which cause the month to rollover.

    var nextYear = new Date(yesterday.setFullYear(yesterday.getFullYear() + 1)); //new Date(new Date().setFullYear(new Date().getFullYear() + 1));
    var dd = nextYear.getDate();
    var mm = nextYear.getMonth() + 1; //January is 0!
    var yyyy = nextYear.getFullYear();

    if (dd < 10) {
      dd = "0" + dd;
    }

    if (mm < 10) {
      mm = "0" + mm;
    }

    nextYear = yyyy + "-" + mm + "-" + dd;
    return nextYear;
  },
  getNextDay: function(today) {
    today = today.split("-");
    var todayDate = new Date(today[0], today[1] - 1, today[2]);

    var tomorrow = new Date(todayDate);
    tomorrow.setDate(todayDate.getDate() + 1);
    var dd = tomorrow.getDate();
    var mm = tomorrow.getMonth() + 1; //January is 0!
    var yyyy = tomorrow.getFullYear();

    if (dd < 10) {
      dd = "0" + dd;
    }

    if (mm < 10) {
      mm = "0" + mm;
    }

    tomorrow = yyyy + "-" + mm + "-" + dd;
    return tomorrow;
  },
  getPrevYear: function(today) {
    today = today.split("-");
    // Please pay attention to the month (parts[1]); JavaScript counts months from 0:
    // January - 0, February - 1, etc.
    var todayDate = new Date(today[0], today[1] - 1, today[2]);

    var tomorrow = new Date(todayDate);
    tomorrow.setDate(todayDate.getDate() + 1); //setDate also supports negative values, which cause the month to rollover.

    var prevYear = new Date(tomorrow.setFullYear(tomorrow.getFullYear() - 1)); //new Date(new Date().setFullYear(new Date().getFullYear() + 1));
    var dd = prevYear.getDate();
    var mm = prevYear.getMonth() + 1; //January is 0!
    var yyyy = prevYear.getFullYear();

    if (dd < 10) {
      dd = "0" + dd;
    }

    if (mm < 10) {
      mm = "0" + mm;
    }

    prevYear = yyyy + "-" + mm + "-" + dd;
    return prevYear;
  },
  adjustParentIndex: function(component, listOppLine, rowIndex) {
    var tmpIdx;
    for (var idx = listOppLine.length - 1; idx > rowIndex; idx--) {
      if (
        listOppLine[idx].Parent__c != undefined &&
        !isNaN(listOppLine[idx].Parent__c)
      ) {
        tmpIdx = listOppLine[idx].Parent__c * 1;
        if (tmpIdx > rowIndex) {
          listOppLine[idx].Parent__c = --tmpIdx;
        }
      }
    }
  },
  validateDuplicate: function(component, listOppLine, product2Id) {
    for (var idx in listOppLine) {
      if (
        listOppLine[idx].Parent__c == undefined &&
        listOppLine[idx].Product2Id == product2Id
      ) {
        alert(listOppLine[idx].Product2.Name + " is already selected.");
        return false;
      }
    }
    return true;
  },
  calculateTotalPrice: function(
    component,
    event,
    listOppLine,
    idx,
    discount,
    discountAmount
  ) {
    var unitPrice =
      listOppLine[idx].UnitPrice == null ? 0 : listOppLine[idx].UnitPrice;
    var quantity =
      listOppLine[idx].Quantity == null ? 0 : listOppLine[idx].Quantity;
    var complimentary = listOppLine[idx].Complimentary__c;
    var totalPrice = unitPrice * quantity;
    var oppObj = component.get("v.oppObj");
    var RenewDis = component.get("v.RenewDisValue");
    discount = discount == undefined ? null : discount;
    discountAmount = discountAmount == undefined ? null : discountAmount;
    var discountedAmount =
      discount != null
        ? (unitPrice * quantity * discount) / 100
        : discountAmount;
    var noRecalculate = component.get("v.noRecalculate");

    console.log("--RenewDis--" + RenewDis);
    console.log("--discountAmount--" + discountAmount);
    if (discount == 0) {
      listOppLine[idx].Discount__c = null;
    }
    if (discountAmount == 0) {
      listOppLine[idx].Discount_Amount__c = null;
    }
    if (
      listOppLine[idx].Parent__c == "null" ||
      listOppLine[idx].Parent__c == null
    ) {
      listOppLine[idx].Parent__c = null;
    }

    console.log(
      'component.get("v.resetAllRelatedBonus"):' +
        component.get("v.resetAllRelatedBonus")
    );
    if (component.get("v.resetAllRelatedBonus")) {
      console.log("false tapi masuk");
      component.set("v.resetAllRelatedBonus", false);
      component.set("v.campaignObj", { sobjectType: "Campaign", Name: null });
      listOppLine[idx].Campaign__r = component.get("v.campaignObj");
      listOppLine[idx].OriginDiscountPercentage = null;
      listOppLine[idx].OriginDiscountAmount = null;
      listOppLine[idx].Campaign__c = null;
      // PTYG01T-20: Changing discount manually is not reset Tier Price to Unit Price
      // listOppLine[idx].UnitPrice = listOppLine[idx].Original_Price__c;
      if (
        (listOppLine[idx].Pro_Rate_Amount__c == null ||
          listOppLine[idx].Pro_Rate_Amount__c == undefined ||
          listOppLine[idx].Pro_Rate_Amount__c == 0) &&
        listOppLine[idx].Discount_Remarks__c != undefined &&
        listOppLine[idx].Discount_Remarks__c != null &&
        listOppLine[idx].Discount_Remarks__c.indexOf("Pro Rated Amount") == -1
      ) {
        listOppLine[idx].Discount_Remarks__c = null;
      }
      unitPrice = listOppLine[idx].UnitPrice;
      discountedAmount =
        discount != null
          ? (unitPrice * quantity * discount) / 100
          : discountAmount;
      totalPrice = unitPrice * quantity;
      listOppLine[idx].Amount__c =
        totalPrice -
        (isNaN(discountedAmount) ? 0 : discountedAmount) -
        (isNaN(listOppLine[idx].Pro_Rate_Amount__c)
          ? 0
          : totalPrice - (isNaN(discountedAmount) ? 0 : discountedAmount) >=
            listOppLine[idx].Pro_Rate_Amount__c
          ? listOppLine[idx].Pro_Rate_Amount__c
          : totalPrice - (isNaN(discountedAmount) ? 0 : discountedAmount));
      if (
        (discount == 0 || discount == null) &&
        discountAmount != 0 &&
        discountAmount != null
      ) {
        if (listOppLine[idx].Amount__c > 0) {
          listOppLine[idx].Discount_Reason__c = "Managerial Discount";
        }
        listOppLine[idx].Discount__c = null;
        listOppLine[idx].OriginDiscountPercentage = null;
        listOppLine[idx].OriginDiscountAmount =
          listOppLine[idx].Discount_Amount__c;
      } else if (
        discount != 0 &&
        discount != null &&
        (discountAmount == 0 || discountAmount == null)
      ) {
        if (listOppLine[idx].Amount__c > 0) {
          listOppLine[idx].Discount_Reason__c = "Managerial Discount";
        }
        listOppLine[idx].Discount_Amount__c = null;
        listOppLine[idx].OriginDiscountAmount = null;
        listOppLine[idx].OriginDiscountPercentage =
          listOppLine[idx].Discount__c;
      } else {
        listOppLine[idx].Discount_Reason__c = null;
        var abc = this;
        setTimeout(function() {
          abc.setDiscountOnEdit(component, event, oppObj, listOppLine, idx);
        }, 500);
      }
    } else if (
      discount != listOppLine[idx].OriginDiscountPercentage ||
      discountAmount != listOppLine[idx].OriginDiscountAmount
    ) {
      listOppLine[idx].OriginDiscountPercentage = null;
      listOppLine[idx].OriginDiscountAmount = null;
      listOppLine[idx].Campaign__c = null;
      listOppLine[idx].Campaign__r.Name = null;
      listOppLine[idx].UnitPrice = listOppLine[idx].Original_Price__c;
      if (
        (listOppLine[idx].Pro_Rate_Amount__c == null ||
          listOppLine[idx].Pro_Rate_Amount__c == undefined ||
          listOppLine[idx].Pro_Rate_Amount__c == 0) &&
        listOppLine[idx].Discount_Remarks__c != undefined &&
        listOppLine[idx].Discount_Remarks__c != null &&
        listOppLine[idx].Discount_Remarks__c.indexOf("Pro Rated Amount") == -1
      ) {
        listOppLine[idx].Discount_Remarks__c = null;
      }
      unitPrice = listOppLine[idx].UnitPrice;
      discountedAmount =
        discount != null
          ? (unitPrice * quantity * discount) / 100
          : discountAmount;
      totalPrice = unitPrice * quantity;
      listOppLine[idx].Amount__c =
        totalPrice -
        (isNaN(discountedAmount) ? 0 : discountedAmount) -
        (isNaN(listOppLine[idx].Pro_Rate_Amount__c)
          ? 0
          : totalPrice - (isNaN(discountedAmount) ? 0 : discountedAmount) >=
            listOppLine[idx].Pro_Rate_Amount__c
          ? listOppLine[idx].Pro_Rate_Amount__c
          : totalPrice - (isNaN(discountedAmount) ? 0 : discountedAmount));
      if (
        noRecalculate == false &&
        (discount == 0 || discount == null) &&
        (discountAmount == 0 || discountAmount == null)
      ) {
        listOppLine[idx].Discount_Reason__c = null;
        var abc = this;
        setTimeout(function() {
          abc.setDiscountOnEdit(component, event, oppObj, listOppLine, idx);
        }, 500);
      } else if (listOppLine[idx].Amount__c > 0 && RenewDis != discountAmount) {
        listOppLine[idx].Discount_Reason__c = "Managerial Discount";
      }
    } else {
      listOppLine[idx].Amount__c =
        totalPrice -
        (isNaN(discountedAmount) ? 0 : discountedAmount) -
        (isNaN(listOppLine[idx].Pro_Rate_Amount__c)
          ? 0
          : totalPrice - (isNaN(discountedAmount) ? 0 : discountedAmount) >=
            listOppLine[idx].Pro_Rate_Amount__c
          ? listOppLine[idx].Pro_Rate_Amount__c
          : totalPrice - (isNaN(discountedAmount) ? 0 : discountedAmount));
    }
    console.log(
      "--BlistOppLine[idx].Discount_Reason__c--" +
        listOppLine[idx].Discount_Reason__c
    );
    if (listOppLine[idx].Amount__c > 0 && RenewDis == discountAmount) {
      listOppLine[idx].Discount_Reason__c = "Renewal Promotion";
    }
    console.log(
      "--AlistOppLine[idx].Discount_Reason__c--" +
        listOppLine[idx].Discount_Reason__c
    );

    if (listOppLine[idx].Amount__c == 0) {
      listOppLine[idx].Complimentary__c = true;
      if (listOppLine[idx].Parent__c != null) {
        listOppLine[idx].Discount__c = 100;
      }
    } else {
      listOppLine[idx].Complimentary__c = false;
    }
    listOppLine[idx].Gross_Amount__c =
      listOppLine[idx].Amount__c +
      listOppLine[idx].Amount__c * (listOppLine[idx].GST_VAT_Rate__c / 100);
    setTimeout(function() {
      component.set("v.listOppLine", null);
      component.set("v.listOppLine", listOppLine);
      component.set("v.sizeOppLineItem", listOppLine.length);
      component.set("v.Spinner", false);
    }, 500);
    component.set("v.noRecalculate", false);
  },
  checkProfilePermission: function(component, event) {
    let action = component.get("c.getProfileNamePermission");
    action.setCallback(this, result => {
      component.set("v.checkProfile", result.getReturnValue());
    });
    $A.enqueueAction(action);
  }
});