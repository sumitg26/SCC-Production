@isTest
public class POControllerTest {
    static testMethod void POInvoice(){
        
        Account a = new Account();
        a.Name = 'Smart Supply Co LLC - Franchise Community';
        a.Email__c = 'test@test.com';
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.id;
        c.FirstName = 'test';
        c.LastName = 'Invoice';
        insert c;
        
        
        Purchase_Orders__c po = new Purchase_Orders__c();
        po.Account_Name__c = a.id;
        po.Type__c = 'Outbound';
        po.Status__c = 'Order Created';
        insert po;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Available_Quantity__c = 10,
        Family = 'Hardware');
        insert prod;
        
        Purchase_Order_Lines__c pol = new Purchase_Order_Lines__c();
        pol.Purchase_Orders__c = po.id;
        pol.Description__c = 'Description';
        pol.Product__c = prod.id;
        pol.Quantity__c = 1;
        insert pol;
        
        /*Purchase_Order_Email_Template__mdt POEmailTTtemplate = new Purchase_Order_Email_Template__mdt();
        POEmailTTtemplate.MasterLabel = 'ABC';
        POEmailTTtemplate.Template_Id__c = */
        
        ApexPages.currentPage().getParameters().put('id', po.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(po);
        POController poinv = new POController(sc);
        
        POController invoice = new POController();
        poinv.getEmailTemplates();
        poinv.selectedContacts.add(new SelectOption(c.id,c.LastName));
        poinv.getContacts();
        poinv.getOrgwideAddress();
        poinv.getTemplates();
        poinv.selectedTemplate = 'None';
        poinv.attachment = true;
        poinv.selectedTemplate = 'Purchase Order';
        poinv.selectedMethod = 'Email';
        poinv.saveAttachement();
        //poinv.prepareEmail();
        //poinv.onChangePrepareEmail();
        //poinv.sendInvoiceEmail();
        poinv.Cancel();
        poinv.cancelForCommunity();
    }    
    static testMethod void POInvoice1(){
        Account a = new Account();
        a.Name = 'Smart Supply Co LLC - Franchise Community';
        a.Email__c = 'test@test.com';
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.id;
        c.LastName = 'Invoice 1';
        insert c;
        
        Purchase_Orders__c po = new Purchase_Orders__c();
        po.Account_Name__c = a.id;
        po.Type__c = 'Outbound';
        po.Status__c = 'Order Created';
        insert po;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Available_Quantity__c = 10,
        Family = 'Hardware');
        insert prod;
        
        Purchase_Order_Lines__c pol = new Purchase_Order_Lines__c();
        pol.Purchase_Orders__c = po.id;
        pol.Description__c = 'Description';
        pol.Product__c = prod.id;
        pol.Quantity__c = 1;
        insert pol;
        
        ApexPages.currentPage().getParameters().put('id', po.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(po);
        POController poinv = new POController(sc);
        
        POController invoice = new POController();
        poinv.selectedContacts.add(new SelectOption(c.id,c.LastName));
        poinv.getContacts();
        poinv.getOrgwideAddress();
        poinv.getTemplates();
        poinv.attachment = true;
        poinv.selectedTemplate = 'Packing Slip';
        //poinv.selectedTemplate = 'Purchase Order';
        poinv.selectedMethod = 'Email';
        poinv.saveAttachement();
        poinv.Cancel();
    }
    static testMethod void POInvoice2(){
        Id profileId = [Select Id From Profile Where Name ='Franchise Partner Community'].Id;
        
        Account a = new Account();
        a.Name = 'Smart Supply Co LLC - Franchise Community';
        a.Email__c = 'test@test.com';
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.id;
        c.LastName = 'Invoice 1';
        insert c;
        
        /*User tempUser = new User(  
            FirstName = 'Test',  
            LastName = 'User',  
            email = 'test@test.com',  
            Username = 'test@testing.com',  
            EmailEncodingKey = 'ISO-8859-1',  
            Alias = 'test12334',  
            TimeZoneSidKey = 'America/Los_Angeles',  
            LocaleSidKey = 'en_US',  
            LanguageLocaleKey = 'en_US',  
            ProfileId = profileId
        ); */
        
        User user = new User(alias = 'test123', email='test123@noemail.com',
                             emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
                             localesidkey='en_US', profileid = profileId, country='United States',IsActive =true,
                             ContactId = c.Id,
                             timezonesidkey='America/Los_Angeles', username='tester1nht@noemail.com');
        
        insert user;
        
        
        Purchase_Orders__c po = new Purchase_Orders__c();
        po.Account_Name__c = a.id;
        po.Type__c = 'Outbound';
        po.Status__c = 'Order Placed';
        insert po;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Available_Quantity__c = 10,
        Family = 'Hardware');
        insert prod;
        
        Purchase_Order_Lines__c pol = new Purchase_Order_Lines__c();
        pol.Purchase_Orders__c = po.id;
        pol.Description__c = 'Description';
        pol.Product__c = prod.id;
        pol.Quantity__c = 1;
        insert pol;
        
       
        System.runAs(user){
            
             PageReference pageRef = Page.PO_SendInvoice;
        Test.setCurrentPage(pageRef);
        EmailTemplate email;
        //email = [select id,Name from EmailTemplate where Name = 'Purchase Order'];
        ApexPages.currentPage().getParameters().get('templateId');
        //ApexPages.currentPage().getParameters().put('doc_Id',document.id);
        ApexPages.currentPage().getParameters().put('templateId','00X1P000000Ef3X');
        system.debug('TemplateId: '+ApexPages.currentPage().getParameters().get('templateId'));
        ApexPages.currentPage().getParameters().put('id', po.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(po);
        POController poinv = new POController(sc);
        
        POController invoice = new POController();
        poinv.selectedContacts.add(new SelectOption(c.id,c.LastName));
        poinv.getContacts();
        poinv.getOrgwideAddress();
        poinv.getTemplates();
        //poinv.type = 'slip';
        poinv.attachment = true;
        poinv.selectedTemplate = 'Purchase Order';
        poinv.selectedMethod = 'Attach';
       	poinv.templateId = '00X1P000000Ef3X';
            poinv.selectedEmailTemplate ='00X1P000000Ef3X';
        //poinv.saveAttachement();
        poinv.Cancel();
            poinv.prepareEmail();
            poinv.onChangePrepareEmail();
         // poinv.sendInvoiceEmail();
        }
       
    }
}