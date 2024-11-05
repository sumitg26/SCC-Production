@isTest
public class CaptureContractSignatureControllerTest {
    
    static testMethod void contractTest(){
        account acc = new account();
        acc.name = 'Sailfin test account';
        insert acc;
        
        contact con = new contact();
        con.LastName = 'sailfin technologies invoice';
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
        
        Attachment att = new Attachment();
        att.ParentId = acc.id;
        att.Name ='Signature.pdf';
        att.contentType = 'image/png';
        att.OwnerId = UserInfo.getUserId(); 
        att.Body =EncodingUtil.base64Decode('Unit Test Attachment Body');
        insert att;
        
        PageReference pref = Page.CaptureContractSignature;
        pref.getParameters().put('Id', acc.id);
        Test.setCurrentPage(pref);
        acc.Contract_Template_Name__c = sag.Id;
        update acc;
        
        CaptureContractSignatureController cc = new CaptureContractSignatureController();
        cc.imageUrl = 'imageUrlimageUrlimageUrlimageUrl';
        cc.updatedTemplateLine = '';
        cc.templateProcessing();
        cc.saveCustomerSignature();
        cc.generatePdfWithSign();
        Integer i = cc.AttachCount;
        List<Id> Fin = cc.FinalAttach;
        }
}