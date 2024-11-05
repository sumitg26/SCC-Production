global class CaptureContractSignatureController{

    global String updatedTemplateLine{get;set;}
    global Account AccSignObj {get;set;}
    global Guest_Account__c guestAcc {get;set;}
    global Attachment Att{get;set;}
    global Id AccId;
    global String signedBy{get;set;}
    global String imageUrl {get;set;}
    global String DynamicSignature{get;set;}
    
    global Integer AttachCount{
        get{
        Integer c=0;
        for(Attachment att : [select Id from Attachment where ParentId = :AccId AND Name='Signature.pdf' ]) 
            c++;
        return c;
        }
    }
    
    global CaptureContractSignatureController(){
    
        templateProcessing();
    }
    global void templateProcessing (){
        AccId = ApexPages.currentPage().getParameters().get('id');
        system.debug('att'+Att);
        signedBy = '';
       
        AccSignObj = [SELECT Id,Name,Agreement_Signed_Date__c,Agreement_Signed__c,Customer_Name__c,Contract_Resource__c FROM Account WHERE Id =:AccId LIMIT 1];
        system.debug('date>>'+AccSignObj.Agreement_Signed_Date__c);
        DynamicSignature = AccSignObj.Contract_Resource__c;
        system.debug('DynamicSignature= '+DynamicSignature);
        //guestAcc = [Select Account_Id__c, Id, Agreement_Signed_Date__c, Agreement_Signed_By__c, Agreement_Signed__c, Name From Guest_Account__c  WHERE Account_Id__c=:AccId LIMIT 1];
        Att = new Attachment();
        //Querying all the fields on Account
        String SobjectApiName = 'Account';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String commaSepratedFields = '';
        for(String fieldName : fieldMap.keyset()){
            if(commaSepratedFields == null || commaSepratedFields == ''){
                commaSepratedFields = fieldName;
            }else{
                commaSepratedFields = commaSepratedFields + ', ' + fieldName;
            }
        }
        
        //Additional Fields
        commaSepratedFields += '';
        
        //Query Formation
        String query = 'SELECT ' + commaSepratedFields + ' FROM ' + SobjectApiName + ' WHERE Id=:AccId LIMIT 1';
        system.debug('query='+query);
        //Querying from the database
        sObject AccRecord = Database.query(query);
        
        String templateName = String.valueOf(AccRecord.get('Contract_Template_Name__c'));
        system.debug('templateName ='+templateName);
        
        
        List<Smart_Agreement_Template__c> sat = [Select Id,Name,Agreement_Content__c FROM Smart_Agreement_Template__c  WHERE Id=:templateName];
        
        for(Smart_Agreement_Template__c templateLine: sat){
            updatedTemplateLine = '';
            
            if(templateLine.Agreement_Content__c.containsIgnoreCase('[[')){ //If the template lines contains any merge field or not.
                List<String> splittedByBracket = templateLine.Agreement_Content__c .split(']]'); //All the sentences with merge fields are separated.
                system.debug('splittedByBracket='+splittedByBracket);
                for(String s: splittedByBracket){
                    //Check if the sentence contains any merge field
                    if(s.stripHtmlTags().contains('[[')){
                        String keyword = s.stripHtmlTags().substringAfterLast('[['); // Extracting the merge field name from the sentence.
                        system.debug('keyword='+keyword);
                        Map<String, Merge_Fields_Mapping__c> mapCS = Merge_Fields_Mapping__c.getAll(); //Create a map of all the CS Values
                        system.debug('mapCS.keySet='+mapCS.keySet());
                        if(mapCS.keySet().contains(keyword)){
                            //Get the field name from custom setting
                            system.debug('keyword found in cs');
                            String apiName = mapCS.get(keyword).Field_API_Name__c;
                            System.debug('api name in cs='+apiName);
                            String fieldValue = '';
                            
                            //If the merge field is a parent field
                            if(apiName.contains('.')){
                                List<String> apiNameSplit = apiName.split('\\.');
                                if(apiNameSplit.size() == 2){
                                    fieldValue = String.valueOf(AccRecord.getsObject(apiNameSplit[0]).get(apiNameSplit[1]));
                                    system.debug('fieldValue 2='+fieldValue);
                                }
                                else if(apiNameSplit.size() == 3){
                                    fieldValue = String.valueOf(AccRecord.getsObject(apiNameSplit[0]).getsObject(apiNameSplit[1]).get(apiNameSplit[2]));
                                    system.debug('fieldValue 3='+fieldValue);
                                }
                                else if(apiNameSplit.size() == 4){
                                    fieldValue = String.valueOf(AccRecord.getsObject(apiNameSplit[0]).getsObject(apiNameSplit[1]).getsObject(apiNameSplit[2]).get(apiNameSplit[3]));
                                    system.debug('fieldValue 4='+fieldValue);
                                }
                                else if(apiNameSplit.size() == 5){
                                    fieldValue = String.valueOf(AccRecord.getsObject(apiNameSplit[0]).getsObject(apiNameSplit[1]).getsObject(apiNameSplit[2]).getsObject(apiNameSplit[3]).get(apiNameSplit[4]));
                                }
                            }
                            //If the merge field is on Account level
                            else{
                                fieldValue = String.valueOf(AccRecord.get(apiName));
                            }
                            if(AccRecord !=null && apiName =='Agreement_Signed_Date__c'){
                                
                                if(fieldValue == null || fieldValue == '')
                                    fieldValue = string.valueof(system.today().format());
                                else 
                                    fieldValue = AccSignObj.Agreement_Signed_Date__c.format();
                                system.debug(' inside fieldValue : '+fieldValue);
                                s = s.replace(keyword, fieldValue);
                                s = s.replace('[[','');
                            }
                            else if(AccRecord !=null && fieldValue!=null && fieldValue!=''){
                                //Replace the keyword with the actual value in the sentence
                                s = s.replace(keyword, fieldValue);
                                //Replace the opening braces with blank value for proper formatting
                                s = s.replace('[[','');
                            }else{
                                s = s.replace('[['+keyword,'');
                            }
                        }
                    }
                   
                    //Rejoin all the split sentences to form one template Line
                    updatedTemplateLine += s;
                }
            }
            
        }
    }
    global List<Id> FinalAttach{
        get{
                List<Id> photoIds = new List<Id>();
                Id AccId = ApexPages.currentPage().getParameters().get('id');
                for(Attachment att : [select Id from Attachment where ParentId = :AccId AND Name='Signature.pdf' order by CreatedDate desc limit 1]) {
                    photoIds.Add(att.Id);
                }            
            return photoIds;
        }
    }
    
    global void saveCustomerSignature() {
        try{
            Attachment accSign = new Attachment();
            accSign.ParentID = AccId;
            accSign.Body = EncodingUtil.base64Decode(imageUrl);
            accSign.contentType = 'image/png';
            accSign.Name = 'Signature.pdf';
            accSign.OwnerId = UserInfo.getUserId();
            insert accSign;
            system.debug('accSign attach');
            
            guestAcc = new Guest_Account__c();
            
            guestAcc.Agreement_Signed_By__c = signedBy;
            guestAcc.Account_Id__c =  AccId;
            guestAcc.Agreement_Signed_Date__c = System.Today();
            guestAcc.Agreement_Signed__c = true;
            insert guestAcc;
            
            system.debug('guest acc'+guestAcc);
            templateProcessing();
            Integer i = AttachCount ;
        }catch(Exception e){
            system.debug('---------- ' + e.getMessage());
            //return JSON.serialize(e.getMessage());
        }
        
    }
    global void generatePdfWithSign(){
       system.debug('Contract PDF');
        PageReference pdf;
               pdf = new PageReference ('/apex/CaptureContractSignature?id='+AccId);
            Blob body;
            if(pdf != null && !test.isRunningTest()){
               body = pdf.getContentAsPDF();
               
            }else{
                body = Blob.valueOf('No file');
            }
            Account AccOwner = [Select Id,OwnerId FROM Account WHERE Id =:AccId];
            system.debug('accid= '+accId+'SOQL= '+AccOwner);
            Attachment contract = new Attachment();
            contract.ParentID = AccId;
            contract.Body = body ;
            contract.Name = 'Smart Interval Cleaning Agreement.pdf';
           //contract.OwnerId = AccOwner.OwnerId;
            contract.OwnerId = UserInfo.getUserId();
            system.debug('Attachment Contact >>'+contract);
            insert contract;
            
            /*Account Acc = [Select Id,Agreement_Signed__c FROM Account WHERE Id =:AccId];
            Acc.Agreement_Signed__c =true;
            Acc.Agreement_Signed_Date__c = System.Today();
            update Acc;*/
            system.debug('Contract PDF insert'+contract);
        
    }  
}