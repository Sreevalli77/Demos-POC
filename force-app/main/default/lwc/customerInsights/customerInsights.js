import { LightningElement, track } from 'lwc';
import getCustomerInsights from '@salesforce/apex/CustomerInsightsController.getCustomerInsights';
import getRecommendationApex from '@salesforce/apex/CustomerInsightsController.getRecommendation';

export default class CustomerInsights extends LightningElement {

    // ── State ──────────────────────────────────────────────────
    @track contactId = '';
    @track customerData = null;
    @track recommendation = '';
    @track isLoading = false;
    @track isRecommendationLoading = false;
    @track hasError = false;
    @track errorMessage = '';
    @track showActivity = true;

    // ── Computed Properties ────────────────────────────────────

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

    // ── Event Handlers ─────────────────────────────────────────

    handleIdChange(event) {
        this.contactId = event.target.value;
        // Reset state on new input
        this.customerData = null;
        this.recommendation = '';
        this.hasError = false;
    }

    async loadInsights() {
        if (!this.contactId || this.contactId.trim() === '') {
            this.showError('Please enter a valid Customer ID.');
            return;
        }

        this.isLoading = true;
        this.hasError = false;
        this.recommendation = '';
        this.customerData = null;

        try {
            const data = await getCustomerInsights({ contactId: this.contactId.trim() });
            this.customerData = data;
        } catch (error) {
            this.showError(
                error?.body?.message ?? 'Failed to load customer data. Please try again.'
            );
        } finally {
            this.isLoading = false;
        }
    }

    toggleActivity() {
        this.showActivity = !this.showActivity;
    }

    async getRecommendation() {
        if (!this.customerData) return;

        this.isRecommendationLoading = true;

        try {
            const rec = await getRecommendationApex({
                contactId:       this.customerData.contactId,
                engagementScore: this.customerData.engagementScore,
                intentLevel:     this.customerData.intentLevel
            });
            this.recommendation = rec;
        } catch (error) {
            this.recommendation =
                '⚠️ Unable to fetch recommendation at this time. Please try again.';
        } finally {
            this.isRecommendationLoading = false;
        }
    }

    // ── Helpers ────────────────────────────────────────────────

    showError(message) {
        this.hasError = true;
        this.errorMessage = message;
        this.isLoading = false;
    }
}