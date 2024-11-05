global class LeadExtractionEmailServiceClass implements Messaging.InboundEmailHandler{
    
    global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, Messaging.InboundEnvelope env){
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        String TextbodyEmail = email.plainTextBody;
        string capital = '';
        //system.debug('TextbodyEmail>> '+TextbodyEmail);
        if(string.isNotBlank(TextbodyEmail)){
            Lead ld = new Lead();
            Id devRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Franchise').getRecordTypeId();
            ld.RecordTypeId = devRecordTypeId;
            ld.Franchise_Lead_Source__c = '5th Avenue';
            
            if(string.isNotBlank(TextbodyEmail.substringBetween('Lead ID:', '\n')))
                ld.Lead_Id__c = TextbodyEmail.substringBetween('Lead ID:', '\n');
            string datestring = TextbodyEmail.substringBetween('Date Posted:', '\n');
            
            if(string.isNotBlank(datestring)){
                Integer year = integer.valueOf(datestring.substring(7,11));
                Integer month = integer.valueOf(datestring.substring(1,3));
                Integer day = integer.valueOf(datestring.substring(4,6));
                integer hour = integer.valueOf(datestring.substring(12,14));
                integer minute = integer.valueOf(datestring.substring(15,17));
                integer second = integer.valueOf(datestring.substring(18,20));
                system.debug('date> '+year +':'+month +':'+day +':'+hour +':'+minute +':'+second);
                ld.Lead_Added_Date_Time__c = datetime.newInstance(year, month, day, hour, minute, second);
            }
            if(string.isNotBlank(TextbodyEmail.substringBetween('First Name:', '\n')))
                ld.FirstName = TextbodyEmail.substringBetween('First Name:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Last Name:', '\n')))
                ld.LastName = TextbodyEmail.substringBetween('Last Name:', '\n');
            String accname = TextbodyEmail.substringBetween('First Name:', '\n') + ' ' + TextbodyEmail.substringBetween('Last Name:', '\n');
            if(string.isNotBlank(accname))
                ld.Company = accname;
                if(string.isNotBlank(TextbodyEmail.substringBetween('Address:', 'City:')))
                ld.Street = TextbodyEmail.substringBetween('Address:', 'City:');
            if(string.isNotBlank(TextbodyEmail.substringBetween('City:', '\n')))
                ld.City = TextbodyEmail.substringBetween('City:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('State:', '\n')))
                ld.state = TextbodyEmail.substringBetween('State:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Zip:', '\n')))
                ld.PostalCode = TextbodyEmail.substringBetween('Zip:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Email:', '\n')))
                ld.Email = TextbodyEmail.substringBetween('Email:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Phone:', '\n')))
                ld.Phone = TextbodyEmail.substringBetween('Phone:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Best Time to Contact:', '\n')))
                ld.Best_Time_To_Contact__c = TextbodyEmail.substringBetween('Best Time to Contact:', '\n');
            if(string.isNotBlank(TextbodyEmail.substringBetween('Collection:', '\n')))
                ld.Collection__c = TextbodyEmail.substringBetween('Collection:', '\n');
            ld.Description = '';
            if(string.isNotBlank(TextbodyEmail.substringBetween('Franchise Coordinator:', '\n'))){
                string franchCoord = TextbodyEmail.substringBetween('Franchise Coordinator:', '\n');
                ld.Franchise_Coordinator__c = franchCoord;
                ld.Description = 'Coordinator: '+franchCoord +'\n';
            }
            if(string.isNotBlank(TextbodyEmail.substringBetween('Timeframe to Start Business:', '\n')))
                ld.Looking_to_Start__c = TextbodyEmail.substringBetween('Timeframe to Start Business:', '\n');
               if(string.isNotBlank(TextbodyEmail.substringBetween('Liquid Capital to Invest: ', ' to')))
                capital = TextbodyEmail.substringBetween('Liquid Capital to Invest: ', ' to');
             capital = capital.replaceAll('[^a-zA-Z0-9\\s+]', '');
            ld.Liquid_Assets__c = Decimal.valueOf(capital);
            if(string.isNotBlank(TextbodyEmail.substringBetween('Net Worth (approx):', '\n')))
                ld.Net_Worth__c = TextbodyEmail.substringBetween('Net Worth (approx):', '\n');
            if(string.isNotBlank(TextbodyEmail.substringAfter('Comments:')))
                ld.Description = ld.Description +TextbodyEmail.substringAfter('Comments:').remove('\n');
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