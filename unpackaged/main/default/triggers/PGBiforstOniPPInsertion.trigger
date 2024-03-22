trigger PGBiforstOniPPInsertion on Biforst_Sync__e (after insert) {
boolean isEnabled = true;
    
    //Check trigger execute
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('PGBiforstOniPPInsertion');
    isEnabled = TE.Enable_del__c;
    
    if(isEnabled)
    {
        TriggerDispatcher.run(new PGBiforstOniPPInsertionController(), 'PGBiforstOniPPInsertion');
    }
}