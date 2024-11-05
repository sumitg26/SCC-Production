@isTest
public class CreateInvoiceControllerTest {
    static testMethod void Invoice(){
        User u = [select id, name, email from User where Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
        account acc = new account();
        acc.name = 'test account';
        insert acc;
        EmailTemplate et = [select id,Name from EmailTemplate where Name = 'Interval Cleaning Contract'];
        contact con = new contact();
        con.LastName = 'Kumarr technologies invoice';
        con.Email = 'test@email.com';
        con.AccountId = acc.Id;
        insert con;
        
        Work_Order__c work;
        work = new Work_Order__c();
        work.Van_assignment__c = 'Van5';
        work.Account_Name__c = acc.Id;
        work.Requested_By__c = 'Test';
        String val = 'Bleaching;Carpet Roll;Banding;Wear That Looks Like Soil;Pivot Wear;Residual Urine Smell;Stain Magic;';
        work.Invoice_Notes_Options__c = val;
        work.Invoice_Notes__c = 'My Invoice Notes';
        work.Start_Date__c = system.today();
        work.Status__c = 'Completed';
        work.OwnerId = UserInfo.getUserId();
        work.Field_Crew_End_Time__c = system.today()-1;
        work.Field_Crew_Start_Time__c = system.today();
        work.Invoice_Frequency__c = 'Monthly';  
        work.Discount__c='Custom';  
        work.Discount_Percentage__c = 10;   
        insert work;    
            
        Service__c serv = new Service__c(); 
        serv.Active__c = true;  
        serv.Service_Description__c = 'Description';    
        serv.Price__c = 123;    
        serv.name = 'test'; 
        insert serv;    
            
        Work_Order_Item__c item = new Work_Order_Item__c(); 
        item.Work_Order__c = work.id;   
        item.Service__c = serv.id;  
        item.Comment__c = 'comm';   
        item.Price__c = 200;    
        insert item;    
            
        ContentVersion contentVersionInsert = new ContentVersion(Title = 'Test',PathOnClient = 'Test.jpg',  
                                                                 VersionData = Blob.valueOf('Test Content Data'),   
                                                                 IsMajorVersion = true);    
        insert contentVersionInsert;    
            
        // Test INSERT  
        ContentVersion contentVersionSelect = [SELECT Id, Title, ContentDocumentId FROM ContentVersion  
                                               WHERE Id = :contentVersionInsert.Id LIMIT 1];    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];    
        System.assertEquals(documents.size(), 1);
        List <string> ids = new list<string>();
        ids.add(item.id);
        string jsonIds = JSON.serialize(ids);
        ApexPages.currentPage().getParameters().put('woiIdJson', jsonIds);
        ApexPages.currentPage().getParameters().put('id', work.id); 
        //ApexPages.currentPage().getParameters().put('woItem', item.id);   
        ApexPages.StandardController sc = new ApexPages.StandardController(work);   
        CreateInvoiceController invoice1 = new CreateInvoiceController(sc); 
            
        system.runAs(u){
            invoice1.attachment = true;
            invoice1.saveAttachement();
            CreateInvoiceController invoice = new CreateInvoiceController();
            invoice1.attachment = true;
            invoice1.LoggedInUserEmail = u.email;
            invoice1.getContacts();
            invoice1.getTemplates();
            invoice1.onChangeTemplate();
            invoice1.getEmailTemplates();
            invoice1.selectedEmailTemplate = et.Id;
            invoice1.onChangeRadio();
            invoice1.cancel();
            work.Status__c = 'Invoice Paid';
            update work;
            invoice1.getTemplates();
            //invoice1.initialised = false;
            invoice1.selectedTemplate = 'Smart Invoice with BL Report';
            invoice1.selectedMethod = 'Attach';
            invoice1.onChangeRadio();
            invoice1.onChangeTemplate();
            invoice1.getContentDis();
            
            invoice1.getOrgwideAddress();
            invoice1.cancelForCommunity();
            invoice1.templateId= et.id;
            invoice1.prepareEmail(); 
            invoice1.onChangePrepareEmail();
            //invoice1.prepareEmail();
            //invoice1.sendInvoiceEmail();
        }
        
    }
    
