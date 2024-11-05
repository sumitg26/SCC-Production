@isTest
public class CreditInventoryTest {
    static testMethod void credit()
    {
        Account a = new Account(Name = 'Smart Supply Co LLC - Franchise Community', ShippingStreet = 'Smart Street',ShippingCity = 'Smart City',
                               ShippingState = 'Smart State',ShippingPostalCode = '123456',ShippingCountry = 'Smart Country');
        insert a;
        Address addr = a.ShippingAddress; 
   	    String poAddress = '';
    
    if(addr != null){
        if(addr.Street != null){
            poAddress = addr.Street + ' \r\n';
        }
        if(addr.City != null){
            poAddress =poAddress + addr.City + ',';
        }
        if(addr.State != null){      
            poAddress =poAddress + addr.State + ' ';
        }
        if(addr.PostalCode != null){     
            poAddress =poAddress + addr.PostalCode + ' \r\n';
        }
        if(addr.Country != null){  
            poAddress =poAddress + addr.Country;
        } 
    } 
        Purchase_Orders__c  po;
        po = new Purchase_Orders__c();
        po.Email__c = 'abc@xyz.com';
        po.Status__c = 'Order Completed';
        po.Type__c = 'Outbound';
        po.Shipping_Address__c = '';
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
        
        po.Status__c = 'Order Completed';
        update po;    
    }

}