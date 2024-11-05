trigger InvoiceEmails on Account (after insert,after update) {
    Map<Id,Map<String,Contact>> newContactMap = new Map<Id,Map<String,Contact>>();
    
    Map<ID,RecordType> recordtypes = new Map<ID,RecordType>([Select id,name from RecordType where sObjectType = 'Account' 
                                and developerName IN('Residential_Accounts')]);
                                
    List<Contact> conLst = [SELECT AccountID,ID,LastName,Email FROM Contact WHERE AccountID IN : Trigger.newMap.KeySet()];
    for(Contact c : conLst){
        if(!newContactMap.containsKey(c.AccountID)){
            newContactMap.put(c.AccountID,new Map<String,Contact>());
        }
        newContactMap.get(c.AccountID).put(c.LastName,c);
    }
    for(Account a : Trigger.new){
        if(recordtypes!=null && recordtypes.size()>0 && recordtypes.containsKey(a.RecordTypeId)){
            if(!newContactMap.containsKey(a.id)){
                newContactMap.put(a.id,new Map<String,Contact>());
            }
            if(a.Invoice_Email_1__c!=null && !newContactMap.get(a.id).containsKey(Schema.Account.fields.Invoice_Email_1__c.getDescribe().getLabel())){
                newContactMap.get(a.id).put(Schema.Account.fields.Invoice_Email_1__c.getDescribe().getLabel(),new Contact(AccountId = a.Id,
                    LastName = Schema.Account.fields.Invoice_Email_1__c.getDescribe().getLabel(),Email = a.Invoice_Email_1__c,Auto_Created__c = True));
            }else if(a.Invoice_Email_1__c!=null){
                Contact c = newContactMap.get(a.id).get(Schema.Account.fields.Invoice_Email_1__c.getDescribe().getLabel());
                c.Email = a.Invoice_Email_1__c;
                newContactMap.get(a.id).put(Schema.Account.fields.Invoice_Email_1__c.getDescribe().getLabel(),c);
            }
            
            if(a.Invoice_Email_2__c!=null && !newContactMap.get(a.id).containsKey(Schema.Account.fields.Invoice_Email_2__c.getDescribe().getLabel())){
                newContactMap.get(a.id).put(Schema.Account.fields.Invoice_Email_2__c.getDescribe().getLabel(),new Contact(AccountId = a.Id,
                    LastName = Schema.Account.fields.Invoice_Email_2__c.getDescribe().getLabel(),Email = a.Invoice_Email_2__c,Auto_Created__c = True));
            }else if(a.Invoice_Email_2__c!=null){
                Contact c = newContactMap.get(a.id).get(Schema.Account.fields.Invoice_Email_2__c.getDescribe().getLabel());
                c.Email = a.Invoice_Email_2__c;
                newContactMap.get(a.id).put(Schema.Account.fields.Invoice_Email_2__c.getDescribe().getLabel(),c);
            }
            
            if(a.Invoice_Email_3__c!=null && !newContactMap.get(a.id).containsKey(Schema.Account.fields.Invoice_Email_3__c.getDescribe().getLabel())){
                newContactMap.get(a.id).put(Schema.Account.fields.Invoice_Email_3__c.getDescribe().getLabel(),new Contact(AccountId = a.Id,
                    LastName = Schema.Account.fields.Invoice_Email_3__c.getDescribe().getLabel(),Email = a.Invoice_Email_3__c,Auto_Created__c = True));
            }else if(a.Invoice_Email_3__c!=null){
                Contact c = newContactMap.get(a.id).get(Schema.Account.fields.Invoice_Email_3__c.getDescribe().getLabel());
                c.Email = a.Invoice_Email_3__c;
                newContactMap.get(a.id).put(Schema.Account.fields.Invoice_Email_3__c.getDescribe().getLabel(),c);
            }
            
            if(a.Email__c !=null && a.Primary_Contact__c!=null){
                if(Trigger.isInsert && !a.Convert_Lead__c){
                    //Create a new primary contact if the contact doesn't exists
                    if(!newContactMap.get(a.id).containsKey(a.Primary_Contact__c)){
                        newContactMap.get(a.id).put(a.Primary_Contact__c,new Contact(AccountId = a.Id,
                            LastName = a.Primary_Contact__c,Email = a.Email__c,Auto_Created__c = True));
                    }
                    //update the contact with the email on Account
                    else{
                        Contact c = newContactMap.get(a.id).get(a.Primary_Contact__c);
                        c.Email = a.Email__c;
                        newContactMap.get(a.id).put(a.Primary_Contact__c,c);
                    }
                }else if(Trigger.isUpdate && (!a.Convert_Lead__c || (a.Convert_Lead__c 
                    && (a.Primary_Contact__c != trigger.oldMap.get(a.Id).Primary_Contact__c || a.Email__c!=trigger.oldMap.get(a.Id).Email__c)))){
                    
                    //if there is an update on Account on Primary contact field
                    if(a.Primary_Contact__c != trigger.oldMap.get(a.Id).Primary_Contact__c && trigger.oldMap.get(a.Id).Primary_Contact__c!=null 
                        && newContactMap.get(a.id).containsKey(trigger.oldMap.get(a.Id).Primary_Contact__c)){
                        
                        //Update the information on Contact with the details on Account
                        Contact c = newContactMap.get(a.id).get(trigger.oldMap.get(a.Id).Primary_Contact__c);
                        c.LastName = a.Primary_Contact__c;
                        c.Email = a.Email__c;
                        c.Id = newContactMap.get(a.id).get(trigger.oldMap.get(a.Id).Primary_Contact__c).Id;
                        
                        newContactMap.get(a.id).remove(trigger.oldMap.get(a.Id).Primary_Contact__c);
                        newContactMap.get(a.id).put(a.Primary_Contact__c,c);
                    }
                    //Email update if Email is changed
                    else if(a.Primary_Contact__c==trigger.oldMap.get(a.Id).Primary_Contact__c 
                        && newContactMap.get(a.id).containsKey(a.Primary_Contact__c)){
                        Contact c = newContactMap.get(a.id).get(a.Primary_Contact__c);
                        c.Email = a.Email__c;
                        newContactMap.get(a.id).put(a.Primary_Contact__c,c);
                    }
                    else{
                        System.debug('New Contact In Else');
                        newContactMap.get(a.id).put(a.Primary_Contact__c,new Contact(AccountId = a.Id,
                        LastName = a.Primary_Contact__c,Email = a.Email__c,Auto_Created__c = True));
                    }
                }
            }
        }
    }
    if(newContactMap.size()>0){
        List<Contact> records = new List<Contact>();
        for(Id a : newContactMap.keyset()){
            records.addAll(newContactMap.get(a).values());
        }
        if(records != null && records.size()>0)
            upsert records;
    }
}