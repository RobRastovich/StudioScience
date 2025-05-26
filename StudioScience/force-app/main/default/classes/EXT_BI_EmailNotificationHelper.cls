public class EXT_BI_EmailNotificationHelper {
    
    public static String prepareEmailBody(String userName, Integer successfulRecordsCount, Integer failedRecordsCount, List<Campaign__c> allRejectedRecords, Integer totalRecordsCount, String appName)
    {
        string htmlBody = '<div> ';
        htmlBody += '<p>Hello,</p>';
        if(appName == UTL_API_Utility.APPNAME_USBI){
            htmlBody += '<p>A process had been initiated by '+ userName +' to send the campaign IO to SAP.</p>';
        }
        else if(appName == UTL_API_Utility.APPNAME_AUSBI){
            htmlBody += '<p>A process had been initiated by '+ userName +' to send the campaign WBS to SAP.</p>';
        }

        htmlBody += '<p>'+ successfulRecordsCount +' record(s) created successfully out of '+ totalRecordsCount +' and '+ failedRecordsCount +' record(s) failed.</p>';
        if(failedRecordsCount != 0)
        {
            htmlBody += '<p>Please find details of the failed record(s) below: </p>';
            if(appName == UTL_API_Utility.APPNAME_USBI)
            	htmlBody +='<table style="width:100%;border: solid black; border-width: 1;border-collapse: collapse;table-layout: fixed;"><tr > <th style="border: solid black; border-width: 1">IO Code</th><th style="border: solid black; border-width: 1"> Salesforce External Id </th>  <th style="border: solid black; border-width: 1"> Error message </th></tr>';
            else if(appName == UTL_API_Utility.APPNAME_AUSBI)
                htmlBody +='<table style="width:100%;border: solid black; border-width: 1;border-collapse: collapse;table-layout: fixed;"><tr > <th style="border: solid black; border-width: 1">WBS Code</th><th style="border: solid black; border-width: 1"> Salesforce External Id </th>  <th style="border: solid black; border-width: 1"> Error message </th></tr>';
            for(Campaign__c c : allRejectedRecords) { 
                    htmlBody += '<tr><td style="border: solid black; border-width: 1;text-align:center">';
                	if(appName == UTL_API_Utility.APPNAME_USBI)
                		htmlBody += getFormatedValue(c.IOCode__c);
                	else if(appName == UTL_API_Utility.APPNAME_AUSBI)
                        htmlBody += getFormatedValue(c.WBSCode__c);
                    htmlBody +='</td><td style="border: solid black; border-width: 1;text-align:center"><a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + 
                    '/'+ getFormatedValue(c.id) +'"> ' + getFormatedValue(c.id) + '</td><td style="border: solid black; border-width: 1;"> ' + getFormatedValue(c.Request_Status_Message__c) + '</td></tr>';
            }
            htmlBody += '</table>';
        }
        htmlBody += '</div>';
        System.debug(htmlBody);
        return htmlBody;        
    }
    
    public static void sendingEmailNotification(List<Id> campaignIdList, String appName)
    {
        List<Campaign__c> allRejectedRecords = new List<Campaign__c>();
        List<String> emailRecipientList = new List<String>();
        if(appName == UTL_API_Utility.APPNAME_USBI)
        	emailRecipientList = Label.US_BI_Email_Recipients.Split(',');
        else
            emailRecipientList = Label.AUS_BI_Email_Recipients.Split(',');
        Integer failedRecordsCount = 0;
        String userName = UserInfo.getName();
        String userEmail =UserInfo.getUserEmail();
        emailRecipientList.add(userEmail);
        if(appName == UTL_API_Utility.APPNAME_USBI){
            allRejectedRecords = [SELECT Id,Name,IOCode__c,RequestStatus__c,Request_Status_Message__c FROM Campaign__c 
                            WHERE id IN:campaignIdList AND RequestStatus__c =:EXT_BI_CampaignHelper.STATUS_IO_REJECTED ];
        }
        else{
            allRejectedRecords = [SELECT Id,Name,WBSCode__c,RequestStatus__c,Request_Status_Message__c FROM Campaign__c 
                            WHERE id IN:campaignIdList AND RequestStatus__c =:EXT_BI_CampaignHelper.STATUS_WBS_REJECTED ];
        }
        Integer successfulRecordsCount = campaignIdList.size() - allRejectedRecords.size();        
        messaging.singleEmailMessage mail = new messaging.singleEmailMessage();
        mail.ToAddresses = emailRecipientList;
        if(appName == UTL_API_Utility.APPNAME_USBI)
        	mail.setSubject(Label.US_BI_Email_Subject);
        else
            mail.setSubject(Label.AUS_BI_Email_Subject);
        mail.setUseSignature(false);
        String htmlBody = prepareEmailBody(userName, successfulRecordsCount, allRejectedRecords.size(), allRejectedRecords, campaignIdList.size(), appName);       
        mail.setHtmlBody(htmlBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }

    public static String getFormatedValue(String value)
    {
        return value == null ? '' : value;
    }
    
}