@isTest
public class emailtoLead_Test {
public static testmethod void emailtoleadmethod(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        List<String> toList = new List<String>{'abc@test1.com'};
            string textbody = 'Lead ID:303450' ; 
        textbody = textbody + 'FirstName:Robert Isom' ;
        textbody = textbody + 'LastName:Isom' ;
        textbody = textbody + 'Email:robert@testing.com';
        textbody = textbody + 'Phone:9870654321' ;
        textbody = textbody + 'State:Maharashtra' ;
    	textbody = textbody + 'Description:Testing' ;
        
        email.subject = 'Test';
        email.fromname = 'Testing';
        email.toAddresses = toList;
        envelope.fromAddress = 'scc@testdomain.com';
        email.fromAddress = 'scc@testdomain.com';
        email.plainTextBody = textbody;
        
        emailtolead emailProcess = new emailtolead();
        emailProcess.handleInboundEmail(email, envelope);
    }
}