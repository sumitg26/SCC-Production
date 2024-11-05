@isTest
public class AddPOLinesTest {
    static testMethod void add(){
        Account a = new Account(Name = 'Smart Supply Co LLC - Franchise Community', ShippingStreet = 'Smart Street',ShippingCity = 'Smart City',
                               ShippingState = 'Smart State',ShippingPostalCode = '123456',ShippingCountry = 'Smart Country');
        insert a;
        
        Purchase_Orders__c  po;
        po = new Purchase_Orders__c();
        po.Email__c = 'abc@xyz.com';
        po.Status__c = 'Pending';
        po.Type__c = 'Inbound';
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
        AddPOLines add = new AddPOLines();
        add.Submit();
        add.Cancel();
    }
    
    static testMethod void Save(){
        Account a = new Account(Name = 'Smart Supply Co LLC - Franchise Community', ShippingStreet = 'Smart Street',ShippingCity = 'Smart City',
                               ShippingState = 'Smart State',ShippingPostalCode = '123456',ShippingCountry = 'Smart Country');
        insert a;
        
        Purchase_Orders__c  po;
        po = new Purchase_Orders__c();
        po.Email__c = 'abc@xyz.com';
        po.Status__c = 'Pending';
        po.Type__c = 'Inbound';
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
        AddPOLines add = new AddPOLines();
        add.Save();
        add.Cancel();
    }
}