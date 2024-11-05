@isTest
public class ServicesTest {
    static testMethod void ServiceTestMethod(){
        Service__c s = new Service__c(Name = 'Other',Service_Description__c = 'Service Description',Active__c = true);
        insert s ;
        
        Work_Order__c work;
        work = new Work_Order__c();
        work.Van_assignment__c = 'Van5'; 
        work.Requested_By__c = 'Test';
        work.Start_Date__c = system.today();
        work.OwnerId = UserInfo.getUserId();
        insert work; 
        
        Work_Order_Item__c workItem = new Work_Order_Item__c(Work_Order__c = work.id,Services__c = 'Other');
        insert workItem;
    }

}