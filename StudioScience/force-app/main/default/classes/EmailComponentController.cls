/**************************************************************************************
 Apex Class Name     : EmailComponentController
 Created Date        : 2/2018
 Function            : Methods called from a lightning component EmailComponent
*************************************************************************************/
public without sharing class EmailComponentController {

    public static final String ORDERS_EMAIL_TEMPLATE = 'Order_Case_Creation';
    public static final String ORDERS_Barrel_EMAIL_TEMPLATE = 'Order_Case_Creation_Barrel';
    public static final String ORDERS_Bulk_EMAIL_TEMPLATE = 'Order_Case_Creation_Bulk';
    public static final String ORDERS_Requisition_EMAIL_TEMPLATE = 'Order_Case_Creation_Requisition';
    public static final String ORDERS_Standard_EMAIL_TEMPLATE = 'Order_Case_Creation_Standard';
    public static final String CHANGES_EMAIL_TEMPLATE = 'Changes_Case_Creation';
    public static final String ORDER_CLAIM_EMAIL_TEMPLATE = 'Order_Claim_Case_Creation';
    public static final String QUALITY_CLAIM_EMAIL_TEMPLATE = 'Quality_Claim_Case_Creation';
    public static final String ESCALATED_FORM_EMAIL_TEMPLATE = 'Escalated_Case_Created';
    public static final String INQUIRY_EMAIL_TEMPLATE = 'Inquiry_Case_Creation';
    public static String emailTemplateName {get; set;}

    // query case and update that ccEmail field
    @AuraEnabled
    public static List<Case> getCaseById(Id caseId) {
        return [select id
                , type
                , ccEmail__c
                , Order_Claim_Amount__c
                , Product_Destination_Country__c
                , Beam_Suntory_Item_Number__c
                , Distibutor_Currency__c
                , Purchase_Order_Number__c
                , Claim_Amount__c
                , CaseNumber
                , AccountId
                , Shipping_Plant__c
                , Product_Description__c
                , Beam_Suntory_Order_Number__c from Case where Id = : caseId limit 1];
    }

    /**************************************************************************************************************
    Method name:    getLastCaseEmailFieldByUser
    Object:         Case
    RecordType:     Order Claim
    Date:           2/2018
    Details and Notes:
    This method is referenced in a visual flow CSFlow.  An email component which takes an email address is in the flow
    and each time you enter an email address and finish the flow we store that email address or addresses in a semi-colon separated
    string.  The next time a user enters the flow and comes across that email component we will pull in the most recent email address or
    addresses they used automatically.
	
	Update Date: 9/2023
	Updated this method for SAL-5020
    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getLastCaseEmailFieldByUser(Id userId, Id caseId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        String initialQuery ='select id, ccEmail__c, CreatedDate from Case where CreatedById = :userId AND ccEmail__c != null';
        String query ='select id, ccEmail__c, CreatedDate from Case where CreatedById = :userId AND ParentId = null';
        if(caseId != null){
            query += ' AND Id != :caseId';
        }else{
            query = initialQuery;
        }
        query += ' Order by CreatedDate Desc limit 1';
        List<Case> mostRecentCase = Database.query(query);
        // List<Case> mostRecentCase = [select id, ccEmail__c, CreatedDate from Case where CreatedById = :userId AND ccEmail__c != null Order by CreatedDate Desc limit 1];
        
        try {
            responseMap.put('allEmails', mostRecentCase[0].ccEmail__c);  
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    /**************************************************************************************************************
    Method name:    updateCaseEmailField
    Object:         Case
    RecordType:     Order Claim
    Date:           2/2018
    Details and Notes:
    Updates the case field with the email address or addresses that were entered in the lightning component
    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus updateCaseEmailField(Id caseId, String ccEmail) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();


        try {
            Case c = getCaseById(caseId)[0];
            c.ccEmail__c = ccEmail;
            update c;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    /**************************************************************************************************************
    Method name:    removeEmailFromCase
    Object:         Case
    RecordType:     Order Claim
    Date:           2/2018
    Details and Notes:
    There is an option to remove an email that you entered incorrectly in the lightning component
    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus removeEmailFromCase(Id caseId, String emailToRemove) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            Case c = getCaseById(caseId)[0];
            List<String> emails = c.ccEmail__c.split(';');
            for (Integer i = 0; i < emails.size(); i++) {
                if (emails[i].equalsIgnoreCase(emailToRemove)) {
                    emails.remove(i);
                }
            }
            c.ccEmail__c = string.join(emails, ';');
            update c;

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    /**************************************************************************************************************
    Method name:    setEmailTemplateBasedOnCaseType
    Object:         Case
    RecordType:     Order Claim, Order Claim Sub Case, Changes, Orders, Quality Claim, Inquiry, Escalated Form
    Date:           2/2018
    Details and Notes:
    Decides which email templates to use based on the record type
    ***************************************************************************************************************/
    public static void setEmailTemplateBasedOnCaseType(String caseType, String Type) {
        if (caseType == CSConstants.ORDERS) {
            
            if(Type == CSConstants.ORDERS_Barrel_Type)
            {
                emailTemplateName = EmailComponentController.ORDERS_Barrel_EMAIL_TEMPLATE ;
            }
            else if(Type == CSConstants.ORDERS_Bulk_Type)
            {
                emailTemplateName = EmailComponentController.ORDERS_Bulk_EMAIL_TEMPLATE;
            }
            else if(Type == CSConstants.ORDERS_Requisition_Type)
            {
                emailTemplateName = EmailComponentController.ORDERS_Requisition_EMAIL_TEMPLATE;
            }
            else if(Type == CSConstants.ORDERS_Standard_Type)
            {
                emailTemplateName = EmailComponentController.ORDERS_Standard_EMAIL_TEMPLATE;
            }

        } else if (caseType == CSConstants.CHANGES) {
            emailTemplateName = EmailComponentController.CHANGES_EMAIL_TEMPLATE;

        } else if (caseType == CSConstants.ORDER_CLAIM) {
            emailTemplateName = EmailComponentController.ORDER_CLAIM_EMAIL_TEMPLATE;

        } else if (caseType == CSConstants.QUALITY_CLAIM) {
            emailTemplateName = EmailComponentController.QUALITY_CLAIM_EMAIL_TEMPLATE;

        } else if (caseType == CSConstants.ESCALATED_FORM) {
            emailTemplateName = EmailComponentController.ESCALATED_FORM_EMAIL_TEMPLATE;

        } else if (caseType == CSConstants.INQUIRY) {
            emailTemplateName = EmailComponentController.INQUIRY_EMAIL_TEMPLATE;
        }
    }


    /**************************************************************************************************************
    Method name:    sendEmail
    Object:         Case
    RecordType:     Order Claim, Order Claim Sub Case, Changes, Orders, Quality Claim, Inquiry, Escalated Form
    Date:           2/2018
    Details and Notes:
    Once a user has completed the CS flow(visual flow) then an email will be sent to them and any recepients they choose 
    in the email component housed in the cs flow
    ***************************************************************************************************************/
    public static void sendEmail(String ccEmails, Id caseId, String caseType, String Type) {
        setEmailTemplateBasedOnCaseType(caseType, Type);
        List<String> ccEmailsList = new List<String>();
        Case parentCase = getCaseById(caseId)[0];
        List<Case> childCases = getChildCasesByParentId(caseId);
        Set<Id> allCaseIds = new Set<Id>();
        allCaseIds.add(caseId);
        for (Case c : childCases) {
            allCaseIds.add(c.Id);
        }

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate template = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :emailTemplateName LIMIT 1];

        Map<Id, ContentDocumentLink> contentDocumentToLinkMap = new Map<Id, ContentDocumentLink>();
        List<ContentDocumentLink> cdLinkList = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :caseId];
        for (ContentDocumentLink cdl : cdLinkList) {
            contentDocumentToLinkMap.put(cdl.ContentDocumentId, cdl);
        }

        // any attachments made to the parent case will also be attached to the child case(s)
        assignParentAttachmentsToChildCases(childCases, parentCase, cdLinkList);

        Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>([SELECT Id, ContentDocumentId FROM ContentVersion WHERE IsLatest = true AND ContentDocumentId IN: contentDocumentToLinkMap.keySet()]);
        Map<Id, List<Id>> caseToCVMap = new Map<Id, List<Id>>();
        for (ContentVersion cv : cvMap.values()) {
            Id entityId = contentDocumentToLinkMap.get(cv.ContentDocumentId).LinkedEntityId;
            if (!caseToCVMap.containsKey(entityId)) {
                caseToCVMap.put(entityId, new List<Id> {cv.Id});
            } else {
                caseToCVMap.get(entityId).add(cv.Id);
            }

        }

        String htmlBody = template.HtmlValue;
        String plainBody = template.Body;
        String htmlBodyString = '';
        String plainBodyString = '';

        // order claim is a special case because there could be several child cases and this is how we are handling it
        if (caseType == CSConstants.ORDER_CLAIM) {
            htmlBodyString = buildParentCaseEmailHTMLString(parentCase, htmlBodyString);
            plainBodyString = buildParentCaseEmailPlainTextString(parentCase, plainBodyString);
            if (!childCases.isEmpty()) {
                htmlBodyString += '<u><strong>Child Cases(' + childCases.size() + ')</strong></u></br>';
                plainBodyString += '<u><strong>Child Cases(' + childCases.size() + ')</strong></u></br>';
            }
            htmlBodyString += '<ul>';
            plainBodyString += '<ul>';

            for (Case c : getChildCasesByParentId(caseId)) {
                htmlBodyString += '<li style="font-size:14px">';
                htmlBodyString += '<div> <span> <strong>Case Number: </strong>' + c.caseNumber + '</span></div>';
                htmlBodyString += '<div> <span>Type of Order Claim: ' + c.Type + '</span></div>';
                if (String.isNotBlank(c.Product_Destination_Country__c)) {
                    htmlBodyString += '<div> <span> Country: ' + c.Product_Destination_Country__c + '</span></div>';
                }
                if (String.isNotBlank(c.Product_Description__c)) {
                    htmlBodyString += '<div> Product Description: ' + c.Product_Description__c + '</div>';
                }
                if (String.isNotBlank(c.Shipping_Plant__c)) {
                    htmlBodyString += '<div> Shipping Plant: ' + c.Shipping_Plant__c + '</div>';
                }
                if (String.isNotBlank(c.Distibutor_Currency__c)) {
                    htmlBodyString += '<div> Distibutor Currency: ' + c.Distibutor_Currency__c + '</div>';
                }
                if (c.Order_Claim_Amount__c != null) {
                    htmlBodyString += '<div> Claim Amount: ' + c.Order_Claim_Amount__c + '</div>';
                }
                if (String.isNotBlank(c.Beam_Suntory_Item_Number__c)) {
                    htmlBodyString += '<div> Beam Suntory Item Number: ' + c.Beam_Suntory_Item_Number__c + '</div>';
                }
                if (String.isNotBlank(c.Beam_Suntory_Order_Number__c)) {
                    htmlBodyString += '<div> Beam Suntory Order Number: ' + c.Beam_Suntory_Order_Number__c + '</div>';
                }
                if (String.isNotBlank(c.Purchase_Order_Number__c)) {
                    htmlBodyString += '<div> Purchase Order Number: ' + c.Purchase_Order_Number__c + '</div>';
                }
                htmlBodyString += '</li>';
                htmlBodyString += '<div></div>';

                plainBodyString += '<li style="font-size:14px">';
                plainBodyString += '<div> <span><strong>Case Number: </strong>' + c.caseNumber + '</span></div>';
                plainBodyString += '<div> <span>Type of Order Claim: ' + c.Type + '</span></div>';
                if (String.isNotBlank(c.Product_Destination_Country__c)) {
                    plainBodyString += '<div> <span> Country: ' + c.Product_Destination_Country__c + '</span></div>';
                }
                if (String.isNotBlank(c.Product_Description__c)) {
                    plainBodyString += '<div> Product Description: ' + c.Product_Description__c + '</div>';
                }
                if (String.isNotBlank(c.Shipping_Plant__c)) {
                    plainBodyString += '<div> Shipping Plant: ' + c.Shipping_Plant__c + '</div>';
                }
                if (String.isNotBlank(c.Distibutor_Currency__c)) {
                    plainBodyString += '<div> Distibutor Currency: ' + c.Distibutor_Currency__c + '</div>';
                }
                if (c.Order_Claim_Amount__c != null) {
                    plainBodyString += '<div> Claim Amount: ' + c.Order_Claim_Amount__c + '</div>';
                }
                if (String.isNotBlank(c.Beam_Suntory_Item_Number__c)) {
                    plainBodyString += '<div> Beam Suntory Item Number: ' + c.Beam_Suntory_Item_Number__c + '</div>';
                }
                if (String.isNotBlank(c.Beam_Suntory_Order_Number__c)) {
                    plainBodyString += '<div> Beam Suntory Order Number: ' + c.Beam_Suntory_Order_Number__c + '</div>';
                }
                if (String.isNotBlank(c.Purchase_Order_Number__c)) {
                    plainBodyString += '<div> Purchase Order Number: ' + c.Purchase_Order_Number__c + '</div>';
                }
                plainBodyString += '</li>';
                plainBodyString += '<div></div>';
            }
            htmlBodyString += '</ul>';
            plainBodyString += '</ul>';
        }

        if (String.isNotBlank(ccEmails)) {
            ccEmailsList = ccEmails.split(';');
        }

        // add the email to case service address so that the email will be tied to the case
        //ccEmailsList.add(CSConstants.EMAIL_SERVICE_ADDRESS);

        Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(String.valueOf(template.Id), UserInfo.getUserId(), String.valueOf(caseId));
        email.setToAddresses(new List<String> { UserInfo.getUserEmail()});
        email.setCcAddresses(ccEmailsList);
        OrgWideEmailAddress[] owea = [select Id, Address from OrgWideEmailAddress where Address = 'customer.service@beamsuntory.com'];
        if ( owea.size() > 0 ) {
            email.setOrgWideEmailAddressId(owea.get(0).Id);
            String bccAddress = owea[0].Address;
            Integer emailLocalPartIndex = bccAddress.indexOf('@');
            if(emailLocalPartIndex > 0 && !Global_Utility.isProd()) {
                String localPart = bccAddress.substring(0, emailLocalPartIndex);
                EmailServicesAddress[] lstEmailServices = [SELECT EmailDomainName FROM EmailServicesAddress WHERE LocalPart =: localPart];
                if(!lstEmailServices.isEmpty()) {
                    bccAddress = localPart + '@' + lstEmailServices[0].EmailDomainName;
                    email.setBccAddresses(new String[]{bccAddress});
                }
            } else {
                email.setBccAddresses(new String[]{bccAddress});
            }
            
        }
        email.setWhatId(caseId);
        String renderedTemplateHtmlBody = email.getHTMLBody();
        String renderedTemplateTextBody = email.getPlainTextBody();
        System.debug('renderedTemplateTextBody ' + renderedTemplateTextBody);
        System.debug('renderedTemplateHtmlBody ' + renderedTemplateHtmlBody);
        System.debug('plainBodyString ' + plainBodyString);
        System.debug('htmlBodyString ' + htmlBodyString);

        if (caseType == CSConstants.ORDER_CLAIM) {
            email.setPlainTextBody(renderedTemplateTextBody.replace('[body]', plainBodyString));
            email.setHTMLBody(renderedTemplateHtmlBody.replace('[body]', htmlBodyString));
            //htmlBody = htmlBody.replace('{!body}', htmlBodyString);
            //plainBody = plainBody.replace('{!body}', plainBodyString);
            //email.setHtmlBody(htmlBodyString);
            //email.setPlainTextBody(plainBodyString);
        }
        email.setSaveAsActivity(false);
        if (caseToCVMap.containsKey(caseId)) {
            email.setEntityAttachments(caseToCVMap.get(caseId));
        }
        emails.add(email);
        Messaging.reserveSingleEmailCapacity(emails.size());
        try {
            Messaging.SendEmailResult[] lstEmailResult = Messaging.sendEmail(emails);
            List<String> lstErrorMessage = new List<String>();
            for(Messaging.SendEmailResult emailResult : lstEmailResult) {
                if(!emailResult.isSuccess()) {
                    for(Messaging.SendEmailError emailError : emailResult.getErrors()) {
                        lstErrorMessage.add(emailError.getFields() + ' ' + emailError.getMessage() + ' ' + emailError.getStatusCode() + ' ' +emailError.getTargetObjectId());
                    }
                }
            }
            if(!lstErrorMessage.isEmpty()) {
                CreateExceptionLog.insertErrorLog('EmailComponentController', 'sendEmail', lstErrorMessage.toString(), 'Error');
            }
        } catch (Exception e) {
            String errorMessage = 'Error sending emails ' + e.getMessage() + '\n' + e.getStackTraceString();
            CreateExceptionLog.insertErrorLog('EmailComponentController', 'sendEmail', String.valueOf(errorMessage), 'Fatal');
        }

    }

    public static List<Case> getChildCasesByParentId(Id parentId) {
        return [select id
                , type
                , Order_Claim_Amount__c
                , CaseNumber
                , Product_Destination_Country__c
                , Beam_Suntory_Item_Number__c
                , Distibutor_Currency__c
                , Purchase_Order_Number__c
                , Claim_Amount__c
                , AccountId
                , Shipping_Plant__c
                , Product_Description__c
                , Beam_Suntory_Order_Number__c from Case where ParentId = : parentId];
    }

    public static String buildParentCaseEmailHTMLString(Case c, String htmlBodyString) {


        htmlBodyString += '<div><u><strong>Parent Case</strong></u></div>';
        htmlBodyString += '<div style="font-size:15px">';
        if (String.isNotBlank(c.Product_Destination_Country__c)) {
            htmlBodyString += '<div>Country: ' + c.Product_Destination_Country__c + '</div>';
        }
        if (String.isNotBlank(c.Beam_Suntory_Order_Number__c)) {
            htmlBodyString += '<div>Beam Suntory Order Number: ' + c.Beam_Suntory_Order_Number__c + '</div>';
        }
        if (String.isNotBlank(c.Purchase_Order_Number__c)) {
            htmlBodyString += '<div>Purchase Order Number: ' + c.Purchase_Order_Number__c + '</div>';
        }
        htmlBodyString += '</div>';
        htmlBodyString += '</br> </br>';

        return htmlBodyString;
    }

    public static String buildParentCaseEmailPlainTextString(Case c, String plainBodyString) {

        plainBodyString += '<div><u><strong>Parent Case</strong></u></div>';
        plainBodyString += '<div style="font-size:15px">';
        if (String.isNotBlank(c.Product_Destination_Country__c)) {
            plainBodyString += '<div>Country: ' + c.Product_Destination_Country__c + '</div>';
        }
        if (String.isNotBlank(c.Beam_Suntory_Order_Number__c)) {
            plainBodyString += '<div>Beam Suntory Order Number: ' + c.Beam_Suntory_Order_Number__c + '</div>';
        }
        if (String.isNotBlank(c.Purchase_Order_Number__c)) {
            plainBodyString += '<div>Purchase Order Number: ' + c.Purchase_Order_Number__c + '</div>';
        }
        plainBodyString += '</div>';
        plainBodyString += '</br> </br>';

        return plainBodyString;
    }

    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getEmailLabelMap() {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            Map<String, String> auraIdLabelMap = new Map<String, String> {
                'corresponding_collaborators'           => System.Label.Corresponding_Collaborators,
                'add_email_description'                 => System.Label.Add_Email_Description,
                'email'                                 => System.Label.Email,
                'missing_value'                         => System.Label.Please_enter_a_value,
                'actions'                               => System.Label.Actions,
                'error'                                 => System.Label.Error,
                'edit'                                  => System.Label.Edit,
                'remove'                                => System.Label.Remove,
                'add_email'                             => System.Label.Add_Email
            };
            responseMap.put('labelMap', auraIdLabelMap);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    public static void assignParentAttachmentsToChildCases(List<Case> childCases, Case parentCase, List<ContentDocumentLink> cdLinkList) {
        List<ContentDocumentLink> attachmentsToInsert = new List<ContentDocumentLink>();

        for (ContentDocumentLink cdl : cdLinkList) {
            for (Case c : childCases) {
                ContentDocumentLink newCdl = new ContentDocumentLink();
                newCdl.ContentDocumentId = cdl.ContentDocumentId;
                newCdl.ShareType = 'V';
                newCdl.LinkedEntityId = c.Id;
                attachmentsToInsert.add(newCdl);
            }
        }


        if (!attachmentsToInsert.isEmpty()) {
            insert attachmentsToInsert;
        }
    }

}