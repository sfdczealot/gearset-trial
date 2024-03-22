import { LightningElement, api, track } from 'lwc';
import sendTemplateMessage from '@salesforce/apex/WhatsappIntegration.sendTemplateMessage';

export default class WhatsAppIntegration extends LightningElement {
    @api recordId;
    @track chatMessage;
    @track messageClass;

    onSendMessage() {
        sendTemplateMessage({ contactId: this.recordId })
            .then(result => {
                this.messageClass = 'success';
                this.chatMessage = 'Message sent successfully';
            })
            .catch(error => {
                this.messageClass = 'error';
                this.chatMessage = 'Message failed to send';
            });
    }
}