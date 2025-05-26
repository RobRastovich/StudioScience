public without sharing class INT_EmailDeliveryService {
    public static final List<Group> DEFAULT_OWNERS = new List<Group>([
        SELECT Id FROM Group WHERE Type = 'Queue' AND DeveloperName = 'INT_EmailOpsDevTeam'
    ]);

    public static final List<GroupMember> QUEUE_MEMBERS = new List<GroupMember>([
        SELECT Id, UserOrGroupId
        FROM GroupMember
        WHERE GroupId IN :DEFAULT_OWNERS AND UserOrGroup.IsActive = true
    ]);

    public static final Map<String, EmailTemplate> EMAIL_TEMPLATES = new Map<String, EmailTemplate>();

    static {
        for (EmailTemplate et : [
            SELECT Id, DeveloperName
            FROM EmailTemplate
            WHERE DeveloperName LIKE 'INT_%'
        ]) {
            EMAIL_TEMPLATES.put(et.DeveloperName, et);
        }
    }

    public static void setOwnership(
        List<INT_EmailDelivery__c> records,
        Map<Id, INT_EmailDelivery__c> priorValues
    ) {
        for (INT_EmailDelivery__c ed : records) {
            if (String.isNotBlank(ed.INT_Status__c) && ed.INT_Status__c != priorValues.get(ed.Id)?.INT_Status__c) {
                MetadataTriggerHandler.bypass('INT_EmailDeliveries.LockOwnership');
                switch on ed.INT_Status__c {
                    when 'Submitted' {
                        if (!DEFAULT_OWNERS.isEmpty()) {
                            ed.OwnerId = DEFAULT_OWNERS.get(0).Id;
                        }
                    }

                    when 'Analyzing', 'Build' {
                        ed.OwnerId = UserInfo.getUserId();
                    }

                    when 'Information Required', 'CRM Manager Review' {
                        ed.OwnerId = ed.CreatedById;
                    }
                }
            }
        }
    }

    public static void sendNotifications(
        List<INT_EmailDelivery__c> records,
        Map<Id, INT_EmailDelivery__c> priorValues
    ) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (INT_EmailDelivery__c ed : records) {
            
            if (String.isNotBlank(ed.INT_Status__c) && ed.INT_Status__c != priorValues.get(ed.Id)?.INT_Status__c) {
                switch on ed.INT_Status__c {
                    when 'Submitted' {

                        if (!DEFAULT_OWNERS.isEmpty()) {
                            for (GroupMember gm : QUEUE_MEMBERS) {
                                if (gm.UserOrGroupId.getSobjectType() !== Schema.User.SObjectType) {
                                    return;
                                }

                                Messaging.SingleEmailMessage msg0 = Messaging.renderStoredEmailTemplate(
                                    EMAIL_TEMPLATES.get('INT_NewRequest').Id,
                                    gm.UserOrGroupId,
                                    ed.Id
                                );
        
                                msg0.setSubject(msg0.getSubject());
                                msg0.setPlainTextBody(msg0.getPlainTextBody());
                                msg0.setTargetObjectId(gm.UserOrGroupId);
                                msg0.setOrgWideEmailAddressId('0D25c000000kAV9CAM');
                                msg0.setSaveAsActivity(false);
                                emails.add(msg0);
                            }
                        }

                        Messaging.SingleEmailMessage msg1 = Messaging.renderStoredEmailTemplate(
                            EMAIL_TEMPLATES.get('INT_SubmitConfirm').Id,
                            UserInfo.getUserId(),
                            ed.Id
                        );

                        msg1.setSubject(msg1.getSubject());
                        msg1.setPlainTextBody(msg1.getPlainTextBody());
                        msg1.setTargetObjectId(UserInfo.getUserId());
                        msg1.setOrgWideEmailAddressId('0D25c000000kAV9CAM');
                        msg1.setSaveAsActivity(false);

                        emails.add(msg1);
                    }

                    when 'Analizing', 'Build' {
                        // send email
                    }

                    when 'Information Required' {
                        // send email
                    }
                }
            }
        }

        if (!emails.isEmpty()) {
            Messaging.sendEmail(emails);
        }
    }

    public static void setBrandId(List<INT_EmailDelivery__c> records) {
        for (INT_EmailDelivery__c ed : records) {
            if (String.isNotBlank(ed.INT_Brand__c)) {
                ed.INT_BrandId__c = ed.INT_Brand__c;
            }
        }
    }

    public static void lockOwnership(
        List<INT_EmailDelivery__c> records,
        Map<Id, INT_EmailDelivery__c> priorValues
    ) {
        for (INT_EmailDelivery__c ed : records) {
            if (ed.OwnerId != priorValues.get(ed.Id)?.OwnerId) {
                ed.addError('You cannot perform this action.');
            }
        }
    }

    public static void setDeliveryName(List<INT_EmailDelivery__c> records) {
        Set<Id> brandIds = new Set<Id>();
        Set<Id> marketIds = new Set<Id>();

        for (INT_EmailDelivery__c ed : records) {
            if (String.isNotEmpty(ed.INT_Brand__c)) {
                brandIds.add(ed.INT_Brand__c);
            }
            if (String.isNotEmpty(ed.INT_Market__c)) {
                marketIds.add(ed.INT_Market__c);
            }
        }

        Map<Id, INT_Brand__c> brands = new Map<Id, INT_Brand__c>([
            SELECT Id, INT_Abbreviation__c FROM INT_Brand__c WHERE Id IN :brandIds
        ]);

        Map<Id, INT_Market__c> markets = new Map<Id, INT_Market__c>([
            SELECT Id, INT_Abbreviation__c FROM INT_Market__c WHERE Id IN :marketIds 
        ]);

        for (INT_EmailDelivery__c ed : records) {
            ed.INT_DeliveryName__c = '';

            if (ed.INT_SendOutDateTime__c != null) {
                ed.INT_DeliveryName__c += ed.INT_SendOutDateTime__c.format('yyyyMMdd') + '_';
            }

            if (
                String.isNotBlank(ed.INT_Brand__c) &&
                brands.containsKey(ed.INT_Brand__c)
            ) {
                ed.INT_DeliveryName__c += brands.get(ed.INT_Brand__c).INT_Abbreviation__c + '_';
            }

            if (
                String.isNotBlank(ed.INT_Market__c) &&
                markets.containsKey(ed.INT_Market__c)
            ) {
                ed.INT_DeliveryName__c += markets.get(ed.INT_Market__c).INT_Abbreviation__c + '_';
            }

            ed.INT_DeliveryName__c += 'EM_';

            switch on ed.INT_CommunicationType__c {
                when 'Email Journey' {
                    ed.INT_DeliveryName__c += 'REC_';
                }
                when 'Email Newsletter' {
                    ed.INT_DeliveryName__c += 'TRG_';
                }
            }

            if (String.isNotEmpty(ed.INT_CampaignName__c)) {
                ed.INT_DeliveryName__c += ed.INT_CampaignName__c.normalizeSpace().capitalize().replaceAll('\\s*', '');
            }
        }

    }
}