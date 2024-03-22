import { LightningElement, api, wire, track } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import SO_NAME from '@salesforce/schema/csmso__Sales_Order__c.Name';
import SO_NUMBER_OF_LINES from '@salesforce/schema/csmso__Sales_Order__c.SO_Lines_Number_of_lines__c';
import SO_TOTAL_PRICE from '@salesforce/schema/csmso__Sales_Order__c.Total_Price_Calculated_In_Currency__c';
import SO_TOTAL_IMPRESSIONS from '@salesforce/schema/csmso__Sales_Order__c.Total_Impressions__c';
import SO_TOTAL_DELIVERED from '@salesforce/schema/csmso__Sales_Order__c.Total_Delivered__c';
import SO_TOTAL_SPEND from '@salesforce/schema/csmso__Sales_Order__c.Total_Spend__c';
import SO_DISPLAY_STATUS from '@salesforce/schema/csmso__Sales_Order__c.Status_Read_Only__c';
import SO_STATUS from '@salesforce/schema/csmso__Sales_Order__c.csmso__Status__c';
import SO_SOLD from '@salesforce/schema/csmso__Sales_Order__c.Sold__c';
import SO_LAST_RETRACTED from '@salesforce/schema/csmso__Sales_Order__c.Last_Date_Retracted__c';
import SO_ORDER_TYPE from '@salesforce/schema/csmso__Sales_Order__c.Order_Type__c';
import SO_START_DATE from '@salesforce/schema/csmso__Sales_Order__c.From_Calculated__c';
import SO_END_DATE from '@salesforce/schema/csmso__Sales_Order__c.To_Calculated__c';
import SO_DURATION from '@salesforce/schema/csmso__Sales_Order__c.Duration__c';

import SO_IS_PROGRAMMATIC from '@salesforce/schema/csmso__Sales_Order__c.Is_Programmatic__c';
import SO_LEGAL_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.Legal_Approval__c';
import SO_INVENTORY_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.Inventory_Approval__c';
import SO_ARM_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.ARM_Approval__c';
import SO_PRICING_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.Pricing_Approval__c';
import SO_CUSTOMER_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.Customer_Approval__c';
import SO_COUNTERSIGN_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.Countersign_IO_Approval__c';
import SO_COMPLIANCE_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.Compliance_Approval__c';
import SO_ACCOUNT_CHECK from '@salesforce/schema/csmso__Sales_Order__c.Account_Check_Approval__c';
import SO_CURRENCY from '@salesforce/schema/csmso__Sales_Order__c.CurrencyIsoCode';

//PropertyGuru fields
import SO_SD_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.SD_Approval__c';
import SO_CM_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.CM_Approval__c';
import SO_HOB_FAST_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.HOB_FastKey_Approval__c';
import SO_HOB_FIN_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.HOB_Fintech_Approval__c';
import SO_HOB_EVENTS_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.HOB_Events_Approval__c';
import SO_HOB_MAAS_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.HOB_MaaS_Approval__c';
import SO_HOB_AWARDS_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.HOB_Awards_Approval__c';
import SO_HOB_CNS_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.HOB_CNS_Approval__c';
import SO_CBO_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.CBO_Approval__c';
import SO_OMC_APPROVAL from '@salesforce/schema/csmso__Sales_Order__c.OMC_Approval__c';

import getPossibleSteps from '@salesforce/apex/CS_SalesOrderSummaryController.getPossibleSteps';
import getActiveSteps from '@salesforce/apex/CS_SalesOrderSummaryController.getActiveSteps';

