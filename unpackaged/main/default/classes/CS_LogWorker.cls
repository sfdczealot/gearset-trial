/**
 * @name CS_LogWorker
 * @description Class for Log object which allows logging
 * @revision
 *
 */
public class CS_LogWorker {
    @TestVisible
    private static CS_LogWorker instance;

    /**
     * Message string for log record
     */
    @TestVisible
    protected string message = '{0} Process {1} {2}. ';

    @TestVisible
    private Log__c log {get; set;}

    public List<Log_Message__c> logMessages {get; set;}
    
    @TestVisible
    private List<Attachment> attachments {get; set;}

    /**
     * Get an instance of the class
     * @param  processName String
     * @return             LogWorker
     */
    public static CS_LogWorker getInstance() {
        if(instance == null) {
            instance = new CS_LogWorker();
        }
        
        return instance;
    }

    /**
     * Set the instance of the class
     * @param  instance LogWorker
     */
    public static void setInstance(CS_LogWorker logInstance) {
        instance = (CS_LogWorker) logInstance;     
    }

    /**
     * Gets Log__c record
     * @return og__c
     */ 
    public Log__c getLog() {
        return this.log;
    }

    /**
     * Class constructor
     * @param  processName String
     * @return             LogWorker
     */
    private CS_LogWorker() {
        this.log = new Log__c(Start_Time__c = Datetime.now());
        this.logMessages = new List<Log_Message__c>();
        this.attachments = new List<Attachment>();
    }

    /**
     * Sets the start time of the log
     * @param startTime Datetime
     */
    public void setStartTime(Datetime startTime) {
        this.log.Start_Time__c = startTime;
    }

    /**
     * Add a new LogWorker Message to the LogWorker using Exception
     * @param e Exception
     */
    public void addMessage(Exception e) {
        addMessage(null, e.getMessage(), e.getTypeName(), CS_const_LogMessage.Type_Error, e.getStackTraceString());
    }
    
    /**
     * Add a new LogWorker Message to the LogWorker using Exception
     * @param e 	   Exception
     * @param recordId String
     */
    public void addMessage(Exception e, String recordId) {
        addMessage(recordId, e.getMessage(), e.getTypeName(), CS_const_LogMessage.Type_Error, e.getStackTraceString());
    }

    /**
     * Add a new LogWorker Message to the LogWorker using Database.SaveResult
     * @param record SObject
     * @param result Database.SaveResult
     */
    public void addMessage(SObject record, Database.SaveResult result) {
        for(Database.Error error : result.getErrors()) {
            addMessage(record.Id, error.getMessage(), String.valueOf(error.getStatusCode()), CS_const_LogMessage.Type_Error);
        }
    }
    
    /**
     * Add a new LogWorker Message to the LogWorker using Database.UpsertResult
     * @param record SObject
     * @param result Database.UpsertResult
     */
    public void addMessage(SObject record, Database.UpsertResult result) {
        for(Database.Error error : result.getErrors()) {
            addMessage(record.Id, error.getMessage(), String.valueOf(error.getStatusCode()), CS_const_LogMessage.Type_Error);
        }
    }

    /**
     * Add a new LogWorker Message to the LogWorker using Database.DeleteResult
     * @param record SObject
     * @param result Database.DeleteResult
     */
    public void addMessage(SObject record, Database.DeleteResult result) {
        for(Database.Error error : result.getErrors()) {
            addMessage(record.Id, error.getMessage(), String.valueOf(error.getStatusCode()), CS_const_LogMessage.Type_Error);
        }
    }

    /**
     * Adds a new Message to the LogWorker
     * @param recordId   String
     * @param message    String
     * @param statusCode String
     * @param type       String
     */
    public void addMessage(String recordId, String message, String statusCode, String type) {
        addMessage(recordId, message, statusCode, type, null);
    }

