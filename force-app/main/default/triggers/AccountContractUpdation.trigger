trigger AccountContractUpdation on Guest_Account__c (after insert, after update) {
    
    Map<Id,Guest_Account__c > accIdGuestMap = new Map<Id,Guest_Account__c>();
    for(Guest_Account__c  ga : Trigger.new){
        if(ga.Account_Id__c != '' || ga.Account_Id__c != null){
            accIdGuestMap.put(ga.Account_Id__c,ga);
        }
    }
    
    List<Account> AccToUpdate = [Select Id, Agreement_Signed__c, Agreement_Signed_Date__c,
                                 Customer_Name__c From Account WHERE Id IN:accIdGuestMap.keySet()];

    List <Account> FinalUpdateList = new List<Account>();
    
    for(Account acc: AccToUpdate){
        Guest_Account__c gAccObj = accIdGuestMap.get(acc.Id);
        acc.Agreement_Signed__c = gAccObj.Agreement_Signed__c;
        acc.Agreement_Signed_Date__c = gAccObj.Agreement_Signed_Date__c;
        acc.Customer_Name__c = gAccObj.Agreement_Signed_By__c;
        FinalUpdateList.add(acc);
    }
    if(FinalUpdateList.size()>0){
        update FinalUpdateList;
    }

}