import {
    Step,
    Approval,
    STEP_STATUS_INITIALIZING,
    STEP_STATUS_COMPLETE,
    STEP_STATUS_ERROR,
    SALES_ORDER_STATUS_BOOKED,
    SALES_ORDER_STATUS_KILLED,
    SALES_ORDER_STATUS_DRAFT,
    SALES_ORDER_STATUS_IN_PROGRESS,
    SALES_ORDER_STATUS_REJECTED,
    SALES_ORDER_STATUS_RETRACTED,
    SALES_ORDER_STATUS_PRICE_RECALCULATION_REQUIRED,
    SALES_ORDER_STATUS_PENDING,
    SALES_ORDER_STATUS_WORKING,
    SALES_ORDER_PHASE_NEW_SALE,
    SALES_ORDER_PHASE_IN_FLIGHT,
    APPROVAL_INVENTORY,
    APPROVAL_ARM,
    APPROVAL_PRICING,
    APPROVAL_ACCOUNT_CHECK,
    APPROVAL_LEGAL,
    APPROVAL_COUNTERSIGN,
    APPROVAL_DISCOUNT,
    APPROVAL_CUSTOMER,
    APPROVAL_OMC,
    APPROVAL_CBO,
    APPROVAL_HOB,
    APPROVAL_SD,
    APPROVAL_CM, APPROVAL_HOB_FAST,APPROVAL_HOB_FIN, APPROVAL_HOB_MAAS, APPROVAL_HOB_EVENTS, APPROVAL_HOB_AWRDS, APPROVAL_HOB_CNS
} from './salesOrderSummaryUtil';

const FIELDS = [SO_NAME, SO_NUMBER_OF_LINES, SO_TOTAL_PRICE, SO_TOTAL_IMPRESSIONS, SO_DISPLAY_STATUS,
                SO_TOTAL_DELIVERED, SO_TOTAL_SPEND, SO_STATUS, SO_ORDER_TYPE, SO_SOLD, SO_LAST_RETRACTED,
                SO_IS_PROGRAMMATIC, SO_LEGAL_APPROVAL, SO_INVENTORY_APPROVAL, SO_ARM_APPROVAL, SO_PRICING_APPROVAL, SO_CURRENCY,
                SO_CUSTOMER_APPROVAL, SO_COUNTERSIGN_APPROVAL, SO_COMPLIANCE_APPROVAL, SO_ACCOUNT_CHECK, SO_START_DATE, SO_END_DATE, SO_DURATION,
                SO_OMC_APPROVAL,SO_CM_APPROVAL,SO_SD_APPROVAL,SO_CBO_APPROVAL,
                SO_HOB_FAST_APPROVAL,SO_HOB_FIN_APPROVAL,SO_HOB_MAAS_APPROVAL,SO_HOB_EVENTS_APPROVAL,
                SO_HOB_AWARDS_APPROVAL,SO_HOB_CNS_APPROVAL];

const APPROVAL_TYPES = [
    {
        name: APPROVAL_SD,
        field: 'SD_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_CM,
        field: 'CM_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_HOB_FAST,
        field: 'HOB_FastKey_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_HOB_FIN,
        field: 'HOB_Fintech_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_HOB_MAAS,
        field: 'HOB_MaaS_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_HOB_EVENTS,
        field: 'HOB_Events_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_HOB_AWRDS,
        field: 'HOB_Awards_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_HOB_CNS,
        field: 'HOB_CNS_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_CBO,
        field: 'CBO_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_CUSTOMER,
        field: 'Customer_Approval__c',
        programmatic: false
    },
    {
        name: APPROVAL_OMC,
        field: 'OMC_Approval__c',
        programmatic: false
    }

];

export default class SalesOrderSummary extends LightningElement {
    // provided by the sales order record page
    @api recordId;

    // sales order used
    @track salesOrder;

    // error message
    @track errorMsg;

    // steps to show
    @track possibleSteps;

    // current step
    currentStep;

    // active steps to show
    @track activeSteps

    // show/hide a loading spinner
    @track spinner = false;

    constructor() {
        super();
        setInterval(() => {
            refreshApex(this.salesOrder);
            refreshApex(this.possibleSteps);
            refreshApex(this.activeSteps);
        }, 1000);
    }

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredSalesOrder(provisionedValue) {
        if(provisionedValue) {
            if (provisionedValue.data) {
                this.salesOrder = provisionedValue;
                this.errorMsg = undefined;
            } else if (provisionedValue.error) {
                this.errorMsg = provisionedValue.error;
                this.salesOrder = undefined;
            }
        }
    }

