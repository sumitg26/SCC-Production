@isTest
public class EmailToEntrepreneurLeadSourceTestClass {
    public static testmethod void emailtoentrepreneurleadmethod(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        List<String> toList = new List<String>{'abc@test1.com'};
        string textbody = 'Lead ID:	303450' + '\n'; 
        textbody = textbody + 'Name:	Robert Isom' + '\n';
        textbody = textbody + 'LastName: Isom' + '\n';
        textbody = textbody + 'Daytime Phone: 9870654321' + '\n';
        textbody = textbody + 'Email: robert@testing.com' + '\n';
        textbody = textbody + 'Address: maha' + '\n';
        textbody = textbody + 'City: Olive Branch' + '\n';
        textbody = textbody + 'State: Mississippi' + '\n';
        textbody = textbody + 'Zip code: 38654' + '\n';
        textbody = textbody + 'Capital to Invest: $10,000' + '\n';
        textbody = textbody + 'When to start: 1 to 3 Months' + '\n';
        textbody = textbody + 'Comments: 1 to 3 Months' + '\n';
        email.subject = 'Test';
        email.fromname = 'Testing';
        email.toAddresses = toList;
        envelope.fromAddress = 'scc@testdomain.com';
        email.fromAddress = 'scc@testdomain.com';
        email.plainTextBody = textbody;
        
        EmailToEntrepreneurLeadSource emailProcess = new EmailToEntrepreneurLeadSource();
        emailProcess.handleInboundEmail(email, envelope);
    }
}