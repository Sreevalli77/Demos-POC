import { LightningElement, track, api } from 'lwc';
import getCustomerInsights from '@salesforce/apex/CustomerInsightsControllerDynamic.getCustomerInsights';
import getRecommendationApex from '@salesforce/apex/CustomerInsightsControllerDynamic.getRecommendation';

export default class CustomerInsightsDynamic extends LightningElement {
    @api recordId; // Automatically populated if on a Record Page
    
    @track contactId = '';
    @track customerData = null;
    @track recommendation = '';
    @track isLoading = false;
    @track isRecommendationLoading = false;
    @track hasError = false;
    @track errorMessage = '';
    @track showActivity = true;

    // Runs automatically when the component loads
    connectedCallback() {
        if (this.recordId) {
            this.contactId = this.recordId;
            this.loadInsights();
        }
    }

    get hasData() {
        return this.customerData !== null && !this.isLoading;
    }

    get activityToggleIcon() {
        return this.showActivity ? 'utility:chevronup' : 'utility:chevrondown';
    }

    get scoreRingClass() {
        const score = this.customerData?.engagementScore ?? 0;
        if (score >= 60) return 'score-ring score-ring--high';
        if (score >= 30) return 'score-ring score-ring--medium';
        return 'score-ring score-ring--low';
    }

    get intentBadgeClass() {
        const level = this.customerData?.intentLevel ?? 'LOW';
        const map = { HIGH: 'badge--high', MEDIUM: 'badge--medium', LOW: 'badge--low' };
        return map[level] ?? 'badge--low';
    }

    handleIdChange(event) {
        this.contactId = event.target.value;
    }

    async loadInsights() {
        if (!this.contactId) return;

        this.isLoading = true;
        this.hasError = false;
        this.recommendation = '';

        try {
            const data = await getCustomerInsights({ contactId: this.contactId });
            this.customerData = data;
        } catch (error) {
            this.hasError = true;
            this.errorMessage = error?.body?.message ?? 'Error loading data';
        } finally {
            this.isLoading = false;
        }
    }

    toggleActivity() {
        this.showActivity = !this.showActivity;
    }

    async getRecommendation() {
        this.isRecommendationLoading = true;
        try {
            this.recommendation = await getRecommendationApex({
                contactId: this.customerData.contactId,
                engagementScore: this.customerData.engagementScore,
                intentLevel: this.customerData.intentLevel
            });
        } catch (error) {
            this.recommendation = '⚠️ Unable to fetch recommendation.';
        } finally {
            this.isRecommendationLoading = false;
        }
    }
}