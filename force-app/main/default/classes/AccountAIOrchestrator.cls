/**
 * AccountAIOrchestrator
 * ----------------------
 * Queueable Apex job that asynchronously regenerates AI-driven summaries
 * for one or more Account records after related objects are inserted or updated.
 *
 * This ensures all callouts to Gemini occur outside the trigger context,
 * complying with Salesforce callout restrictions.
 *
 * Typical Entry Point:
 *  - Called by triggers on Intercom_Support_Ticket__c, Rocketlane_Project__c, etc.
 *
 * Dependencies:
 *  - CustomerHealthSummaryGenerator (handles Gemini callout and Account update)
 */
public class AccountAIOrchestrator implements Queueable, Database.AllowsCallouts {

    private Set<Id> accountIds;

    /**
     * Constructor
     * @param accIds - Set of Account Ids to process
     */
    public AccountAIOrchestrator(Set<Id> accIds) {
        this.accountIds = accIds;
    }

    /**
     * Main asynchronous execution method.
     * Runs once the transaction that enqueued this job has fully committed.
     */
    public void execute(QueueableContext context) {
        System.debug('🧠 AccountAIOrchestrator started for Accounts: ' + accountIds);

        for (Id accId : accountIds) {
            try {
                String result = CustomerHealthSummaryGenerator.generateGeminiCustomerHealthSummary(accId);
                System.debug('✅ Successfully refreshed AI Customer Health Summary for Account: ' + accId);
                System.debug('Summary content: ' + result);
            } catch (Exception e) {
                System.debug('💥 Error generating summary for Account ' + accId + ': ' + e.getMessage());
            }
        }

        System.debug('🏁 AccountAIOrchestrator completed.');
    }
}