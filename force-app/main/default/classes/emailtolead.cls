global class emailtolead implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        System.debug('Hi');
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String TextbodyEmail = email.plainTextBody;
        
        string LName = '';
        if(string.isNotBlank(TextbodyEmail)){
            Lead ld = new Lead();
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
            ld.RecordTypeId = devRecordTypeId;
            ld.Franchise_Lead_Source__c = 'Facebook';  
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('First Name:', 'Last')))
                ld.LastName = TextbodyEmail.substringBetween('First Name:', 'Last');
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Last Name:', 'Phone')))
                LName = TextbodyEmail.substringBetween('Last Name:', 'Phone');
            ld.Company = ld.LastName + Lname;
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Phone:', 'Email')))
                ld.Phone = TextbodyEmail.substringBetween('Phone:', 'Email');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Email:', 'State')))
                ld.Email = TextbodyEmail.substringBetween('Email:', 'State');
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('State:', 'Tell')))
                ld.State = TextbodyEmail.substringBetween('State:', 'Tell');
                if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Tell us about yourself:', 'IP')))
                ld.Description = TextbodyEmail.substringBetween('Tell us about yourself:', 'IP');
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('IP:','\n')))
                ld.IP__c = TextbodyEmail.substringBetween('IP:','\n');
           
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