/**
 * Created by jameshladek on 2/24/20.
 */

public with sharing class CS_BatchProcessingErrors implements Schedulable {

    public void execute(SchedulableContext param1) {
        CS_BatchProcessingErrorsHelper.checkForErrors();
    }
}