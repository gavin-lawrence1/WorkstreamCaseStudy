/**
 * CustomerHealthSummaryGenerator
 * -------------------------------
 * Generates a concise one-paragraph customer health summary for an Account using Gemini.
 *
 * Depends on:
 *  - CustomerHealthSummaryInputBuilder
 *  - GeminiAPIService
 *  - Custom Metadata: Gemini_Prompt__mdt (DeveloperName = 'Customer_Health_Summary')
 */
public without sharing class CustomerHealthSummaryGenerator {

    @AuraEnabled(cacheable=true)
    public static String compileHealthInput(Id accountId) {
        return CustomerHealthSummaryInputBuilder.compileHealthInput(accountId);
    }

    @AuraEnabled
    public static String generateGeminiCustomerHealthSummary(Id accountId) {
        try {
            // Step 1: Compile structured input
            String compiledInput = compileHealthInput(accountId);

            // Step 2: Fetch Gemini prompt
            Gemini_Prompt__mdt promptRecord = [
                SELECT Prompt__c
                FROM Gemini_Prompt__mdt
                WHERE DeveloperName = 'Customer_Health_Summary'
                LIMIT 1
            ];
            String prompt = promptRecord.Prompt__c;

            // Step 3: Combine prompt + compiled data
            String fullPrompt = prompt + '\n\n' + compiledInput;

            // Step 4: Send to Gemini
            GeminiAPIService.GeminiResponse response = GeminiAPIService.generateContent(fullPrompt);

            if (!response.success) {
                throw new CalloutException('Gemini Error: ' + response.errorMessage);
            }

            // Step 5: Save summary back to Account
            update new Account(
                Id = accountId,
                AI_Customer_Health_Summary__c = response.generatedText
            );

            return response.generatedText;

        } catch (Exception e) {
            return 'Error generating customer health summary: ' + e.getMessage();
        }
    }
}