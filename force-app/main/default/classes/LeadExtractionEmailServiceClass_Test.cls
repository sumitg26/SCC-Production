@isTest
public class LeadExtractionEmailServiceClass_Test {
    public static testmethod void test1(){
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        List<String> toList = new List<String>{'abc@test1.com'};
            string textbody = 'Lead ID:	303450' + '\n';
        textbody = textbody + 'Date Posted:	11/19/2020 09:11:49' + '\n';
        textbody = textbody + 'First Name:	Ferry' + '\n';
        textbody = textbody + 'Last Name:	Cherry' + '\n';
        textbody = textbody + 'Address:	New street' + '\n';
        textbody = textbody + 'City:	De Leon Springs' + '\n';
        textbody = textbody + 'State:	FL' + '\n';
        textbody = textbody + 'Zip:	32130' + '\n';
        textbody = textbody + 'Email:	cherry@testmail.com' + '\n';
        textbody = textbody + 'Phone:	533666333' + '\n';
        textbody = textbody + 'Best Time to Contact:	Mornings' + '\n';
        textbody = textbody + 'Collection:	CV_Exec_5' + '\n';
        textbody = textbody + 'Franchise Coordinator:	Sheila Davis' + '\n';
        textbody = textbody + 'Timeframe to Start Business:	ASAP' + '\n';
        textbody = textbody + 'Liquid Capital to Invest: $10000' + ' to';
        textbody = textbody + 'Net Worth (approx):	$1,000,000 to 1,249,999' + '\n';
        textbody = textbody + 'Comments:	B2BProductsServices; He would like to open a franchise business in ' + '\n';
        textbody = textbody + 'or near the Ocala, FL area.';
        
        email.subject = 'Test';
        email.fromname = 'John Dev';
        email.toAddresses = toList;
        env.fromAddress = 'scc@testdomain.com';
        email.fromAddress = 'scc@testdomain.com';
        email.plainTextBody = textbody;
        //email.binaryAttachments = b;
        
        LeadExtractionEmailServiceClass emailProcess = new LeadExtractionEmailServiceClass();
        emailProcess.handleInboundEmail(email, env);
    }
}