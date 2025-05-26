public without sharing class SampleOrderPDFController {
    
    public List<Case> cases{get; set;}
    public Id sampleCaseId { get; private set; }
    public SFT_SampleOrderFormController.SampleOrderWrapper orderWrapper { get; set; }
    public String caseNum {get; set;}
    
    public SampleOrderPDFController() {
        sampleCaseId = ApexPages.currentPage().getParameters().get('id');        
        cases = [SELECT Id, CaseNumber, Sample_Order_Information__c FROM Case WHERE Id =: sampleCaseId];
        if(cases.size() > 0) {
            String sampleOrderJSON = cases[0].Sample_Order_Information__c;
            caseNum = cases[0].CaseNumber;
            sampleOrderJSON = sampleOrderJSON.replaceAll('&quot;', '"');
            sampleOrderJSON = sampleOrderJSON.replaceAll('&#39;', '\'');
            orderWrapper = (SFT_SampleOrderFormController.SampleOrderWrapper)system.JSON.deserialize(sampleOrderJSON, SFT_SampleOrderFormController.SampleOrderWrapper.class);
            String soldTo = orderWrapper.soldTo;
            List<String> soldToArray = soldTo.split('\\(');
            if(soldToArray.size() > 0) {
                orderWrapper.soldTo = soldToArray[0];
            }
            List<String> soldToNumberArray = new List<String>();
            if(soldToArray.size() > 1) {
                soldToNumberArray = soldToArray[1].split('\\)');
            }
            if(soldToNumberArray.size() > 0) {
                orderWrapper.soldTo += ' - ' + soldToNumberArray[0];
            }
        }
    }
        
}