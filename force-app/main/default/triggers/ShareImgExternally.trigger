trigger ShareImgExternally on ContentVersion (after insert) {
    List<ContentVersion> cvList = [SELECT ID,FirstPublishLocationId,ContentDocumentId,ContentDocument.Title,FileType 
                                    FROM ContentVersion WHERE ID IN :Trigger.newMap.keySet()];
    List<ContentDistribution> dists = new List<ContentDistribution>();
    for(ContentVersion cv: cvList ){
        String workOrder = string.valueof(cv.FirstPublishLocationId.getsobjecttype());
        if((cv.FileType.toLowercase() =='jpg' || cv.FileType.toLowercase() =='png' || cv.FileType.toLowercase() =='jpeg') && workOrder == 'Work_Order__c'){
            ContentDistribution cd = new ContentDistribution();
            cd.name = cv.ContentDocument.Title;
            cd.ContentVersionId = cv.ID;
            cd.PreferencesAllowOriginalDownload = true;
            cd.PreferencesAllowPDFDownload = true;
            cd.PreferencesAllowViewInBrowser = true;
            dists.add(cd);
        }
    }
    if(dists.size() > 0){
        insert dists;
    }
}