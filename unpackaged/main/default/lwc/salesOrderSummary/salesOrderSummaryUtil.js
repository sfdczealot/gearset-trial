/**
 * Created by sasa.marjancic on 22.4.2020..
 */
export const STEP_STATUS_INITIALIZING = 'Initializing';
export const STEP_STATUS_WAITING = 'Waiting';
export const STEP_STATUS_WAITING_FOR_EVENT = 'Waiting For Event';
export const STEP_STATUS_COMPLETE = 'Complete';
export const STEP_STATUS_BLOCKED = 'Blocked';
export const STEP_STATUS_ERROR = 'Error';
 
export const SALES_ORDER_STATUS_DRAFT = 'Draft';
export const SALES_ORDER_STATUS_IN_PROGRESS = 'In Progress';
export const SALES_ORDER_STATUS_REJECTED = 'Rejected';
export const SALES_ORDER_STATUS_RETRACTED = 'Retracted';
export const SALES_ORDER_STATUS_BOOKED = 'Booked';
export const SALES_ORDER_STATUS_KILLED = 'Killed';
export const SALES_ORDER_STATUS_PENDING = 'Pending';
export const SALES_ORDER_STATUS_WORKING = 'Working';
export const SALES_ORDER_STATUS_PRICE_RECALCULATION_REQUIRED = 'Price Recalculation Required';

export const SALES_ORDER_PHASE_NEW_SALE = 'New Sale';
export const SALES_ORDER_PHASE_IN_FLIGHT = 'In-Flight';

export const APPROVAL_EMPTY = 'empty';

export const APPROVAL_INVENTORY = 'Inventory';
export const APPROVAL_ARM = 'ARM';
export const APPROVAL_PRICING = 'Pricing';
export const APPROVAL_ACCOUNT_CHECK = 'Account Check';
export const APPROVAL_CUSTOMER = 'Customer';
export const APPROVAL_LEGAL = 'Legal';
export const APPROVAL_COUNTERSIGN = 'Countersign';
export const APPROVAL_COMPLIANCE = 'Compliance';

//PropertyGuru
export const APPROVAL_SD = 'SD';
export const APPROVAL_CM = 'CM';
//HOB Specific
export const APPROVAL_HOB = 'HOB';
export const APPROVAL_HOB_FAST = 'FastKey';
export const APPROVAL_HOB_FIN = 'Fintech';
export const APPROVAL_HOB_MAAS = 'MaaS';
export const APPROVAL_HOB_EVENTS = 'Events';
export const APPROVAL_HOB_AWRDS = 'Awards';
export const APPROVAL_HOB_CNS = 'China Sol.';

export const APPROVAL_CBO = 'CBO';

export const APPROVAL_OMC = 'OMC';

export const APPROVAL_DISCOUNT = 'Discount';


//TBD
export const APPROVAL_CST = 'CST';
export const APPROVAL_RESERVE_EXT = 'Reservation';

export class Approval {
    label;
    value;
    classText;

    constructor(name, value) {
        this.name = name;
        this.value = value;
        this.classText = this.getClassText(value);
    }

    getClassText(val) {
        return "circle " + (val ? val.toLowerCase() : APPROVAL_EMPTY);
    }
}

export class Step {
    value;
    label;
    index;
    status;
    classText;

    constructor(value, label, index, status) {
        this.value = value;
        this.label = label;
        this.index = index;
        this.status = status;
    }

    /**
     * Returns true if current Step instance has same value property as the other one.
     * In case otherStep is a string compares current instance value property with the string value
     * @param {Step|string} otherStep Other step to compare to. Can be an instance of Step or a string.
     */
    equals(otherStep) {
        if (!otherStep) {
            return false;
        }

        if (otherStep instanceof Step) {
            return this.value === otherStep.value;
        }

        if (typeof otherStep === 'string' || otherStep instanceof String) {
            // eslint-disable-next-line eqeqeq
            return this.value == otherStep;
        }

        return false;
    }

    setClassText(val) {
        this.classText = val;
    }

    /**
     * Returns true if current instance has a lower index value than the other one
     * @param {Step} otherStep Step instance to compare
     */
    isBefore(otherStep) {
        return this.index < otherStep.index;
    }

    /**
     * Returns true if current instance has a greater index value than the other one
     * @param {Step} otherStep Step instance to compare
     */
    isAfter(otherStep) {
        return this.index > otherStep.index;
    }

    /**
     * Returns true if current instance has same index value than the other one
     * @param {Step} otherStep Step instance to compare
     */
    isSame(otherStep) {
        return this.index === otherStep.index;
    }

    hasValue() {
        return !!this.value;
    }
}