@IsTest(SeeAllData=false)
private class FulfilmentExceptionEventTest {

	/* Test method for checking the error message and stack trace */

    @IsTest
    static void exceptionTest() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.csdf__Fulfilment_Message_Status__c = 'Component that';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
		custSetting.Name = 'Ad Server Integration';
		custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		insert custSetting;

		csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
		testObjGrph.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
		insert testObjGrph;

		csam__Outgoing_Message__c outMsg = new csam__Outgoing_Message__c(Name = 'testoutmsg', csam__Content_Type__c = 'testtype', csam__URL_Host__c = 'testhost', csam__ObjectGraph_Callout_Handler__c = testObjGrph.Id);
		insert outMsg;

		csam__Incoming_Message__c testmsg1 = new csam__Incoming_Message__c(csam__Status__c = 'Integration Error', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg1;

		csam__Incoming_Message__c testmsg2 = new csam__Incoming_Message__c(csam__Status__c = 'Process Error', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg2;

		csam__Outgoing_Message__c outMsg1 = new csam__Outgoing_Message__c(Name = 'testoutmsg1', csam__Content_Type__c = 'testtype1', csam__URL_Host__c = 'testhost1', csam__ObjectGraph_Callout_Handler__c = testObjGrph.Id);
		insert outMsg1;

		csam__Outgoing_Message_Record__c outMsgRec = new csam__Outgoing_Message_Record__c(csam__Object_Name__c = 'csdf__Fulfilment__c', csam__Outgoing_Message__c = outMsg.Id, csam__Object_Record_Id__c = testFulfilment.Id);
		insert outMsgRec;

		csam__Outgoing_Message_Record__c outMsgRec1 = new csam__Outgoing_Message_Record__c(csam__Object_Name__c = 'csdf__Fulfilment__c', csam__Outgoing_Message__c = outMsg1.Id, csam__Object_Record_Id__c = testFulfilment.Id);
		insert outMsgRec1;

		Attachment testAttach1 = new Attachment(Name = 'Message_cs_00D1b000000Conn_1461081421326_-1210344185613467505', ParentId = testmsg1.Id,
				Body = Blob.valueOf('{"errorMessage":"Component that caused exception is: DefaultJavaComponent{consumerAvailabilityFlow.component.133821960}. Message payload is of type: ObjectGraph","stackTrace":"java.lang.Thread.run Caused by: com.cloudsense.messaging.UnrecoverableException"}'));
		insert testAttach1;

		Attachment testAttach2 = new Attachment(Name = 'test', ParentId = testmsg2.Id, Body = Blob.valueOf('Message_cs_00D1b000000Conn_1461081421326_-1210344185613467505'));
		insert testAttach2;

		csam.InboundMessageObservable o = (csam.InboundMessageObservable) JSON.deserialize('{"messages": ' + JSON.serialize([SELECT csam__Final_Chunk__c, csam__Outgoing_Message__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Status__c FROM csam__Incoming_Message__c LIMIT 4]) + ', "name": "AfterIncomingMessageProcessed"}', csam.InboundMessageObservable.class);

		FulfilmentExceptionEventMapping__c fulCS = new FulfilmentExceptionEventMapping__c();
		fulCS.Name = 'testName';
		fulCS.Input_Message__c = 'Component that caused exception is:';
		fulCS.Output_Message__c = 'outputmsg';
		insert fulCS;

		Test.startTest();
		FulfilmentExceptionEvent fe = new FulfilmentExceptionEvent();
		fe.execute(o, null);
		Test.stopTest();
	}

	/* Test method for checking the error message with different pattern */

    @IsTest
    static void pattern1_Test() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
		custSetting.Name = 'Ad Server Integration';
		custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		insert custSetting;

		csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
		testObjGrph.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
		testObjGrph.Name = 'SO Fulfilment Item Availability Check';
		insert testObjGrph;

		csam__Outgoing_Message__c outMsg = new csam__Outgoing_Message__c(Name = 'testoutmsg', csam__Content_Type__c = 'testtype', csam__URL_Host__c = 'testhost', csam__ObjectGraph_Callout_Handler__c = testObjGrph.Id);
		insert outMsg;

		csam__Outgoing_Message_Record__c outMsgRec2 = new csam__Outgoing_Message_Record__c(csam__Object_Name__c = 'csdf__Fulfilment_Item__c', csam__Outgoing_Message__c = outMsg.Id, csam__Object_Record_Id__c = testFulfilmentItem.Id);
		insert outMsgRec2;

		csam__Incoming_Message__c testmsg1 = new csam__Incoming_Message__c(csam__Status__c = 'Integration Error', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg1;

		csam__Incoming_Message__c testmsg2 = new csam__Incoming_Message__c(csam__Status__c = 'Process Error', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg2;

		csam__Outgoing_Message_Record__c outMsgRec = new csam__Outgoing_Message_Record__c(csam__Object_Name__c = 'csdf__Fulfilment__c', csam__Outgoing_Message__c = outMsg.Id, csam__Object_Record_Id__c = acc.Id);
		insert outMsgRec;


		Attachment testAttach1 = new Attachment(Name = 'Message_cs_00D1b000000Conn_1461081421326_-1210344185613467505', ParentId = testmsg1.Id,
				Body = Blob.valueOf('{"errorMessage":"Component that caused exception is: DefaultJavaComponent{consumerAvailabilityFlow.component.133821960}. Message payload is of type: ObjectGraph","stackTrace":"Caused by: com.cloudsense.messaging.UnrecoverableException: (.*)"}'));
		insert testAttach1;

		Attachment testAttach2 = new Attachment(Name = 'test', ParentId = testmsg2.Id, Body = Blob.valueOf('Message_cs_00D1b000000Conn_1461081421326_-1210344185613467505'));
		insert testAttach2;

		csam.InboundMessageObservable o = (csam.InboundMessageObservable) JSON.deserialize('{"messages": ' + JSON.serialize([SELECT csam__Final_Chunk__c, csam__Outgoing_Message__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Status__c FROM csam__Incoming_Message__c LIMIT 4]) + ', "name": "AfterIncomingMessageProcessed"}', csam.InboundMessageObservable.class);

		FulfilmentExceptionEventMapping__c fulCS = new FulfilmentExceptionEventMapping__c();
		fulCS.Name = 'testName';
		fulCS.Input_Message__c = 'Component that caused exception is:';
		fulCS.Output_Message__c = 'outputmsg';
		insert fulCS;

		Test.startTest();
		FulfilmentExceptionEvent fe = new FulfilmentExceptionEvent();
		fe.execute(o, null);
		Test.stopTest();
	}

	/* Test method for checking the error message of different pattern */

    @IsTest
    static void pattern2_Test() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
		custSetting.Name = 'Ad Server Integration';
		custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		insert custSetting;

		csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
		testObjGrph.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
		insert testObjGrph;

		csam__Outgoing_Message__c outMsg = new csam__Outgoing_Message__c(Name = 'testoutmsg', csam__Content_Type__c = 'testtype', csam__URL_Host__c = 'testhost');
		insert outMsg;

		csam__Incoming_Message__c testmsg1 = new csam__Incoming_Message__c(csam__Status__c = 'Integration Error', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg1;

		csam__Incoming_Message__c testmsg2 = new csam__Incoming_Message__c(csam__Status__c = 'Process Error', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg2;

		csam__Incoming_Message__c testmsg3 = new csam__Incoming_Message__c(csam__Status__c = 'test', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg3;

		csam__Outgoing_Message_Record__c outMsgRec = new csam__Outgoing_Message_Record__c(csam__Object_Name__c = 'csdf__Fulfilment__c', csam__Outgoing_Message__c = outMsg.Id, csam__Object_Record_Id__c = acc.Id);
		insert outMsgRec;

		Attachment testAttach1 = new Attachment(Name = 'Message_cs_00D1b000000Conn_1461081421326_-1210344185613467505', ParentId = testmsg3.Id,
				Body = Blob.valueOf('{"errorMessage":"Component that caused exception is: DefaultJavaComponent{consumerAvailabilityFlow.component.133821960}. Message payload is of type: ObjectGraph","stackTrace":"Caused by: [(.*)]"}'));
		insert testAttach1;

		csam.InboundMessageObservable o = (csam.InboundMessageObservable) JSON.deserialize('{"messages": ' + JSON.serialize([SELECT csam__Final_Chunk__c, csam__Outgoing_Message__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Status__c FROM csam__Incoming_Message__c LIMIT 4]) + ', "name": "AfterIncomingMessageProcessed"}', csam.InboundMessageObservable.class);

		FulfilmentExceptionEventMapping__c fulCS = new FulfilmentExceptionEventMapping__c();
		fulCS.Name = 'testName';
		fulCS.Input_Message__c = 'Component that caused exception is:';
		fulCS.Output_Message__c = 'outputmsg';
		insert fulCS;

		Test.startTest();
		FulfilmentExceptionEvent fe = new FulfilmentExceptionEvent();
		fe.execute(o, null);
		Test.stopTest();
	}

    @IsTest
    static void FulfilmentExceptionEven_method4() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
		custSetting.Name = 'Ad Server Integration';
		custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		insert custSetting;

		csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
		testObjGrph.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
		testObjGrph.Name = 'SO Fulfilment Item Availability Check';
		insert testObjGrph;

		csam__Outgoing_Message__c outMsg = new csam__Outgoing_Message__c(Name = 'testoutmsg', csam__Content_Type__c = 'testtype', csam__URL_Host__c = 'testhost', csam__ObjectGraph_Callout_Handler__c = testObjGrph.Id);
		insert outMsg;

		csam__Outgoing_Message_Record__c outMsgRec2 = new csam__Outgoing_Message_Record__c(csam__Object_Name__c = 'csdf__Fulfilment_Item__c', csam__Outgoing_Message__c = outMsg.Id, csam__Object_Record_Id__c = testFulfilmentItem.Id);
		insert outMsgRec2;

		csam__Incoming_Message__c testmsg1 = new csam__Incoming_Message__c(csam__Status__c = 'Processed', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg1;


		Attachment testAttach1 = new Attachment(Name = 'Message_cs_00D1b000000Conn_1461081421326_-1210344185613467505', ParentId = testmsg1.Id,
				Body = Blob.valueOf('{"errorMessage":"Component that caused exception is: DefaultJavaComponent{consumerAvailabilityFlow.component.133821960}. Message payload is of type: ObjectGraph","stackTrace":"Caused by: com.cloudsense.messaging.UnrecoverableException: (.*)"}'));
		insert testAttach1;


		csam.InboundMessageObservable o = (csam.InboundMessageObservable) JSON.deserialize('{"messages": ' + JSON.serialize([SELECT csam__Final_Chunk__c, csam__Outgoing_Message__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Status__c FROM csam__Incoming_Message__c LIMIT 4]) + ', "name": "AfterIncomingMessageProcessed"}', csam.InboundMessageObservable.class);

		FulfilmentExceptionEventMapping__c fulCS = new FulfilmentExceptionEventMapping__c();
		fulCS.Name = 'testName';
		fulCS.Input_Message__c = 'Component that caused exception is:';
		fulCS.Output_Message__c = 'outputmsg';
		insert fulCS;

		Test.startTest();
		FulfilmentExceptionEvent fe = new FulfilmentExceptionEvent();
		fe.execute(o, null);

		delete testObjGrph;
		delete outMsg;
		delete testmsg1;
		delete fulCS;


		testObjGrph = TestDataSetupTargetables.createObjGrph();
		testObjGrph.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
		testObjGrph.Name = 'Fulfilment Push';
		upsert testObjGrph;

		outMsg = new csam__Outgoing_Message__c(Name = 'testoutmsg', csam__Content_Type__c = 'testtype', csam__URL_Host__c = 'testhost', csam__ObjectGraph_Callout_Handler__c = testObjGrph.Id);
		upsert outMsg;

		outMsgRec2 = new csam__Outgoing_Message_Record__c(csam__Object_Name__c = 'csdf__Fulfilment_Item__c', csam__Outgoing_Message__c = outMsg.Id, csam__Object_Record_Id__c = testFulfilmentItem.Id);
		upsert outMsgRec2;

		testmsg1 = new csam__Incoming_Message__c(csam__Status__c = 'Processed', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		upsert testmsg1;


		testAttach1 = new Attachment(Name = 'Message_cs_00D1b000000Conn_1461081421326_-1210344185613467505', ParentId = testmsg1.Id,
				Body = Blob.valueOf(''));
		upsert testAttach1;


		o = (csam.InboundMessageObservable) JSON.deserialize('{"messages": ' + JSON.serialize([SELECT csam__Final_Chunk__c, csam__Outgoing_Message__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Status__c FROM csam__Incoming_Message__c LIMIT 4]) + ', "name": "AfterIncomingMessageProcessed"}', csam.InboundMessageObservable.class);

		fulCS = new FulfilmentExceptionEventMapping__c();
		fulCS.Name = 'testName';
		fulCS.Input_Message__c = 'Component that caused exception is:';
		fulCS.Output_Message__c = 'outputmsg';
		upsert fulCS;

		Test.stopTest();
	}

    @IsTest
    static void FulfilmentExceptionEven_method5() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
		custSetting.Name = 'Ad Server Integration';
		custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		insert custSetting;

		csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
		testObjGrph.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
		testObjGrph.Name = 'Fulfilment Push';
		insert testObjGrph;

		csam__Outgoing_Message__c outMsg = new csam__Outgoing_Message__c(Name = 'testoutmsg', csam__Content_Type__c = 'testtype', csam__URL_Host__c = 'testhost', csam__ObjectGraph_Callout_Handler__c = testObjGrph.Id);
		insert outMsg;

		csam__Outgoing_Message_Record__c outMsgRec2 = new csam__Outgoing_Message_Record__c(csam__Object_Name__c = 'csdf__Fulfilment_Item__c', csam__Outgoing_Message__c = outMsg.Id, csam__Object_Record_Id__c = testFulfilmentItem.Id);
		insert outMsgRec2;

		csam__Incoming_Message__c testmsg1 = new csam__Incoming_Message__c(csam__Status__c = 'Processed', csam__HTTP_Method__c = 'testhttp', csam__Outgoing_Message__c = outMsg.Id, csam__Final_Chunk__c = true);
		insert testmsg1;


		Attachment testAttach1 = new Attachment(Name = 'Message_cs_00D1b000000Conn_1461081421326_-1210344185613467505', ParentId = testmsg1.Id,
				Body = Blob.valueOf('{"errorMessage":"Component that caused exception is: DefaultJavaComponent{consumerAvailabilityFlow.component.133821960}. Message payload is of type: ObjectGraph","stackTrace":"Caused by: com.cloudsense.messaging.UnrecoverableException: (.*)"}'));
		insert testAttach1;


		csam.InboundMessageObservable o = (csam.InboundMessageObservable) JSON.deserialize('{"messages": ' + JSON.serialize([SELECT csam__Final_Chunk__c, csam__Outgoing_Message__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Status__c FROM csam__Incoming_Message__c LIMIT 4]) + ', "name": "AfterIncomingMessageProcessed"}', csam.InboundMessageObservable.class);

		FulfilmentExceptionEventMapping__c fulCS = new FulfilmentExceptionEventMapping__c();
		fulCS.Name = 'testName';
		fulCS.Input_Message__c = 'Component that caused exception is:';
		fulCS.Output_Message__c = 'outputmsg';
		insert fulCS;

		Test.startTest();
		FulfilmentExceptionEvent fe = new FulfilmentExceptionEvent();
		fe.execute(o, null);

		Test.stopTest();
	}

	@IsTest
	static void testAvailCheckHandlerWorker() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Integration_Chunk_Size__c = 25;
		customSettings.Integration_Delay_Between_Callouts__c = 0;
		update customSettings;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;

		CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
		rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert rs;

		CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
		bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
		insert bsItem;

		CS_Revenue_Schedule_Item__c rsItem = new CS_Revenue_Schedule_Item__c();
		rsItem.Sales_Order__c = so.Id;
		rsItem.Product_Configuration__c = prodConfig.Id;
		rsItem.Revenue_Schedule__c = rs.Id;
		rsItem.Status__c = 'Forecast';
		insert rsItem;

		csam__AsyncMessOptions__c asyncMessOptions = new csam__AsyncMessOptions__c();
		asyncMessOptions.csam__Disable_Validations__c = true;
		insert asyncMessOptions;

		csam__ObjectGraph_Callout_Handler__c fulfilmentCheckAvailsOGCH = new csam__ObjectGraph_Callout_Handler__c();
		fulfilmentCheckAvailsOGCH.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
		fulfilmentCheckAvailsOGCH.csam__URL_Path__c = '/services/adserver/availability';
		fulfilmentCheckAvailsOGCH.csam__Method__c = 'PUT';
		fulfilmentCheckAvailsOGCH.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment__c';
		fulfilmentCheckAvailsOGCH.csam__Status_Field__c = 'csdf__Availability_Check_Status__c';
		fulfilmentCheckAvailsOGCH.Handler_Class__c = 'FulfilmentExceptionEvent.AvailCheckHandlerWorker';
		insert fulfilmentCheckAvailsOGCH;

		csam__Outgoing_Message__c outgoingMessage = new csam__Outgoing_Message__c();
		outgoingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		outgoingMessage.csam__URL_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		outgoingMessage.csam__URL_File__c = '/services/adserver/availability';
		outgoingMessage.csam__Content_Type__c = 'application/json; charset=utf-8';
		outgoingMessage.csam__HTTP_Method__c = 'PUT';
		outgoingMessage.csam__Status__c = 'Response Received';
		outgoingMessage.csam__Fast_Async__c = true;
		outgoingMessage.csam__One_Way__c = false;
		outgoingMessage.csam__ObjectGraph_Callout_Handler__c = fulfilmentCheckAvailsOGCH.Id;
		insert outgoingMessage;

		csam__Incoming_Message__c incomingMessage = new csam__Incoming_Message__c();
		incomingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		incomingMessage.csam__Incoming_URL_Path__c = '/csam/callback/availability';
		incomingMessage.csam__HTTP_Method__c = 'PUT';
		incomingMessage.csam__Status__c = 'Processed';
		incomingMessage.csam__Host__c = 'spotify--CSDev1.cs85.my.salesforce.com';
		incomingMessage.csam__Outgoing_Message__c = outgoingMessage.Id;
		insert incomingMessage;

		csam__Incoming_Message__c incomingMessage2 = [SELECT Id, Name, csam__Outgoing_Message__c,csam__Status__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c FROM csam__Incoming_Message__c WHERE Id = :incomingMessage.Id];
		FulfilmentExceptionEvent.Message message = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord = new csam__Outgoing_Message_Record__c();
		messageRecord.csam__Object_Name__c = 'csdf__Fulfilment__c';
		messageRecord.csam__Object_Record_Id__c = testFulfilment.Id;
		message.addRecord(messageRecord);

		FulfilmentExceptionEvent.Message message2 = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord2 = new csam__Outgoing_Message_Record__c();
		messageRecord2.csam__Object_Name__c = 'csdf__Fulfilment_Item__c';
		messageRecord2.csam__Object_Record_Id__c = testFulfilmentItem.Id;
		message2.addRecord(messageRecord2);

		CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;

		FulfilmentExceptionEvent.AvailCheckHandlerWorker availCheckHandlerWorker = new FulfilmentExceptionEvent.AvailCheckHandlerWorker();
		availCheckHandlerWorker.init(message,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		availCheckHandlerWorker.prepareWork();
		List<SObject> result = availCheckHandlerWorker.doWork();

		FulfilmentExceptionEvent.AvailCheckHandlerWorker availCheckHandlerWorker2 = new FulfilmentExceptionEvent.AvailCheckHandlerWorker();
		availCheckHandlerWorker2.init(message2,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		availCheckHandlerWorker2.prepareWork();
		List<SObject> result2 = availCheckHandlerWorker2.doWork();
	}

	@IsTest
	static void testPushHandlerWorker() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Integration_Chunk_Size__c = 25;
		customSettings.Integration_Delay_Between_Callouts__c = 0;
		update customSettings;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;

		CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
		rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert rs;

		CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
		bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
		insert bsItem;

		CS_Revenue_Schedule_Item__c rsItem = new CS_Revenue_Schedule_Item__c();
		rsItem.Sales_Order__c = so.Id;
		rsItem.Product_Configuration__c = prodConfig.Id;
		rsItem.Revenue_Schedule__c = rs.Id;
		rsItem.Status__c = 'Forecast';
		insert rsItem;

		csam__AsyncMessOptions__c asyncMessOptions = new csam__AsyncMessOptions__c();
		asyncMessOptions.csam__Disable_Validations__c = true;
		insert asyncMessOptions;

		csam__ObjectGraph_Callout_Handler__c fulfilmentPushOGCH = new csam__ObjectGraph_Callout_Handler__c();
		fulfilmentPushOGCH.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
		fulfilmentPushOGCH.csam__URL_Path__c = '/services/adserver/fulfilment/new';
		fulfilmentPushOGCH.csam__Method__c = 'PUT';
		fulfilmentPushOGCH.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment_Item__c';
		fulfilmentPushOGCH.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
		fulfilmentPushOGCH.Handler_Class__c = 'FulfilmentExceptionEvent.PushHandlerWorker';
		insert fulfilmentPushOGCH;

		csam__Outgoing_Message__c outgoingMessage = new csam__Outgoing_Message__c();
		outgoingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		outgoingMessage.csam__URL_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		outgoingMessage.csam__URL_File__c = '/services/adserver/fulfilment/new';
		outgoingMessage.csam__Content_Type__c = 'application/json; charset=utf-8';
		outgoingMessage.csam__HTTP_Method__c = 'PUT';
		outgoingMessage.csam__Status__c = 'Response Received';
		outgoingMessage.csam__Fast_Async__c = true;
		outgoingMessage.csam__One_Way__c = false;
		outgoingMessage.csam__ObjectGraph_Callout_Handler__c = fulfilmentPushOGCH.Id;
		insert outgoingMessage;

		csam__Incoming_Message__c incomingMessage = new csam__Incoming_Message__c();
		incomingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		incomingMessage.csam__Incoming_URL_Path__c = '/csam/callback/error';
		incomingMessage.csam__HTTP_Method__c = 'PUT';
		incomingMessage.csam__Status__c = 'Integration Error';
		incomingMessage.csam__Host__c = 'spotify--CSDev1.cs85.my.salesforce.com';
		incomingMessage.csam__Outgoing_Message__c = outgoingMessage.Id;
		insert incomingMessage;

		Attachment attachment = new Attachment();
		attachment.Name = 'Message_cs-00D6E0000008xSQ-1551175710405-7331591045244973824.json';
		attachment.Body = Blob.valueOf('{"currentPayload":"FulfilmentItemId:' + testFulfilmentItem.Id + '","errorMessage":"[CommonError.CANNOT_UPDATE @ lineItem[0].orderId;]","stackTrace":"AxisFault"}');
		attachment.ParentId = incomingMessage.Id;
		insert attachment;

		csam__Incoming_Message__c incomingMessage2 = [SELECT Id, Name, csam__Outgoing_Message__c,csam__Status__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c FROM csam__Incoming_Message__c WHERE Id = :incomingMessage.Id];
		FulfilmentExceptionEvent.Message message = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord = new csam__Outgoing_Message_Record__c();
		messageRecord.csam__Object_Name__c = 'csdf__Fulfilment__c';
		messageRecord.csam__Object_Record_Id__c = testFulfilment.Id;
		message.addRecord(messageRecord);

		FulfilmentExceptionEvent.Message message2 = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord2 = new csam__Outgoing_Message_Record__c();
		messageRecord2.csam__Object_Name__c = 'csdf__Fulfilment_Item__c';
		messageRecord2.csam__Object_Record_Id__c = testFulfilmentItem.Id;
		message2.addRecord(messageRecord2);

		CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;

		FulfilmentExceptionEvent.PushHandlerWorker pushHandlerWorker = new FulfilmentExceptionEvent.PushHandlerWorker();
		pushHandlerWorker.init(message,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		pushHandlerWorker.prepareWork();
		List<SObject> result = pushHandlerWorker.doWork();

		FulfilmentExceptionEvent.PushHandlerWorker pushHandlerWorker2 = new FulfilmentExceptionEvent.PushHandlerWorker();
		pushHandlerWorker2.init(message2,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		pushHandlerWorker2.prepareWork();
		List<SObject> result2 = pushHandlerWorker2.doWork();
	}

	@IsTest
	static void testReserveHandlerWorker() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Integration_Chunk_Size__c = 25;
		customSettings.Integration_Delay_Between_Callouts__c = 0;
		update customSettings;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;

		CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
		rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert rs;

		CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
		bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
		insert bsItem;

		CS_Revenue_Schedule_Item__c rsItem = new CS_Revenue_Schedule_Item__c();
		rsItem.Sales_Order__c = so.Id;
		rsItem.Product_Configuration__c = prodConfig.Id;
		rsItem.Revenue_Schedule__c = rs.Id;
		rsItem.Status__c = 'Forecast';
		insert rsItem;

		csam__AsyncMessOptions__c asyncMessOptions = new csam__AsyncMessOptions__c();
		asyncMessOptions.csam__Disable_Validations__c = true;
		insert asyncMessOptions;

		csam__ObjectGraph_Callout_Handler__c fulfilmentItemPushReserveOGCH = new csam__ObjectGraph_Callout_Handler__c();
		fulfilmentItemPushReserveOGCH.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
		fulfilmentItemPushReserveOGCH.csam__URL_Path__c = '/services/adserver/fulfilment/new';
		fulfilmentItemPushReserveOGCH.csam__Method__c = 'PUT';
		fulfilmentItemPushReserveOGCH.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment_Item__c';
		fulfilmentItemPushReserveOGCH.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
		fulfilmentItemPushReserveOGCH.Handler_Class__c = 'FulfilmentExceptionEvent.ReserveHandlerWorker';
		insert fulfilmentItemPushReserveOGCH;

		csam__Outgoing_Message__c outgoingMessage = new csam__Outgoing_Message__c();
		outgoingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		outgoingMessage.csam__URL_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		outgoingMessage.csam__URL_File__c = '/services/adserver/fulfilment/new';
		outgoingMessage.csam__Content_Type__c = 'application/json; charset=utf-8';
		outgoingMessage.csam__HTTP_Method__c = 'PUT';
		outgoingMessage.csam__Status__c = 'Response Received';
		outgoingMessage.csam__Fast_Async__c = true;
		outgoingMessage.csam__One_Way__c = false;
		outgoingMessage.csam__ObjectGraph_Callout_Handler__c = fulfilmentItemPushReserveOGCH.Id;
		insert outgoingMessage;

		csam__Incoming_Message__c incomingMessage = new csam__Incoming_Message__c();
		incomingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		incomingMessage.csam__Incoming_URL_Path__c = '/csam/callback/fulfilment/push';
		incomingMessage.csam__HTTP_Method__c = 'POST';
		incomingMessage.csam__Status__c = 'Processed';
		incomingMessage.csam__Host__c = 'spotify--CSDev1.cs85.my.salesforce.com';
		incomingMessage.csam__Outgoing_Message__c = outgoingMessage.Id;
		insert incomingMessage;

		csam__Incoming_Message__c incomingMessage2 = [SELECT Id, Name, csam__Outgoing_Message__c,csam__Status__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c FROM csam__Incoming_Message__c WHERE Id = :incomingMessage.Id];
		FulfilmentExceptionEvent.Message message = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord = new csam__Outgoing_Message_Record__c();
		messageRecord.csam__Object_Name__c = 'csdf__Fulfilment__c';
		messageRecord.csam__Object_Record_Id__c = testFulfilment.Id;
		message.addRecord(messageRecord);

		FulfilmentExceptionEvent.Message message2 = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord2 = new csam__Outgoing_Message_Record__c();
		messageRecord2.csam__Object_Name__c = 'csdf__Fulfilment_Item__c';
		messageRecord2.csam__Object_Record_Id__c = testFulfilmentItem.Id;
		message2.addRecord(messageRecord2);

		CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;

		FulfilmentExceptionEvent.ReserveHandlerWorker reserveHandlerWorker = new FulfilmentExceptionEvent.ReserveHandlerWorker();
		reserveHandlerWorker.init(message,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		reserveHandlerWorker.prepareWork();
		List<SObject> result = reserveHandlerWorker.doWork();

		FulfilmentExceptionEvent.ReserveHandlerWorker reserveHandlerWorker2 = new FulfilmentExceptionEvent.ReserveHandlerWorker();
		reserveHandlerWorker2.init(message2,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		reserveHandlerWorker2.prepareWork();
		List<SObject> result2 = reserveHandlerWorker2.doWork();
	}

	@IsTest
	static void testReserveReleaseHandlerWorker() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Integration_Chunk_Size__c = 25;
		customSettings.Integration_Delay_Between_Callouts__c = 0;
		update customSettings;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;

		CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
		rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert rs;

		CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
		bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
		insert bsItem;

		CS_Revenue_Schedule_Item__c rsItem = new CS_Revenue_Schedule_Item__c();
		rsItem.Sales_Order__c = so.Id;
		rsItem.Product_Configuration__c = prodConfig.Id;
		rsItem.Revenue_Schedule__c = rs.Id;
		rsItem.Status__c = 'Forecast';
		insert rsItem;

		csam__AsyncMessOptions__c asyncMessOptions = new csam__AsyncMessOptions__c();
		asyncMessOptions.csam__Disable_Validations__c = true;
		insert asyncMessOptions;

		csam__ObjectGraph_Callout_Handler__c fulfilmentItemReserveReleaseOGCH = new csam__ObjectGraph_Callout_Handler__c();
		fulfilmentItemReserveReleaseOGCH.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
		fulfilmentItemReserveReleaseOGCH.csam__URL_Path__c = '/services/adserver/fulfilment/reserve-release';
		fulfilmentItemReserveReleaseOGCH.csam__Method__c = 'PUT';
		fulfilmentItemReserveReleaseOGCH.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment_Item__c';
		fulfilmentItemReserveReleaseOGCH.csam__Status_Field__c = 'csdf__Pause_Resume_Message_Status__c';
		fulfilmentItemReserveReleaseOGCH.Handler_Class__c = 'FulfilmentExceptionEvent.ReserveReleaseHandlerWorker';
		insert fulfilmentItemReserveReleaseOGCH;

		csam__Outgoing_Message__c outgoingMessage = new csam__Outgoing_Message__c();
		outgoingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		outgoingMessage.csam__URL_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		outgoingMessage.csam__URL_File__c = '/services/adserver/fulfilment/reserve-release';
		outgoingMessage.csam__Content_Type__c = 'application/json; charset=utf-8';
		outgoingMessage.csam__HTTP_Method__c = 'PUT';
		outgoingMessage.csam__Status__c = 'Response Received';
		outgoingMessage.csam__Fast_Async__c = true;
		outgoingMessage.csam__One_Way__c = false;
		outgoingMessage.csam__ObjectGraph_Callout_Handler__c = fulfilmentItemReserveReleaseOGCH.Id;
		insert outgoingMessage;

		csam__Incoming_Message__c incomingMessage = new csam__Incoming_Message__c();
		incomingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		incomingMessage.csam__Incoming_URL_Path__c = '/csam/callback/fulfilment/reserve_release';
		incomingMessage.csam__HTTP_Method__c = 'POST';
		incomingMessage.csam__Status__c = 'Processed';
		incomingMessage.csam__Host__c = 'spotify--CSDev1.cs85.my.salesforce.com';
		incomingMessage.csam__Outgoing_Message__c = outgoingMessage.Id;
		insert incomingMessage;

		csam__Incoming_Message__c incomingMessage2 = [SELECT Id, Name, csam__Outgoing_Message__c,csam__Status__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c FROM csam__Incoming_Message__c WHERE Id = :incomingMessage.Id];
		FulfilmentExceptionEvent.Message message = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord = new csam__Outgoing_Message_Record__c();
		messageRecord.csam__Object_Name__c = 'csdf__Fulfilment__c';
		messageRecord.csam__Object_Record_Id__c = testFulfilment.Id;
		message.addRecord(messageRecord);

		FulfilmentExceptionEvent.Message message2 = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord2 = new csam__Outgoing_Message_Record__c();
		messageRecord2.csam__Object_Name__c = 'csdf__Fulfilment_Item__c';
		messageRecord2.csam__Object_Record_Id__c = testFulfilmentItem.Id;
		message2.addRecord(messageRecord2);

		CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;

		FulfilmentExceptionEvent.ReserveReleaseHandlerWorker reserveReleaseHandlerWorker = new FulfilmentExceptionEvent.ReserveReleaseHandlerWorker();
		reserveReleaseHandlerWorker.init(message,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		reserveReleaseHandlerWorker.prepareWork();
		List<SObject> result = reserveReleaseHandlerWorker.doWork();

		FulfilmentExceptionEvent.ReserveReleaseHandlerWorker reserveReleaseHandlerWorker2 = new FulfilmentExceptionEvent.ReserveReleaseHandlerWorker();
		reserveReleaseHandlerWorker2.init(message2,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		reserveReleaseHandlerWorker2.prepareWork();
		List<SObject> result2 = reserveReleaseHandlerWorker2.doWork();
	}

	@IsTest
	static void testRefreshHandlerWorker() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Integration_Chunk_Size__c = 25;
		customSettings.Integration_Delay_Between_Callouts__c = 0;
		update customSettings;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.Callout_Type__c = 'ButtonSORetract';
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;

		CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
		rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert rs;

		CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
		bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
		insert bsItem;

		CS_Revenue_Schedule_Item__c rsItem = new CS_Revenue_Schedule_Item__c();
		rsItem.Sales_Order__c = so.Id;
		rsItem.Product_Configuration__c = prodConfig.Id;
		rsItem.Revenue_Schedule__c = rs.Id;
		rsItem.Status__c = 'Forecast';
		insert rsItem;

		csam__AsyncMessOptions__c asyncMessOptions = new csam__AsyncMessOptions__c();
		asyncMessOptions.csam__Disable_Validations__c = true;
		insert asyncMessOptions;

		csam__ObjectGraph_Callout_Handler__c fulfilmentItemRefreshOGCH = new csam__ObjectGraph_Callout_Handler__c();
		fulfilmentItemRefreshOGCH.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
		fulfilmentItemRefreshOGCH.csam__URL_Path__c = '/services/adserver/status';
		fulfilmentItemRefreshOGCH.csam__Method__c = 'PUT';
		fulfilmentItemRefreshOGCH.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment_Item__c';
		fulfilmentItemRefreshOGCH.csam__Status_Field__c = 'csdf__Status_Update_Message_Status__c';
		fulfilmentItemRefreshOGCH.Handler_Class__c = 'FulfilmentExceptionEvent.RefreshHandlerWorker';
		insert fulfilmentItemRefreshOGCH;

		csam__Outgoing_Message__c outgoingMessage = new csam__Outgoing_Message__c();
		outgoingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		outgoingMessage.csam__URL_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		outgoingMessage.csam__URL_File__c = '/services/adserver/status';
		outgoingMessage.csam__Content_Type__c = 'application/json; charset=utf-8';
		outgoingMessage.csam__HTTP_Method__c = 'PUT';
		outgoingMessage.csam__Status__c = 'Response Received';
		outgoingMessage.csam__Fast_Async__c = true;
		outgoingMessage.csam__One_Way__c = false;
		outgoingMessage.csam__ObjectGraph_Callout_Handler__c = fulfilmentItemRefreshOGCH.Id;
		insert outgoingMessage;

		csam__Incoming_Message__c incomingMessage = new csam__Incoming_Message__c();
		incomingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		incomingMessage.csam__Incoming_URL_Path__c = '/csam/callback/status';
		incomingMessage.csam__HTTP_Method__c = 'POST';
		incomingMessage.csam__Status__c = 'Processed';
		incomingMessage.csam__Host__c = 'spotify--CSDev1.cs85.my.salesforce.com';
		incomingMessage.csam__Outgoing_Message__c = outgoingMessage.Id;
		insert incomingMessage;

		csam__Incoming_Message__c incomingMessage2 = [SELECT Id, Name, csam__Outgoing_Message__c,csam__Status__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c FROM csam__Incoming_Message__c WHERE Id = :incomingMessage.Id];
		FulfilmentExceptionEvent.Message message = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord = new csam__Outgoing_Message_Record__c();
		messageRecord.csam__Object_Name__c = 'csdf__Fulfilment__c';
		messageRecord.csam__Object_Record_Id__c = testFulfilment.Id;
		message.addRecord(messageRecord);

		FulfilmentExceptionEvent.Message message2 = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord2 = new csam__Outgoing_Message_Record__c();
		messageRecord2.csam__Object_Name__c = 'csdf__Fulfilment_Item__c';
		messageRecord2.csam__Object_Record_Id__c = testFulfilmentItem.Id;
		message2.addRecord(messageRecord2);

		CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;

		FulfilmentExceptionEvent.RefreshHandlerWorker refreshHandlerWorker = new FulfilmentExceptionEvent.RefreshHandlerWorker();
		refreshHandlerWorker.init(message,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		refreshHandlerWorker.prepareWork();
		List<SObject> result = refreshHandlerWorker.doWork();

		FulfilmentExceptionEvent.RefreshHandlerWorker refreshHandlerWorker2 = new FulfilmentExceptionEvent.RefreshHandlerWorker();
		refreshHandlerWorker2.init(message2,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		refreshHandlerWorker2.prepareWork();
		List<SObject> result2 = refreshHandlerWorker2.doWork();
	}

	@IsTest
	static void testCancelHandlerWorker() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Integration_Chunk_Size__c = 25;
		customSettings.Integration_Delay_Between_Callouts__c = 0;
		update customSettings;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.Callout_Type__c = 'ButtonSORetract';
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;

		CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
		rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert rs;

		CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
		bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
		insert bsItem;

		CS_Revenue_Schedule_Item__c rsItem = new CS_Revenue_Schedule_Item__c();
		rsItem.Sales_Order__c = so.Id;
		rsItem.Product_Configuration__c = prodConfig.Id;
		rsItem.Revenue_Schedule__c = rs.Id;
		rsItem.Status__c = 'Forecast';
		insert rsItem;

		csam__AsyncMessOptions__c asyncMessOptions = new csam__AsyncMessOptions__c();
		asyncMessOptions.csam__Disable_Validations__c = true;
		insert asyncMessOptions;

		csam__ObjectGraph_Callout_Handler__c fulfilmentItemRefreshOGCH = new csam__ObjectGraph_Callout_Handler__c();
		fulfilmentItemRefreshOGCH.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
		fulfilmentItemRefreshOGCH.csam__URL_Path__c = '/services/adserver/fulfilment/cancel';
		fulfilmentItemRefreshOGCH.csam__Method__c = 'PUT';
		fulfilmentItemRefreshOGCH.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment_Item__c';
		fulfilmentItemRefreshOGCH.csam__Status_Field__c = 'csdf__Cancel_Message_Status__c';
		fulfilmentItemRefreshOGCH.Handler_Class__c = 'FulfilmentExceptionEvent.CancelHandlerWorker';
		insert fulfilmentItemRefreshOGCH;

		csam__Outgoing_Message__c outgoingMessage = new csam__Outgoing_Message__c();
		outgoingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		outgoingMessage.csam__URL_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		outgoingMessage.csam__URL_File__c = '/services/adserver/status';
		outgoingMessage.csam__Content_Type__c = 'application/json; charset=utf-8';
		outgoingMessage.csam__HTTP_Method__c = 'PUT';
		outgoingMessage.csam__Status__c = 'Response Received';
		outgoingMessage.csam__Fast_Async__c = true;
		outgoingMessage.csam__One_Way__c = false;
		outgoingMessage.csam__ObjectGraph_Callout_Handler__c = fulfilmentItemRefreshOGCH.Id;
		insert outgoingMessage;

		csam__Incoming_Message__c incomingMessage = new csam__Incoming_Message__c();
		incomingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		incomingMessage.csam__Incoming_URL_Path__c = '/csam/callback/status';
		incomingMessage.csam__HTTP_Method__c = 'POST';
		incomingMessage.csam__Status__c = 'Processed';
		incomingMessage.csam__Host__c = 'spotify--CSDev1.cs85.my.salesforce.com';
		incomingMessage.csam__Outgoing_Message__c = outgoingMessage.Id;
		insert incomingMessage;

		csam__Incoming_Message__c incomingMessage2 = [SELECT Id, Name, csam__Outgoing_Message__c,csam__Status__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c FROM csam__Incoming_Message__c WHERE Id = :incomingMessage.Id];
		FulfilmentExceptionEvent.Message message = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord = new csam__Outgoing_Message_Record__c();
		messageRecord.csam__Object_Name__c = 'csdf__Fulfilment__c';
		messageRecord.csam__Object_Record_Id__c = testFulfilment.Id;
		message.addRecord(messageRecord);

		FulfilmentExceptionEvent.Message message2 = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord2 = new csam__Outgoing_Message_Record__c();
		messageRecord2.csam__Object_Name__c = 'csdf__Fulfilment_Item__c';
		messageRecord2.csam__Object_Record_Id__c = testFulfilmentItem.Id;
		message2.addRecord(messageRecord2);

		CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;

		FulfilmentExceptionEvent.CancelHandlerWorker cancelHandlerWorker = new FulfilmentExceptionEvent.CancelHandlerWorker();
		cancelHandlerWorker.init(message,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		cancelHandlerWorker.prepareWork();
		List<SObject> result = cancelHandlerWorker.doWork();

		FulfilmentExceptionEvent.CancelHandlerWorker cancelHandlerWorker2 = new FulfilmentExceptionEvent.CancelHandlerWorker();
		cancelHandlerWorker2.init(message2,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		cancelHandlerWorker2.prepareWork();
		//  List<sObject> result2 = cancelHandlerWorker2.doWork();
	}

	@IsTest
	static void testCancelItemHandlerWorker() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
		customSettings.Integration_Chunk_Size__c = 25;
		customSettings.Integration_Delay_Between_Callouts__c = 0;
		update customSettings;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.Callout_Type__c = 'ButtonSORetract';
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		testFulfilment.Message_Type__c = 'Fulfilment Push';
		insert testFulfilment;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		insert prodConfig;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		insert testAttr1;

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;

		CS_Revenue_Schedule__c rs = new CS_Revenue_Schedule__c();
		rs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert rs;

		CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
		bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Fulfilment_Item__c = testFulfilmentItem.Id;
		bsItem.Status__c = CS_const_SalesOrder.ScheduleStatus_Forecast;
		insert bsItem;

		CS_Billing_Schedule_Item__c bsItem2 = new CS_Billing_Schedule_Item__c();
		bsItem2.Sales_Order__c = so.Id;
		bsItem2.Product_Configuration__c = prodConfig.Id;
		bsItem2.Billing_Schedule__c = bs.Id;
		bsItem2.Fulfilment_Item__c = testFulfilmentItem.Id;
		bsItem2.Status__c = CS_const_SalesOrder.ScheduleStatus_Forecast;
		insert bsItem2;


		CS_Revenue_Schedule_Item__c rsItem = new CS_Revenue_Schedule_Item__c();
		rsItem.Sales_Order__c = so.Id;
		rsItem.Product_Configuration__c = prodConfig.Id;
		rsItem.Revenue_Schedule__c = rs.Id;
		rsItem.Fulfilment_Item__c = testFulfilmentItem.Id;
		rsItem.Status__c = CS_const_SalesOrder.ScheduleStatus_Forecast;
		insert rsItem;

		CS_Revenue_Schedule_Item__c rsItem2 = new CS_Revenue_Schedule_Item__c();
		rsItem2.Sales_Order__c = so.Id;
		rsItem2.Product_Configuration__c = prodConfig.Id;
		rsItem2.Revenue_Schedule__c = rs.Id;
		rsItem2.Fulfilment_Item__c = testFulfilmentItem.Id;
		rsItem2.Status__c = CS_const_SalesOrder.ScheduleStatus_Forecast;
		insert rsItem2;

		csam__AsyncMessOptions__c asyncMessOptions = new csam__AsyncMessOptions__c();
		asyncMessOptions.csam__Disable_Validations__c = true;
		insert asyncMessOptions;

		csam__ObjectGraph_Callout_Handler__c fulfilmentItemRefreshOGCH = new csam__ObjectGraph_Callout_Handler__c();
		fulfilmentItemRefreshOGCH.Name = 'Fulfilment Item Archive';
		fulfilmentItemRefreshOGCH.csam__Integration_Endpoint_Name__c = 'Ad Server Integration';
		fulfilmentItemRefreshOGCH.csam__URL_Path__c = '/services/adserver/fulfilment/cancel';
		fulfilmentItemRefreshOGCH.csam__Method__c = 'PUT';
		fulfilmentItemRefreshOGCH.csam__Startpoint_Type_Name__c = 'csdf__Fulfilment_Item__c';
		fulfilmentItemRefreshOGCH.csam__Status_Field__c = 'csdf__Cancel_Message_Status__c';
		fulfilmentItemRefreshOGCH.Handler_Class__c = 'FulfilmentExceptionEvent.CancelItemHandlerWorker';
		insert fulfilmentItemRefreshOGCH;

		csam__Outgoing_Message__c outgoingMessage = new csam__Outgoing_Message__c();
		outgoingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		outgoingMessage.csam__URL_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
		outgoingMessage.csam__URL_File__c = '/services/adserver/fulfilment/cancel';
		outgoingMessage.csam__Content_Type__c = 'application/json; charset=utf-8';
		outgoingMessage.csam__HTTP_Method__c = 'PUT';
		outgoingMessage.csam__Status__c = 'Response Received';
		outgoingMessage.csam__Fast_Async__c = true;
		outgoingMessage.csam__One_Way__c = false;
		outgoingMessage.csam__ObjectGraph_Callout_Handler__c = fulfilmentItemRefreshOGCH.Id;
		insert outgoingMessage;

		csam__Incoming_Message__c incomingMessage = new csam__Incoming_Message__c();
		incomingMessage.Name = 'cs-00D6E0000008xSQ-1549969393116--6377007385442160420';
		incomingMessage.csam__Incoming_URL_Path__c = '/csam/callback/fulfilment/cancel';
		incomingMessage.csam__HTTP_Method__c = 'POST';
		incomingMessage.csam__Status__c = 'Processed';
		incomingMessage.csam__Host__c = 'spotify--CSDev1.cs85.my.salesforce.com';
		incomingMessage.csam__Outgoing_Message__c = outgoingMessage.Id;
		insert incomingMessage;

		csam__Incoming_Message__c incomingMessage2 = [SELECT Id, Name, csam__Outgoing_Message__c,csam__Status__c, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__r.Name, csam__Outgoing_Message__r.csam__ObjectGraph_Callout_Handler__c FROM csam__Incoming_Message__c WHERE Id = :incomingMessage.Id];
		FulfilmentExceptionEvent.Message message = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord = new csam__Outgoing_Message_Record__c();
		messageRecord.csam__Object_Name__c = 'csdf__Fulfilment__c';
		messageRecord.csam__Object_Record_Id__c = testFulfilment.Id;
		csam__Outgoing_Message_Record__c messageRecord2 = new csam__Outgoing_Message_Record__c();
		messageRecord2.csam__Object_Name__c = 'csdf__Fulfilment_Item__c';
		messageRecord2.csam__Object_Record_Id__c = testFulfilmentItem.Id;
		message.addRecord(messageRecord);
		message.addRecord(messageRecord2);

		FulfilmentExceptionEvent.Message message2 = new FulfilmentExceptionEvent.Message(incomingMessage2);
		csam__Outgoing_Message_Record__c messageRecord3 = new csam__Outgoing_Message_Record__c();
		messageRecord3.csam__Object_Name__c = 'csdf__Fulfilment_Item__c';
		messageRecord3.csam__Object_Record_Id__c = testFulfilmentItem.Id;
		message2.addRecord(messageRecord3);

		CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;

		FulfilmentExceptionEvent.CancelItemHandlerWorker cancelItemHandlerWorker = new FulfilmentExceptionEvent.CancelItemHandlerWorker();
		cancelItemHandlerWorker.init(message,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		cancelItemHandlerWorker.prepareWork();
		List<SObject> result = cancelItemHandlerWorker.doWork();

		FulfilmentExceptionEvent.CancelItemHandlerWorker cancelItemHandlerWorker2 = new FulfilmentExceptionEvent.CancelItemHandlerWorker();
		cancelItemHandlerWorker2.init(message2,
				so,
				testFulfilment,
				new List<csdf__Fulfilment_Item__c>{
						testFulfilmentItem
				},
				new List<CS_Billing_Schedule_Item__c>{
						bsItem2
				},
				new List<CS_Revenue_Schedule_Item__c>{
						rsItem2
				},
				new List<CSPOFA__Orchestration_Step__c>{
						testOrchestrationStep
				},
				CS_LogWorker.getInstance());
		cancelItemHandlerWorker2.prepareWork();
		List<SObject> result2 = cancelItemHandlerWorker2.doWork();
	}
}