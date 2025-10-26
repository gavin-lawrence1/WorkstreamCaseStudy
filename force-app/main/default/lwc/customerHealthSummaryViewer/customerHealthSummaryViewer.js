import { LightningElement, api, wire } from 'lwc';
import generateGeminiCustomerHealthSummary from '@salesforce/apex/CustomerHealthSummaryGenerator.generateGeminiCustomerHealthSummary';
import { getRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

const FIELDS = ['Account.AI_Customer_Health_Summary__c'];

export default class CustomerHealthSummaryViewer extends LightningElement {
    @api recordId;
    summary;
    error;
    loading = false;
    wiredAccountResult;
    _summaryTriggered = false;

    @wire(getRecord, { recordId: '$recordId', fields: FIELDS })
    wiredAccount(result) {
        this.wiredAccountResult = result;
        const { data, error } = result;

        if (data) {
            this.summary = data.fields.AI_Customer_Health_Summary__c?.value || '';
            this.error = null;

            // ✅ Auto-generate once if blank
            if (!this._summaryTriggered && (!this.summary || this.summary.trim() === '')) {
                this._summaryTriggered = true;
                this.handleRefresh();
            }
        } else if (error) {
            this.error = 'Error loading saved summary.';
            this.summary = null;
            console.error(error);
        }
    }

    handleRefresh() {
        this.summary = null;
        this.error = null;
        this.loading = true;

        generateGeminiCustomerHealthSummary({ accountId: this.recordId })
            .then(result => {
                this.summary = result;
                return refreshApex(this.wiredAccountResult);
            })
            .then(() => {
                this.loading = false;
            })
            .catch(error => {
                this.error = error?.body?.message || 'Error generating customer health summary.';
                console.error('Gemini Apex Error:', error);
                this.loading = false;
            });
    }
}