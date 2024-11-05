@isTest
public class emailToFranchiseWebsiteLead_Test {
public static testmethod void emailToFranchiseWebsiteLeadmethod(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        List<String> toList = new List<String>{'abc@test1.com'};
             string htmlbody = 'Lead ID:303450' ; 
        htmlbody = htmlbody + 'First Name: Robert Isom' ;
        htmlbody = htmlbody + 'Last Name: Isom' ;
        htmlbody = htmlbody + 'Phone: 9870654321' ;
        htmlbody = htmlbody + 'Email: robert@testing.com';
        htmlbody = htmlbody + 'state: Maharashtra' ;
    	htmlbody = htmlbody + 'Description: Testing' ;
            
            string textbody = 'Lead ID:303450' ; 
        textbody = textbody + 'First Name: Robert Isom' ;
        textbody = textbody + 'Last Name: Isom' ;
        textbody = textbody + 'Phone: 9870654321' ;
        textbody = textbody + 'Email: robert@testing.com';
        textbody = textbody + 'state: Maharashtra' ;
    	textbody = textbody + 'Description: Testing' ;
        
        email.subject = 'Test';
        email.fromname = 'Testing';
        email.toAddresses = toList;
        envelope.fromAddress = 'scc@testdomain.com';
        email.fromAddress = 'scc@testdomain.com';
        email.plainTextBody = textbody;
    email.htmlBody = htmlbody;
        
        emailToFranchiseWebsiteLead emailProcess = new emailToFranchiseWebsiteLead();
        emailProcess.handleInboundEmail(email, envelope);
    }
}