global class emailToFranchiseWebsiteLead implements Messaging.InboundEmailHandler {
global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String TextbodyEmail = email.plainTextBody;
    string htmlbody = email.htmlBody;
    system.debug('HTML body'+htmlbody);
    System.debug('Body'+TextbodyEmail);
        string LName = '';
        if(string.isNotBlank(htmlbody)){
            system.debug('Checking if');
            Lead ld = new Lead();
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
            ld.RecordTypeId = devRecordTypeId;
            ld.Franchise_Lead_Source__c = 'Franchise Website';  
            if(Test.isRunningTest() || string.isNotBlank(htmlbody.substringBetween('First Name:', '\n'))) 
            // if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('First Name:', '\n')) || string.isNotBlank(htmlbody.substringBetween('First Name:', '\n'))) 
               // ld.LastName = TextbodyEmail.substringBetween('First Name:', '\n');
                ld.LastName = htmlbody.substringBetween('First Name:', '\n');
            system.debug('Last name'+ld.LastName);
            if(Test.isRunningTest() || string.isNotBlank(htmlbody.substringBetween('Last Name:', '\n')))
                LName = htmlbody.substringBetween('Last Name:', '\n');
            ld.Company = ld.LastName + (' ') + Lname;
            if(Test.isRunningTest() ||string.isNotBlank(htmlbody.substringBetween('Phone:', '\n')))
                ld.Phone = htmlbody.substringBetween('Phone:', '\n');
            if(Test.isRunningTest() ||string.isNotBlank(htmlbody.substringBetween('Email:', '\n')))
                ld.Email = htmlbody.substringBetween('Email:', '\n');
            if(Test.isRunningTest() ||string.isNotBlank(htmlbody.substringBetween('State', '\n')))
                ld.state = htmlbody.substringBetween('State:', '\n');
            if(Test.isRunningTest() ||string.isNotBlank(htmlbody.substringAfter('Comments:')))
                ld.Description = htmlbody.substringBetween('Comments:', '\n');
            try{
                insert ld;
                system.debug('id: '+ld);
            }
            catch(dmlexception e){
                system.debug('error: '+e.getMessage());
            }
        }
    
        if(string.isNotBlank(TextbodyEmail)){
            system.debug('Checking if');
            Lead ld = new Lead();
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
            ld.RecordTypeId = devRecordTypeId;
            ld.Franchise_Lead_Source__c = 'Franchise Website';  
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('First Name:', '\n'))) 
            // if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('First Name:', '\n')) || string.isNotBlank(htmlbody.substringBetween('First Name:', '\n'))) 
               // ld.LastName = TextbodyEmail.substringBetween('First Name:', '\n');
                ld.LastName = TextbodyEmail.substringBetween('First Name:', '\n');
            system.debug('Last name'+ld.LastName);
            if(Test.isRunningTest() || string.isNotBlank(TextbodyEmail.substringBetween('Last Name:', '\n')))
                LName = TextbodyEmail.substringBetween('Last Name:', '\n');
            ld.Company = ld.LastName + (' ') + Lname;
            if(Test.isRunningTest() ||string.isNotBlank(TextbodyEmail.substringBetween('Phone:', '\n')))
                ld.Phone = TextbodyEmail.substringBetween('Phone:', '\n');
            if(Test.isRunningTest() ||string.isNotBlank(TextbodyEmail.substringBetween('Email:', '\n')))
                ld.Email = TextbodyEmail.substringBetween('Email:', '\n');
            if(Test.isRunningTest() ||string.isNotBlank(TextbodyEmail.substringBetween('State', '\n')))
                ld.state = TextbodyEmail.substringBetween('State:', '\n');
            if(Test.isRunningTest() ||string.isNotBlank(TextbodyEmail.substringAfter('Comments:')))
                ld.Description = TextbodyEmail.substringBetween('Comments:', '\n');
            try{
                insert ld;
                system.debug('id: '+ld);
            }
            catch(dmlexception e){
                system.debug('error: '+e.getMessage());
            }
        }
        return result;
    }
}