@isTest
public class accountControllerExtensionTest {
    @isTest
    static void positiveCase() {
        Account acct = new Account();
        acct.Name = 'Damco';
        acct.Email__c = 'test@damcogroup.com';
        insert acct;
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        accountControllerExtension testAcc = new accountControllerExtension(sc);
        PageReference pageRef = Page.accountDelete; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(acct.Id));
        Test.setCurrentPage(pageRef);
        testAcc.deleteAccounts();
        //testAccPlan.save(); call all your function here
        Test.StopTest();
    }
    @isTest
    static void negativeCase() {
        Account acct = new Account();
        acct.Name = 'Damco';
        acct.Email__c = 'test@damcogroup.com';
        insert acct;
        
        Work_Order__c wtest = new Work_Order__c();
        wtest.Account_Name__c = acct.Id;
        insert wtest;    
        
        Test.StartTest(); 
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        accountControllerExtension testAcc = new accountControllerExtension(sc);
        PageReference pageRef = Page.accountDelete; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(acct.Id));
        Test.setCurrentPage(pageRef);
        testAcc.deleteAccounts();
        //testAccPlan.save(); call all your function here
        Test.StopTest();
    }
    @isTest
    static void redirect() {
        Account acct = new Account();
        acct.Name = 'Damco';
        acct.Email__c = 'test@damcogroup.com';
        insert acct;
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(acct);
        accountControllerExtension testAcc = new accountControllerExtension(sc);
        PageReference pageRef = Page.accountDelete; // Add your VF page Name here
        pageRef.getParameters().put('id', String.valueOf(acct.Id));
        Test.setCurrentPage(pageRef);
        testAcc.accountRecordView();
    }
}