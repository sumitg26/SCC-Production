global class EmailToEntrepreneurLeadSource implements Messaging.InboundEmailHandler{
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String TextbodyEmail = email.plainTextBody;
        string fullName = '';
        string capital = '';
        if(string.isNotBlank(TextbodyEmail)){
            Lead ld = new Lead();
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
            ld.RecordTypeId = devRecordTypeId;
            ld.Franchise_Lead_Source__c = 'Entrepreneur';  
            if(string.isNotBlank(TextbodyEmail.substringBetween('Name: ', '\n')))
                fullName = TextbodyEmail.substringBetween('Name: ', '\n');
            string[] sname = fullName.split(' ');
            ld.LastName = sname[0];
            if(string.isNotBlank(fullName))
                ld.Company = fullName;
            if(string.isNotBlank(TextbodyEmail.substringBetween('Daytime Phone: ', '\n')))
                ld.Phone = TextbodyEmail.substringBetween('Daytime Phone: ', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Email: ', '\n')))
                ld.Email = TextbodyEmail.substringBetween('Email: ', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Address: ', '\n')))
                ld.Street = TextbodyEmail.substringBetween('Address: ', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('City:', '\n')))
                ld.City = TextbodyEmail.substringBetween('City:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('State: ', '\n')))
                ld.state = TextbodyEmail.substringBetween('State: ', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Zip code: ', '\n')))
                ld.PostalCode = TextbodyEmail.substringBetween('Zip code: ', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Capital to Invest: ', '\n')))
                capital = TextbodyEmail.substringBetween('Capital to Invest: ', '\n');
            capital = capital.replaceAll('[^a-zA-Z0-9\\s+]', '');
            ld.Liquid_Assets__c = Decimal.valueOf(capital);
            if(string.isNotBlank(TextbodyEmail.substringBetween('When to start: ', '\n')))
                ld.Looking_to_Start__c = TextbodyEmail.substringBetween('When to start: ', '\n');
            if(string.isNotBlank(TextbodyEmail.substringAfter('Comments: ')))
                ld.Description = TextbodyEmail.substringBetween('Comments: ', '\n');
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