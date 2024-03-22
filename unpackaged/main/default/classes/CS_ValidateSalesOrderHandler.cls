/**
 * Created by jameshladek on 4/28/20.
 */

global with sharing class CS_ValidateSalesOrderHandler extends CS_StepHandlerBase {
    global CS_ValidateSalesOrderHandler() {
        this.action = 'Validate Sales Order';
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;
        CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');
        CS_ValidateSaleOrderHandlerHelper helper = new CS_ValidateSaleOrderHandlerHelper();
        if (!helper.isValid((Id) paramsType.get('salesOrderId'))) {
            helper.updateSalesOrder();
            context.setVariable(step.CSPOFA__Orchestration_Process__c, CS_StepHandlerBase.ValidationReasonVariable, helper.getValidationReason());
        }
        
        setStepProgress(step, 'Sales Order Validated.');

        return step;
    }

    public class CS_ValidateSaleOrderHandlerHelper extends CS_ButtonBase {
        public override Boolean doAdditionalValidation() {
            if (isStartDateOfAnyLineInThePast()
                    || isThereNotKilledSoldSO()) {
                return false;
            }
            return true;
        }

        public Boolean isValid(Id salesOrderId) {
            this.salesOrder = getSalesOrder(salesOrderId);
            this.configs = new Map<Id, cscfga__Product_Configuration__c>(this.salesOrder.Product_Configurations__r);

            return validate();
        }

        public String getValidationReason() {
            if(isStartDateOfAnyLineInThePast()) return CS_StepHandlerBase.ValidationReason_StartDate;
            else if(isThereNotKilledSoldSO()) return CS_StepHandlerBase.ValidationReason_BookedSo;
            else return null;
        }

        public void updateSalesOrder() {
            this.salesOrder.csmso__Process_Message__c = returnMessage.message;
            this.salesOrder.csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Information;
            update salesOrder;
        }
    }
}