public class TestDataProgramCalendar {
 
    public program__c createPrograms(date startDate,date EndDate,id trritory, id brand,string channel,string pFocus,String pType,String funds){
        program__c newProgram= new Program__c();
        newProgram.StartDate__c=startDate;
        newProgram.EndDate__c=EndDate;
        newProgram.Territory__c=trritory;
        newProgram.Brand__c=brand;
        newProgram.Channel__c=channel;
        newProgram.FocusType__c=pFocus;
        newProgram.ProgrammingType__c=pType;
        newProgram.Funds__c=funds;
        
        return newProgram;
    }
    
    public void createCalendarSetting(){
        List<Calendar_Settings__c> lstCalSetting= new List<Calendar_Settings__c>();
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.BrandName__c', Field__c='BrandName__c',Object__c='Program__c',Type__c='Text',Label__c='Brand',JSON__c='BrandName__c',FilterBy__c=false,FilterOrder__c=3,SortBy__c=true,SortOrder__c=3)); 
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.Channel__c', Field__c='Channel__c',Object__c='Program__c',Type__c='Picklist',Label__c='Channel Type',JSON__c='Channel__c',FilterBy__c=true,FilterOrder__c=4,SortBy__c=true,SortOrder__c=4));    
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.FocusType__c', Field__c='FocusType__c',Object__c='Program__c',Type__c='Picklist',Label__c='Focus Type',JSON__c='FocusType__c',FilterBy__c=true,FilterOrder__c=7,SortBy__c=true,SortOrder__c=7)); 
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.Funds__c', Field__c='Funds__c',Object__c='Program__c',Type__c='Picklist',Label__c='Funds',JSON__c='Funds__c',FilterBy__c=true,FilterOrder__c=8,SortBy__c=true,SortOrder__c=8)); 
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.ProgramFocus__c', Field__c='ProgramFocus__c',Object__c='Program__c',Type__c='Picklist',Label__c='Program Focus',JSON__c='ProgramFocus__c',FilterBy__c=true,FilterOrder__c=5,SortBy__c=true,SortOrder__c=5));   
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.ProgrammingType__c', Field__c='ProgrammingType__c',Object__c='Program__c',Type__c='Picklist',Label__c='Program Type',JSON__c='ProgrammingType__c',FilterBy__c=true,FilterOrder__c=6,SortBy__c=true,SortOrder__c=6, GroupByDefault__c=true)); 
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.TerritoryName__c', Field__c='TerritoryName__c',Object__c='Program__c',Type__c='Text',Label__c='Territory',JSON__c='TerritoryName__c',FilterBy__c=true,FilterOrder__c=1,SortBy__c=true,SortOrder__c=2));   
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.Description__c', Field__c='Description__c',Object__c='Program__c',Type__c='Text',Label__c='Description',JSON__c='Description__c',SearchBy__c=true));                     
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.Name', Field__c='Name',Object__c='Program__c',Type__c='Text',Label__c='Name',JSON__c='Name',SearchBy__c=true));  
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.StartDate__c', Field__c='StartDate__c',Object__c='Program__c',Type__c='Date',Label__c='Start Date',JSON__c='StartDate__c',SortBy__c=true,SortOrder__c=0));
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.EndDate__c', Field__c='EndDate__c',Object__c='Program__c',Type__c='Date',Label__c='End Date',JSON__c='EndDate__c')); 
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.Owner.Name', Field__c='Owner.Name',Object__c='Program__c',Type__c='lookup',Label__c='Owner',JSON__c='Owner.Name'));                                   
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.DistributorName__c', Field__c='DistributorName__c',Object__c='Program__c',Type__c='Text',Label__c='Distributor Name',JSON__c='DistributorName__c'));                                                                                                                                                             
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.BrandObjective__c', Field__c='BrandObjective__c',Object__c='Program__c',Type__c='Picklist',Label__c='Brand Objective',JSON__c='BrandObjective__c'));                                                                                                                                                                                                                                                                                              
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.Parent__c', Field__c='Parent__r.Name',Object__c='Program__c',Type__c='lookup',Label__c='Parent Program',JSON__c='Parent'));   
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.BrandStrategy__c', Field__c='BrandStrategy__c',Object__c='Program__c',Type__c='Picklist',Label__c='Brand Strategy',JSON__c='BrandStrategy__c'));                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     
        lstCalSetting.add(new Calendar_Settings__c(Name='Program__c.BrandFamilyName__c', Field__c='BrandFamilyName__c',Object__c='Program__c',Type__c='Text',Label__c='Brand Family',JSON__c='BrandFamilyName__c',FilterBy__c=true,FilterOrder__c=3,SortBy__c=true,SortOrder__c=3, groupby__c=true,GroupOrder__c=3));
        insert lstCalSetting;
    
    }
    
