/**
* @desc	SObject factory that can be used in unit tests to create test data.
* @version	1.0
* @date	2018/04/24
* @see https://github.com/dhoechst/Salesforce-Test-Factory
*/
@isTest
public class TestFactory {

	public static String SYSTEM_ADMIN_PROFILE_NAME = 'S: Systems Administrator';

	public static Boolean runningInASandbox() {
		return [SELECT Id, IsSandbox FROM Organization LIMIT 1].IsSandbox;
	}

	public static SObject createSObject(SObject sObj) {
		// Check what type of object we are creating and add any defaults that are needed.
		String objectName = String.valueOf(sObj.getSObjectType());
		// Construct the default values class. Salesforce doesn't allow '__' in class names
		String defaultClassName = 'TestFactory.' + objectName.replaceAll('__(c|C)$|__', '') + 'Defaults';
		// If there is a class that exists for the default values, then use them
		if (Type.forName(defaultClassName) != null) {
			sObj = createSObject(sObj, defaultClassName);
		}
		return sObj;
	}

	public static SObject createSObject(SObject sObj, Boolean doInsert) {
		SObject retObject = createSObject(sObj);
		if (doInsert) {
			insert retObject;
		}
		return retObject;
	}

	public static SObject createSObject(SObject sObj, String defaultClassName) {
		// Create an instance of the defaults class so we can get the Map of field defaults
		Type t = Type.forName(defaultClassName);
		if (t == null) {
			Throw new TestFactoryException('Invalid defaults class.');
		}
		FieldDefaults defaults = (FieldDefaults)t.newInstance();
		addFieldDefaults(sObj, defaults.getFieldDefaults());
		return sObj;
	}

	public static SObject createSObject(SObject sObj, String defaultClassName, Boolean doInsert) {
		SObject retObject = createSObject(sObj, defaultClassName);
		if (doInsert) {
			insert retObject;
		}
		return retObject;
	}

	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects) {
		return createSObjectList(sObj, numberOfObjects, (String)null);
	}

	public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, Boolean doInsert) {
		SObject[] retList = createSObjectList(sObj, numberOfObjects, (String)null);
		if (doInsert) {
			insert retList;
		}
		return retList;
	}

	public static SObject[] createSObjectList(SObject sObj, Integer numberOfObjects, String defaultClassName, Boolean doInsert) {
		SObject[] retList = createSObjectList(sObj, numberOfObjects, defaultClassName);
		if (doInsert) {
			insert retList;
		}
		return retList;
	}

	public static SObject[] createSObjectList(Sobject sObj, Integer numberOfObjects, String defaultClassName) {
		SObject[] sObjs = new SObject[] {};
		SObject newObj;

		// Get one copy of the object
		if (defaultClassName == null) {
			newObj = createSObject(sObj);
		} else {
			newObj = createSObject(sObj, defaultClassName);
		}

		// Get the name field for the object
		String nameField = nameFieldMap.get(String.valueOf(sObj.getSObjectType()));
		if (nameField == null) {
			nameField = 'Name';
		}

		// Clone the object the number of times requested. Increment the name field so each record is unique
		for (Integer i = 0; i < numberOfObjects; i++) {
			SObject clonedSObj = newObj.clone(false, true);
			clonedSObj.put(nameField, (String)clonedSObj.get(nameField) + ' ' + i);
			sObjs.add(clonedSObj);
		}
		return sObjs;
	}

	private static void addFieldDefaults(SObject sObj, Map<Schema.SObjectField, Object> defaults) {
		// Loop through the map of fields and if they weren't specifically assigned, fill them.
		Map<String, Object> populatedFields = sObj.getPopulatedFieldsAsMap();
        	for (Schema.SObjectField field : defaults.keySet()) {
			if (!populatedFields.containsKey(String.valueOf(field))) {
				sObj.put(field, defaults.get(field));
			}
		}
	}

	// When we create a list of SObjects, we need to
	private static Map<String, String> nameFieldMap = new Map<String, String> {
		'Contact' => 'LastName',
		'Case' => 'Subject'
	};

	public class TestFactoryException extends Exception {}

	// Use the FieldDefaults interface to set up values you want to default in for all objects.
	public interface FieldDefaults {
		Map<Schema.SObjectField, Object> getFieldDefaults();
	}

	// To specify defaults for objects, use the naming convention [ObjectName]Defaults.
	// For custom objects, omit the __c from the Object Name

	public class AccountDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Account.Name => 'Test Account'
			};
		}
	}

	public class ContactDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Contact.FirstName => 'First',
				Contact.LastName => 'Last'
			};
		}
	}

	public class OpportunityDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Opportunity.Name => 'Test Opportunity',
				Opportunity.StageName => 'Closed Won',
				Opportunity.CloseDate => System.today(),
				Opportunity.Probability => 10
			};
		}
	}

	public class CaseDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Case.Subject => 'Test Case'
			};
		}
	}

	public class FinanceDataDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
			};
		}
	}

	public class Ad_ServerDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				csdf__Ad_Server__c.Name => 'Test DSM Ad Server',
                csdf__Ad_Server__c.csdf__Type__c => 'DFP',
                csdf__Ad_Server__c.csdf__Network_Code__c => '010101010',
                csdf__Ad_Server__c.csdf__Client_Id__c => 'testClientId',
                csdf__Ad_Server__c.csdf__Client_Secret__c => 'testClientSecret',
                csdf__Ad_Server__c.csdf__Refresh_Token__c => 'testRefreshToken'
			};
		}
	}

	public class UserDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				User.Username => Crypto.getRandomInteger() + '@' + Crypto.getRandomInteger() + '.com',
				User.Lastname => Crypto.getRandomInteger() + '',
				User.Email => 'test@test.com',
				User.Alias => (Crypto.getRandomInteger() + 'testtest').substring(0, 8),
				User.CommunityNickname => (Crypto.getRandomInteger() + 'testtest').substring(0, 8),
				User.TimeZoneSidKey => 'GMT',
				User.LocaleSidKey => 'en_US',
				User.EmailEncodingKey => 'ISO-8859-1',
				User.LanguageLocaleKey => 'en_US'

			};
		}
	}

	public class CreditRequestHeaderDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
			};
		}
	}

	public class PremiumCodeBatchAuthorizationDefaults implements FieldDefaults {
		public Map<Schema.SObjectField, Object> getFieldDefaults() {
			return new Map<Schema.SObjectField, Object> {
				Premium_Code_Batch_Authorization__c.Authorization_request_name__c => 'PCBA-'
			};
		}
	}





}