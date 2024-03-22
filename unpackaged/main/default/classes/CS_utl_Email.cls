/**
 * @name CS_utl_Email
 * @description Utility class for Email
 * @revision
 *
 */
public class CS_utl_Email {
    /**
     * Checks if given email address is valid
     * @param  email  String
     * @return        Boolean
     */
    public static Boolean isAddressValid(String email) {
        if(String.isNotBlank(email)) {
            String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
            Pattern emailPattern = Pattern.compile(emailRegex);
            Matcher emailMatcher = emailPattern.matcher(email);

            return emailMatcher.matches();
        }

        else {
            return false;
        }
    }

    /**
     * Sends email
     * @param addresses     List<String> 
     * @param plainTextBody String
     * @param htmlBody      String
     * @param subject       String
     * @return              List<Messaging.SendEmailResult>
     */
    public static List<Messaging.SendEmailResult> sendEmail(List<String> addresses, String plainTextBody,
                                                            String htmlBody, String subject) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(addresses);
        mail.setSubject(subject);
        mail.setHtmlBody(htmlBody);
        mail.setPlainTextBody(plainTextBody);

        return Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
    }
}