    /**
     * Adds a new Message to the LogWorker
     * @param recordId      String
     * @param message       String
     * @param statusCode    String
     * @param type          String
     * @param stackTrace    String
     */
    public void addMessage(String recordId, String message, String statusCode,
                           String type, String stackTrace) {
        logMessages.add(createMessage(recordId, message, statusCode, type, stackTrace));
    }
    
    public void addAttachment(String name, Blob body, String contentType) {
        attachments.add(new Attachment(Body = body, Name = name, ContentType = contentType));
    }

    /**
     * Create a new LogWorker Message record
     * @param  recordId   String
     * @param  message    String
     * @param  statusCode String
     * @param  type       String
     * @param  stackTrace String
     * @return            LogWorker_Message__c
     */
    private Log_Message__c createMessage(String recordId, String message, String statusCode,
                                         String type, String stackTrace) {
        return new Log_Message__c(Record_Id__c = recordId,
                                  Message__c = message.length() > 255 ? message.substring(0, 255) : message,
                                  Status_Code__c = statusCode,
                                  Time__c = Datetime.now(),
                                  Type__c = type,
                                  Stack_Trace__c = stackTrace);
    }

    /**
     * Saves log to database
     * @param processName String
     * @param jobType     String
     * @param jobId       String
     */
    public void save(String processName, String jobType, String jobId, Boolean success) {
        save(processName, jobType, jobId, success, null);
    }

    /**
     * Saves log to database
     * @param processName   String
     * @param jobType       String
     * @param jobId         String
     * @param appendMessage String
     */
    public void save(String processName, String jobType, String jobId, Boolean success, String appendMessage) {
        this.log.Process_Name__c = processName;
        this.log.Job_Type__c = jobType;
        this.log.Job_Id__c = jobId;
        this.log.Success__c = success;
        this.log.Message__c = formatMessage(this.message, processName, jobType,
                                            this.log.Success__c, appendMessage);
        this.log.End_Time__c = Datetime.now();
        this.log.Timer__c = (Decimal)(this.log.End_Time__c.getTime() - this.log.Start_Time__c.getTime()) / 1000;
        upsert this.log;

        if(!logMessages.isEmpty()) {
            for(Log_Message__c message : logMessages) {
            	if(message.Log__c == null) {
                	message.Log__c = this.log.Id;
            	}
            }

            upsert logMessages;
        }
        
        if(!attachments.isEmpty()) {
            for(Attachment att : attachments) {
                att.ParentId = this.log.Id;
            }

            insert attachments;
        }
    }

    /**
     * Sends email
     * @return  List<Messaging.SendEmailResult>
     */
    public List<Messaging.SendEmailResult> sendEmail() {
        String subject = log.Process_Name__c + ' ' + Datetime.now();
        String body = log.Message__c;
        body += '<br>For more information please visit: <a href="' +
                URL.getSalesforceBaseUrl().toExternalForm() + '/' + log.Id + '">' +
                URL.getSalesforceBaseUrl().toExternalForm() + '/' + log.Id + '</a>';
        if(!logMessages.isEmpty()) {
            body += '<br><br>' + 'The following messages have been captured:';
            
            for(Log_Message__c message : logMessages) {
                body += '<br>' + message.Status_Code__c + ' - ' + message.Message__c +
                        ' - Related to: ' + message.Record_Id__c;
            }
        }

        return CS_utl_Email.sendEmail(new List<String>{UserInfo.getUserEmail()}, body, body, subject);
    }

    /**
     * Formats message for the log
     * @param  message       String
     * @param  processName   String
     * @param  jobType       String
     * @param  success       Boolean
     * @param  appendMessage String
     * @return               String
     */
    @TestVisible
    private String formatMessage(String message, String processName, String jobType,
                                 Boolean success, String appendMessage) {
        if(success) {
            message = String.format(message, new List<String>{jobType, processName, 'completed successfully'});
        }
        else {
            message = String.format(message, new List<String>{jobType, processName, 'failed'});
        }

        if(String.isNotBlank(appendMessage)) {
            message += appendMessage;
        }

        return message; 
    }
}