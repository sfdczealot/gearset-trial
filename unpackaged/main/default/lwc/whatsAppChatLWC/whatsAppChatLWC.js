import { LightningElement, track, wire } from 'lwc';
import listAllMessages from '@salesforce/apex/WhatsAppLWCService.listAllMessages';
import sendTextMessage from '@salesforce/apex/WhatsAppLWCService.sendTextMessage'
import getSingleMessage from '@salesforce/apex/WhatsAppLWCService.getSingleMessage';

import { subscribe, unsubscribe, onError } from 'lightning/empApi';

export default class whatsAppChatLWC extends LightningElement {

    @track messages;
    @track errorDetails;

    showMessages = false;
    isSpinner = false;
    phone;
    messageText;

    eventName = '/event/WA_Message_Event__e' //PE
    subscription;


    connectedCallback() {
        this.handleErrorRegister();
        this.handleSubscribe();
    }
    disconnectedCallback() {
        this.handleUnSubscribe();
    }

    handleUnSubscribe() {
        //unsubscribe(this.subscription)
    }

    handleSubscribe() {
        subscribe(this.eventName, -1, this.handleSubscribeResponse.bind(this)).then((response) => {
            this.subscription = response;
            console.log('Subscribed to channel ', JSON.stringify(response));
        });
    }

    handleSubscribeResponse(response) {
        console.log('Response from WhatsApp Webhook ', JSON.stringify(response));
        let data = response.data.payload;
        let messageId = data.Message_Id__c;
        let customerPhone = data.Customer_Phone__c;
        if (this.phone === customerPhone) {
            // Make the Apex Class Call to get the message details
            getSingleMessage({
                recordId: messageId,
                customerPhone: customerPhone
            })
                .then((response) => {
                    this.messages.push(response);
                })
                .catch((error) => {
                    console.error('Error While Recieving the Platform Event Message')
                })
                .finally(() => {
                    let chatArea = this.template.querySelector('.chatArea');
                    if (chatArea) {
                        chatArea.scrollTop = chatArea.scrollHeight;
                    }
                })
        }
    }

    handleErrorRegister() {
        onError((error) => {
            console.error('Received error from server: ', JSON.stringify(error));
            // Error contains the server-side error
        });
    }

    handlePhoneChange(event) {
        event.preventDefault();
        this.phone = event.target.value;
        console.log(this.phone);
    }

    handleChat(event) {
        event.preventDefault();
        console.log(this.phone);
        if (this.handleValidate()) {
            // make a call to Salesforce Apex to get the list of message
            this.isSpinner = true;
            listAllMessages({
                customerPhone: this.phone
            })
                .then((result) => {
                    this.messages = result;
                    this.showMessages = true;
                })
                .catch((errors) => {
                    this.errorDetails = errors;
                    this.showMessages = false;
                })
                .finally(() => {
                    //
                    let chatArea = this.template.querySelector('.chatArea');
                    if (chatArea) {
                        chatArea.scrollTop = chatArea.scrollHeight;
                    }
                    this.isSpinner = false;
                    this.setUpChatMessage();
                })
        } else {
            return;
        }
    }

    setUpChatMessage() {
        let chatInput = this.template.querySelector(".chat-input");
        if (chatInput) {
            chatInput.addEventListener("keydown", (event) => {
                if (event.key === "Enter") {
                    this.handleSendMessage();
                }
            });
        }
    }

    handleSendMessage() {
        let allValid = this.handleValidate();
        if (allValid) {
            this.isSpinner = true;
            sendTextMessage({
                messageContent: this.messageText,
                toPhone: this.phone
            })
                .then((result) => {
                    this.messages.push(result);
                })
                .catch((errors) => {
                    this.errorDetails = errors;
                    this.showMessages = false;
                })
                .finally(() => {
                    let chatArea = this.template.querySelector('.chatArea');
                    if (chatArea) {
                        chatArea.scrollTop = chatArea.scrollHeight;
                    }
                    this.isSpinner = false;
                    this.messageText = '';
                })
        }
    }

    handleChange(event) {
        event.preventDefault();
        this.messageText = event.target.value;
    }

    handleAnotherChat() {
        this.messageText = '';
        this.showMessages = false;
        this.messages = undefined;
    }

    handleValidate() {
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        return allValid;
    }
}