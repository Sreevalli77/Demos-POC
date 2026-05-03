import { LightningElement, track } from 'lwc';
import getCustomerInsights from '@salesforce/apex/CustomerInsightsController.getCustomerInsights';
import getRecommendationApex from '@salesforce/apex/CustomerInsightsController.getRecommendation';
import searchContacts from '@salesforce/apex/CustomerInsightsController.searchContacts';

export default class CustomerInsights extends LightningElement {

    // ── State ──────────────────────────────────────────────────
    @track contactId = '';
    @track searchTerm = '';
    @track searchResults = [];
    @track selectedContact = null;
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

    get clearButtonClass() {
        return this.selectedContact ? 'clear-button' : 'clear-button clear-button-hidden';
    }

    // ── Event Handlers ─────────────────────────────────────────

    async handleSearchChange(event) {
        const newValue = event.target.value;
        if (this.selectedContact && newValue !== this.selectedContact.name) {
            // User is typing something different, clear selection
            this.selectedContact = null;
            this.contactId = '';
            this.customerData = null;
            this.recommendation = '';
            this.hasError = false;
        }
        this.searchTerm = newValue;

        if (this.searchTerm && this.searchTerm.length >= 2 && !this.selectedContact) {
            try {
                this.searchResults = await searchContacts({ searchTerm: this.searchTerm });
            } catch (error) {
                this.searchResults = [];
            }
        } else {
            this.searchResults = [];
        }
    }

    handleContactSelect(event) {
        const selectedId = event.currentTarget.dataset.contactId;
        this.selectedContact = this.searchResults.find(contact => contact.contactId === selectedId);
        this.contactId = selectedId;
        this.searchTerm = this.selectedContact?.name || '';
        this.searchResults = []; // Hide dropdown after selection
    }

    clearSelection() {
        this.selectedContact = null;
        this.contactId = '';
        this.searchTerm = '';
        this.searchResults = [];
        this.customerData = null;
        this.recommendation = '';
        this.hasError = false;
    }

    async loadInsights() {
        if (!this.selectedContact) {
            this.showError('Please select a contact from the search results.');
            return;
        }

        this.isLoading = true;
        this.hasError = false;
        this.recommendation = '';
        this.customerData = null;

        try {
            const data = await getCustomerInsights({ contactId: this.contactId });
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