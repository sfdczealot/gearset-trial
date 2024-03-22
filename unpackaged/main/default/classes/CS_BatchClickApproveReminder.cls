/**
 * @name CS_BatchClickApproveReminder
 * @description Class that handles sending email reminders for ClickApprove
 * @revision
 *
 */
public class CS_BatchClickApproveReminder extends CS_SalesOrderScheduleBatch implements Schedulable {
	private Datetime executeDate;
	private Integer offerReminderDays;
	private Integer retryBatchAttempt;
	private Boolean errorOnSendingEmails;

	@TestVisible
	private static String QUERY_TEMPLATE = 'SELECT Id, cscap__Opportunity__c, CreatedDate, CreatedById, CSCAP__Contact__c ' +
			'FROM cscap__Customer_Approval__c ' +
			'WHERE cscap__Approved_By_Customer__c = null AND cscap__Rejected_By_Customer__c = null ' +
			'AND Reminder_Sent__c = false AND CreatedDate <= {0}';

	/**
     * Class constructor
     * @return CS_BatchClickApproveReminder
     */
	public CS_BatchClickApproveReminder() {
		this(Datetime.now(), 1);
		this.retryBatchAttempt = Integer.valueOf(CSCAP__ClickApprove_Constants__c.getInstance().Reminder_Email_Retry_Attempts__c);
		this.errorOnSendingEmails = false;
	}

	/**
     * Class constructor with Date and retry Batch parameter
     * @return CS_BatchClickApproveReminder
     */
	public CS_BatchClickApproveReminder(Datetime executeDate, Integer retryBatchAttempt) {
		super('CS_BatchClickApproveReminder', 1);
		this.executeDate = executeDate;
		this.retryBatchAttempt = retryBatchAttempt;
		this.errorOnSendingEmails = false;
	}

	public override void init(String processName, Integer batchSize) {
		super.init(processName, batchSize);
		this.executeDate = Datetime.now();
		this.offerReminderDays = Integer.valueOf(CSCAP__ClickApprove_Constants__c.getInstance().ClickApprove_Reminder_Days__c * -1);
	}

	/**
     * Method that send email reminders
     * @param  customerApprovals List<SObject>
     */
	public override void doWork(List<SObject> customerApprovals) {
		Map<Id, SObject> customerApprovalsToProcess = new Map<Id, SObject>(customerApprovals);

		try {
			EmailTemplate emailTemplate = [
					SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
					FROM EmailTemplate
					WHERE Name = :CS_Constants.EMAIL_TEMPLATE_CA_REMINDER_TEMPLATE
			];
			Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>{};
			Map<Integer, SObject> indexToCustomerApproval = new Map<Integer, SObject>();
			Integer index = 0;

			for (SObject approval : customerApprovals) {
				// TODO: check which object will be in email template and to what address to send
				Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
				message.setTargetObjectId((Id) approval.get('CreatedById'));
				message.setSenderDisplayName('ClickApprove');
				message.setUseSignature(false);
				message.setBccSender(false);
				message.setSaveAsActivity(false);
				message.setTemplateId(emailTemplate.Id);
				message.setWhatId((Id) approval.get('CSCAP__Contact__c'));
				messages.add(message);

				approval.put('Reminder_Sent__c', true);

				indexToCustomerApproval.put(index, approval);
				index++;
			}

			index = 0;

			if (messages.size() > 0) {
				for (Messaging.SendEmailResult sendResult : Messaging.sendEmail(messages, true)) {
					if (!sendResult.isSuccess()) {
						errorOnSendingEmails = true;
						indexToCustomerApproval.get(index).put('Reminder_Sent__c', false);

						for (Messaging.SendEmailError sendResultError : sendResult.getErrors()) {
							log.addMessage(String.valueOf(indexToCustomerApproval.get(index).get('Id')),
									sendResultError.getMessage(), String.valueOf(sendResultError.getStatusCode()),
									String.valueOf(sendResultError.getFields()), sendResultError.getMessage());
						}
					}
					index++;
				}
			}

			update customerApprovals;
		} catch (Exception e) {
			for (Id customerApprovalId : customerApprovalsToProcess.keySet()) {
				log.addMessage(e, customerApprovalId);
			}

			this.success = false;
		}
	}

	@TestVisible
	protected override Database.QueryLocator onStart() {
		this.queryString = getQueryString(QUERY_TEMPLATE);
		return super.onStart();
	}

	@TestVisible
	private String getQueryString(String template) {
		return String.format(template, new List<String>{
				(executeDate.addDays(offerReminderDays).formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''))
		});
	}

	/**
     * Method execute on finish of the batch
     * @return Database.QueryLocator
     */
	@TestVisible
	protected virtual override void onFinish() {
		this.recordCount = dml.recordCount;
		if (retryBatchAttempt > 0 && errorOnSendingEmails) {
			CS_BatchClickApproveReminder batchClickApproveReminder = new CS_BatchClickApproveReminder(executeDate, retryBatchAttempt--);
			batchClickApproveReminder.execute();
		}
	}
}