    @wire(getPossibleSteps, { salesOrder: '$recordId', orderType: '$salesOrder.data.fields.Order_Type__c.value' })
    wiredPossibleSteps(provisionedValue) {
        if(provisionedValue) {
            if (provisionedValue.data) {
                this.possibleSteps = provisionedValue;
                this.errorMsg = undefined;
            } else if (provisionedValue.error) {
                this.errorMsg = provisionedValue.error;
                this.possibleSteps = undefined;
            }
        }
    }

    @wire(getActiveSteps, { salesOrder: '$recordId'})
    wiredActiveSteps(provisionedValue) {
        if(provisionedValue) {
            if (provisionedValue.data) {
                this.activeSteps = provisionedValue;
                this.errorMsg = undefined;
            } else if (provisionedValue.error) {
                this.errorMsg = provisionedValue.error;
                this.activeSteps = undefined;
            }
        }
    }

    // getters
    get hasToShowSpinner() {
        return this.spinner || !this.isLoaded;
    }

    get isLoaded() {
        return this.salesOrder && this.possibleSteps && this.activeSteps;
    }

    // true if current record reached a closed step
    get isClosed() {
        return this.isClosedKo || this.isClosedOk;
    }

    // true if current record was closed OK
    get isClosedOk() {
        return this.status === SALES_ORDER_STATUS_BOOKED;
    }

    // true if current record was closed KO
    get isClosedKo() {
        return this.status === SALES_ORDER_STATUS_KILLED;
    }

    get isDraft() {
        return this.status === SALES_ORDER_STATUS_DRAFT || this.status === SALES_ORDER_STATUS_IN_PROGRESS ||
                this.status === SALES_ORDER_STATUS_REJECTED || this.status === SALES_ORDER_STATUS_RETRACTED ||
                this.status === SALES_ORDER_STATUS_PRICE_RECALCULATION_REQUIRED;
    }

    /**
     * Given a step returns the css class to apply in the rendered html element
     * @param {Object} step Step instance
     */
    _getStepElementCssClass(step) {
        let classText = 'slds-path__item';

        if (step.equals(SALES_ORDER_STATUS_BOOKED) && this.isClosedOk && !this._hasActiveSteps()) {
            classText += ' slds-is-won';
        }

        if (step.equals(SALES_ORDER_STATUS_KILLED) && this.isClosedKo) {
            classText += ' slds-is-lost';
        }

        if (step.equals(this.currentStep)) {
            classText += ' slds-is-current slds-is-active';
        } else if (step.isBefore(this.currentStep) && !this.isClosedKo) {
            classText += ' slds-is-complete';
        } else {
            // not yet completed or closedKo
            classText += ' slds-is-incomplete';
        }

        return classText;
    }

    _getCurrentStep(steps) {
        var maxIndex = Math.max.apply(Math, steps.filter(step =>
            step.status === STEP_STATUS_COMPLETE)
        .map(step => {
            return step.index;
        }));

        if(this.isDraft) {
            return this.sold ? steps[1] : steps[0];
        }

        if(this.isClosed) {
            if(this.isClosedKo) return steps.find(step => step.value === SALES_ORDER_STATUS_KILLED);
            else return steps.find(step => step.value === SALES_ORDER_STATUS_BOOKED);
        }
        else if(steps.find(step => step.index == maxIndex + 1)) {
            return steps.find(step => step.index == maxIndex + 1);
        }
        else {
            return steps[0];
        }
    }

    _activeStepMap() {
        return this.activeSteps ? this.activeSteps.data.reduce((a,x) => ({...a, [x.CSPOFA__Milestone_Description__c]: x}), {}) : {};
    }

    _hasActiveSteps() {
        return (Array.isArray(this.activeSteps.data) && this.activeSteps.data.length);
    }

