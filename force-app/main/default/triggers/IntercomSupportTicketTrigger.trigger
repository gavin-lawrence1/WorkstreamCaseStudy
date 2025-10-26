trigger IntercomSupportTicketTrigger on Intercom_Support_Ticket__c (after insert, after update) {
    Set<Id> accountIds = new Set<Id>();

    for (Intercom_Support_Ticket__c t : Trigger.new) {
        if (t.Account__c != null) {
            accountIds.add(t.Account__c);
        }
    }

    if (!accountIds.isEmpty()) {
        // Enqueue asynchronous job to run Gemini callouts
        System.enqueueJob(new AccountAIOrchestrator(accountIds));
    }
}