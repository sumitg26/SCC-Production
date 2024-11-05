@isTest
public class EmailToLeadTestClass {
    public static testmethod void emailtoleadmethod(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        List<String> toList = new List<String>{'abc@test1.com'};
            string textbody = 'Lead ID:	303450' + '\n'; 
        textbody = textbody + 'Name:	Robert Isom' + '\n';
        textbody = textbody + 'LastName: Isom' + '\n';
        textbody = textbody + 'Email:	robert@testing.com' + '\n';
        textbody = textbody + 'Phone:	9870654321' + '\n';
        textbody = textbody + 'City:	Olive Branch' + '\n';
        textbody = textbody + 'State:	Mississippi' + '\n';
        textbody = textbody + 'Zip:	38654' + '\n';
        textbody = textbody + 'Available Capital: $10000' + '\n';
        textbody = textbody + 'Time frame: 1 to 3 Months' + '\n';
        
        email.subject = 'Test';
        email.fromname = 'Testing';
        email.toAddresses = toList;
        envelope.fromAddress = 'scc@testdomain.com';
        email.fromAddress = 'scc@testdomain.com';
        email.plainTextBody = textbody;
        
        EmailToLeadClass emailProcess = new EmailToLeadClass();
        emailProcess.handleInboundEmail(email, envelope);
    }
}