@IsTest
private class CustomerHealthSummaryGeneratorTest {

    // --- Mock for successful service call ---
    private class SuccessMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(200);
            res.setBody(JSON.serialize(new Map<String, Object>{
                'candidates' => new List<Object>{
                    new Map<String, Object>{
                        'content' => new Map<String, Object>{
                            'parts' => new List<Object>{
                                new Map<String, Object>{ 'text' => 'Customer shows strong product adoption and healthy engagement.' }
                            }
                        }
                    }
                }
            }));
            return res;
        }
    }

    // --- Mock for failed service call ---
    private class ErrorMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500);
            res.setBody('{"error":"Mock failure"}');
            return res;
        }
    }

    // --- Test: successful health summary generation ---
    @IsTest
    static void testGenerateCustomerHealthSummary_Success() {
        // Create sample Account
        Account acc = new Account(
            Name = 'Acme Corporation',
            Industry = 'Manufacturing',
            Type = 'Customer'
        );
        insert acc;

        // Related records
        insert new Opportunity(
            Name = 'Q4 Expansion',
            AccountId = acc.Id,
            StageName = 'Closed Won',
            Amount = 250000,
            CloseDate = System.today()
        );

        insert new Rocketlane_Project__c(
            Name = 'Onboarding Project',
            Account__c = acc.Id,
            Project_Status__c = 'In progress',
            Risk_Flag__c = 'On Track'
        );

        insert new Intercom_Support_Ticket__c(
            Name = 'Ticket #123',
            Account__c = acc.Id,
            Ticket_Status__c = 'Resolved'
        );

        // Mock callout
        Test.setMock(HttpCalloutMock.class, new SuccessMock());

        Test.startTest();
        String result = CustomerHealthSummaryGenerator.generateGeminiCustomerHealthSummary(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assert(result.contains('healthy engagement'),
            'Expected the mock summary text in the result.');

        Account updated = [SELECT AI_Customer_Health_Summary__c FROM Account WHERE Id = :acc.Id];
        System.assert(updated.AI_Customer_Health_Summary__c.contains('healthy engagement'),
            'Expected Account summary to be updated.');
    }

    // --- Test: service call returns error ---
    @IsTest
    static void testGenerateCustomerHealthSummary_ErrorHandling() {
        Account acc = new Account(Name = 'Error Account');
        insert acc;

        Test.setMock(HttpCalloutMock.class, new ErrorMock());

        Test.startTest();
        String result = CustomerHealthSummaryGenerator.generateGeminiCustomerHealthSummary(acc.Id);
        Test.stopTest();

        System.assert(result.contains('Error generating customer health summary'),
            'Expected graceful handling of service errors.');
    }
}