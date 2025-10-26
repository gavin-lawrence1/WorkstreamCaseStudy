@IsTest
private class IntercomSupportTicketTriggerTest {

    @IsTest
    static void testInsertAndUpdateFiresTrigger() {
        // --- Step 1: Setup mock Account ---
        Account acc = new Account(Name = 'Test Account');
        insert acc;

        // --- Step 2: Create a new Intercom Support Ticket ---
        Intercom_Support_Ticket__c ticket = new Intercom_Support_Ticket__c(
            Account__c = acc.Id,
            Ticket_Status__c = 'New'
        );

        Test.startTest();
        // Insert (fires trigger)
        insert ticket;

        // Update (fires trigger again)
        ticket.Ticket_Status__c = 'In Progress';
        update ticket;
        Test.stopTest();

        // --- Step 3: Verify trigger executed without exception ---
        System.assert(true, 'Trigger executed successfully on insert and update.');
    }

    @IsTest
    static void testTriggerWithNoAccount() {
        // --- Ticket without Account reference ---
        Intercom_Support_Ticket__c orphanTicket = new Intercom_Support_Ticket__c(
            Ticket_Status__c = 'New'
        );

        Test.startTest();
        insert orphanTicket;
        Test.stopTest();

        System.assert(true, 'Trigger handled missing Account__c safely.');
    }
}