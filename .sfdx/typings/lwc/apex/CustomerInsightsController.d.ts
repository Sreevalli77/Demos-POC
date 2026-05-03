declare module "@salesforce/apex/CustomerInsightsController.getCustomerInsights" {
  export default function getCustomerInsights(param: {contactId: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomerInsightsController.searchContacts" {
  export default function searchContacts(param: {searchTerm: any}): Promise<any>;
}
declare module "@salesforce/apex/CustomerInsightsController.getRecommendation" {
  export default function getRecommendation(param: {contactId: any, engagementScore: any, intentLevel: any}): Promise<any>;
}
