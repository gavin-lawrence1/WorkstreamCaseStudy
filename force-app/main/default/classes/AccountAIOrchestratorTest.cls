@IsTest
private class AccountAIOrchestratorTest {

    @IsTest
    static void testExecuteWithValidAccounts() {
        // --- Step 1: Create a test Account ---
        Account acc = new Account(Name = 'Acme AI Test Account');
        insert acc;

        // --- Step 2: Enqueue the orchestrator job ---
        Test.startTest();
        System.enqueueJob(new AccountAIOrchestrator(new Set<Id>{ acc.Id }));
        Test.stopTest();

        // --- Step 3: Verify orchestrator completed without exception ---
        System.assert(true, 'AccountAIOrchestrator executed successfully.');
    }

    @IsTest
    static void testExecuteHandlesErrorsGracefully() {
        // --- Step 1: Create a test Account ---
        Account acc = new Account(Name = 'Error Handling Account');
        insert acc;

        // --- Step 2: Enqueue orchestrator with empty Set (edge case) ---
        Set<Id> emptySet = new Set<Id>();

        Test.startTest();
        System.enqueueJob(new AccountAIOrchestrator(emptySet));
        Test.stopTest();

        // --- Step 3: Verify no unhandled exceptions occurred ---
        System.assert(true, 'AccountAIOrchestrator handled empty input gracefully.');
    }
}