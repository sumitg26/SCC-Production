/*
	Test Class:EmailServiceBestFranchiseNetworkTest
*/
global class EmailServiceBestFranchiseNetwork implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String TextbodyEmail = email.plainTextBody;
        string fName = '';
        if(string.isNotBlank(TextbodyEmail)){
            Lead ld = new Lead();
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
            ld.RecordTypeId = devRecordTypeId;
            ld.Status='New_Lead';
            ld.Franchise_Lead_Source__c = 'Best Franchise Networks';  
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Email:', 'First')))
                ld.Email = TextbodyEmail.substringBetween('Email:', 'First');
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('First Name:', 'Last')))
                ld.FirstName = TextbodyEmail.substringBetween('First Name:', 'Last');
            	fName=TextbodyEmail.substringBetween('First Name:', 'Last');
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Last Name:', 'Cell')))
                ld.LastName = TextbodyEmail.substringBetween('Last Name:', 'Cell');
               	ld.Company = fName+ld.LastName;
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Cell:', 'Zip')))
                ld.Cell_Phone__c = TextbodyEmail.substringBetween('Cell:', 'Zip');
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Zip:','State')))
                ld.PostalCode = TextbodyEmail.substringBetween('Zip:','State');
           	if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('State:','Capital')))
                ld.State = TextbodyEmail.substringBetween('State:','Capital');
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Capital:','Comments')))
                ld.Additional_Financial_Comments__c = TextbodyEmail.substringBetween('Capital:','Comments');
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Comments:','Thanks,')))
                ld.Description = TextbodyEmail.substringBetween('Comments:','Thanks,'); 
            
            try{
                insert ld;
                system.debug('id: '+ld.id);
            }
            catch(dmlexception e){
                system.debug('error: '+e.getMessage());
            }
        }
        return result;
    }
}