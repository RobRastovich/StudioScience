/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesSelfRegConfirmController {
public String selectedLang{get;set;}
    public CommunitiesSelfRegConfirmController() {
        
        selectedLang= ApexPages.currentPage().getParameters().get('language');
    }
}