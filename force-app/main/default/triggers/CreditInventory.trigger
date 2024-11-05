trigger CreditInventory on Purchase_Orders__c (after update) {
    Set<Id> poId = new Set<Id>();
    
    Account a;
    if(!Test.isRunningTest()){
    	a = [Select id,Name,Email__c,ShippingAddress from Account where id = '0011a00000pCPsgAAG' limit 1]; //change record Id
    }
    else{
    	a = [Select id,Name,Email__c,ShippingAddress from Account limit 1];
    }
  
   
    Address addr;
        if(a!= null){
        addr = a.ShippingAddress;
    }     
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
    for(Purchase_Orders__c p : Trigger.New){
        if(p.Type__c == 'Outbound' && p.Status__c == 'Order Completed' && p.Shipping_Address__c == poAddress){
            poId.add(p.id);
        }
    }
    
    List<Purchase_Order_Lines__c> poLines = [select id,Product__c,Quantity__c,Purchase_Orders__c from Purchase_Order_Lines__c 
                                             where Purchase_Orders__c IN : poId];
                                             
    Set<Id> proId = new Set<Id>();                                         
    for(Purchase_Order_Lines__c pol : poLines){
        proId.add(pol.Product__c);
    }
    
    List<Product2> productList = [Select id,Name,ProductCode,Available_Quantity__c,Parent_Product__c,Product_Type__c,Supplier_Manufacturer__c,
                                  ReorderPoint__c,Smart_Supply_Maintained_Inventory__c from Product2 WHERE ID IN : proId];
    Map<Id,Product2> productMap = new Map<Id,Product2>();                              
    for(Product2 p : productList){
        productMap.put(p.id,p);    
    }
    List<Product2> newProductList = new List<Product2>();
    for(Purchase_Order_Lines__c pol : poLines){
        Product2 prod = productMap.get(pol.Product__c);
        prod.Available_Quantity__c = prod.Available_Quantity__c + pol.Quantity__c;
        newProductList.add(prod);
    }
    update newProductList;
}