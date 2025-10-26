/**
 * CustomerHealthSummaryInputBuilder
 * ----------------------------------
 * Compiles account-level data for Gemini to generate a one-paragraph customer health summary.
 *
 * Gathers data from:
 *  - Account (key fields)
 *  - Opportunities
 *  - Rocketlane Projects
 *  - Intercom Service Tickets
 *
 * Output: A structured text block summarizing customer activity and context.
 */
public without sharing class CustomerHealthSummaryInputBuilder {

    @AuraEnabled(cacheable=true)
    public static String compileHealthInput(Id accountId) {
        try {
            // --- Step 1: Account ---
            Account acc = [
                SELECT Id, Name, Industry, Type, Owner.Name
                FROM Account
                WHERE Id = :accountId
                LIMIT 1
            ];

            String summary = 'Account Overview:\n';
            summary += 'Name: ' + acc.Name + '\n';
            summary += 'Industry: ' + acc.Industry + '\n';
            summary += 'Type: ' + acc.Type + '\n';
            summary += 'Account Owner: ' + acc.Owner.Name + '\n\n';

            // --- Step 2: Opportunities ---
            List<Opportunity> opps = [
                SELECT Name, StageName, Amount, CloseDate
                FROM Opportunity
                WHERE AccountId = :accountId
                ORDER BY CloseDate DESC
                LIMIT 10
            ];

            summary += 'Opportunities (' + opps.size() + ' total):\n';
            if (opps.isEmpty()) {
                summary += 'None found.\n\n';
            } else {
                for (Opportunity o : opps) {
                    summary += '- ' + o.Name +
                        ' | Stage: ' + o.StageName +
                        ' | Amount: $' + String.valueOf(o.Amount) +
                        ' | Close Date: ' + String.valueOf(o.CloseDate) + '\n';
                }
                summary += '\n';
            }

            // --- Step 3: Rocketlane Projects ---
            List<Rocketlane_Project__c> projects = [
                SELECT Name, Project_Status__c, Risk_Flag__c
                FROM Rocketlane_Project__c
                WHERE Account__c = :accountId
                ORDER BY Name DESC
                LIMIT 10
            ];

            summary += 'Rocketlane Projects (' + projects.size() + ' total):\n';
            if (projects.isEmpty()) {
                summary += 'None found.\n\n';
            } else {
                for (Rocketlane_Project__c p : projects) {
                    summary += '- ' + p.Name +
                        ' | Status: ' + p.Project_Status__c +
                        ' | Risk Status: ' + String.valueOf(p.Risk_Flag__c) + '\n';
                }
                summary += '\n';
            }

            // --- Step 4: Intercom Tickets ---
            List<Intercom_Support_Ticket__c> tickets = [
                SELECT Name, Ticket_Status__c, CreatedDate
                FROM Intercom_Support_Ticket__c
                WHERE Account__c = :accountId
                ORDER BY CreatedDate DESC
                LIMIT 10
            ];

            summary += 'Intercom Tickets (' + tickets.size() + ' total):\n';
            if (tickets.isEmpty()) {
                summary += 'None found.\n\n';
            } else {
                for (Intercom_Support_Ticket__c t : tickets) {
                    summary += '- ' + t.Name +
                        ' | Status: ' + t.Ticket_Status__c +
                        ' | Created: ' + String.valueOf(t.CreatedDate.date()) + '\n';
                }
                summary += '\n';
            }

            summary += 'End of data.\n';
            return summary;

        } catch (Exception e) {
            return 'Error compiling account data: ' + e.getMessage();
        }
    }
}