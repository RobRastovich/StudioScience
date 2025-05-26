public class EXT_SAP_SOEmailNotificationHelper {
    
    public static String prepareEmailBody(String Name, Integer successfulRecordsCount, Integer failedRecordsCount, List<gvp__Sales_Order__c> allRejectedRecords, Integer totalRecordsCount)
    {
        string htmlBody = '<div> ';
        htmlBody += '<p>Hello,</p>';
        htmlBody += '<p>A process had been initiated by '+Name+' to send sales order records to SAP.</p>';
        htmlBody += '<p>'+successfulRecordsCount+' record(s) created successfully out of '+totalRecordsCount+' and '+failedRecordsCount+' record(s) failed.</p>';
        if(failedRecordsCount != 0)
        {
            htmlBody += '<p>Please find details of the failed record(s) below: </p><table style="width:100%;border: solid black; border-width: 1;border-collapse: collapse;table-layout: fixed;"><tr > <th style="border: solid black; border-width: 1">'+Label.SAP_SO_ID+'</th><th style="border: solid black; border-width: 1">'+Label.SAP_PURCHASE_ORDER +'</th> <th style="border: solid black; border-width: 1">'+Label.SAP_EXTERNAL_ID +'</th>  <th style="border: solid black; border-width: 1">'+Label.SAP_ERROR_MESSAGE+'</th></tr>';
            for(gvp__Sales_Order__c c : allRejectedRecords){ 
                htmlBody += '<tr><td style="border: solid black; border-width: 1"><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+getFormatedValue(c.id)+'"> ' + getFormatedValue(c.Name) + '</td><td style="border: solid black; border-width: 1"> ' + getFormatedValue(c.gvc_Purchase_Order__c) + '</td><td style="border: solid black; border-width: 1"><a href="'+URL.getSalesforceBaseUrl().toExternalForm()+'/'+getFormatedValue(c.id)+'"> ' + getFormatedValue(c.Id) + '</td><td style="border: solid black; border-width: 1"> ' + getFormatedValue(c.SAP_Error__c) + '</td></tr>';
            }
            htmlBody += '</table>';
        }
        htmlBody += '</div>';
        System.debug(htmlBody);
        return htmlBody;        
    }
    
    public static void sendingEmailNotification(List<Id> salesOrderIdList)
    {
        List<String> emailRecipientList = Label.SAP_Email_Recipients_For_Mexico.Split(',');
        Integer failedRecordsCount = 0;
        String Name = UserInfo.getName();
        List<gvp__Sales_Order__c> allRejectedRecords = [Select Id,Name,SAP_Error__c,gvp__Status__c,gvc_Purchase_Order__c from gvp__Sales_Order__c where id in:salesOrderIdList AND gvp__Status__c =: EXT_SAP_SalesOrderHelper.STATUS_FAILED];
        Integer successfulRecordsCount = salesOrderIdList.size()-allRejectedRecords.size();        
        messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
        mail.ToAddresses = emailRecipientList;
        mail.setSubject(Label.SO_Email_Subject);
        mail.setUseSignature(false);
        String htmlBody = prepareEmailBody(Name, successfulRecordsCount, allRejectedRecords.size(), allRejectedRecords, salesOrderIdList.size());       
        mail.setHtmlBody(htmlBody);
        if(emailRecipientList.size()!=0)
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
    
    public static String getFormatedValue(String value)
    {
        return value == null ? '' : value;
    }
    
}