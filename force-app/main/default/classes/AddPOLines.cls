public class AddPOLines{
    public Purchase_Orders__c poObj{get;set;}
    public String UserType{get; set;}
    public List<Product2> productList{get;set;}
    public List<productwrapper> wrapperList{get;set;}
    public productwrapper wrapObj{get;set;}
    List<Product2> selectedProducts = new List<Product2>();
    
    List<Purchase_Order_Lines__c> pols {get;set;}
    Map<Id,Purchase_Order_Lines__c> productMap{get;set;}
    List<Purchase_Order_Lines__c> poLinesList;
   
    public String poId{get;set;}
    
    public AddPOLines(){
        poId = ApexPages.currentPage().getParameters().get('id');
        UserType = userinfo.getusertype();
        wrapperList = new List<productwrapper>();
        poLinesList = new List<Purchase_Order_Lines__c>();
  
        poObj = [select id,Status__c,Order_Status__c,Type__c ,PO_Date__c,Ship_Via__c,Name,Account_Name__c,Account_Name__r.Name,Account_Address__c,Shipping_Address__c,CreatedDate,Payment_Terms__c
                from Purchase_Orders__c where id =: poId];
                
        if(poObj != null){
            pols = [select id,Quantity__c,Product__c from Purchase_Order_Lines__c where Purchase_Orders__c =: poId];
            
            productMap = new Map<Id,Purchase_Order_Lines__c>();
            
            for(Purchase_Order_Lines__c pol : pols){
                productMap.put(pol.Product__c,pol);
            }    
            
            List<Product2> trueproducts = [select id,ProductCode,Name,Description,List_Price__c,Parent_Product__c,Product_Type__c,Smart_Supply_Maintained_Inventory__c,Supplier_Manufacturer__c
                                           from Product2 where Id IN: productMap.keyset()];   
            
            if(trueproducts != null && trueproducts.size()>0){
                for(Product2 pro : trueproducts){
                    wrapObj = new productwrapper();
                    wrapObj.p = new Product2();
                    wrapObj.p = pro;
                    wrapObj.Quantity = productMap.get(pro.id).Quantity__c;
                    wrapObj.selected = true;
                    wrapperList.add(wrapObj);
                }
            }  
            
            productList = [select id,ProductCode,Name,Description,List_Price__c,Parent_Product__c,Product_Type__c,Smart_Supply_Maintained_Inventory__c,Supplier_Manufacturer__c from Product2 where Id NOT IN: productMap.keyset() order by Smart_Supply_Maintained_Inventory__c DESC ];
            
            if(productList != null && productList.size()>0){
                for(Product2 pro : productList){
                    wrapObj = new productwrapper();
                    wrapObj.p = new Product2();
                    wrapObj.p = pro;
                    wrapObj.Quantity = 0;
                    wrapObj.selected = false;
                    wrapperList.add(wrapObj);
                }
            } 
        }   
        
        if(poObj != null && poObj.Status__c == 'Order Placed'){
            Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.INFO, 'Your order has been placed.You can not edit or add more Line Items!!'));
        }
    }
    
    public void Save(){
    
        delete pols;
        Integer row = 1;
        
        for(productwrapper pwrapper : wrapperList){
           if(pwrapper.selected == true){
               Purchase_Order_Lines__c pol = new Purchase_Order_Lines__c();
               pol.Item__c = row++;
               pol.Purchase_Orders__c = poId;
               pol.Product__c = pwrapper.p.id;
               pol.Act_Cost__c = pwrapper.p.List_Price__c;
               pol.Quantity__c = pwrapper.Quantity;
               poLinesList.add(pol); 
           } 
        }
          
            poObj.Status__c = 'Pending';
            update poObj;
            
            insert poLinesList;
    }
 
    public Pagereference Submit(){
       delete pols;
       Integer row = 1;
        
        for(productwrapper pwrapper : wrapperList){
           if(pwrapper.selected == true && pwrapper.Quantity > 0){
               Purchase_Order_Lines__c pol = new Purchase_Order_Lines__c();
               pol.Item__c = row++;
               pol.Purchase_Orders__c = poId;
               pol.Product__c = pwrapper.p.id;
               pol.Act_Cost__c = pwrapper.p.List_Price__c;
               pol.Quantity__c = pwrapper.Quantity;
               poLinesList.add(pol); 
           } 
        }
        
        poObj.Status__c = 'Order Placed';
        poObj.PO_Date__c = System.Today();
        update poObj;
        
        insert poLinesList;
        
        return new PageReference('/'+poId);
    }
    
    public Pagereference Cancel(){
        return new PageReference('/'+poId);
    }
    
    public class productwrapper{
        public Product2 p{get; set;}
        public Boolean selected {get; set;}
        public Decimal Quantity {get;set;}
        
        public productwrapper(){
            
        }
    }

}