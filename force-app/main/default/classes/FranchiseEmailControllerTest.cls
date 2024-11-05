@isTest
Public class FranchiseEmailControllerTest
{
       
    @isTest static void testSendEmail() {
        Lead obj = new Lead();
        obj.Email = 'test.test@gmail.com';
        obj.Franchise_Type__c = 'No Contact Made - 2 weeks';
        obj.Last_Franchise_Email_Sent__c  = Date.Today() - 15;
        obj.LastName = 'test';
        obj.Company = 'test';
        Id RecordTypeIdLead = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
        obj.recordTypeID = RecordTypeIdLead ;
        insert obj;
        
        obj = new Lead();
        obj.Email = 'test.test@gmail.com';
        obj.Franchise_Type__c = 'No Contact Made Monthly';
        obj.Last_Franchise_Email_Sent__c  = Date.Today() - 30;
        obj.LastName = 'test';
        obj.Company = 'test';
        obj.recordTypeID = RecordTypeIdLead ;
        insert obj;
        
        obj = new Lead();
        obj.Email = 'test.test@gmail.com';
        obj.Franchise_Type__c = 'Homeowner Issue';
        obj.Last_Franchise_Email_Sent__c  = Date.Today() - 30;
        obj.LastName = 'test';
        obj.Company = 'test';
        obj.recordTypeID = RecordTypeIdLead ;
        insert obj;
        
        obj = new Lead();
        obj.Email = 'test.test@gmail.com';
        obj.Franchise_Type__c = 'Full Time Issue';
        obj.Last_Franchise_Email_Sent__c  = Date.Today() - 30;
        obj.LastName = 'test';
        obj.Company = 'test';
        obj.recordTypeID = RecordTypeIdLead ;
        insert obj;
        
        obj = new Lead();
        obj.Email = 'test.test@gmail.com';
        obj.Franchise_Type__c = 'No Contact Made Quarterly';
        obj.Last_Franchise_Email_Sent__c  = Date.Today() - 90;
        obj.LastName = 'test';
        obj.Company = 'test';
        obj.recordTypeID = RecordTypeIdLead ;
        insert obj;
        
        obj = new Lead();
        obj.Email = 'test.test@gmail.com';
        obj.Franchise_Type__c = 'Not Enough Capital';
        obj.Last_Franchise_Email_Sent__c  = Date.Today() - 90;
        obj.LastName = 'test';
        obj.Company = 'test';
        obj.recordTypeID = RecordTypeIdLead ;
        insert obj;
        
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        System.RunAs(usr)
        {
            Test.startTest();
               EmailTemplate validEmailTemplate = new EmailTemplate();
                validEmailTemplate.isActive = true;
                validEmailTemplate.Name = 'Franchise No Contact Made';
                validEmailTemplate.DeveloperName = 'Franchise_No_Contact_Made';
                validEmailTemplate.TemplateType = 'text';
                validEmailTemplate.Body = 'test';
                validEmailTemplate.FolderId = UserInfo.getUserId();        
                insert validEmailTemplate;
                  
                  validEmailTemplate = new EmailTemplate();
                validEmailTemplate.isActive = true;
                validEmailTemplate.Name = 'Franchise Homeowner Issue';
                validEmailTemplate.DeveloperName = 'Franchise_Homeowner_Issue';
                validEmailTemplate.TemplateType = 'text';
                validEmailTemplate.Body = 'test';
                validEmailTemplate.FolderId = UserInfo.getUserId();        
                insert validEmailTemplate;
                
                validEmailTemplate = new EmailTemplate();
                validEmailTemplate.isActive = true;
                validEmailTemplate.Name = 'Franchise Full Time Issue';
                validEmailTemplate.DeveloperName = 'Franchise_Full_Time_Issue';
                validEmailTemplate.TemplateType = 'text';
                validEmailTemplate.Body = 'test';
                validEmailTemplate.FolderId = UserInfo.getUserId();        
                insert validEmailTemplate;
                
                validEmailTemplate = new EmailTemplate();
                validEmailTemplate.isActive = true;
                validEmailTemplate.Name = 'Franchise Not Enough Capital';
                validEmailTemplate.DeveloperName = 'Franchise_Not_Enough_Capital';
                validEmailTemplate.TemplateType = 'text';
                validEmailTemplate.Body = 'test';
                validEmailTemplate.FolderId = UserInfo.getUserId();        
                insert validEmailTemplate;
                  
                FranchiseEmailController fEmailObj = new FranchiseEmailController();
                String sch = '0 0 2 * * ?'; 
                system.schedule('Test Sched', sch , fEmailObj);
            test.stopTest();
        }
    }
}