@isTest
Public class TestPaymentController
{
    public static Work_Order__c workOrder{get;set;}
    public static void setupData(){
        SquareAPI__c squareAPI = new SquareAPI__c();
        squareAPI.ApplicationId__c = 'test';
        squareAPI.EndpointURL__c = 'https://connect.squareupsandbox.com/v2/payments';        
        squareAPI.Token__c = 'test';
        insert squareAPI;
        
        workOrder = new Work_Order__c();
        workOrder.Status__c = 'Pending';
        workOrder.Requested_By__c = 'Test';
        workOrder.Invoice_Frequency__c = 'Single';
        insert workOrder;
        
        Work_Order_Item__c workOrderItem = new Work_Order_Item__c();
        workOrderItem.Price__c = 1300;
        workOrderItem.Work_Order__c = workOrder.id;
        insert workOrderItem;
        
        ApexPages.currentPage().getParameters().put('id',workOrder.Id);
    }
    
    @isTest static void testMakePayment() {
        setupData();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.startTest();
               
        PaymentController obj = new PaymentController();
        obj.makePayment();
        Test.stopTest();
    }
    
    @isTest static void testMakePaymentError() {
        setupData();
        Test.setMock(HttpCalloutMock.class, new MockHttpeErrorResponseGenerator ());
        Test.startTest();
               
        PaymentController obj = new PaymentController();
        obj.makePayment();
        Test.stopTest();
    }
    
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"payment": {"id": "XFtuxZU1AKqSiMqlzESzJ7kat1BZY","created_at": "2020-07-23T17:56:36.296Z","updated_at": "2020-07-23T17:56:36.463Z","amount_money": {"amount": 1200,"currency": "USD"},"status": "COMPLETED","delay_duration": "PT168H","source_type": "CARD","card_details": {"status": "CAPTURED","card": {"card_brand": "VISA","last_4": "1111","exp_month": 11,"exp_year": 2022,"fingerprint": "sq-1-CLX6VYqy7Ad6SORZw7VdPMZUtU370yLA7wYBZC5yJpVERAAQiMMB7hdEkdha2ikEpg","card_type": "CREDIT","bin": "411111"},"entry_method": "KEYED","cvv_status": "CVV_ACCEPTED","avs_status": "AVS_ACCEPTED","statement_description": "SQ *DEFAULT TEST ACCOUNT"},"location_id": "LX2PH9SEARJQV","order_id": "zSGONuz8nt1vlWvr8sZaGtEIPkaZY","total_money": {"amount": 1200,"currency": "USD"},"receipt_number": "XFtu","receipt_url": "https://squareupsandbox.com/receipt/preview/XFtuxZU1AKqSiMqlzESzJ7kat1BZY","delay_action": "CANCEL","delayed_until": "2020-07-30T17:56:36.296Z"}}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockHttpeErrorResponseGenerator implements HttpCalloutMock {
        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"errors": [{"code": "UNAUTHORIZED","detail": "test","category": "AUTHENTICATION_ERROR"}]}');
            res.setStatusCode(400);
            return res;
        }
    }
    
}