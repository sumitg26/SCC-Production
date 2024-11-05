@isTest
private class superCloneController_Test {

	private static testMethod void test() {
	    Work_Order__c workOrdr = new Work_Order__c();
	    workOrdr.recordTypeId = Schema.SObjectType.Work_Order__c.getRecordTypeInfosByName().get('Commercial').getRecordTypeId() ;
	    workOrdr.Van_assignment__c = 'van 5';
	    workOrdr.Status__c ='Invoiced';
	    workOrdr.Field_Crew_End_Time__c = system.now();
	    insert workOrdr;
	    
        PageReference pageRef = Page.superClonePage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', workOrdr.id);
        
        //superCloneController controller = new superCloneController(); 
        
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(workOrdr);
    
        superCloneController controller = new superCloneController(stdcontroller);    
        
        
        controller.cloneRecord();
	}
    
    private static testMethod void ShareWorkOrder(){
        //User u = [SELECT id from User where Profile.Name = 'Customer Community User - Custom'];
        Profile p =[select id from Profile where Name = 'Franchise Partner Community'];        
            
        account acc = new account();
        acc.name = 'Damco test account';
        insert acc;
        
        contact con = new contact();
        con.LastName = 'Damco invoice';
        con.Email = 'test@email.com';
        con.AccountId = acc.Id;
        insert con;
        
        acc.Primary_Business_Contact__c= con.id;
        update acc;
        
        Territory_Coverage__C tc = new Territory_Coverage__C();
        tc.Zip_Code__c = '121008';
        insert tc;
        
        Account_Territory__c at = new Account_Territory__c();
        at.Account__c = acc.id;
        at.Territory_Coverage__c = tc.id;
        insert at;
        User u2 = new User(Alias = 'standt', Email=con.Email, 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='standarduserrrrrr@testorg.com',IsActive =true,ContactId = con.id);
        insert u2;
        system.debug('u2--'+u2);

        
        Work_Order__c workOrdr = new Work_Order__c();
        workOrdr.Property_Zip_Code__c = '121008';
        workOrdr.Invoice_Notes_Options__c = 'Banding';
        insert workOrdr;
        
        Work_Order__c workOrdr2 = new Work_Order__c();
        workOrdr2.Property_Zip_Code__c = '121008';
        workOrdr2.Invoice_Notes_Options__c = 'Wear That Looks Like Soil';
        insert workOrdr2;
        
        Work_Order__c workOrdr3 = new Work_Order__c();
        workOrdr3.Property_Zip_Code__c = '121008';
        workOrdr3.Invoice_Notes_Options__c = 'Residual Urine Smell';
        insert workOrdr3;
        
        Work_Order__c workOrdr4 = new Work_Order__c();
        workOrdr4.Property_Zip_Code__c = '121008';
        workOrdr4.Invoice_Notes_Options__c = 'Pivot Wear';
        insert workOrdr4;
        
        Work_Order__c workOrdr5 = new Work_Order__c();
        workOrdr5.Property_Zip_Code__c = '121008';
        workOrdr5.Invoice_Notes_Options__c = 'Stain Magic';
        insert workOrdr5;
        
        Work_Order__c workOrdr6 = new Work_Order__c();
        workOrdr6.Property_Zip_Code__c = '121008';
        workOrdr6.Invoice_Notes_Options__c = 'High Levels Of Pet Hair';
        insert workOrdr6;
        
        ShareWorkOrder.manualshare(workOrdr);
        
        /*system.runAs(u){
            Work_Order__c workOrdr = new Work_Order__c();
            workOrdr.Property_Zip_Code__c = '121008';
            insert workOrdr;
        }*/
        
    }

}