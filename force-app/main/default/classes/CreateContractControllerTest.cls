@isTest
public class CreateContractControllerTest {
    static testMethod void contractTest1(){
        account acc = new account();
        acc.name = 'test account';
        insert acc;
        EmailTemplate et = [select id,Name from EmailTemplate where Name = 'Interval Cleaning Contract'];
        contact con = new contact();
        con.LastName = 'nitesh Kumar invoice';
        con.Email = 'test@email.com';
        con.AccountId = acc.Id;
        insert con;
         Merge_Fields_Mapping__c mf = new Merge_Fields_Mapping__c();
        mf.name= 'Name';
        mf.Field_API_Name__c = 'Name';
        insert mf;
        
        Smart_Agreement_Template__c sag = new Smart_Agreement_Template__c();
        sag.Name = 'Template 1';
        sag.Is_Active__c = true;
        sag.Agreement_Content__c ='Agreement_Content__c [[Name]] {{Agreement Signed Date }} Agreement_Content__cAgreement_Content__c Agreement_Content__c';
        insert sag;
        
        
        PageReference pref = Page.Create_Contract;
        pref.getParameters().put('Id', acc.id);
        Test.setCurrentPage(pref);
        ApexPages.StandardController sc = new ApexPages.StandardController(acc);
        CreateContractController cc = new CreateContractController(sc);
            CreateContractController c = new CreateContractController();
        
        List<SelectOption> co = cc.getContacts();
        List<SelectOption> ow = cc.getOrgwideAddress();
        List<SelectOption> temp = cc.getTemplates();
        cc.selectedTemplate = string.valueOf(sag.id);
        List<Id> c1 = new List<Id>();
        c1.add(con.id);
        cc.selectedContacts.addAll(c1);
        cc.onChangeTemplate();
        cc.getEmailTemplates();
        cc.selectedEmailTemplate = et.Id;
        cc.onChangePrepareEmail();
        cc.sendContract();
        cc.SendContractCancel();
        
    }
    public static testmethod void test2(){
        account acc = new account();
        acc.name = 'Sailfin test account';
        insert acc;
        
        contact con = new contact();
        con.LastName = 'sailfin technologies invoice';
        con.Email = 'test@email.com';
        con.AccountId = acc.Id;
        insert con; 
        EmailTemplate et = [select id,Name from EmailTemplate where Name = 'Interval Cleaning Contract'];
        system.debug('et = '+et);
        
        PageReference pref1 = Page.SendContractInvoice;
        Test.setCurrentPage(pref1);
        ApexPages.currentPage().getParameters().put('id',acc.id);
        ApexPages.currentPage().getParameters().put('templateId',et.id);
        ApexPages.currentPage().getParameters().put('whoId',con.Id);
        ApexPages.currentPage().getParameters().put('toEmail',con.Email);
        
        
        CreateContractController c = new CreateContractController();
        c.prepareEmail();
        c.Cancel();
        c.sendInvoiceEmail();
        
    }
}