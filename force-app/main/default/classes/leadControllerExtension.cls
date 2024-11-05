public class leadControllerExtension {
    public final Lead ld;
    ApexPages.StandardController stdController;
    
    public leadControllerExtension(ApexPages.StandardController stdController) {
        this.ld = (Lead)stdController.getRecord();
    }
    public PageReference deleteLeads() {
        System.debug(this.ld);
        Database.DeleteResult dr = Database.delete(this.ld, false);
        
        if (dr.isSuccess()) {
            System.debug('Successfully deleted Lead with ID: ' + dr.getId());
            return listview();
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : dr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Lead fields that affected this error: ' + err.getFields());
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, err.getMessage());
                ApexPages.addMessage(msg);
            }
            return null;
        }        
    }

    public PageReference leadRecordView() {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        PageReference ref = new PageReference(baseUrl + '/s/detail/' + ld.Id);
        ref.setRedirect(true);
        return ref;
    }
   
    public PageReference listview() {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        PageReference ref = new PageReference(baseUrl + '/s/recordlist/Lead/Default');
        ref.setRedirect(true);
        return ref;
    }

}