    static testMethod void Invoice1(){
        account acc = new account();
        acc.name = 'Sailfin test account';
        insert acc;
        contact con = new contact();
        con.LastName = 'sailfin technologies invoice';
        con.Email = 'test@email.com';
        con.AccountId = acc.Id;
        insert con;
        
        Work_Order__c work;
        work = new Work_Order__c();
        work.Account_Name__c = acc.Id;
        work.Van_assignment__c = 'Van5'; 
        work.Requested_By__c = 'Test';
        work.Start_Date__c = system.today();
        work.Status__c = 'Invoice Paid';
        work.OwnerId = UserInfo.getUserId();
        work.Field_Crew_End_Time__c = system.today()-1;
        work.Field_Crew_Start_Time__c = system.today();
         work.Invoice_Frequency__c = 'Single';  
        insert work;    
            
        Service__c serv = new Service__c(); 
        serv.Active__c = true;  
        serv.Service_Description__c = 'Description';    
        serv.Price__c = 123;    
        insert serv;    
            
        Work_Order_Item__c item = new Work_Order_Item__c(); 
        item.Work_Order__c = work.id;   
        item.Service__c = serv.id;  
        insert item;    
            
        ApexPages.currentPage().getParameters().put('woItem', 'null');  
        ApexPages.currentPage().getParameters().put('id', work.id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(work);   
        CreateInvoiceController invoice1 = new CreateInvoiceController(sc); 
            
        //CreateInvoiceController invoice = new CreateInvoiceController();  
        //invoice1.attachment = true;   
        invoice1.getContentDis();
        invoice1.getContacts();
        invoice1.getTemplates();
        invoice1.onChangeTemplate();
        invoice1.onChangeRadio();
        invoice1.cancel();
        invoice1.getTemplates();
        //invoice1.initialised = true;
        invoice1.selectedTemplate = 'Work Order Invoice Paid';
        invoice1.selectedMethod = 'Email';
        invoice1.onChangeRadio();
        invoice1.onChangeTemplate();
        invoice1.saveAttachement();
        
    }
    
    static testMethod void Invoice2(){
        Work_Order__c work;
        work = new Work_Order__c();
        work.Van_assignment__c = 'Van5'; 
        work.Requested_By__c = 'Test';
        work.Start_Date__c = system.today();
        work.Status__c = 'Invoice Paid';
        work.Blacklight_Inspection__c = 'Blacklight Inspection with Brief Report';
        work.OwnerId = UserInfo.getUserId();
        work.Field_Crew_End_Time__c = system.today()-1;
        work.Field_Crew_Start_Time__c = system.today();
        insert work;
        
        Service__c serv = new Service__c();
        serv.Active__c = true;
        serv.Service_Description__c = 'Description';
        serv.Price__c = 123;
        insert serv;
        
        Work_Order_Item__c item = new Work_Order_Item__c();
        item.Work_Order__c = work.id;
        item.Service__c = serv.id;
        insert item;
        
        ApexPages.currentPage().getParameters().put('id', work.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(work);
        CreateInvoiceController invoice1 = new CreateInvoiceController(sc);
        
        //CreateInvoiceController invoice = new CreateInvoiceController();
        invoice1.attachment = true;
        invoice1.getContacts();
        invoice1.getTemplates();
        invoice1.onChangeTemplate();
        invoice1.onChangeRadio();
        invoice1.cancel();
        invoice1.getTemplates();
        invoice1.initialised = false;
        invoice1.selectedTemplate = 'Work Order Invoice Paid';
        invoice1.selectedMethod = 'Attach';
        invoice1.onChangeRadio();
        invoice1.onChangeTemplate();
        invoice1.saveAttachement();
        
    }
}