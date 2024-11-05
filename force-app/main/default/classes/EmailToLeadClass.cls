global class EmailToLeadClass implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String TextbodyEmail = email.plainTextBody;
        string fullName = '';
        string capital = '';
        if(string.isNotBlank(TextbodyEmail)){
            Lead ld = new Lead();
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
            ld.RecordTypeId = devRecordTypeId;
            ld.Franchise_Lead_Source__c = 'BizBuySell';  
            if(string.isNotBlank(TextbodyEmail.substringBetween('Name: ', '\n')))
                fullName = TextbodyEmail.substringBetween('Name: ', '\n');
         string[] sname = fullName.split(' ');
            ld.LastName = sname[0];
            String accname = fullName;
            if(string.isNotBlank(accname))
                ld.Company = accname;
            if(string.isNotBlank(TextbodyEmail.substringBetween('Email:', '\n')))
                ld.Email = TextbodyEmail.substringBetween('Email:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Phone:', '\n')))
                ld.Phone = TextbodyEmail.substringBetween('Phone:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('City:', '\n')))
                ld.City = TextbodyEmail.substringBetween('City:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('State:', '\n')))
                ld.state = TextbodyEmail.substringBetween('State:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Zip:', '\n')))
                ld.PostalCode = TextbodyEmail.substringBetween('Zip:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Available Capital: ', '\n')))
                capital = TextbodyEmail.substringBetween('Available Capital: ', '\n');
             capital = capital.replaceAll('[^a-zA-Z0-9\\s+]', '');
            ld.Liquid_Assets__c = Decimal.valueOf(capital);
            if(string.isNotBlank(TextbodyEmail.substringBetween('Time frame:', '\n')))
                ld.Looking_to_Start__c = TextbodyEmail.substringBetween('Time frame:', '\n');
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