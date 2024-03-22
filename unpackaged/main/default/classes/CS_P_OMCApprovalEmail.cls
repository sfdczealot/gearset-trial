/**
 * Created by petar on 27/10/20.
 */

public with sharing class CS_P_OMCApprovalEmail  extends CS_ProcessBase {
        @TestVisible
        Map<Id, csmso__Sales_Order__c> applicableObjects;

        @TestVisible
        Map<Id, csmso__Sales_Order__c> oldObjects;

        public csmso__Sales_Order__c salesOrder { get; set; }

        public CS_P_OMCApprovalEmail(Map<Id, csmso__Sales_Order__c> oldObjects) {
            super(CS_ProcessDefinition.SO_OMCAPPROVALEMAIL, 'CS_P_OMCApprovalEmail');

            this.oldObjects = oldObjects;
            applicableObjects = new Map<Id, csmso__Sales_Order__c>();
        }

        public override void isRecordEligible(SObject obj) {
            csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
            csmso__Sales_Order__c oldSalesOrder = oldObjects != null ? (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id) : null;

            // if status moved to Pending OMC Approval (done via Orch)
            if(oldSalesOrder != null
                    && oldSalesOrder.csmso__Status__c != CS_const_SalesOrder.Status_PendingOMCApproval
                    && newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_PendingOMCApproval ) {
                applicableObjects.put(newSalesOrder.Id, newSalesOrder);
            }

            this.runProcess = !applicableObjects.isEmpty();
        }

        public override void logic() {
            EmailTemplate emailTemplate = [
                    SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
                    FROM EmailTemplate
                    WHERE DeveloperName = 'Freskdesk_OMC_Notification'
            ];

            //requred configured OMC addresses per Subsidiary
            List<Subsidiary_OMC_Target__mdt> omcTargets = [SELECT Subsidiary__c,Email_List__c FROM Subsidiary_OMC_Target__mdt];

            //create a map to help with identifying emails
            Map<String,Subsidiary_OMC_Target__mdt> targetPerSubMap = new Map<String, Subsidiary_OMC_Target__mdt>();
            for (Subsidiary_OMC_Target__mdt omcTarget : omcTargets) {
                targetPerSubMap.put(omcTarget.Subsidiary__c, omcTarget);
            }

            //need opp lookup subsidiary info which is not present in trigger
            Map<Id, csmso__Sales_Order__c> salesOrderMap = new Map<Id, csmso__Sales_Order__c>([
                    SELECT
                            Id, csmso__Opportunity__r.Subsidiary__r.Subsidiary_Code__c
                    FROM
                            csmso__Sales_Order__c
                    WHERE Id IN: applicableObjects.keySet()]);


            Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{};


            // create message for every applicable SO
            for (csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
                Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id,salesOrder.OwnerId, salesOrder.csmso__Opportunity__c);

                String oppSubCode = salesOrderMap.get(salesOrder.Id).csmso__Opportunity__r.Subsidiary__r.Subsidiary_Code__c;
                Subsidiary_OMC_Target__mdt emailTarget = targetPerSubMap.get(oppSubCode);

                // get rendered email details
                String  subject = message.getSubject();
                String body = message.getHtmlBody();

                //setup email message
                message.setHtmlBody(body);
                message.setSubject(subject);
                message.setUseSignature(false);
                message.setBccSender(false);
                message.setSaveAsActivity(false);

                // using configured email target for designated emails
                message.setCcAddresses( emailTarget.Email_List__c.split(',') );

                messages.add(message);
            }

            //sending all messages
            Messaging.sendEmail(messages,true);
        }
    }