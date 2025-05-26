public without sharing class SBP_BarrelRecipeCmpCtrl {

    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:    Pulls in the custom metadata for the staves
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/

    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getSingleBarrelStaveCustomMetadata(String brand) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();

        try {
            List<Single_Barrel_Stave_Setting__mdt> staves = [select MasterLabel, Brand__c, isActive__c, Order__c, Static_Resource_Name__c, Stave_Name__c from Single_Barrel_Stave_Setting__mdt where isActive__c = true AND Brand__c = :brand order by Order__c asc];

            responseMap.put('staves', staves);
            //SCTASK0020521 | Show French Mocha Stave to CS Plant profile
            List<Profile> Profile = [SELECT Id, Name FROM Profile WHERE Id=:Userinfo.getProfileId()];
            responseMap.put('isCSPlantProfile', Profile[0].Name == 'CS Plant');
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
    Description:    Pulls in all the recent recipes related to a particular account
    Inputs:        caseId:  single barrel program case id
                    brand: single barrel program brand
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/

    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getRecentRecipes(String caseId, String brand) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Set<Id> barrelRecipeIds = new Set<Id>();
        List<Case> casetypelst = new List<Case>();
        String accountName;
        Id accountId;

        try {
            Case c = [select id, Retail_Account__c, Retail_Account_Name__c, Status from Case where Id = :Id.valueOf(caseId) limit 1];
            accountId = c.Retail_Account__c;
            accountName = c.Retail_Account_Name__c;
            List<Barrel__c> lstBarrel = [SELECT Barrel_Recipe__c FROM Barrel__c WHERE Case__r.Retail_Account__c =: c.Retail_Account__c AND Barrel_Recipe__c != null];
            if(!lstBarrel.isEmpty()) {
                for(Barrel__c barrel : lstBarrel) {
                    barrelRecipeIds.add(barrel.Barrel_Recipe__c);
                }
            }
            for (Account_Barrel_Recipe__c abr : [select Id
                                                 , Name
                                                 , Account_Name__c
                                                 , Barrel_Recipe__c
                                                 , Account__r.Name from Account_Barrel_Recipe__c where Account__c = :accountId
                                                         AND Account_Name__c = :c.Retail_Account_Name__c
                                                                 AND Barrel_Recipe__r.Brand__c = :brand]) {
                barrelRecipeIds.add(abr.Barrel_Recipe__c);
                if (String.isBlank(abr.Account_Name__c)) {
                    accountName = abr.Account__r.Name;
                } else {
                    accountName = abr.Account_Name__c;
                }

            }
         
            for(Case cs : [select id,Type,Recent_Recipes_Selected__c from Case where Id =:Id.valueOf(caseId) limit 1]){
                cs.Recent_Recipes_Selected__c = true ;
                casetypelst.add(cs);
            }
            update casetypelst;
            List<Barrel_Recipe__c> recipes = [select Id, Name, Recipe_Label__c, Creation_Date__c, (select id, Quantity__c, Type__c from Staves__r) from Barrel_Recipe__c where Id IN :barrelRecipeIds];

            responseMap.put('recipes', recipes);
            responseMap.put('accountName', accountName);
            responseMap.put('caseStatus',c.Status);
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
    public static LightningComponentUtility.RequestStatus createBarrelRecord(String caseId, String brand, String recipe) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Barrel__c barrel = new Barrel__c();

        try {
            List<Barrel__c> existingBarrel = [select id, Barrel_Recipe__c from Barrel__c where Case__c = :String.valueOf(caseId)];
            if (!existingBarrel.isEmpty()) {
                barrel = existingBarrel[0];
                barrel.Barrel_Recipe__c = Id.valueOf(recipe);

            } else {
                barrel.Brand__c = brand;
                barrel.Barrel_Recipe__c = Id.valueOf(recipe);
                barrel.RecordTypeId = SBP_Constants.fullBarrelBrandRTIdMap.get(brand);
                barrel.Case__c = Id.valueOf(caseId);
            }

            upsert barrel;


            /**
            Case c = new Case();
            c.put('Id', Id.valueOf(caseId));
            c.Barrel_Selected__c = true;
            c.Type = 'Recent Recipes';
            update c;
            
*/
            Case c = [select id, Retail_Account__c, Retail_Account_Name__c, Brand__c, Barrel_Selected__c, Product_Type__c, AccountId, ContactId, Submitter__c, Related_Barrel_PO_Number__c,Type,Plant_Event__r.Scheduled_Date__c,Remote_Selection_Date__c,CreatedDate,Regional_Diplomat__c,Regional_Diplomat__r.Name,Heritage_Manager__c,CaseNumber,Submitter_Name__c,Barrel_Number__c,Submitter__r.Name,Retail_Account__r.Name,Retail_Account__r.State__c from Case where Id = :Id.valueOf(caseId)];
            c.Barrel_Selected__c = true;
            c.Type = 'Recent Recipes';
            update c;

            responseMap.put('barrelId', barrel.Id);
            responseMap.put('casetype', c.Type);
            List<Case> caseList = new List<Case>();
            caseList.add(c);
            if(c.Brand__c == 'Makers Mark'){
                SBP_MMPSBarrelFillSubcase.createSubCaseForBarrelReady(caseList);
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

    /**************************************************************************************************************
    Author:        Craig Austgen
    Company:       Slalom, LLC
    Description:
    Inputs:        recordId: case Id
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    7/2018      Craig Austgen       Initial Creation

    ***************************************************************************************************************/
    @AuraEnabled
    public static LightningComponentUtility.RequestStatus getCase(String recordId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        String state;

        try {
            Case c = [select Id, Barrel_Selected__c, Type, Brand__c,Remote_Selection_Date__c,IsDiplomat__c,Is_Heritage_Manager__c, Status from Case where Id = :Id.valueOf(recordId) limit 1];
            responseMap.put('barrelSelected', c.Barrel_Selected__c);
            responseMap.put('type', c.Type);
            responseMap.put('brand', c.Brand__c);
            responseMap.put('selDate', c.Remote_Selection_Date__c);
            responseMap.put('isdiplomat', c.IsDiplomat__c);
            responseMap.put('isHm', c.Is_Heritage_Manager__c);    
            responseMap.put('caseStatus', c.Status);
            Boolean p = isMochaPresent(recordId, c.Brand__c);
			if(p == true)
                responseMap.put('isRecipePresent', true);
            else
                responseMap.put('isRecipePresent', false);
            User u = getUserInfo();
            if(u!=null && u.User_Type__c !=null){
				responseMap.put('userType', u.User_Type__c);
                responseMap.put('profileName', u.Profile.Name);
            }
            else {
                responseMap.put('userType', 'None');
                responseMap.put('profileName', u.Profile.Name);
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




    @AuraEnabled
    public static LightningComponentUtility.RequestStatus createBarrelRecipe(String jsonRecipe, String caseId) {
        Boolean success = true;
        String message = null;
        Map<String, Object> responseMap = new Map<String, Object>();
        Map<String, Integer> staveNameToQuantity = new Map<String, Integer>();
        Map<String, Boolean> staveMatchMap = new Map<String, Boolean>();
        Barrel_Recipe__c matchingRecipe = new Barrel_Recipe__c();

        System.debug(jsonRecipe);
        List<Stave__c> staves = (List<Stave__c>)System.JSON.deserialize(jsonRecipe, List<Stave__c>.Class);

        // default stave match to false in order to find if a combination of staves already exists in the system
        for (Stave__c stave : staves) {
            staveNameToQuantity.put(stave.Type__c, Integer.valueOf(stave.Quantity__c));
            staveMatchMap.put(stave.Type__c, false);
        }

        try {
            Case c = [select id, Retail_Account__c, Retail_Account_Name__c, Brand__c, Barrel_Selected__c, Product_Type__c, AccountId, ContactId, Submitter__c, Related_Barrel_PO_Number__c,Type,Plant_Event__r.Scheduled_Date__c,Remote_Selection_Date__c,CreatedDate,Regional_Diplomat__c,Regional_Diplomat__r.Name,Heritage_Manager__c,CaseNumber,Submitter_Name__c,Barrel_Number__c,Submitter__r.Name,Retail_Account__r.Name,Retail_Account__r.State__c from Case where Id = :Id.valueOf(caseId)];
			System.debug('case is '+c);
            // search for all existing barrel recipes
            for (Barrel_Recipe__c recipe : [select id, (select Type__c, Quantity__c from Staves__r) from Barrel_Recipe__c where Brand__c = :c.Brand__c]) {
                // if the stave matches then flag it
                for (Stave__c stave : recipe.Staves__r) {
                    if (staveNameToQuantity.containsKey(stave.Type__c)) {
                        if (staveNameToQuantity.get(stave.Type__c) == stave.Quantity__c) {
                            staveMatchMap.put(stave.Type__c, true);
                        }
                    }
                }
                // loop through staves to see if a match was found
                for (Boolean staveMatch : staveMatchMap.values()) {
                    if (!staveMatch) {
                        matchingRecipe = null;
                        break;
                    } else {
                        matchingRecipe = recipe;
                    }
                }
                if (matchingRecipe != null) {
                    break;
                }
                // reset stave matches for next loop
                for (Stave__c stave : staves) {
                    staveMatchMap.put(stave.Type__c, false);
                }
            }
            // use existing recipe
            if (matchingRecipe == null) {
                matchingRecipe = createNewBarrelRecipe(c.Brand__c);
                List<Stave__c> newStaves = createStaves(staves, matchingRecipe);
            }
            Account_Barrel_Recipe__c abr = createNewAccountBarrelRecipe(c, matchingRecipe);
            List<Barrel__c> barrels = updateBarrelRecordWithStaveSelection(c, matchingRecipe);
            // update the case to show that the recipe has been selected
            c.Barrel_Selected__c = true;
            update c;

            responseMap.put('newRecipe', matchingRecipe);
            responseMap.put('staveMatchMap', staveMatchMap);
            responseMap.put('barrels', barrels);
            List<Case> caseList = new List<Case>();
            caseList.add(c);
            if(c.Brand__c == 'Makers Mark')
                SBP_MMPSBarrelFillSubcase.createSubCaseForBarrelReady(caseList);
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
            message = e.getMessage();
            message = message + '\n' + e.getStackTraceString();
            success = false;

        }


        LightningComponentUtility.RequestStatus requestStatus = new LightningComponentUtility.RequestStatus(success, message, responseMap);
        System.debug(LoggingLevel.INFO, requestStatus);
        return requestStatus;

    }
    public static Barrel_Recipe__c createNewBarrelRecipe(String brand) {
        Barrel_Recipe__c br = new Barrel_Recipe__c();
        br.Brand__c = brand;
        insert br;
        return br;
    }
    public static Account_Barrel_Recipe__c createNewAccountBarrelRecipe(Case c, Barrel_Recipe__c recipe) {
        Account_Barrel_Recipe__c abr = new Account_Barrel_Recipe__c();

        List<Account_Barrel_Recipe__c> abrs = [select id from Account_Barrel_Recipe__c where Barrel_Recipe__c = :recipe.Id limit 1];

        if (abrs.isEmpty()) {
            abr.Account__c = c.Retail_Account__c;
            abr.Account_Name__c = c.Retail_Account_Name__c;
            abr.Barrel_Recipe__c = recipe.Id;
            insert abr;
        } else {
            abr = abrs[0];
        }
        return abr;
    }

    public static List<Stave__c> createStaves(List<Stave__c> staves, Barrel_Recipe__c recipe) {
        for (Stave__c stave : staves) {
            stave.Barrel_Recipe__c = recipe.Id;
            stave.Name = stave.Type__c;
        }

        insert staves;
        return staves;
    }

    public static List<Barrel__c> updateBarrelRecordWithStaveSelection(Case c, Barrel_Recipe__c recipe) {
        List<Barrel__c> barrels = [select id, Barrel_Recipe__c from Barrel__c where Case__c = :c.Id];
        if (!barrels.isEmpty()) {
            barrels[0].Barrel_Recipe__c = recipe.Id;
            update barrels[0];

        } else {
            Barrel__c newBarrel = new Barrel__c();
            newBarrel.Brand__c = c.Brand__c;
            newBarrel.Barrel_Recipe__c = recipe.Id;
            newBarrel.RecordTypeId = SBP_Constants.fullBarrelBrandRTIdMap.get(c.Brand__c);
            newBarrel.Case__c = c.Id;

            insert newBarrel;
        }

        return barrels;
    }
            /*
Author:			Yash Jain
Company:		Metacube
Description:	it is used to get stave quantity

History
<Date>           <Authors Name>    <Brief Description of Change>
05,2021    Yash Jain       fetching stave quantity
*/
    @AuraEnabled 
    public static Map<String, Integer> getStaveQuantity(List<Single_Barrel_Stave_Setting__mdt> staveList,String recId){
        list<case> s = [select id,CaseNumber,ParentId,Retail_Account_Name__c from case where Id = : recId];
        list<case> m = [select id,CaseNumber,Retail_Account_Name__c from case where Id = : s[0].ParentId];
        list<Barrel_Recipe__c> k = new list<Barrel_Recipe__c>();
        Map<String, Integer> m1 = new Map<String, Integer>();
        list<Barrel__c> t = [select id,Barrel_Recipe__c from Barrel__c where Case__c = :m[0].Id];
        k = [select Baked_American_Pure_2__c, Maker_s_46__c, Mendiant__c, Roasted_French_Mocha__c, Seared_French_Cuvee__c, Toasted_French_Spice__c from Barrel_Recipe__c where id =:t[0].Barrel_Recipe__c];
        for(Single_Barrel_Stave_Setting__mdt j : staveList)
        {
            String staveName = j.Stave_Name__c;
            if(staveName == 'Baked American Pure 2')
            { 
                m1.put(staveName,Integer.valueOf(k[0].Baked_American_Pure_2__c));
            }
            if(staveName == 'Maker\'s 46')
            {
                m1.put(staveName,Integer.valueOf(k[0].Maker_s_46__c));
            }
            if(staveName == 'Mendiant')
            {
                m1.put(staveName,Integer.valueOf(k[0].Mendiant__c));
            }
            if(staveName == 'Roasted French Mocha')
            {
                m1.put(staveName,Integer.valueOf(k[0].Roasted_French_Mocha__c));
            }
            if(staveName == 'Seared French Cuvee')
            {
                m1.put(staveName,Integer.valueOf(k[0].Seared_French_Cuvee__c));
            }
            if(staveName == 'Toasted French Spice')
            {
                m1.put(staveName,Integer.valueOf(k[0].Toasted_French_Spice__c));
            }
        }
        return m1;
    }
         /**************************************************************************************************************
Author:			Yash Jain
Company:		Metacube
Description:	it is used to find if roasted mocha is present or not

History
<Date>           <Authors Name>    <Brief Description of Change>
05,2021    Yash Jain       finding roasted mocha status in past
**************************************************************************************************************/   
     @AuraEnabled
    public static Boolean isMochaPresent(String caseId, String brand) {
        Set<Id> barrelRecipeIds = new Set<Id>();
        String accountName;
        Id accountId;
        Boolean isRecipePresent = false;

        try {
            Case c = [select id, Retail_Account__c, Retail_Account_Name__c from Case where Id = :Id.valueOf(caseId) limit 1];
            accountId = c.Retail_Account__c;
            accountName = c.Retail_Account_Name__c;
            List<Barrel__c> lstBarrel = [SELECT Barrel_Recipe__c FROM Barrel__c WHERE Case__r.Retail_Account__c =: c.Retail_Account__c AND Barrel_Recipe__c != null];
            if(!lstBarrel.isEmpty()) {
                for(Barrel__c barrel : lstBarrel) {
                    barrelRecipeIds.add(barrel.Barrel_Recipe__c);
                }
            }
            for (Account_Barrel_Recipe__c abr : [select Id
                                                 , Name
                                                 , Account_Name__c
                                                 , Barrel_Recipe__c
                                                 , Account__r.Name from Account_Barrel_Recipe__c where Account__c = :accountId
                                                         AND Account_Name__c = :c.Retail_Account_Name__c
                                                                 AND Barrel_Recipe__r.Brand__c = :brand]) {
                barrelRecipeIds.add(abr.Barrel_Recipe__c);
                if (String.isBlank(abr.Account_Name__c)) {
                    accountName = abr.Account__r.Name;
                } else {
                    accountName = abr.Account_Name__c;
                }

            }
			
            List<Barrel_Recipe__c> recipes = [select Id, Name, Recipe_Label__c, Creation_Date__c, (select id, Quantity__c, Type__c from Staves__r) from Barrel_Recipe__c where Id IN :barrelRecipeIds];
            
            for(Barrel_Recipe__c b : recipes)
            {
                for(Stave__c s: b.Staves__r)
                {
         			if(s.Quantity__c >0 && s.Type__c == 'Roasted French Mocha')
                    {
                        isRecipePresent = true;
                        break;
                    }
                }
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.INFO, e.getMessage());
        }
        return isRecipePresent;
    }
          /**************************************************************************************************************
Author:			Yash Jain
Company:		Metacube
Description:	it is used to find user type of current user

History
<Date>           <Authors Name>    <Brief Description of Change>
05,2021    Yash Jain      finding user type of current user

Update
<Date>     <Authors Name>       <Brief Description of Change>
04,2024    Badri Vishal Soni     finding required details of current user
**************************************************************************************************************/  
    @AuraEnabled 
    public static User getUserInfo(){ 
        List<User> loggedInUser =  [Select Id,Profile.Name,User_Type__c from User where Id = :UserInfo.getUserId()];
        if(!loggedInUser.isEmpty())
            return loggedInUser[0];
        else
            return null;
    }

}