@isTest
public class feedbackformTest {
    static testMethod void formtestFalse(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Contact cont = new Contact();
        cont.FirstName = 'Test';
        cont.LastName = 'Test';
        cont.AccountId = acc.Id;
        insert cont;
        Lead led = new Lead();
        led.LastName = 'Test';
        led.Company = 'Test1';
        led.Status = 'New Lead';
        led.Updated_by_Franchise_Contact__c = False;
        insert led;   
        
        Test.startTest();
        
        PageReference pageRef = Page.feedbackform;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(led.Id));
           
        LeadUpdate controller = new LeadUpdate();
        controller.InitPage();
        controller.UpdateRecord();
        PageReference prf = controller.UpdateRecord();
        
        Test.stopTest();
    }
    static testMethod void formtestTrue(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        Contact cont = new Contact();
        cont.FirstName = 'Test';
        cont.LastName = 'Test';
        cont.AccountId = acc.Id;
        insert cont;
        Lead led = new Lead();
        led.LastName = 'Test';
        led.Company = 'Test1';
        led.Status = 'New Lead';
        led.Updated_by_Franchise_Contact__c = True;
        insert led;   
        
        Test.startTest();
        
        PageReference pageRef = Page.feedbackform;
        Test.setCurrentPage(pageRef);
        
        ApexPages.currentPage().getParameters().put('id', String.valueOf(led.Id));
           
        LeadUpdate controller = new LeadUpdate();
        controller.InitPage();
        controller.UpdateRecord();
        PageReference prf = controller.UpdateRecord();
        
        Test.stopTest();
    }
}