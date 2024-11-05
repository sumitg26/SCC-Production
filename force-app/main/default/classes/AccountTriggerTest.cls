@isTest
public class AccountTriggerTest {

   /* public static testmethod void TestAccountInsert() {
        
        //Insert an Account with email addresses - test for the contacts
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.Accounts_Payable_Email__c = 'ap@mail.com';
        newAccount.Email__c = 'email@mail.com';
        newAccount.Invoice_Email_1__c = 'i1@mail.com';
        newAccount.Invoice_Email_2__c = 'i2@mail.com';
        newAccount.Invoice_Email_3__c = 'i3@mail.com';
        newAccount.Other_Email__c = 'other@mail.com';
        insert newAccount;
        
        List<Contact> c = [SELECT Id FROM Contact];
        //system.assertEquals(6, c.size());
        
        // Update an Account with no changes to the email addresses
        newAccount.Description = 'Update';
        update newAccount;
        
        List<Contact> c2 = [SELECT Id FROM Contact];
        //system.assertEquals(6, c2.size());
        
        // Update an Account with change to email address
        newAccount.Email__c = 'email2@mail.com';
        update newAccount;
        
        List<Contact> c3 = [SELECT Id FROM Contact];
        //system.assertEquals(7, c3.size());
        
    }
    
    public static testmethod void TestAccountInsertWithSameAddress() {
        
        //Insert an Account with email addresses - test for the contacts
        Account newAccount = new Account();
        newAccount.Name = 'Test Account';
        newAccount.Accounts_Payable_Email__c = 'email@mail.com';
        newAccount.Email__c = 'email@mail.com';
        newAccount.Invoice_Email_1__c = 'email@mail.com';
        newAccount.Invoice_Email_2__c = 'email@mail.com';
        newAccount.Invoice_Email_3__c = 'email@mail.com';
        newAccount.Other_Email__c = 'email@mail.com';
        insert newAccount;
        
        List<Contact> c = [SELECT Id FROM Contact];
        //system.assertEquals(1, c.size());
        
        // Update an Account with no changes to the email addresses
        newAccount.Description = 'Update';
        update newAccount;
        
        List<Contact> c2 = [SELECT Id FROM Contact];
        //system.assertEquals(1, c2.size());
        
        // Update an Account with change to email address
        newAccount.Email__c = 'email2@mail.com';
        update newAccount;
        
        List<Contact> c3 = [SELECT Id FROM Contact];
        //system.assertEquals(2, c3.size()); 
        
    }*/
}