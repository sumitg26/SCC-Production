public class AccountTriggerHelper {
    
    private static boolean CreateNewContact(List<Contact> contacts, String email){
        boolean retVal = true;
        
        for(Contact c : contacts){
            if(c.Email == email){
                retVal = false;
                break;
            }
        }
        
        return retVal;
    }
    
    public static void SyncAccountContacts(List<Account> accounts){
        
        Map<String, String> emails = new Map<String, String>();
        Map<String, Contact> newContacts = new Map<String, Contact>(); 
        
        // Walk through the accounts to build the list of emails that need to be checked
        for(Account a : accounts){
            if(a.Email__c != null){
                if (emails.get(a.Email__c) == null) {
                    emails.put(a.Email__c, a.Email__c);
                }
            }
            if(a.Accounts_Payable_Email__c != null){
                if (emails.get(a.Accounts_Payable_Email__c) == null) {
                    emails.put(a.Accounts_Payable_Email__c, a.Accounts_Payable_Email__c);
                }
            }
            if(a.Invoice_Email_1__c != null){
                if (emails.get(a.Invoice_Email_1__c) == null) {
                    emails.put(a.Invoice_Email_1__c, a.Invoice_Email_1__c);
                }
            }
            if(a.Invoice_Email_2__c != null){
                if (emails.get(a.Invoice_Email_2__c) == null) {
                    emails.put(a.Invoice_Email_2__c, a.Invoice_Email_2__c);
                }
            }
            if(a.Invoice_Email_3__c != null){
                if (emails.get(a.Invoice_Email_3__c) == null) {
                    emails.put(a.Invoice_Email_3__c, a.Invoice_Email_3__c);
                }
            }
            if(a.Other_Email__c != null){
                if (emails.get(a.Other_Email__c) == null) {
                    emails.put(a.Other_Email__c, a.Other_Email__c);
                }
            }
        }
        
        // Get all the existing contacts with the emails
        List<Contact> c = [SELECT Id, Email FROM Contact WHERE Email IN :emails.values()];
        
        // Walk back through the list and compare to existing to determine if they need to be created.
        // Check to see if it's already being added - many of the accounts have the same address being used in the different roles
        for(Account a : accounts){
            if(a.Email__c != null){ 
                if (CreateNewContact(c, a.Email__c)) {
                    if(newContacts.get(a.Email__c) == null){
                        Contact newContact = new Contact(LastName = a.Email__c, Email = a.Email__c, Auto_Created__c = True, AccountId = a.Id);
                        newContacts.put(a.Email__c, newContact);
                    }
                }
            }
            if(a.Accounts_Payable_Email__c != null){
                if (CreateNewContact(c, a.Accounts_Payable_Email__c)) {
                    if(newContacts.get(a.Accounts_Payable_Email__c) == null){
                        Contact newContact = new Contact(LastName = a.Accounts_Payable_Email__c, Email = a.Accounts_Payable_Email__c, Auto_Created__c = True, AccountId = a.Id);
                        newContacts.put(a.Accounts_Payable_Email__c, newContact);
                    }
                }
            }
            if(a.Invoice_Email_1__c != null){
                if (CreateNewContact(c, a.Invoice_Email_1__c)) {
                    if(newContacts.get(a.Invoice_Email_1__c) == null){
                        Contact newContact = new Contact(LastName = a.Invoice_Email_1__c, Email = a.Invoice_Email_1__c, Auto_Created__c = True, AccountId = a.Id);
                        newContacts.put(a.Invoice_Email_1__c, newContact);
                    }
                }
            }
            if(a.Invoice_Email_2__c != null){
                if (CreateNewContact(c, a.Invoice_Email_2__c)) {
                    if(newContacts.get(a.Invoice_Email_2__c) == null){
                        Contact newContact = new Contact(LastName = a.Invoice_Email_2__c, Email = a.Invoice_Email_2__c, Auto_Created__c = True, AccountId = a.Id);
                        newContacts.put(a.Invoice_Email_2__c, newContact);
                    }
                }
            }
            if(a.Invoice_Email_3__c != null){
                if (CreateNewContact(c, a.Invoice_Email_3__c)) {
                    if(newContacts.get(a.Invoice_Email_3__c) == null){
                        Contact newContact = new Contact(LastName = a.Invoice_Email_3__c, Email = a.Invoice_Email_3__c, Auto_Created__c = True, AccountId = a.Id);
                        newContacts.put(a.Invoice_Email_3__c, newContact);
                    }
                }
            }
            if(a.Other_Email__c != null){
                if (CreateNewContact(c, a.Other_Email__c)) {
                    if(newContacts.get(a.Other_Email__c) == null){
                        Contact newContact = new Contact(LastName = a.Other_Email__c, Email = a.Other_Email__c, Auto_Created__c = True, AccountId = a.Id);
                        newContacts.put(a.Other_Email__c, newContact);
                    }
                }
            }
        }
        
        // If we have any that need to be created - do the deed
        if(newContacts.size() > 0) {
            insert newContacts.values();
        }
        
    }
}