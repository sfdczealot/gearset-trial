@isTest
public class CurrentUserDetails_test {

    @isTest
    public static void test1(){
       CurrentUserDetails.getAllDetails getDet= CurrentUserDetails.getDetails();
        system.assertEquals('System Administrator', getDet.profileName, 'profile name doesnot match');
    }
}