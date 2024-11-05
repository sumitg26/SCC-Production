public class PaymentController{
    public string paymentCode{get;set;}
    public boolean paymentSuccess{get;set;}
    public string paymentResponse{get;set;}
    public Work_Order__c workOrderObj {get;set;}
    public Decimal payabletAmt {get;set;}
    public String workOrderId  {get;set;}
    public String applicationID {get;set;}
    public String locationID {get;set;}
            
    public PaymentController() {
        try
        {
            paymentSuccess = false;
            workOrderId = ApexPages.currentPage().getParameters().get('id');
            workOrderObj = [SELECT Id,Name,Balance_Due1__c,Invoice_Frequency__c,OwnerId From Work_Order__c Where id = :workOrderId and Invoice_Frequency__c = 'Single'Limit 1];
            if(workOrderObj != null && workOrderObj.Balance_Due1__c != null)
            {
                payabletAmt = workOrderObj.Balance_Due1__c;
                applicationID = SquareAPI__c.getInstance(workOrderObj.OwnerId).ApplicationId__c;
                locationID = SquareAPI__c.getInstance(workOrderObj.OwnerId).LocationId__c;
            }
        }
        catch(Exception e)
        {
            System.debug('Error PaymentController.....' + e.getMessage());
            paymentResponse = e.getMessage();
        }
    }
    public void makePayment(){
        try
        {
            if(workOrderObj != null && workOrderObj.Balance_Due1__c > 0)
            {
                System.debug('!!!!!'+workOrderObj);
                Http http = new Http();
                HttpRequest request = new HttpRequest();             
                request.setEndpoint(SquareAPI__c.getInstance(workOrderObj.OwnerId ).EndpointURL__c);            
                request.setHeader('Authorization', 'Bearer ' + SquareAPI__c.getInstance(workOrderObj.OwnerId ).Token__c);
                request.setMethod('POST');
                request.setHeader('Accept', 'application/json');
                request.setHeader('Content-Type', 'application/json;charset=UTF-8');
                Blob b = Crypto.GenerateAESKey(128);
                String h = EncodingUtil.ConvertTohex(b);
                String uniqueKey = h.SubString(0,8)+ '-' + h.SubString(8,12) + '-' + h.SubString(12,16) + '-' + h.SubString(16,20) + '-' + h.substring(20);
                
                request.setBody('{"idempotency_key": "' + uniqueKey + '","source_id": "' + paymentCode +'","autocomplete":true,"amount_money":{"amount" : ' + (payabletAmt * 100) + ',"currency":"USD"}}');                
                //Adding as payabletAmt * 100 part of prod case as API accepts amt in cent
                
                System.debug('request.Body............' +  request.getBody());
                
                HttpResponse response = http.send(request);
                System.debug('response.Body............' +  response.getBody());
                if(response.getBody() != null)
                {
                    paymentSuccess = true;
                    PaymentResponseWrapper paymentResObj = (PaymentResponseWrapper)JSON.deserialize(response.getBody(),PaymentResponseWrapper.class);
                    
                    if(response.getStatusCode() == 200)
                    {
                        paymentResponse = 'Thank you for making payment.We appreciate your Business!';
                        //create payment detail record
                        Payment__c paymentObj = new Payment__c();
                        paymentObj.PaymentID__c = paymentResObj.payment.id;
                        paymentObj.Card_Type__c = paymentResObj.payment.card_details.card.card_type;
                        paymentObj.Entry_Method__c = paymentResObj.payment.card_details.entry_method;
                        paymentObj.Expiry_Month__c = paymentResObj.payment.card_details.card.exp_month;
                        paymentObj.Expiry_Year__c = paymentResObj.payment.card_details.card.exp_year;
                        paymentObj.Last_4_Digit__c = paymentResObj.payment.card_details.card.last_4;
                        paymentObj.Card_Brand__c = paymentResObj.payment.card_details.card.card_brand;
                        paymentObj.Order_ID__c = paymentResObj.payment.order_id;
                        paymentObj.Payment_Creation_Date__c = paymentResObj.payment.created_at;
                        paymentObj.Receipt_Number__c = paymentResObj.payment.receipt_number;
                        paymentObj.Source_Type__c = paymentResObj.payment.source_type;
                        paymentObj.Status__c = paymentResObj.payment.status;
                        paymentObj.Work_Order__c = workOrderId;
                        paymentObj.Amount__c = paymentResObj.payment.amount_money.amount / 100;
                        insert paymentObj;
                    }
                    else
                    {
                        paymentResponse = paymentResObj.errors[0].detail;
                        Payment__c paymentObj = new Payment__c();
                        paymentObj.Error_Category__c = paymentResObj.errors[0].category;
                        paymentObj.Error_Code__c = paymentResObj.errors[0].code;
                        paymentObj.Error_Detail__c = paymentResObj.errors[0].detail;
                        paymentObj.Work_Order__c = workOrderId;
                        insert paymentObj;
                    }
                }
            }      
        }
        catch(Exception e)
        {
            System.debug('Error PaymentController:makePayment().....' + e.getMessage());
            paymentResponse = e.getMessage();
        }
    }
}