public without sharing class SBP_POSItemCmpCtrl {
    public static Set<String> posItemSpecificStates = new Set<String> {'New York', 'Oregon', 'NY', 'OR'};

    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getSingleBarrelCustomMetaDataSettings(String state, String brand, String premiseType, String productType) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            Map<String, List<SBP_POSItemCmpCtrl.POSItem>> brandToPOSItemMap = buildPOSItemMap(state, brand, premiseType, productType);
            system.debug('brandToPOSItemMap' + brandToPOSItemMap);
            responseMap.put('brandToPOSItemMap', brandToPOSItemMap);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    public class POSItem {
        @AuraEnabled public String staticResourceName;
        @AuraEnabled public String brand;
        @AuraEnabled public String premiseType;
        @AuraEnabled public String state;
        @AuraEnabled public String helpText;
        @AuraEnabled public String itemText;
        @AuraEnabled public String itemPrice;
        @AuraEnabled public String posId;
        @AuraEnabled public String masterLabel;
        @AuraEnabled public String options;
        @AuraEnabled public Boolean hasInsert;
        @AuraEnabled public Boolean showTextOptions;
        @AuraEnabled public String defaultTextValue;
        @AuraEnabled public String productType;
        

        public POSItem() {

        }
    }

    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    public static Map<String, List<SBP_POSItemCmpCtrl.POSItem>> buildPOSItemMap(String state, String brand, String premiseType, String productType) {
        Map<String, List<SBP_POSItemCmpCtrl.POSItem>> brandToPOSItemMap = new Map<String, List<SBP_POSItemCmpCtrl.POSItem>>();

        for (POS_State_Setting__mdt cm : getPOSCustomMetadata(state, brand, premiseType,productType)) {
            SBP_POSItemCmpCtrl.POSItem posItem = new SBP_POSItemCmpCtrl.POSItem();
            posItem.staticResourceName = cm.POS_Static_Resource__r.Static_Resource_Name__c;
            posItem.brand = cm.POS_Static_Resource__r.Brand__c;
            posItem.premiseType = cm.Premise_Type__c;
            posItem.state = cm.State__c;
            posItem.helpText = cm.POS_Static_Resource__r.POS_Item__r.Help_Text__c;
            posItem.masterLabel = cm.POS_Static_Resource__r.DeveloperName;
            posItem.options = cm.Options__c;
            posItem.posId = String.valueOf(cm.Id);
            posItem.showTextOptions = cm.Show_Text_Options__c;
            posItem.defaultTextValue = cm.Default_Text_Value__c;
            posItem.itemPrice = cm.POS_Static_Resource__r.Item_Price__c;
            //posItem.hasInsert = cm.POS_Static_Resource__r.POS_Item__r.hasInsert__c;

            // if there is not overriding text that needs to be displayed based on the brand then pull in the generic text
            if (String.isBlank(cm.POS_Static_Resource__r.Item_Text__c)) {
                posItem.itemText = cm.POS_Static_Resource__r.POS_Item__r.MasterLabel;
            } else {
                posItem.itemText = cm.POS_Static_Resource__r.Item_Text__c;
            }

            // add item to map of brand to pos items
            if (brandToPOSItemMap.containsKey(cm.POS_Static_Resource__r.Brand__c)) {
                brandToPOSItemMap.get(cm.POS_Static_Resource__r.Brand__c).add(posItem);
            } else {
                brandToPOSItemMap.put(cm.POS_Static_Resource__r.Brand__c, new List<SBP_POSItemCmpCtrl.POSItem> {posItem});
            }
        }
        return brandToPOSItemMap;
    }

    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    // appears to be an issue when querying based on a related field that is of type picklist
    // below is the work around
    public static List<POS_State_Setting__mdt> getPOSCustomMetadata(String state, String brand, String premiseType, String productType) {
        system.debug('state --> ' + state);
        system.debug('brand --> ' + brand);
        system.debug('premiseType --> ' + premiseType);
        System.debug('vikash debug product type-->'+ productType);
        List<POS_State_Setting__mdt> stateSettings = new List<POS_State_Setting__mdt>();
        for (POS_State_Setting__mdt cm : [select Premise_Type__c
                                          , State__c
                                          , Product_Type__c
                                          , Default_Text_Value__c
                                          , Show_Text_Options__c
                                          , Options__c
                                          , MasterLabel
                                          , POS_Static_Resource__r.Brand__c
                                          , POS_Static_Resource__r.MasterLabel
                                          , POS_Static_Resource__r.DeveloperName
                                          , POS_Static_Resource__r.Item_Text__c
                                          , POS_Static_Resource__r.Item_Price__c
                                          , POS_Static_Resource__r.Static_Resource_Name__c
                                          , POS_Static_Resource__r.POS_Item__r.Help_Text__c
                                          , POS_Static_Resource__r.POS_Item__r.Options__c
                                          , POS_Static_Resource__r.POS_Item__r.hasInsert__c
                                          , POS_Static_Resource__r.POS_Item__r.MasterLabel from POS_State_Setting__mdt where Premise_Type__c = :premiseType AND Is_Active__c = TRUE]) {
            if (cm.POS_Static_Resource__r.Brand__c == brand) {
                system.debug('First if --> ' + cm.POS_Static_Resource__r.Brand__c);
                if (state == cm.State__c || !posItemSpecificStates.contains(state)) {
                    system.debug('here');
                    if(productType == SBP_Constants.PRODUCT_TYPE_RYE){
                        if(cm.Product_Type__c == productType){
                            stateSettings.add(cm);
                        }
                    }else if(cm.Product_Type__c != SBP_Constants.PRODUCT_TYPE_RYE){
                          stateSettings.add(cm);
                    }
                }
            }
        }
        system.debug('stateSettings --> ' + stateSettings);
        return stateSettings;
    }


    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus insertPOSItems(String posItems, String recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        POS_Customization__c bottleText = new POS_Customization__c();
        List<POS_Customization__c> posCustomizations = new List<POS_Customization__c>();
        String accountName;

        System.debug('posItems >> ' + posItems);

        List<POS_Customization__c> posItemList = (List<POS_Customization__c>)System.JSON.deserialize(posItems, List<POS_Customization__c>.Class);

        try {
            // insert pos item
            String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if (objectType == 'Barrel__c') {
                for (POS_Customization__c item : [select id, Type__c, Barrel__r.Case__r.Retail_Account__r.Name, Insert_Text__c from POS_Customization__c where Barrel__c = :Id.valueOf(recordId) AND Type__c = 'Bottle Plate Text']) {
                    bottleText = item;
                    accountName = item.Barrel__r.Case__r.Retail_Account__r.Name;
                    break;
                }
            } else if (objectType == 'Case') {
                Case c = [select id, Type, (Select id from Barrels__r) from Case where Id = :Id.valueOf(recordId)];
                if (c.Type != 'Split Barrel') {

                    Id barrelId = c.Barrels__r[0].Id;
                    objectType = 'Barrel__c';
                    recordId = barrelId;
                    for (POS_Customization__c item : [select id, Type__c, Barrel__r.Case__r.Retail_Account__r.Name, Insert_Text__c from POS_Customization__c where Barrel__c = :barrelId AND Type__c = 'Bottle Plate Text']) {
                        bottleText = item;
                        accountName = item.Barrel__r.Case__r.Retail_Account__r.Name;
                        break;
                    }
                } else {
                    for (POS_Customization__c item : [select id, Type__c, Case__r.Retail_Account__r.Name, Insert_Text__c from POS_Customization__c where Case__c = :Id.valueOf(recordId) AND Type__c = 'Bottle Plate Text']) {
                        bottleText = item;
                        accountName = item.Case__r.Retail_Account__r.Name;
                        break;
                    }
                }
            }

            for (POS_Customization__c item : posItemList) {
                if (objectType == 'Barrel__c') {
                    item.Barrel__c = Id.valueOf(recordId);
                    item.RecordTypeId = SBP_Constants.POS_FULL_BARREL_RT_ID;
                } else if (objectType == 'Case') {
                    item.Case__c = Id.valueOf(recordId);
                    item.RecordTypeId = SBP_Constants.POS_SPLIT_BARREL_RT_ID;
                }
            }

            insert posItemList;

            responseMap.put('posItems', posItemList);
            responseMap.put('numberOfPosItems', posItemList.size());
            responseMap.put('values', posItems);

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage() + ' ' + e.getStackTraceString();
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        //System.assert(false,LoggingLevel.INFO+'--'+requestStatus);
        return requestStatus;
    }


    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getDistributorRecord(String recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Id accountId;


        try {
            String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();

            if (objectType == 'Barrel__c') {
                Barrel__c barrel = [select Id, Case__r.AccountId from Barrel__c where Id = :Id.valueOf(recordId) limit 1];
                accountId = barrel.Case__r.AccountId;
            } else if (objectType == 'Case') {
                Case c = [select Id, AccountId from Case where Id = :Id.valueOf(recordId) limit 1];
                accountId = c.AccountId;
            }
            Account acct = [select Id, Attention__c, Name, Phone, BillingCity, BillingStreet, BillingState, BillingCountry, BillingPostalCode from Account where Id = :accountId limit 1];

            responseMap.put('account', acct);
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
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus updateStepsAsCompleted(String recordId, Boolean posItemsSelected, Boolean bottlePlateTextComplete) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        String brand, state, premiseType;
        try {
            String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            Case c = new Case();

            if (objectType == 'Barrel__c') {
                Barrel__c barrel = [SELECT 
                                        Id, Case__c, Case__r.POS_Items_Selected__c, Case__r.Bottle_Text_Entered__c,
                                        Case__r.Account_State__c, Case__r.Brand__c, Case__r.Premise_Type__c 
                                    FROM 
                                        Barrel__c 
                                    WHERE 
                                        Id = :Id.valueOf(recordId) LIMIT 1];
                c.put('Id', Id.valueOf(barrel.Case__c));
                c.put('POS_Items_Selected__c', barrel.Case__r.POS_Items_Selected__c);
                c.put('Bottle_Text_Entered__c', barrel.Case__r.Bottle_Text_Entered__c);
                brand = barrel.Case__r.Brand__c;
                state = barrel.Case__r.Account_State__c;
                premiseType = barrel.Case__r.Premise_Type__c;
            } else if (objectType == 'Case') {
                Case cc = [SELECT 
                            Id, POS_Items_Selected__c, Bottle_Text_Entered__c, Flow_Completed__c, 
                            Premise_Type__c, Account_State__c, Brand__c 
                           FROM 
                            Case 
                           WHERE 
                            Id = :Id.valueOf(recordId)];
                c.put('Id', Id.valueOf(recordId));
                c.put('POS_Items_Selected__c', cc.POS_Items_Selected__c);
                c.put('Bottle_Text_Entered__c', cc.Bottle_Text_Entered__c);
                brand = cc.Brand__c;
                state = cc.Account_State__c;
                premiseType = cc.Premise_Type__c;
            }
            //Added for SR_183320
            if('El Tesoro'.equalsIgnoreCase(brand) && 
                ('NY'.equalsIgnoreCase(state) || 
                ('OR'.equalsIgnoreCase(state) && 'On Premise'.equalsIgnoreCase(premiseType)))) {
                    c.put('Bottle_Text_Entered__c', true);
                    bottlePlateTextComplete = true;
            }

            if (posItemsSelected) {
                c.POS_Items_Selected__c = posItemsSelected;
                c.POS_Items_Selected_Date__c = Datetime.now();
            }

            if (bottlePlateTextComplete) {
                c.Bottle_Text_Entered__c = bottlePlateTextComplete;
                c.Bottle_Text_Entered_Date__c = Datetime.now();
            }            
            c.Flow_Completed__c = true;//added by mahesh

            update c;
            
            responseMap.put('updatedRecord', c);

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
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getBottleLabelImages(String state, String premiseType) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        try {
            Map<String, SBP_POSItemCmpCtrl.BrandBottleLabel> standardBottleLabelMap = new Map<String, SBP_POSItemCmpCtrl.BrandBottleLabel> {
                'Knob Creek'                => new BrandBottleLabel('Knob Creek', 'knobCreekBottleImage', 'KnobCreekBourbonLabel'), // Modified for SR_127060 - Final Update - Knob Creek Labels
                'Knob Creek Rye'            => new BrandBottleLabel('Knob Creek Rye', 'KnobCreekRyeBottleImage', 'KnobCreekRyeBottleLabel'), // Modified for SR_127060 - Final Update - Knob Creek Labels
                'Makers Mark'               => new BrandBottleLabel( 'Makers Mark', 'makersMarkBottle', 'makersMarkBottleLabel'),
                'El Tesoro'                 => new BrandBottleLabel( 'El Tesoro', 'elTesoroBottleGlorifier', 'elTesoroBottleLabel'),
                'Baker\'s'                  => new BrandBottleLabel( 'Baker\'s', 'makersMarkBottle', 'makersMarkBottleLabel'),
                'El Tesoro Laphroaig Cask'  => new BrandBottleLabel( 'El Tesoro Laphroaig Cask', 'ETLCBottle', 'ETLCBottleLabel'),
                'Laphroaig Single Cask'  => new BrandBottleLabel( 'Laphroaig Single Cask', 'laphroaigSingleCaskBottle', 'laphroaigSingleCaskBottleLabel')//Added By Nishant Khandal LSB-79
            };

            Map<String, SBP_POSItemCmpCtrl.BrandBottleLabel> newYorkBottleLabelMap = new Map<String, SBP_POSItemCmpCtrl.BrandBottleLabel> {
                'Knob Creek'                => new BrandBottleLabel('Knob Creek', 'knobCreekBottleImage', ''),
                'Knob Creek Rye'            => new BrandBottleLabel('Knob Creek Rye', 'KnobCreekRyeBottleImage', ''),
                'Makers Mark'               => new BrandBottleLabel( 'Makers Mark', 'makersMarkBottle', 'makersMarkBottleLabel'),
                'El Tesoro'                 => new BrandBottleLabel( 'El Tesoro', 'elTesoroBottleGlorifier', ''),
                'Baker\'s'                  => new BrandBottleLabel( 'Baker\'s', 'makersMarkBottle', 'makersMarkNewYorkBottleLabel'),
            	'El Tesoro Laphroaig Cask'  => new BrandBottleLabel( 'El Tesoro Laphroaig Cask', 'ETLCBottle', 'ETLCBottleLabel'),
                'Laphroaig Single Cask'  => new BrandBottleLabel( 'Laphroaig Single Cask', 'laphroaigSingleCaskBottle', 'laphroaigSingleCaskBottleLabel')//Added By Nishant Khandal LSB-79
            };

            // Modified for SR_187316
            if (state == 'New York' || state.equals('NY') || ((state == 'Oregon' || state.equals('OR')) && premiseType == 'On Premise')) {
                responseMap.put('bottleLabelMap', newYorkBottleLabelMap);
            } else {
                responseMap.put('bottleLabelMap', standardBottleLabelMap);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            success = false;
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    public class BrandBottleLabel {
        @AuraEnabled public String brandLabel;
        @AuraEnabled public String bottleImageName;
        @AuraEnabled public String bottleLabel;

        public BrandBottleLabel(String brandLabel, String bottleImageName,  String bottleLabel) {
            this.brandLabel = brandLabel;
            this.bottleImageName = bottleImageName;
            this.bottleLabel = bottleLabel;
        }
    }

    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getRecordDetails(String recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        String state;
        String premiseType;
        String retailState; //SR-168626 new variable
        String retailAccountName = '';
        String caseNumber = '';
        String productType;

        try {
            // insert pos item
            String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();

            Account acct = [select id from Account where Name = 'Single Barrel International Account'];

            if (objectType == 'Barrel__c') {
                Barrel__c barrel = [select Id, Case__r.Account.BillingState, Case__r.Retail_Account__r.PremiseType__c, Case__r.Retail_Account__r.Name, Case__r.Account_Missing__c, Case__r.Premise__c,Case__r.Retail_Account__r.BillingState, Case__r.CaseNumber, Product_Type__c  from Barrel__c where Id = :Id.valueOf(recordId) limit 1];//SR-168626 Adding Retail Account State in Query
                productType = barrel.Product_Type__c;
                if (barrel.Case__r.Account_Missing__c) {
                    state = '';
                    premiseType = barrel.Case__r.Premise__c;
                    retailState = ''; //SR-168626 
                } else {
                    state = barrel.Case__r.Account.BillingState;
                    premiseType = barrel.Case__r.Retail_Account__r.PremiseType__c;
                    retailState = barrel.Case__r.Retail_Account__r.BillingState; //SR-168626 
                    retailAccountName = barrel.Case__r.Retail_Account__r.Name;
                    caseNumber = barrel.Case__r.CaseNumber;
                }

            } else if (objectType == 'Case') {
                Case c = [select Id,Account.BillingState, Premise__c, Type, Account_Missing__c, Retail_Account__r.PremiseType__c, Retail_Account__r.BillingState,Retail_Account__r.Name, CaseNumber, Product_Type__c from Case where Id = :Id.valueOf(recordId) limit 1];
                caseNumber = c.caseNumber;
                productType = c.Product_Type__c;
                if (c.Type != 'Split Barrel') {
                    if (c.Account_Missing__c) {
                        state = '';
                        premiseType = c.Premise__c;
                    } else {
                        state = c.Account.BillingState;
                        premiseType = c.Retail_Account__r.PremiseType__c;
                        retailState = c.Retail_Account__r.BillingState;
                        retailAccountName = c.Retail_Account__r.Name;
                    }
                } else {
                    Case sb = [select Id
                               , Account.BillingState
                               , Premise__c
                               , Account_Missing__c
                               , Barrel__r.Case__r.Account.BillingState
                               , Barrel__r.Case__r.Retail_Account__r.PremiseType__c
                               , Barrel__r.Case__r.Retail_Account__r.BillingState
                               , Barrel__r.Case__r.Premise__c
                               , Barrel__r.Case__r.Retail_Account__r.Name
                               , Barrel__r.Case__r.Account_Missing__c
                               , Retail_Account__r.PremiseType__c from Case where Id = :Id.valueOf(recordId) limit 1];
                    if (sb.Barrel__r.Case__r.Account_Missing__c) {
                        state = '';
                        premiseType = sb.Barrel__r.Case__r.Premise__c;
                    } else {
                        state = sb.Barrel__r.Case__r.Account.BillingState;
                        premiseType = sb.Barrel__r.Case__r.Retail_Account__r.PremiseType__c;
                        retailState = sb.Barrel__r.Case__r.Retail_Account__r.BillingState;
                        retailAccountName = sb.Barrel__r.Case__r.Retail_Account__r.Name;
                    }

                }

                // for the data migration if the premise type on the case exists then use that value
                // the retail account will have been defaulted from the migration and won't 
                // reflect the correct premise type which is why it must be pulled from this field
                if (String.isNotBlank(c.Premise__c)) {
                    premiseType = c.Premise__c;
                }

            }
            responseMap.put('state', state);
            responseMap.put('premiseType', premiseType);
            responseMap.put('retailState', retailState);  //SR-168626 Added Retail Account State in response map
            responseMap.put('retailAccountName', retailAccountName);
            responseMap.put('caseNumber', caseNumber);
            responseMap.put('productType', productType);

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            message = message + recordId;
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getPOSRecords(String recordId) {
        Boolean success = true;
        Boolean imagesNotExist = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        String state;
        String premiseType;
        List<POS_Customization__c> posItems = new List<POS_Customization__c>();

        try {
            // insert pos item
            String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if (objectType == 'Case') {
                Case c = [select Id, Type, Barrel__c from Case where Id = :Id.valueOf(recordId) limit 1];

                if (c.Type == 'Split Barrel') {
                    posItems = [select id, Type__c, Insert_Text__c, Attention__c, Company__c, Street__c, City__c, Zip__c, State__c, Phone__c,POS_Item_Seq__c,(SELECT ContentDocumentId FROM ContentDocumentLinks) from POS_Customization__c where Case__c = :Id.valueOf(recordId)];
                } else {
                    posItems = [select id, Type__c, Insert_Text__c, Attention__c, Company__c, Street__c, City__c, Zip__c, State__c, Phone__c,POS_Item_Seq__c,(SELECT ContentDocumentId FROM ContentDocumentLinks) from POS_Customization__c where Barrel__r.Case__c = :Id.valueOf(recordId)];
                }
            }
            for(POS_Customization__c posItem : posItems) {
                if(posItem.Type__c == 'Bottle Plate Text' && !posItem.ContentDocumentLinks.isEmpty()) {
                    imagesNotExist = false;
                    break;
                }
            }
            responseMap.put('imagesNotExist', imagesNotExist);
            responseMap.put('posItems', posItems);
            responseMap.put('numOfPOSItems', posItems.size());

        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            message = message + recordId;
            success = false;
        }

        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    
    // Aded by sripal on 08/02
   @AuraEnabled
    public static string getAccountNamefromCase(string CaseId){
        //system.debug('=====caseid'+CaseId);
        List<Case> caserec = new List<Case>();
        List<Barrel__c>barrels = new List<Barrel__c>();
        caserec = [SELECT id,Retail_Account__r.Name FROM Case where id=:CaseId];
        string AccountName;
        if(caserec.size()>0){
            AccountName =caserec[0].Retail_Account__r.Name;
        }else {
            barrels = [SELECT ID,Name,Case__r.Retail_Account__r.Name FROM Barrel__c where id=:CaseId];
            if(barrels.size()>0){
                AccountName = barrels[0].Case__r.Retail_Account__r.Name;
            }
        }
        
        //system.debug('--------------------------cae rec---'+caserec+CaseId);
        return AccountName;
    }
    
/**************************************************************************************************************
    Author:       Ajeeta Soni
    Company:      TCS
    Description:  Added for SR_183564 - Issue With Closed-Abandoned Cases by Ajeeta Soni 
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    8/2020      Ajeeta Soni       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static String getRecordStatusDetails(String recordId){
        String status;
        List<Case> caserec = new List<Case>();
        List<Barrel__c> barrels = new List<Barrel__c>();
        barrels = [SELECT id,Case__c,Case__r.Status FROM Barrel__c where id=:recordId];       
        if(barrels.size()>0){       
            status =barrels[0].Case__r.Status;           
        }
        else {
            caserec = [SELECT ID,Status FROM Case where id=:recordId];
            if(caserec.size()>0){
                status = caserec[0].Status;
            }
        }
        
        return status;
        
    } 
    //added by Nishant Khandal for LSB-76
    @AuraEnabled
    public static String getPOSRecordBrand(String recordId) {
        String titleLabel = null;
        try {
            if(!String.isEmpty(recordId)){
                String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
                if (objectType != null && objectType == SBP_Constants.CASE_STRING) {
                    Case recordCase = SLT_Case.getCaseByID(Id.valueOf(recordId));
                    titleLabel = recordCase.Brand__c;
                }
            }
            
        } catch (Exception e) {
            return null;
        }
        return titleLabel;
    }

    /*
    Developer Name      : Veeru Pal
    Description         : Use to save POS Add Label Text image for Maker's Mark brand.
    Link to requirement : https://beamsuntory.atlassian.net/browse/MMSBR-2
    */

    private static List<ContentVersion> insertContentVersion(String attachmentRecordBodyJSON){
        List<AttachmentWrapper> attachmentWrapperList;
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        try {
            attachmentWrapperList = (List<AttachmentWrapper>)System.JSON.deserialize(attachmentRecordBodyJSON, List<AttachmentWrapper>.class);
            for(AttachmentWrapper attachmentWrapperData : attachmentWrapperList){
                ContentVersion contentVersion = new ContentVersion();
                contentVersion.title = attachmentWrapperData.name;
                contentVersion.PathOnClient ='/' + attachmentWrapperData.name;
                contentVersion.VersionData = EncodingUtil.base64Decode(attachmentWrapperData.body);
                contentVersion.Description = attachmentWrapperData.parentId;    //Stored ParentId into Description for further use in contentDocumentLink.LinkedEntityid.
                contentVersion.IsMajorVersion = false;
                if(attachmentWrapperData.contentDocument != null && attachmentWrapperData.contentDocument != ''){
                    contentVersion.ContentDocumentId = attachmentWrapperData.contentDocument;
                }
                contentVersionList.add(contentVersion);
            }
            if(!contentVersionList.isEmpty()){
                insert contentVersionList;
            }
        } catch (Exception error) {
            System.debug('SBP_POSItemCmpCtrl -> insertContentVersion -> ' + JSON.serialize(error.getMessage()));
            contentVersionList = new List<ContentVersion>();
        }
        return contentVersionList;
    }

    private static Boolean insertContentDistribution(List<ContentVersion> contentVersionList){
        List<ContentDistribution> contentDistributionList = new List<ContentDistribution>();
        Boolean isSuccess = true;
        try {
            if(!contentVersionList.isEmpty()){
                for(ContentVersion contentVersion : contentVersionList){
    
                    ContentDistribution conDis = new ContentDistribution();
                    conDis.Name = contentVersion.Title;
                    conDis.ContentVersionId = contentVersion.Id;
                    conDis.PreferencesAllowViewInBrowser= true;
                    conDis.PreferencesNotifyOnVisit = false;
                    conDis.PreferencesAllowViewInBrowser = true;
                    conDis.PreferencesAllowOriginalDownload = true;
                    conDis.RelatedRecordId = Id.valueOf(contentVersion.Description);
                    conDis.PreferencesLinkLatestVersion = false;
                    conDis.PreferencesPasswordRequired = false;
    
                    contentDistributionList.add(conDis);
                }
            }
    
            if(!contentDistributionList.isEmpty()){
                insert contentDistributionList;
            }
        } catch (Exception error) {
            System.debug('SBP_POSItemCmpCtrl -> insertContentDistribution -> ' + JSON.serialize(error.getMessage()));
            isSuccess = false;
        }
        return isSuccess;
    }

    private static Boolean insertContentDocumentLink(List<ContentVersion> contentVersionList){
        Set<Id> cotentVersionIds = new Set<Id>();
        List<ContentDocument> contentDocumentList;
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>();
        Boolean isSuccess = true;

        try {
            for(ContentVersion contentVersion : contentVersionList){
                cotentVersionIds.add(contentVersion.Id);
            }

            contentDocumentList = [SELECT ID,LatestPublishedVersion.Description FROM ContentDocument WHERE LatestPublishedVersionId IN :cotentVersionIds];

            for(ContentDocument contentDocument :contentDocumentList){
                ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
                contentDocumentLink.contentDocumentId = contentDocument.ID;
                contentDocumentLink.LinkedEntityid = contentDocument.LatestPublishedVersion.Description;
                contentDocumentLink.ShareType = 'V';
                contentDocumentLink.Visibility = 'AllUsers';
                contentDocumentLinkList.add(contentDocumentLink);
            }

            if(!contentDocumentLinkList.isEmpty()){
                insert contentDocumentLinkList;
            }
        } catch (Exception error) {
            System.debug('SBP_POSItemCmpCtrl -> insertContentDocumentLink -> ' + JSON.serialize(error.getMessage()));
            isSuccess = false;
        }
        return isSuccess;
    }

    @AuraEnabled
    public static LightningComponentUtility.RequestStatus insertPOSAttachmentImage(String attachmentRecordBodyJSON){
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        String parentId = '';
        Savepoint insertAttachmentSavepoint = Database.setSavePoint();

        try {

            contentVersionList = insertContentVersion(attachmentRecordBodyJSON);

            if(!insertContentDistribution(contentVersionList)){
                success = false;
            }

            if(!insertContentDocumentLink(contentVersionList)){
                success = false;
            }

            if(!success || contentVersionList.isEmpty()){
                message = 'Image could Not Saved, please check debug!';
                Database.rollback(insertAttachmentSavepoint);
                contentVersionList = new List<ContentVersion>();
            }

            responseMap.put('contentVersionList',contentVersionList);
        }catch(Exception error){
            system.debug(LoggingLevel.INFO, error.getMessage());
            message = error.getMessage();
            success = false;
            Database.rollback(insertAttachmentSavepoint);
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
    public class AttachmentWrapper{
        public String parentId;
        public String body;
        public String contentType;
        public String name;
        public String contentDocument;
    }

    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getAttachment(String recordId){
        Map<String, Object> responseMap = new Map<String, Object>();
        Boolean success = true;
        String message = null;
        try{
            List<ContentDocumentLink> contentDocumentLinkList;
            contentDocumentLinkList = [SELECT ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.LatestPublishedVersion.Id,LinkedEntityid,ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityid =:Id.valueOf(recordId)];
            String base64Data;
            if(!contentDocumentLinkList.isEmpty()){
                base64Data = 'data:image/' + contentDocumentLinkList[0].ContentDocument.FileExtension + ';charset=utf-8;base64, ';
                base64Data += EncodingUtil.base64Encode(contentDocumentLinkList[0].ContentDocument.LatestPublishedVersion.VersionData);
                responseMap.put('attachedImage',base64Data);
            }else{
                success = false;
                message = 'No Attachment Record Record Found';
            }
        }catch(Exception error){
            success = false;
            message = error.getMessage();
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getBrandStaveMap(String recordId){
        List<Barrel__c> brandWithStaveList;
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Integer> staveInformationMap = new Map<String, Integer>();
        Barrel_Recipe__c barrelRecipe;
        try {
            String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if(objectType == 'Case'){
                brandWithStaveList = [SELECT Id
                                        , Barrel_Recipe__c
                                        , Barrel_Recipe__r.Baked_American_Pure_2__c
                                        , Barrel_Recipe__r.Maker_s_46__c
                                        , Barrel_Recipe__r.Mendiant__c
                                        , Barrel_Recipe__r.Roasted_French_Mocha__c
                                        , Barrel_Recipe__r.Seared_French_Cuvee__c
                                        , Barrel_Recipe__r.Toasted_French_Spice__c
                                    FROM
                                        Barrel__c
                                    WHERE
                                        Case__c = :recordId
                                    LIMIT 1 ];
            }else if(objectType == 'Barrel__c'){
                brandWithStaveList = [SELECT Id
                                        , Barrel_Recipe__c
                                        , Barrel_Recipe__r.Baked_American_Pure_2__c
                                        , Barrel_Recipe__r.Maker_s_46__c
                                        , Barrel_Recipe__r.Mendiant__c
                                        , Barrel_Recipe__r.Roasted_French_Mocha__c
                                        , Barrel_Recipe__r.Seared_French_Cuvee__c
                                        , Barrel_Recipe__r.Toasted_French_Spice__c
                                    FROM
                                        Barrel__c
                                    WHERE
                                        Id = :recordId
                                    LIMIT 1 ];
            }

            if(!brandWithStaveList.isEmpty() && brandWithStaveList[0].Barrel_Recipe__c != null){
                barrelRecipe = brandWithStaveList[0].Barrel_Recipe__r;
                staveInformationMap.put('Baked_American_Pure_2__c',((Integer)barrelRecipe.Baked_American_Pure_2__c));
                staveInformationMap.put('Seared_French_Cuvee__c',((Integer)barrelRecipe.Seared_French_Cuvee__c));
                staveInformationMap.put('Maker_s_46__c',((Integer)barrelRecipe.Maker_s_46__c));
                staveInformationMap.put('Mendiant__c',((Integer)barrelRecipe.Mendiant__c));
                staveInformationMap.put('Toasted_French_Spice__c',((Integer)barrelRecipe.Toasted_French_Spice__c));
            }
            responseMap.put('staveInformationMap',staveInformationMap);
        } catch (Exception e) {
            success = false;
            message = e.getMessage();
            responseMap.put('staveInformationMap','{}');
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getPOSRecordWithStaveInfoForMM(String recordId){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        List<POS_Customization__c> posWithStaveList;
        List<POS_Customization__c> twinRecordList;
        Map<String, Integer> staveInformationMap = new Map<String, Integer>();
        Barrel_Recipe__c barrelRecipe;
        try {
            String objectType = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
            if(objectType == 'POS_Customization__c'){
                posWithStaveList = [SELECT Id
                                        , State__c
                                        , Barrel__r.Brand__c
                                        , Barrel__c
                                        , POS_Item_Seq__c
                                        , Barrel__r.Barrel_Recipe__c
                                        , Barrel__r.Barrel_Recipe__r.Baked_American_Pure_2__c
                                        , Barrel__r.Barrel_Recipe__r.Maker_s_46__c
                                        , Barrel__r.Barrel_Recipe__r.Mendiant__c
                                        , Barrel__r.Barrel_Recipe__r.Roasted_French_Mocha__c
                                        , Barrel__r.Barrel_Recipe__r.Seared_French_Cuvee__c
                                        , Barrel__r.Barrel_Recipe__r.Toasted_French_Spice__c
                                    FROM
                                        POS_Customization__c
                                    WHERE
                                        Id = :recordId
                                        AND Type__c IN ('Bottle Plate Text','Bottle Label Text City and State')
                                    LIMIT 1];
                responseMap.put('posWithStaveList', posWithStaveList);
                responseMap.put('Brand', posWithStaveList[0].Barrel__r.Brand__c);
                twinRecordList = [SELECT Id
                                        , CreatedDate
                                        , State__c
                                        , Insert_Text__c
                                        , Barrel__c
                                        , Type__c
                                        , POS_Item_Seq__c
                                    FROM
                                        POS_Customization__c
                                    WHERE
                                        POS_Item_Seq__c = :posWithStaveList[0].POS_Item_Seq__c
                                        AND Barrel__c = :posWithStaveList[0].Barrel__c
                                        AND Type__c IN ('Bottle Plate Text','Bottle Label Text City and State')
                                    ORDER BY Type__c 
                                    LIMIT 2 ];
                
                responseMap.put('POSItems', twinRecordList);
                if(posWithStaveList[0].Barrel__r.Barrel_Recipe__c != null){
                    barrelRecipe = posWithStaveList[0].Barrel__r.Barrel_Recipe__r;
                    staveInformationMap.put('Baked_American_Pure_2__c',((Integer)barrelRecipe.Baked_American_Pure_2__c));
                    staveInformationMap.put('Seared_French_Cuvee__c',((Integer)barrelRecipe.Seared_French_Cuvee__c));
                    staveInformationMap.put('Maker_s_46__c',((Integer)barrelRecipe.Maker_s_46__c));
                    //staveInformationMap.put('Roasted_French_Mocha__c',((Integer)barrelRecipe.Roasted_French_Mocha__c));
                    staveInformationMap.put('Mendiant__c',((Integer)barrelRecipe.Mendiant__c));
                    staveInformationMap.put('Toasted_French_Spice__c',((Integer)barrelRecipe.Toasted_French_Spice__c));
                }
                responseMap.put('staveInformationMap',staveInformationMap);
            }
        } catch (Exception e) {
            success = false;
            message = e.getMessage();
            responseMap.put('staveInformationMap','{}');
            responseMap.put('POSItems', '[]');
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }


    @AuraEnabled
    public static LightningComponentUtility.RequestStatus upsertPOSItems(String posRecords){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        try{
            List<POSCustomizationWrapper> posWrapperList = (List<POSCustomizationWrapper>)JSON.deserialize(posRecords, List<POSCustomizationWrapper>.class);
            List<POS_Customization__c> posRecordList = new List<POS_Customization__c>();
            for(POSCustomizationWrapper posWrapperRecord : posWrapperList){
                POS_Customization__c posRecord = new POS_Customization__c();
                if(posWrapperRecord.Id != null){
                    posRecord.Id = posWrapperRecord.id;
                }
                posRecord.Insert_Text__c = posWrapperRecord.insertText;
                posRecord.Barrel__c = posWrapperRecord.barrel;
                posRecord.Type__c = posWrapperRecord.type;
                posRecord.POS_Item_Seq__c = posWrapperRecord.posItemSeq;
                posRecord.Bypass_Validation__c = true;
                posRecord.State__c = posWrapperRecord.state;
                posRecordList.add(posRecord);
            }
            if(!posRecordList.isEmpty()){
                upsert posRecordList;
                for(POS_Customization__c posRecord : posRecordList){
                    posRecord.Bypass_Validation__c = false;
                }
                update posRecordList;
            }
            responseMap.put('posRecordList', posRecordList);
            responseMap.put('recordSize', posRecordList.size());
        }catch(Exception error){
            success = false;
            message = error.getMessage();
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }

    public class POSCustomizationWrapper {
        public String id;
        public String insertText;
        public String barrel;
        public String type;
        public String posItemSeq;
        public String state;
    }

    @AuraEnabled
    public static LightningComponentUtility.RequestStatus updateAttachmentImage(String attachedImage, String recordId, String posRecords){
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Savepoint sp = Database.setSavePoint();
        try{
            List<contentDocumentLink> contentDocumentLinkRecord = [SELECT ContentDocument.Id FROM contentDocumentLink WHERE LinkedEntityid =:Id.valueOf(recordId)];
            POS_Customization__c posRecInfo = [SELECT Barrel__r.Case__r.CaseNumber,Barrel__r.Case__r.Retail_Account__r.Name FROM POS_Customization__c WHERE Id = :recordId];
            List<ContentVersion> contentVersionList;
            List<AttachmentWrapper> imageWrapperList = new List<AttachmentWrapper>();

            AttachmentWrapper imageWrapper = new AttachmentWrapper();
            imageWrapper.parentId = recordId;
            imageWrapper.body = attachedImage;
            imageWrapper.contentType = 'jpg/png';
            imageWrapper.name = posRecInfo.Barrel__r.Case__r.CaseNumber + '_' + posRecInfo.Barrel__r.Case__r.Retail_Account__r.Name + '.jpg';
            if(!contentDocumentLinkRecord.isEmpty()){
                imageWrapper.contentDocument = contentDocumentLinkRecord[0].ContentDocument.Id;
            }
            imageWrapperList.add(imageWrapper);

            String attachmentRecordBodyJSON = JSON.serialize(imageWrapperList);
            
            if(!contentDocumentLinkRecord.isEmpty()){
                contentVersionList = insertContentVersion(attachmentRecordBodyJSON);
                if(contentVersionList.isEmpty()){
                    success = false;
                }

                if(!insertContentDistribution(contentVersionList)){
                    success = false;
                }

                responseMap.put('contentVersionResult', contentVersionList);
            }else{
                LightningComponentUtility.RequestStatus returnRequest = insertPOSAttachmentImage(JSON.serialize(imageWrapperList));
                responseMap.putAll(returnRequest.responseMap);
                success = returnRequest.success;
            }
            if(success){
                LightningComponentUtility.RequestStatus returnRequest = upsertPOSItems(posRecords);
                responseMap.putAll(returnRequest.responseMap);
                success = returnRequest.success;
                message = returnRequest.message;
            }
            if(!success){
                Database.rollback(sp);
            }
        }catch(Exception error){
            system.debug(LoggingLevel.INFO, error.getMessage());
            message = error.getMessage();
            success = false;
            Database.rollback(sp);
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;
    }
//Changes ends here by Veeru Pal to save Attachment image.

/*
    Developer Name      : Abhishek Bhati
    Description         : Use to get POS custom Bottle label Images on email pop up and sending them through email.
    Link to requirement : https://beamsuntory.atlassian.net/browse/MMSBR-15
    */

    public class EmailTemplateDetail {
        @AuraEnabled public String emailBody;
        @AuraEnabled public String emailSubject;
    }

    @AuraEnabled
    public static EmailTemplateDetail getEmailTemplateDetails(String recordId, String State){
        String emailTemplateUniqueName;
        if(state == 'NY'){
            emailTemplateUniqueName = 'Makers_Mark_Custom_Bottle_Label_Review_Email_for_NY_and_OR';
        } else {
            emailTemplateUniqueName = 'Makers_Mark_Custom_Bottle_Label_Review_Email';
        }
        EmailTemplate emailTemplate = [Select Id,Subject,Body from EmailTemplate where DeveloperName =: emailTemplateUniqueName];
        Messaging.SingleEmailMessage message =  Messaging.renderStoredEmailTemplate(emailTemplate.Id, recordId , null);
        EmailTemplateDetail emailTemplateDetail = new EmailTemplateDetail();
        emailTemplateDetail.emailBody = message.getPlainTextBody();
        emailTemplateDetail.emailSubject = message.getSubject();
        return emailTemplateDetail;
    } 

    public class POSAttachementDetails {
        @AuraEnabled public String line1;
        @AuraEnabled public String line2;
        @AuraEnabled public Id imageId;
        @AuraEnabled public String emailBody ;
        @AuraEnabled public String toEmailAddress;
        @AuraEnabled public String emailSubject;
        @AuraEnabled public String imageURL;
        @AuraEnabled public String ccEmailAddress;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String imageLink;
        @AuraEnabled public String posrecordId;
    }

    @AuraEnabled
    public static  LightningComponentUtility.RequestStatus getPOSrecordAttachements(String recordId){
        List<POSAttachementDetails> posAttachementDetailsList = new List<POSAttachementDetails>(); 
        Map<Id,POS_Customization__c> posCustomizationRecordsMap = new Map<Id,POS_Customization__c>();
        Set<ID> posRecordsIdSet = new Set<ID>();
        Map<String,POSAttachementDetails> posAttachementDetailsMap = new Map<String,POSAttachementDetails>();
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        String state;
        List<ContentDocumentLink> contentDocumentLinkList = new List<ContentDocumentLink>(); 
        Map<ID,ContentDocumentLink> contentDocumentLinkMap = new Map<ID,ContentDocumentLink>();
        Set<Id> contentDocumentId = new Set<Id>();
        Map<Id,String> posIDimageURLmap = new Map<Id,String>();
        try{
            Case c = [select Id, Type, Barrel__c,CaseNumber,Heritage_Manager__r.Email,Regional_Diplomat__r.Email from Case where Id = :Id.valueOf(recordId) limit 1];
            posCustomizationRecordsMap = new Map<Id,POS_Customization__c>([select  id, Pos_Item_Seq__c,Insert_Text__c, City__c, Type__c, State__c from POS_Customization__c where Barrel__r.Case__c = :Id.valueOf(recordId) AND (Type__c = 'Bottle Plate Text' OR Type__c = 'Bottle Label Text City and State')]);
            for (Id key : posCustomizationRecordsMap.keySet()) {
                if(posCustomizationRecordsMap.get(key).Type__c == 'Bottle Plate Text')
                {
                    posRecordsIdSet.add(key);
                    state = posCustomizationRecordsMap.get(key).State__c;
                }
            }
            contentDocumentLinkList = [SELECT ContentDocument.FileExtension, ContentDocument.LatestPublishedVersion.Title, ContentDocument.LatestPublishedVersion.VersionData,ContentDocument.LatestPublishedVersion.Id,LinkedEntityid,ContentDocumentId FROM contentDocumentLink WHERE LinkedEntityid IN: posRecordsIdSet];
            for(ContentDocumentLink contentDocumentLink : contentDocumentLinkList){
                contentDocumentLinkMap.put(contentDocumentLink.LinkedEntityid,contentDocumentLink);
                contentDocumentId.add(contentDocumentLink.ContentDocumentId);
            }
            List<ContentDistribution> contentDistributionList = [SELECT Id,ContentDownloadUrl, DistributionPublicUrl,RelatedRecordId FROM ContentDistribution WHERE ContentDocumentId IN: contentDocumentId];
            for(ContentDistribution contentDistribution : contentDistributionList ){
                posIDimageURLmap.put(contentDistribution.RelatedRecordId,contentDistribution.ContentDownloadUrl);
            }
            for (Id key : posCustomizationRecordsMap.keySet()) {
                if(posAttachementDetailsMap.containsKey(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c)){
                    if(posCustomizationRecordsMap.get(key).Type__c == 'Bottle Plate Text')
                    {  
                        posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).line1 = posCustomizationRecordsMap.get(key).Insert_Text__c;
                        if(contentDocumentLinkMap.containsKey(key)) {
                            posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).imageId = contentDocumentLinkMap.get(key).ContentDocument.LatestPublishedVersion.Id;
                            String base64Data;
                            base64Data = 'data:image/' + contentDocumentLinkMap.get(key).ContentDocument.FileExtension + ';charset=utf-8;base64, ';
                            base64Data += EncodingUtil.base64Encode(contentDocumentLinkMap.get(key).ContentDocument.LatestPublishedVersion.VersionData);
                            posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).imageURL = base64Data;
                        }
                        posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).imageLink = posIDimageURLmap.get(key);
                        posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).posrecordId = key;
                    } else{
                        posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).line2 = posCustomizationRecordsMap.get(key).Insert_Text__c;
                    }
                } else{
                    if(posCustomizationRecordsMap.get(key).Type__c == 'Bottle Plate Text'){
                        POSAttachementDetails posAttachementDetails = new POSAttachementDetails();
                        posAttachementDetails.line1 = posCustomizationRecordsMap.get(key).Insert_Text__c;
                        posAttachementDetailsMap.put(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c,posAttachementDetails);
                        if(contentDocumentLinkMap.containsKey(key)) {
                            posAttachementDetails.imageId = contentDocumentLinkMap.get(key).ContentDocument.LatestPublishedVersion.Id;
                            String base64Data;
                            base64Data = 'data:image/' + contentDocumentLinkMap.get(key).ContentDocument.FileExtension + ';charset=utf-8;base64, ';
                            base64Data += EncodingUtil.base64Encode(contentDocumentLinkMap.get(key).ContentDocument.LatestPublishedVersion.VersionData);
                            posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).imageURL = base64Data;
                        }
                        posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).imageLink = posIDimageURLmap.get(key);
                        posAttachementDetailsMap.get(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c).posrecordId = key;
                    } else{
                        POSAttachementDetails posAttachementDetails = new POSAttachementDetails();
                        posAttachementDetails.line2 = posCustomizationRecordsMap.get(key).Insert_Text__c;
                        posAttachementDetailsMap.put(posCustomizationRecordsMap.get(key).Pos_Item_Seq__c,posAttachementDetails);
                    }
                }
            }
            EmailTemplateDetail emailTemplateDetail = getEmailTemplateDetails(recordId,state);
            posAttachementDetailsList = posAttachementDetailsMap.values(); 
            for(POSAttachementDetails pOSAttachementDetails : posAttachementDetailsList){
                pOSAttachementDetails.emailBody = emailTemplateDetail.emailBody;
                pOSAttachementDetails.emailSubject= emailTemplateDetail.emailSubject;
                pOSAttachementDetails.toEmailAddress = '';
                pOSAttachementDetails.caseNumber = c.CaseNumber;
                pOSAttachementDetails.ccEmailAddress = c.Heritage_Manager__r.Email + ','+ c.Regional_Diplomat__r.Email+','+UserInfo.getUserEmail();
            }
            responseMap.put('posAttachementDetailsList', posAttachementDetailsList);
            responseMap.put('numOfPOSItems', posAttachementDetailsList.size());
        } catch (Exception e) {
            message = e.getMessage();
            message = message + recordId;
            success = false;
        }
        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        return requestStatus;
    }

    public class  CustomBottleLabelWrapper {
        @AuraEnabled public String imageURL;
        @AuraEnabled public Id imageId;
        @AuraEnabled public String emailBody ;
        @AuraEnabled public String toEmailAddress;
        @AuraEnabled public String emailSubject;
        @AuraEnabled public String ccEmailAddress;
        @AuraEnabled public String caseNumber;
        @AuraEnabled public String imageLink;
        @AuraEnabled public String posrecordId;
    }

    public static String updatePOSrecordWithEmailRecipent(Map<Id,String> posEmailReciepentsMap){
        List<POS_Customization__c> posRecords = new List<POS_Customization__c>();
        try{
            posRecords = [SELECT Id,Email_Recipient__c from POS_Customization__c WHERE Id IN: posEmailReciepentsMap.keySet()];
            for(POS_Customization__c posCustomizationRecord : posRecords){
                posCustomizationRecord.Email_Recipient__c = posEmailReciepentsMap.get(posCustomizationRecord.Id);
            }
            update posRecords;
            return 'success';     
        } catch(Exception e) {
            return JSON.serialize(e.getMessage());
        }
    }

    @AuraEnabled
    public static String  sendEmailToCustomers(String imageWrapperJSON){
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Type idArrType = Type.forName('List<SBP_POSItemCmpCtrl.CustomBottleLabelWrapper>');
        List<SBP_POSItemCmpCtrl.CustomBottleLabelWrapper> imageWrapperList = (List<SBP_POSItemCmpCtrl.CustomBottleLabelWrapper>)JSON.deserialize(imageWrapperJSON, idArrType);
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<Id,String> posEmailReciepentsMap = new Map<Id,String>();
        try{
            for(SBP_POSItemCmpCtrl.CustomBottleLabelWrapper imageWrapper : imageWrapperList){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                List<String> toEmailAddress = imageWrapper.toEmailAddress.split(',');
                List<String> ccEmailAddress = new List<String>();
                if(String.isNotBlank(imageWrapper.ccEmailAddress)){
                    ccEmailAddress = imageWrapper.ccEmailAddress.split(',');
                }
                if(String.isNotBlank(imageWrapper.toEmailAddress)){
                    posEmailReciepentsMap.put(imageWrapper.posrecordId,imageWrapper.toEmailAddress);
                }
                List<String> imageIdList = new List<String>();
                imageIdList.add(String.valueOf(imageWrapper.imageId));
                email = singleEmail(toEmailAddress, imageWrapper.emailSubject, imageWrapper.emailBody, imageWrapper.imageLink, imageIdList,ccEmailAddress, imageWrapper.caseNumber);
                emails.add(email);
            }
            updatePOSrecordWithEmailRecipent(posEmailReciepentsMap);
            List<Messaging.SendEmailResult> emailResults = Messaging.sendEmail(emails);
            return 'success';
        } catch(Exception e) {
            return JSON.serialize(e.getMessage());
        }
    } 

    public static Messaging.SingleEmailMessage singleEmail(List<String> recipientList, String subject, String emailBody, String imageURL,List<String> imageIdList,List<String> ccAddressList,String caseNumber){
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setToAddresses(recipientList);
        email.setSubject(subject);
        emailBody +=  '\r\n\r\n\r\n\r\n\r\n' +'Re:'+ caseNumber;
        emailBody = emailBody.replace('\r\n','<br>');
        emailBody = emailBody.replace('\n','<br>');
        emailBody = emailBody.replace('{Image}','<img src="'+imageURL+'">' );
        email.setHtmlBody(emailBody);
        email.setCcAddresses(ccAddressList);
        email.setEntityAttachments(imageIdList);
        return email;
    }
}