trigger UpdateAccountData on Purchase_Orders__c (before insert) {
    
    User u = [SELECT Username,ContactId,Email, Contact.Name,Contact.AccountId, Contact.Account.Name FROM User where id =: Userinfo.getUserid()];
    
    /*ID contactId = [Select contactid from User where id =: Userinfo.getUserid()].contactId;
    if( contactId != null ){
        Contact c  = [Select AccountID,Email from Contact where id =: contactId];*/

        if(u != null){
            for(Purchase_Orders__c  p : Trigger.New){
                if(p.Type__c == 'Inbound'){
                    p.Account_Name__c = u.Contact.AccountId;
                    p.Email__c = u.Email;
                }
            }
        }
}