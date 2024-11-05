global class parseEmailToFranchiseDirectLeadSource implements Messaging.InboundEmailHandler {
global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email,Messaging.InboundEnvelope envelope) {
        Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
        String TextbodyEmail = email.plainTextBody;
        string fullName = '';
        string capital = '';
        if(string.isNotBlank(TextbodyEmail)){
            Lead ld = new Lead();
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
            ld.RecordTypeId = devRecordTypeId;
            ld.Franchise_Lead_Source__c = 'Franchise Direct';  
            if(string.isNotBlank(TextbodyEmail.substringBetween('NAME: ', '\n')))
                fullName = TextbodyEmail.substringBetween('NAME: ', '\n');
         string[] sname = fullName.split(' ');
            ld.LastName = sname[0];
            String accname = fullName;
            if(string.isNotBlank(accname))
                ld.Company = accname;
            if(string.isNotBlank(TextbodyEmail.substringBetween('EMAIL:', '\n')))
                ld.Email = TextbodyEmail.substringBetween('EMAIL:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('CAPITAL_TO_INVEST: ', '\n')))
                capital = TextbodyEmail.substringBetween('CAPITAL_TO_INVEST: ', '\n');
            capital = capital.replaceAll('[^a-zA-Z0-9\\s+]', '');
            ld.Liquid_Assets__c = Decimal.valueOf(capital);
            if(string.isNotBlank(TextbodyEmail.substringBetween('TELEPHONE_NUMBER:', '\n')))
                ld.Phone = TextbodyEmail.substringBetween('TELEPHONE_NUMBER:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('ALT_TELEPHONE_NUMBER:', '\n')))
                ld.Cell_Phone__c = TextbodyEmail.substringBetween('ALT_TELEPHONE_NUMBER:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('ADDRESS_STATE:', '\n')))
                ld.state = TextbodyEmail.substringBetween('ADDRESS_STATE:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('ADDRESS_ZIP:', '\n')))
                ld.PostalCode = TextbodyEmail.substringBetween('ADDRESS_ZIP:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('ADDRESS_COUNTRY:', '\n')))
                ld.Country = TextbodyEmail.substringBetween('ADDRESS_COUNTRY:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('WHEN_WANTS_TO_START_NEW_BUSINESS:', '\n')))
                ld.Looking_to_Start__c = TextbodyEmail.substringBetween('WHEN_WANTS_TO_START_NEW_BUSINESS:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringAfter('COMMENTS:')))
                ld.Description = TextbodyEmail.substringBetween('COMMENTS:', '\n');
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