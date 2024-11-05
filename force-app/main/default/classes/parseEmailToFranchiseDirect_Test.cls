@isTest
public class parseEmailToFranchiseDirect_Test {
    public static testmethod void emailtoleadmethod(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        List<String> toList = new List<String>{'abc@test2.com'};
        string textbody = 'Lead ID:	0610' + '\n'; 
        textbody = textbody + 'NAME: FirstName LastName' + '\n';
        //  textbody = textbody + 'LastName: Isom' + '\n';
        textbody = textbody + 'EMAIL: damco@testing.com' + '\n';
        textbody = textbody + 'CAPITAL_TO_INVEST: $10000' + '\n';
        textbody = textbody + 'TELEPHONE_NUMBER: 9870654320' + '\n';
        textbody = textbody + 'ALT_TELEPHONE_NUMBER: 9870654321' + '\n';
        textbody = textbody + 'ADDRESS_STATE: Delhi' + '\n';
        textbody = textbody + 'ADDRESS_ZIP:	110001' + '\n';
        textbody = textbody + 'ADDRESS_COUNTRY:	India' + '\n';
        textbody = textbody + 'WHEN_WANTS_TO_START_NEW_BUSINESS: 1 to 3 Months' + '\n';
        textbody = textbody + 'COMMENTS: 0610' + '\n';
        
        email.subject = 'Test';
        email.fromname = 'Testing';
        email.toAddresses = toList;
        envelope.fromAddress = 'scc@testdomain.com';
        email.fromAddress = 'scc@testdomain.com';
        email.plainTextBody = textbody;
        
        parseEmailToFranchiseDirectLeadSource emailParse = new parseEmailToFranchiseDirectLeadSource();
        emailParse.handleInboundEmail(email, envelope);
    }
}