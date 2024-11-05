@isTest
public class EmailServiceBestFranchiseNetworkTest {
	public static testmethod void emailtoentrepreneurleadmethod(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();
        
        List<String> toList = new List<String>{'abc@test1.com'};
        string textbody = 'Lead ID:	303450' + '\n'; 
        textbody = textbody + 'Name:	Robert Isom' + '\n';
        textbody = textbody + 'Email:	sudhawan2@gmail.com' + '\n';
        textbody = textbody + 'Last Name: Isom' + '\n';
        textbody = textbody + 'Last Name: Isom' + '\n';
        textbody = textbody + 'Cell: 9870654321' + '\n';
        textbody = textbody + 'Zip:110018' + '\n';
        textbody = textbody + 'State: maha' + '\n';
        textbody = textbody + 'Capital: Olive Branch' + '\n';
        textbody = textbody + 'Comments: Best time to reach out is after 5pm,Thanks,' + '\n';
        email.subject = 'Test';
        email.fromname = 'Testing';
        email.toAddresses = toList;
        envelope.fromAddress = 'scc@testdomain.com';
        email.fromAddress = 'scc@testdomain.com';
        email.plainTextBody = textbody;
        
        EmailServiceBestFranchiseNetwork emailProcess = new EmailServiceBestFranchiseNetwork();
        emailProcess.handleInboundEmail(email, envelope);
    }
}