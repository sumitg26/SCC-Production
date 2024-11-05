@isTest
public class POInvoiceControllerTest {
    static testMethod void POInvoice(){
        Account a = new Account(Name='Smart Supply Co LLC - Franchise Community');
        insert a;
        
        Purchase_Orders__c po = new Purchase_Orders__c();
        po.Account_Name__c = a.id;
        po.Type__c = 'Inbound';
        po.Status__c = 'Order Completed';
        insert po;
        
        Contact c = new Contact(AccountId = a.id,LastName = 'Test Contact');
        insert c;
        
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
        POInvoiceController poinv = new POInvoiceController(sc);
        
        POInvoiceController invoice = new POInvoiceController();
        poinv.selectedContacts.add(new SelectOption(c.id,c.LastName));
        poinv.getContacts();
        poinv.getTemplates();
        poinv.attachment = true;
        poinv.selectedTemplate = 'Purchase Order Invoice';
        poinv.selectedMethod = 'Email';
        poinv.saveAttachement();
        poinv.Cancel();
    }    

}