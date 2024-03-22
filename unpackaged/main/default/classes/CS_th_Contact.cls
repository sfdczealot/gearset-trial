/**
 * @name CS_th_Contact
 * @description Factory class for Contact object
 * @revision
 *
 */
@IsTest
public class CS_th_Contact {
	/**
	 * Create a contact for test
	 * @param  firstName String
	 * @param  lastName  String
	 * @param  account   Account
	 * @return           Contact
	 */
	public static Contact create(String firstName, String lastName, Account account) {
		return create(firstName, lastName, account, true);
	}

	/**
	 * Create a contact for test
	 * @param  firstName String
	 * @param  lastName  String
	 * @param  account   Account
	 * @param  recordTypeId Id
	 * @param  insertRecord Boolean
	 * @return              Contact
	 */
	public static Contact create(String firstName, String lastName, Account account, Boolean insertRecord) {
		Contact contact = new Contact(
				FirstName = firstName,
				LastName = lastName,
				Title = 'Title',
				Email = firstName.deleteWhitespace() + '.' +
						lastName.deleteWhitespace() + '@' +
						account.Name.deleteWhitespace() + '.com',
				AccountId = account.Id,
				MailingStreet = 'Test Street',
				MailingCity = 'City',
				MailingPostalCode = '10000',
				MailingCountry = 'United States'
		);

		if (insertRecord) {
			insert contact;
		}

		return contact;
	}
}