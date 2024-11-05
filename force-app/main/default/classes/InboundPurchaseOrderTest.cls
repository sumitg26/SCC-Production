@isTest
public class InboundPurchaseOrderTest {
    static testMethod void inbound()
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
        po.Status__c = 'Order Placed';
        po.Type__c = 'Inbound';
        po.Shipping_Address__c = poAddress;
        insert po;
        po.Status__c = 'Order Placed';
        update po;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Available_Quantity__c = 10,
        Family = 'Hardware');
        insert prod;

        List<Purchase_Order_Lines__c> polList = new List<Purchase_Order_Lines__c>();
        Purchase_Order_Lines__c pol = new Purchase_Order_Lines__c();
        pol.Purchase_Orders__c = po.id;
        pol.Description__c = 'Description';
        pol.Product__c = prod.id;
        pol.Quantity__c = 1;
        polList.add(pol);
        
        Product2 product = new Product2(Name = 'Laptop', Available_Quantity__c = 10,Smart_Supply_Maintained_Inventory__c= true,
        Family = 'Hardware');
        insert product;

        Purchase_Order_Lines__c pols = new Purchase_Order_Lines__c();
        pols.Purchase_Orders__c = po.id;
        pols.Description__c = 'Description';
        pols.Product__c = product.id;
        pols.Quantity__c = 20;
        polList.add(pols);
        
        Product2 product2 = new Product2(Name = 'Laptop v2', Available_Quantity__c = 10,Smart_Supply_Maintained_Inventory__c= true,
        Family = 'Hardware', ReorderPoint__c = 20);
        insert product2;

        Purchase_Order_Lines__c pol2 = new Purchase_Order_Lines__c();
        pol2.Purchase_Orders__c = po.id;
        pol2.Description__c = 'Description';
        pol2.Product__c = product2.id;
        pol2.Quantity__c = 2;
        polList.add(pol2);

       	insert polList;
    }

}