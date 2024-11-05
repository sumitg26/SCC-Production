trigger Services on Work_Order_Item__c (before insert,before update) {

    Set<String> ServiceName =  new Set<String>();
    
    Map<String,String> serviceMap = new Map<String,String>();
    
    for(Work_Order_Item__c  w : Trigger.New){
        if(w.Services__c != null)
           ServiceName.add(w.Services__c); 
    }
    
    List<Service__c> serviceList = [select id,Name,Service_Description__c from Service__c where Name IN : ServiceName];
    
    if(serviceList != null && serviceList.size()>0){
        for(Service__c s : serviceList){
            serviceMap.put(s.Name,s.id);
        }
    }
    for(Work_Order_Item__c  w : Trigger.New){
        w.Service__c = serviceMap.get(w.Services__c);
    }

}