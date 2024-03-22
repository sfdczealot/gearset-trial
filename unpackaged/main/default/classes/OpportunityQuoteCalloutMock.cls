@isTest
global class OpportunityQuoteCalloutMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"id":5799,"region":"sg","agent_id":43770,"invoice_id":"PGSO-19005761","currency":"sgd","total":1.07,"order_info":"{\'webuserId\':\'43770\',\'tranTotal\':\'1.07\',\'tranTax\':\'0.07\',\'tranDisc\':\'0.00\',\'tranAmount\':\'1.07\',\'salesRep\':{\'name\':\'Admin Viseo\',\'email\':\'whisnu-satriya.wardhana@viseo.com\',\'contactNo\':\'6546373\'},\'region\':\'sg\',\'referenceNo\':\'PGSO-19005761\',\'email\':\'viseo1.viseo1.deepti.malik09@gmail.com\',\'customerName\':\'Deepti Malik\',\'createdDate\':\'2019-01-30 14:15:29\',\'billaddress\':\'sadas asdas Singapore\', \'items\': [{\'startDate\':\'2019-01-30\',\'itemTax\':\'0.07\',\'itemQuantity\':\'1.00\',\'itemPrice\':\'1.00\',\'itemName\':\'PGSG Bundle Ad Credit (1 Credit)\',\'itemDisc\':\'0.00\',\'itemDescription\':\'Bundle Ad Credit (1 Credit)\',\'itemAmount\':\'1.07\',\'endDate\':\'2020-01-29\'}]}","payment_method":"all","os":"","browser":"","ip_address":"","timestamp":null,"accepted_datetime":null,"created":"2019-01-30 14:16:24","modified":"2019-01-30 14:16:27","status":"open","hash":"U2FsdGVkX19nQSBmR5EtTUjzol6QF8uZkdfMRCO79eCG0orLlEcV/uvSDU+RsNcX","expiry":"2019-01-30 14:16:24","hash_base64":"VTJGc2RHVmtYMTluUVNCbVI1RXRUVWp6b2w2UUY4dVprZGZNUkNPNzllQ0cwb3JMbEVjVi91dlNEVStSc05jWA=="}');
        response.setStatusCode(200);
        return response;
    }
}