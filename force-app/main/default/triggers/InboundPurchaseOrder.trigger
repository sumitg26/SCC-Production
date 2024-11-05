trigger InboundPurchaseOrder on Purchase_Order_Lines__c (after insert) {
    
    List<Account> accList = new List<Account>();
    
    if(!Test.isRunningTest()){
        accList = [Select id,Name,Email__c,ShippingAddress from Account where id = '0011a00000pCPsgAAG' limit 1]; 				//change record Id
    }
    else{
        accList = [Select id,Name,Email__c,ShippingAddress from Account limit 1];    
    } 
    
    Map<ID,Map<ID,List<Purchase_Order_Lines__c>>> polMap = new Map<ID,Map<ID,List<Purchase_Order_Lines__c>>>();
    Set<ID> productIDs = new Set<ID>();
    Set<ID> poIDs = new Set<ID>();
    Set<ID> poSet = new Set<ID>();
    Set<ID> accSet = new Set<ID>();
    
	User u = [SELECT Id, AccountId FROM User WHERE Id =: UserInfo.getUserId()];      				//added code here
    
    
    for(Purchase_Order_Lines__c po : Trigger.new){
        poSet.add(po.Purchase_Orders__c);
    }
    Map<ID,Purchase_Orders__c> poQueryMap = new Map<ID,Purchase_Orders__c>([SELECT ID,Type__c,Status__c, Franchise__c, Franchise_Address__c FROM Purchase_Orders__c WHERE ID IN :poSet]); //added fields in query
    //added by shabana
    Map<id,Product2> POL_Product_Map = new Map<id,Product2>();
    Map<string,Purchase_Orders__c> OutboundPOInsertMap = new Map<string,Purchase_Orders__c>();
    List<Purchase_Order_Lines__c> POLlist = new List<Purchase_Order_Lines__c>();
    //end
    
    for(Purchase_Order_Lines__c po : [SELECT ID,Quantity__c,Shipping_Handling__c,Item__c,Discount__c,Description__c,Purchase_Orders__c,Product__c,Product__r.Supplier_Manufacturer__c from Purchase_Order_Lines__c WHERE ID IN : trigger.newMap.keySet()]){
        System.debug(po);
        System.debug(poQueryMap.get(po.Purchase_Orders__c).Type__c);
        System.debug(poQueryMap.get(po.Purchase_Orders__c).Status__c);
        if(poQueryMap.get(po.Purchase_Orders__c).Type__c =='Inbound' && poQueryMap.get(po.Purchase_Orders__c).Status__c =='Order Placed'){
            
            //added by shabana
            POLlist.add(po);
            //end
            productIDs.add(po.Product__c);
            poIDs.add(po.Purchase_Orders__c);
            
            if(!polMap.containsKey(po.Purchase_Orders__c)){
                polMap.put(po.Purchase_Orders__c,new Map<ID,List<Purchase_Order_Lines__c>>());
            }
            if(!polMap.get(po.Purchase_Orders__c).containsKey(po.Product__r.Supplier_Manufacturer__c)){
                polMap.get(po.Purchase_Orders__c).put(po.Product__r.Supplier_Manufacturer__c,new List<Purchase_Order_Lines__c>());
            }
            polMap.get(po.Purchase_Orders__c).get(po.Product__r.Supplier_Manufacturer__c).add(po);
        }
    }
       
    List<Product2> productList = [Select id,Name,ProductCode,Available_Quantity__c,Parent_Product__c,Product_Type__c,Supplier_Manufacturer__c,
                                  Supplier_Manufacturer__r.name,ReorderPoint__c,Smart_Supply_Maintained_Inventory__c from Product2 WHERE ID IN : productIDs];
    
    Map<Id,Product2> productMap = new Map<Id,Product2>();
    Map<Id,Product2> notInProductMap = new Map<Id,Product2>();
    
    for(Product2 p : productList){
        POL_Product_Map.put(p.id, p);
        accSet.add(p.Supplier_Manufacturer__c);
        
        if(p.Smart_Supply_Maintained_Inventory__c == true){
            productMap.put(p.id,p);
        }
        else{
            notInProductMap.put(p.id,p);
        }
    }
    
    List<Account> aList = [Select id,Name,Email__c,ShippingAddress from Account where id IN : accSet];
    
    Map<Id,Account> accountMap = new Map<Id,Account>();
    
    for(Account a : aList){
        accountMap.put(a.id,a);
    }
    
    List<Purchase_Order_Lines__c> existingLines = [select id,Product__c,Product__r.Supplier_Manufacturer__c,Purchase_Orders__c,Purchase_Orders__r.Shipping_Address__c,
                                                   Purchase_Orders__r.Type__c,Purchase_Orders__r.Inbound_Purchase_Order__c from Purchase_Order_Lines__c
                                                   where Purchase_Orders__r.Inbound_Purchase_Order__c IN : poIDs AND Purchase_Orders__r.Type__c = 'Outbound'];
    
    Map<ID,Map<ID,Map<String,List<Purchase_Order_Lines__c>>>> polExistMap = new Map<ID,Map<ID,Map<String,List<Purchase_Order_Lines__c>>>>();
    System.debug(existingLines);
    for(Purchase_Order_Lines__c po : existingLines){
        System.debug(po);
        if(!polExistMap.containsKey(po.Purchase_Orders__c)){
            polExistMap.put(po.Purchase_Orders__r.Inbound_Purchase_Order__c,new Map<ID,Map<String,List<Purchase_Order_Lines__c>>>());
        }
        if(!polExistMap.get(po.Purchase_Orders__r.Inbound_Purchase_Order__c).containsKey(po.Product__r.Supplier_Manufacturer__c)){
            polExistMap.get(po.Purchase_Orders__r.Inbound_Purchase_Order__c).put(po.Product__r.Supplier_Manufacturer__c,new Map<String,List<Purchase_Order_Lines__c>>());
        }
        if(!polExistMap.get(po.Purchase_Orders__r.Inbound_Purchase_Order__c).get(po.Product__r.Supplier_Manufacturer__c).ContainsKey(po.Product__r.Supplier_Manufacturer__c+'~'+po.Purchase_Orders__r.Shipping_Address__c)){
            polExistMap.get(po.Purchase_Orders__r.Inbound_Purchase_Order__c).get(po.Product__r.Supplier_Manufacturer__c).put(po.Product__r.Supplier_Manufacturer__c+'~'+po.Purchase_Orders__r.Shipping_Address__c,new List<Purchase_Order_Lines__c>());
        }
        polExistMap.get(po.Purchase_Orders__r.Inbound_Purchase_Order__c).get(po.Product__r.Supplier_Manufacturer__c).get(po.Product__r.Supplier_Manufacturer__c+'~'+po.Purchase_Orders__r.Shipping_Address__c).add(po);
    }
    
    Map<Id,Map<Purchase_Order_Lines__c,Decimal>> OutboundPoMap = new Map<Id,Map<Purchase_Order_Lines__c,Decimal>>();
    
    if(polMap != null && polMap.size()>0){
        
        for(Id id : polMap.keySet()){
            for(Id accID : polMap.get(id).keySet()){
                for(Purchase_Order_Lines__c pols : polMap.get(id).get(accID)){
                    if(productMap.containsKey(pols.Product__c)){
                        Product2 pro = productMap.get(pols.Product__c);
                        if(pols.Quantity__c != null && pro.Available_Quantity__c != null){
                            Decimal quant = 0;
                            if(pro.Available_Quantity__c >= pols.Quantity__c){
                                pro.Available_Quantity__c = pro.Available_Quantity__c - pols.Quantity__c;
                                system.debug(pro.Available_Quantity__c );
                                if(pro.Available_Quantity__c <= pro.ReorderPoint__c){
                                    if(OutboundPoMap.containsKey(pols.Purchase_Orders__c)){
                                        OutboundPoMap.get(pols.Purchase_Orders__c).put(pols,quant);    
                                    }
                                    else{
                                        OutboundPoMap.put(pols.Purchase_Orders__c,new Map<Purchase_Order_Lines__c,Decimal>());
                                        OutboundPoMap.get(pols.Purchase_Orders__c).put(pols,quant);
                                    }    
                                }
                            }
                            else{
                                quant = pols.Quantity__c - pro.Available_Quantity__c;
                                pro.Available_Quantity__c = 0;
                                
                                if(OutboundPoMap.containsKey(pols.Purchase_Orders__c)){
                                    OutboundPoMap.get(pols.Purchase_Orders__c).put(pols,quant);    
                                }
                                else{
                                    OutboundPoMap.put(pols.Purchase_Orders__c,new Map<Purchase_Order_Lines__c,Decimal>());
                                    OutboundPoMap.get(pols.Purchase_Orders__c).put(pols,quant);
                                }
                                
                            }
                            List<Product2> productList = new List<Product2>();
                            productList.add(pro);
                        }
                    }
                    
                    if(notInProductMap.containsKey(pols.Product__c)){
                        Product2 prod = notInProductMap.get(pols.Product__c);   
                        if(OutboundPoMap.containsKey(pols.Purchase_Orders__c)){
                            OutboundPoMap.get(pols.Purchase_Orders__c).put(pols,pols.Quantity__c);    
                        }
                        else{
                            OutboundPoMap.put(pols.Purchase_Orders__c,new Map<Purchase_Order_Lines__c,Decimal>());
                            OutboundPoMap.get(pols.Purchase_Orders__c).put(pols,pols.Quantity__c);
                        } 
                    }
                }
            }
        }
        //update productList;
        
        List<Purchase_Orders__c> poList = [select id,Account_Name__c,Email__c,Invoice_Email__c,Notes__c,
                                           Payment_Terms__c,Status__c,Type__c,Inbound_Purchase_Order__c, Franchise__c, Franchise_Address__c 		//added fields
                                           from Purchase_Orders__c where id IN : OutboundPoMap.keySet()];
        
        Map<Id,Purchase_Orders__c> ordersMap = new Map<Id,Purchase_Orders__c>();                                   
        for(Purchase_Orders__c p : poList){
            ordersMap.put(p.id,p);
        }
        
        Map<String,Purchase_Orders__c> insertpoMap = new Map<String,Purchase_Orders__c>();
        Map<String,List<Purchase_Order_Lines__c>> insertpolMap = new Map<String,List<Purchase_Order_Lines__c>>();
        List<Purchase_Order_Lines__c> olines = new List<Purchase_Order_Lines__c>();
        for(Id id : ordersMap.keySet()){
            for(Id accID : polMap.get(id).keySet()){
                for(Purchase_Order_Lines__c pols : polMap.get(id).get(accID)){
                    Purchase_Order_Lines__c lines = new Purchase_Order_Lines__c();
                    lines.Product__c = pols.Product__c;
                    lines.Description__c = pols.Description__c;
                    lines.Discount__c= pols.Discount__c;
                    lines.Item__c = pols.Item__c;
                    lines.Shipping_Handling__c= pols.Shipping_Handling__c;
                    lines.Quantity__c = OutboundPoMap.get(id).get(pols);
                    String poAddress = '';
                    if(OutboundPoMap.get(id).get(pols) == 0 && productMap.containskey(pols.Product__c)){
                        Address addr = accList[0].ShippingAddress;
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
                    }else if(OutboundPoMap.get(id).get(pols) > 0 && (productMap.containskey(pols.Product__c)
                                                                     || notInProductMap.containskey(pols.Product__c))){
                                                                         if(accountMap.containsKey(accID) && String.valueof(accountMap.get(accID).ShippingAddress) != null && String.valueof(accountMap.get(accID).ShippingAddress) != ''){
                                                                             Address addr = accountMap.get(accID).ShippingAddress;
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
                                                                         }
                                                                     }
                    
                    if(polExistMap.containsKey(id) && polExistMap.get(id).containsKey(accID) && polExistMap.get(id).get(accID).containsKey(accID+'~'+poAddress)){
                        lines.Purchase_Orders__c = polExistMap.get(id).get(accID).get(accID+'~'+poAddress).get(0).Purchase_Orders__c;
                        olines.add(lines);
                    }else if(insertpoMap.containsKey(accID+'~'+poAddress)){
                        if(!insertpolMap.containsKey(accID+'~'+poAddress)){
                            insertpolMap.put(accID+'~'+poAddress,new List<Purchase_Order_Lines__c>());
                        }
                        insertpolMap.get(accID+'~'+poAddress).add(lines);
                    }else{
                        Purchase_Orders__c pol = ordersMap.get(id);
                        Purchase_Orders__c po = new Purchase_Orders__c();
                        po.Inbound_Purchase_Order__c = id;
                        if(accList != null && accList.size() > 0){
                            po.Account_Name__c = accList[0].id;
                            po.Email__c= accList[0].Email__c;
                            po.Franchise__c = u.AccountId;										//add franchise
                        }
                        //add supplier/manufacturer
                        if(!POL_Product_Map.get(pols.Product__c).Smart_Supply_Maintained_Inventory__c){
                            po.Supplier_Manufacturer__c = POL_Product_Map.get(pols.Product__c).Supplier_Manufacturer__c;
                        }
                        //
                        po.Invoice_Email__c = pol.Invoice_Email__c;
                        po.Notes__c= pol.Notes__c;
                        po.Payment_Terms__c = pol.Payment_Terms__c;
                        po.Type__c = 'Outbound';
                        if(OutboundPoMap.get(id).get(pols) == 0){
                            po.Status__c = 'Pending';
                        }else{
                            po.Status__c = 'Order Placed';
                            po.PO_Date__c = system.Today();
                        }
                        po.Shipping_Address__c = poAddress;
                        if(!insertpoMap.containsKey(accID+'~'+poAddress)){
                            insertpoMap.put(accID+'~'+poAddress,po);
                            //added by shabana
                            if(!POL_Product_Map.get(pols.Product__c).Smart_Supply_Maintained_Inventory__c){
                                if(POL_Product_Map.get(pols.Product__c).Supplier_Manufacturer__r.name == 'Multi-Sprayer Systems, Inc' ||
                                   POL_Product_Map.get(pols.Product__c).Supplier_Manufacturer__r.name == 'Pacific Floorcare'){
                                       OutboundPOInsertMap.put(accID+'~'+poAddress,po);
                                   }
                            }
                            //end
                        }
                        if(!insertpolMap.containsKey(accID+'~'+poAddress)){
                            insertpolMap.put(accID+'~'+poAddress,new List<Purchase_Order_Lines__c>());
                        }
                        insertpolMap.get(accID+'~'+poAddress).add(lines);
                    }
                }
            }
        }
        //insert insertpoMap.values();
        //Multiple line items for the same supplier (Smart Supply Co, Multi-Sprayer, Pacific) should be grouped into the same PO
        system.debug('OutboundPOInsertMap>'+OutboundPOInsertMap); 
        if(OutboundPOInsertMap != null){
            try{
                insert OutboundPOInsertMap.values();
            }
            catch(DmlException ex){
                system.debug('Error occured- '+ex.getMessage());
            }
        }
        //
        
        for(String po : insertpolMap.keySet()){
            for(Purchase_Order_Lines__c pols : insertpolMap.get(po)){
                if(insertpoMap.get(po).id != null){
                    pols.Purchase_Orders__c = insertpoMap.get(po).id;
                    olines.add(pols);
                }
            }
        }
        try{
            insert olines;
        }
        catch(DmlException ex){
            system.debug('Error occured- '+ex.getMessage());
        }
        
        //delete POLine Items
        List<Purchase_Order_Lines__c> delPOL = new List<Purchase_Order_Lines__c>();
        for(Purchase_Order_Lines__c pol : POLlist){
            if(!POL_Product_Map.get(pol.Product__c).Smart_Supply_Maintained_Inventory__c){
                if(POL_Product_Map.get(pol.Product__c).Supplier_Manufacturer__r.name == 'Multi-Sprayer Systems, Inc' ||
                   POL_Product_Map.get(pol.Product__c).Supplier_Manufacturer__r.name == 'Pacific Floorcare'){
                       delPOL.add(pol);
                   }
            }
        }
        if(delPOL != null && delPOL.size()>0){
            system.debug('delPOL> '+delPOL);
            try{
                Delete delPOL;
            }
            catch(DmlException ex){
                system.debug('Error occured- '+ex.getMessage());
            }
           Set<ID> POIdForDeletedLines = new Set<ID>();
            for(Purchase_Order_Lines__c pol: delPOL) {
                POIdForDeletedLines.add(pol.Purchase_Orders__c);
            }
            List<Purchase_Orders__c> inboundPoWithEmptyLines = [SELECT Id from Purchase_Orders__c where Id IN: POIdForDeletedLines and Type__c = 'Inbound' and Id not in (select Purchase_Orders__c from Purchase_order_Lines__c)];
            System.debug(inboundPoWithEmptyLines);
            for(Purchase_Orders__c checkEmptyPo : inboundPoWithEmptyLines) {
                checkEmptyPo.Is_Emply_Inbound__c = true;
                System.debug(checkEmptyPo.Is_Emply_Inbound__c);
            }
            update inboundPoWithEmptyLines;
        	/**try{
                Delete inboundPoWithEmptyLines;
            }
            catch(DmlException ex){
                system.debug('Error occured- '+ex.getMessage());
            }**/
        }
    }
}