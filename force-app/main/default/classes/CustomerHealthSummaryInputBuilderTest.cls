@IsTest
private class CustomerHealthSummaryInputBuilderTest {

    // Utility method to create realistic data
    private static Account createTestData() {
        Account acc = new Account(
            Name = 'Orion Technologies',
            Industry = 'Technology',
            Type = 'Customer'
        );
        insert acc;

        // Add some Opportunities
        insert new List<Opportunity>{
            new Opportunity(
                Name = 'Renewal FY25',
                AccountId = acc.Id,
                StageName = 'Closed Won',
                Amount = 120000,
                CloseDate = System.today().addDays(-10)
            ),
            new Opportunity(
                Name = 'Expansion Deal',
                AccountId = acc.Id,
                StageName = 'Negotiation/Review',
                Amount = 300000,
                CloseDate = System.today().addMonths(1)
            )
        };

        // Add Rocketlane Projects
        insert new List<Rocketlane_Project__c>{
            new Rocketlane_Project__c(
                Name = 'Implementation Project',
                Account__c = acc.Id,
                Project_Status__c = 'In progress',
                Risk_Flag__c = 'On Track'
            ),
            new Rocketlane_Project__c(
                Name = 'Optimization Sprint',
                Account__c = acc.Id,
                Project_Status__c = 'Completed',
                Risk_Flag__c = 'On Track'
            )
        };

        // Add Intercom Tickets
        insert new List<Intercom_Support_Ticket__c>{
            new Intercom_Support_Ticket__c(
                Name = 'Support Ticket #1',
                Account__c = acc.Id,
                Ticket_Status__c = 'In progress'
            ),
            new Intercom_Support_Ticket__c(
                Name = 'Support Ticket #2',
                Account__c = acc.Id,
                Ticket_Status__c = 'Resolved'
            )
        };

        return acc;
    }

    @IsTest
    static void testCompileHealthInput_WithData() {
        Account acc = createTestData();

        Test.startTest();
        String result = CustomerHealthSummaryInputBuilder.compileHealthInput(acc.Id);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null.');
        System.assert(result.contains('Account Overview'), 'Should contain Account Overview section.');
        System.assert(result.contains('Opportunities (2 total)'), 'Should include Opportunity count.');
        System.assert(result.contains('Rocketlane Projects (2 total)'), 'Should include Rocketlane count.');
        System.assert(result.contains('Intercom Tickets (2 total)'), 'Should include Ticket count.');
        System.assert(result.contains('End of data.'), 'Should end with "End of data."');
    }

    @IsTest
    static void testCompileHealthInput_NoData() {
        Account acc = new Account(Name = 'Empty Account', Type = 'Prospect');
        insert acc;

        Test.startTest();
        String result = CustomerHealthSummaryInputBuilder.compileHealthInput(acc.Id);
        Test.stopTest();

        System.assert(result.contains('None found'), 'Should handle empty related lists gracefully.');
    }

    @IsTest
    static void testCompileHealthInput_InvalidId() {
        Test.startTest();
        String result = CustomerHealthSummaryInputBuilder.compileHealthInput('001000000000000AAA');
        Test.stopTest();

        System.assert(result.startsWith('Error compiling account data'),
            'Should handle invalid account IDs gracefully.');
    }
}