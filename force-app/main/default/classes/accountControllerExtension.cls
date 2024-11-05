public class accountControllerExtension {
    public final Account acct;
    ApexPages.StandardController stdController;
    
    public accountControllerExtension(ApexPages.StandardController stdController) {
        this.acct = (Account)stdController.getRecord();
    }
    
    public PageReference deleteAccounts() {
        System.debug(this.acct);
        Database.DeleteResult dr = Database.delete(this.acct, false);
        
        if (dr.isSuccess()) {
            System.debug('Successfully deleted account with ID: ' + dr.getId());
            return accountListView();
        }
        else {
            // Operation failed, so get all errors                
            for(Database.Error err : dr.getErrors()) {
                System.debug('The following error has occurred.');                    
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
                System.debug('Account fields that affected this error: ' + err.getFields());
                ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.Error, err.getMessage());
                ApexPages.addMessage(msg);
            }
            return null;
        }        
    }

    public PageReference accountRecordView() {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        PageReference ref = new PageReference(baseUrl + '/s/detail/' + acct.Id);
        ref.setRedirect(true);
        return ref;
    }
    
    public PageReference accountListView() {
        String baseUrl = System.URL.getSalesforceBaseUrl().toExternalForm();
        PageReference ref = new PageReference(baseUrl + '/s/recordlist/Account/Default');
        ref.setRedirect(true);
        return ref;
    }
}