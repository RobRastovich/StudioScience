/**************************************************************************************
Apex Class Name     : BS_PR_SubmitPR_ToSAP 
Test Class          : BS_PR_SubmitPR_ToSAP_Test 
Auther              : Harikrishna P 
Function            : This calss will be called by VF page to send the PR to SAP
Updates :
*************************************************************************************/

public class BS_PR_SubmitPR_ToSAP{   
            
    public String retPRNum {set; get;}                      
    public boolean PanelOne {set; get;}
    public boolean successPanel {set; get;}
    public boolean displaySendToSAP{set;get;}
    public id prRecId;
    public BS_PR_SubmitPR_ToSAP(ApexPages.StandardController stdcontroller) {
        PanelOne=true;
        successPanel=false;
        displaySendToSAP=true;
        prRecId = (id)stdcontroller.getRecord().id;
        system.debug('prRecId..'+prRecId);
    }
    
    public pagereference confirmToSubmitPR() {
        submitToSAP();
        return null;
    }
    
    public void submitToSAP( ) {        
        bs_sap_connection_manager.wrapPRResponse retPRResponse=bs_sap_connection_manager.sendPRtoSAP(prRecId);
        system.debug('***post PR TO SAP method:***retPRResponse......... ' + retPRResponse);
        if(retPRResponse.retStatus=='Created'){
            successPanel=true;
            PanelOne=false;
            displaySendToSAP=false;
            retPRNum=retPRResponse.retPRNum;
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Failed to send PR: Please contact your admin.'+retPRResponse.retError));
            displaySendToSAP=false;
        }
    }        
 }