    // get progress bar steps
    get steps() {
        let activeStepMap = this._activeStepMap();

        let res = this.possibleSteps.data.map((elem, idx) => {
                return new Step(elem.CSPOFA__Milestone_Description__c,
                                elem.CSPOFA__Milestone_Description__c,
                                idx,
                         activeStepMap[elem.CSPOFA__Milestone_Description__c] ? activeStepMap[elem.CSPOFA__Milestone_Description__c].CSPOFA__Status__c : STEP_STATUS_INITIALIZING);
            })
            .filter(step => {
                return !this.isClosedKo || step.value !== SALES_ORDER_STATUS_BOOKED
            });

        let firstStep = this.firstStep;
        if(firstStep) res.unshift(firstStep);

        let lastStep = this.lastStep;
        if(lastStep) res.push(lastStep);

        this.currentStep = this._getCurrentStep(res);

        res = res.map(step => {
            // adds the classText property used to render correctly the element
            step.setClassText(this._getStepElementCssClass(step));
            return step;
        });

        return res;
    }

    get firstStep() {
        let firstStep;
        if (this.sold && this.status !== SALES_ORDER_STATUS_BOOKED) {
            firstStep = new Step(
                'PreviouslyBooked',
                SALES_ORDER_STATUS_BOOKED,
                -1,
                STEP_STATUS_COMPLETE
            );
        }

        return firstStep;
    }

    get lastStep() {
        let lastStep;
        if (this.isClosedKo) {
            lastStep = new Step(
                SALES_ORDER_STATUS_KILLED,
                SALES_ORDER_STATUS_KILLED,
                Infinity,
                STEP_STATUS_ERROR
            );
        }

        return lastStep;
    }

    // get all approval types for sales order
    get approvals() {
        let result = [];
        APPROVAL_TYPES.forEach(a => {
            if(!this.isProgrammatic || a.programmatic) {
                result.push(new Approval(a.name, this.salesOrder.data.fields[a.field].value));
            }
        });

        return result;
    }

    // header getters

    get name() {
        return this.salesOrder.data.fields.Name.value;
    }

    get isProgrammatic() {
        return this.salesOrder.data.fields.Is_Programmatic__c.value;
    }

    get numberOfLines() {
        return this.salesOrder.data.fields.SO_Lines_Number_of_lines__c.value;
    }

    get totalPrice() {
        return this.salesOrder.data.fields.Total_Price_Calculated_In_Currency__c.value;
    }

    get currency() {
        return this.salesOrder.data.fields.CurrencyIsoCode.value;
    }

    get totalImpressions() {
        return this.salesOrder.data.fields.Total_Impressions__c.value;
    }

    get totalDelivered() {
        return this.salesOrder.data.fields.Total_Delivered__c.value;
    }

    get startDate() {
        return this.salesOrder.data.fields.From_Calculated__c.value;
    }

    get endDate() {
        return this.salesOrder.data.fields.To_Calculated__c.value;
    }

    // duation in months

    get monDuration(){
        return this.salesOrder.data.fields.Duration__c.value;
    }

    get totalSpend() {
        return this.salesOrder.data.fields.Total_Spend__c.value;
    } 

    get displayStatus() {
        return this.salesOrder.data.fields.Status_Read_Only__c.value === SALES_ORDER_STATUS_PENDING ?
            SALES_ORDER_STATUS_WORKING : this.salesOrder.data.fields.Status_Read_Only__c.value;
    }

    get showSpiner() {
        return this.salesOrder.data.fields.Status_Read_Only__c.value === SALES_ORDER_STATUS_PENDING;
    }

    get status() {
        return this.salesOrder.data.fields.csmso__Status__c.value;
    }

    get sold() {
        return this.salesOrder.data.fields.Sold__c.value;
    }

    get lastDateRetracted() {
        return this.salesOrder.data.fields.Last_Date_Retracted__c.value;
    }
}