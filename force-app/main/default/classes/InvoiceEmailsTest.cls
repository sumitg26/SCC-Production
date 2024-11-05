@isTest
public class InvoiceEmailsTest {
    static testMethod void invoice(){
        Account a = new Account(Name = 'Smart Supply Co LLC', Invoice_Email_1__c = 'a@gmail.com',Invoice_Email_2__c = 'b@gmail.com',
                                Invoice_Email_3__c = 'c@gmail.com', Email__c = 'email@gmail.com',Primary_Contact__c = 'Test User');
        insert a;
        
    }
    static testMethod void myUnitTest() {
        Account a1 = new Account(Name = 'Smart Supply Co LLC1', Invoice_Email_1__c = 'a@gmail.com',Invoice_Email_2__c = 'b@gmail.com',
                                Invoice_Email_3__c = 'c@gmail.com', Email__c = 'email@gmail.com',Primary_Contact__c = 'Test User');
        insert a1;
        //Insert test acc record
        Account a = new Account(Name = 'Smart Supply Co LLC',parentId=a1.Id, Invoice_Email_1__c = 'a@gmail.com',Invoice_Email_2__c = 'b@gmail.com',
                                Invoice_Email_3__c = 'c@gmail.com', Email__c = 'email@gmail.com',Primary_Contact__c = 'Test User');
        insert a;
        
        //Insert emailmessage for acc
        EmailMessage ParentTskObj = new EmailMessage();
         ParentTskObj.RelatedToId = a.id;
            ParentTskObj.Subject = 't.Subject';
            ParentTskObj.FromAddress = system.UserInfo.getUserEmail();
            ParentTskObj.FromName = userinfo.getFirstName();
            ParentTskObj.ToAddress = system.UserInfo.getUserEmail();
            ParentTskObj.BccAddress = system.UserInfo.getUserEmail();
            ParentTskObj.CcAddress = system.UserInfo.getUserEmail();
            ParentTskObj.HtmlBody = 'Body';
        insert ParentTskObj;
    }
}