    public void createCalendarValues(){
        List<Calendar_Values__c> lstCalVal= new List<Calendar_Values__c>();
        lstCalVal.add(new Calendar_Values__c(Name='Objective 2',Value__c='Objective 2',Setting__c='Program__c.BrandObjective__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Objective 3',Value__c='Objective 3',Setting__c='Program__c.BrandObjective__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Objective 4',Value__c='Objective 4',Setting__c='Program__c.BrandObjective__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Drive Awareness',Value__c='Objective 4',Setting__c='Program__c.BrandStrategy__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Strategy 2',Value__c='Strategy 2',Setting__c='Program__c.BrandStrategy__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Strategy 3',Value__c='Strategy 3',Setting__c='Program__c.BrandStrategy__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Non-Premise',Value__c='Non-Premise',Setting__c='Program__c.Channel__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Off Premise',Value__c='Off Premise',Setting__c='Program__c.Channel__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='On Premise',Value__c='On Premise',Setting__c='Program__c.Channel__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Core Priority',Value__c='Core Priority',Setting__c='Program__c.FocusType__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Program',Value__c='Program',Setting__c='Program__c.FocusType__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='EG',Value__c='EG',Setting__c='Program__c.Funds__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='BI',Value__c='BI',Setting__c='Program__c.Funds__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Distributor',Value__c='Distributor',Setting__c='Program__c.ProgramFocus__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Retailer',Value__c='Retailer',Setting__c='Program__c.ProgramFocus__c',IsData__c=false,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='Promotion',Value__c='Promotion',Setting__c='Program__c.ProgrammingType__c',IsData__c=false,Color_Code__c='#B50938'));
        lstCalVal.add(new Calendar_Values__c(Name='Other',Value__c='Other',Setting__c='Program__c.ProgrammingType__c',IsData__c=false,Color_Code__c='#66CCCC'));
        //lstCalVal.add(new Calendar_Values__c(Name='Alaska',Value__c='Alaska',Setting__c='Program__c.TerritoryName__c',IsData__c=true,Color_Code__c=''));
        lstCalVal.add(new Calendar_Values__c(Name='BrandFamily',Value__c='BrandFamily',Setting__c='Program__c.BrandFamilyName__c',IsData__c=true,Color_Code__c=''));
        //lstCalVal.add(new Calendar_Values__c(Name='Arizona',Value__c='Arizona',Setting__c='Program__c.TerritoryName__c',IsData__c=true,Color_Code__c=''));
        //lstCalVal.add(new Calendar_Values__c(Name='Minnesota',Value__c='Minnesota',Setting__c='Program__c.TerritoryName__c',IsData__c=true,Color_Code__c=''));
        //lstCalVal.add(new Calendar_Values__c(Name='Alabama',Value__c='Alabama',Setting__c='Program__c.TerritoryName__c',IsData__c=true,Color_Code__c=''));
        
        insert lstCalVal;
    
    } 
    
    public void createDistributorValues(){
       List<Calendar_Dependent_Values__c> lstCalDistVal= new List<Calendar_Dependent_Values__c>();
        lstCalDistVal.add(new Calendar_Dependent_Values__c(Name='SWineAK',Controlling_Value__c='Alaska', Value__c='SOUTHERN WINE & SPIRITS OF AK',Setting__c='Program__c.Distributor__c',Object__c='Account'));
        lstCalDistVal.add(new Calendar_Dependent_Values__c(Name='NoDistAK',Controlling_Value__c='Alaska', Value__c='*No Distributor',Setting__c='Program__c.Distributor__c',Object__c='Account'));
        lstCalDistVal.add(new Calendar_Dependent_Values__c(Name='NoDistAR',Controlling_Value__c='Arizona', Value__c='*No Distributor',Setting__c='Program__c.Distributor__c',Object__c='Account'));
        lstCalDistVal.add(new Calendar_Dependent_Values__c(Name='MOONAR',Controlling_Value__c='Arizona', Value__c='MOON DISTRIBUTING',Setting__c='Program__c.Distributor__c',Object__c='Account'));
        lstCalDistVal.add(new Calendar_Dependent_Values__c(Name='NoDistMS',Controlling_Value__c='Minnesota', Value__c='*No Distributor',Setting__c='Program__c.Distributor__c',Object__c='Account'));
        lstCalDistVal.add(new Calendar_Dependent_Values__c(Name='SUNNYMS',Controlling_Value__c='Minnesota', Value__c='SUNNY HILL DISTRIBUTORS',Setting__c='Program__c.Distributor__c',Object__c='Account'));
        
        insert lstCalDistVal;
    
    }  
    
    public List<Tags__c> createTerritory(){
       Id territoryRTypeId = Schema.SObjectType.Tags__c.getRecordTypeInfosByName().get('Territory').getRecordTypeId();  
       List<Tags__c> lstnewTerritory= new List<Tags__c>();
       lstnewTerritory.add(new Tags__c(Name='Alaska', recordTypeId=territoryRTypeId)); 
       lstnewTerritory.add(new Tags__c(Name='Arizona', recordTypeId=territoryRTypeId)); 
       lstnewTerritory.add(new Tags__c(Name='Minnesota', recordTypeId=territoryRTypeId)); 
       lstnewTerritory.add(new Tags__c(Name='Alabama', recordTypeId=territoryRTypeId)); 
       return lstnewTerritory;
       
       }
       
   public static List<Tags__c> createBrandFamily(){
       Id brandFamilyRTypeId = Schema.SObjectType.Tags__c.getRecordTypeInfosByName().get('Brand Family').getRecordTypeId();  
       List<Tags__c> lstnewBrandFamily= new List<Tags__c>();
       lstnewBrandFamily.add(new Tags__c(Name='Test Brand Family1', recordTypeId=brandFamilyRTypeId)); 
       
       insert lstnewBrandFamily;
       return lstnewBrandFamily;
       
       }
       
   public static List<Tags__c> createBrand(){
       Id brandRTypeId = Schema.SObjectType.Tags__c.getRecordTypeInfosByName().get('PL4 Brand').getRecordTypeId();  
       Id brandFamilyRTypeId = Schema.SObjectType.Tags__c.getRecordTypeInfosByName().get('Brand Family').getRecordTypeId();
       List<Tags__c> lstnewBrandfamily= new List<Tags__c>();
       lstnewBrandfamily.add(new Tags__c(Name='Test BrandFamily1', recordTypeId=brandFamilyRTypeId));
       insert lstnewBrandfamily;
       List<Tags__c> lstnewBrand= new List<Tags__c>();
       lstnewBrand.add(new Tags__c(Name='Test Brand1', recordTypeId=brandRTypeId, BrandFamily__c=lstnewBrandfamily[0].id,Active__c=true )); 
       
       return lstnewBrand;
       
       } 
       
    public void createDistributorAccount(Id territoryId){
        Id accountRTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();  
        List<Account> lstNewAcc= new List<Account>();
        for(integer i=0;i<10;i++){
            Account acc= new Account();
            acc.Name= 'Test Program Distributor'+ i;
            acc.recordtypeId= accountRTypeId ;
            acc.ProgramPartner__c=true;
            acc.TerritoryTag__c=territoryId;
            acc.Type= 'Distributor';
            lstNewAcc.add(acc);
        
        }   
        insert lstNewAcc;     
    }
    
}