/**************************************************************************************
Apex Class Name     : PRDetail_TriggerHandler
Created Date        : 06-Nov-2019
Auther              : Harikrishna P 
Function            : Handles events from the PRDetail_Trigger trigger
Test Class          : BS_PRDetail_Trigger_Test
Updates :
*************************************************************************************/

public class PRDetail_TriggerHandler{
    public static string startmonth='START_MONTH';
    public static string endmonth='END_MONTH';
    public static void handleBeforeInsert(List<PR_Detail__c> Trigger_New) {
        for(PR_Detail__c prd: Trigger_New){            
            if(prd.Cloned_From__c==null) prd.Unique_Key__c=prd.PR_Header__c+prd.Campaign_ID__c+prd.IOCode__c+prd.GL_Code2__c;
            prd.CurrencyIsoCode=prd.PR_Request_Currency__c;
        }
    }
    public static void handleAfterInsert(List<PR_Detail__c> Trigger_New) {
        //do nothing
    }
    public static void handleBeforeUpdate(List<PR_Detail__c> Trigger_New, Map<Id, PR_Detail__c> Trigger_oldMap) {
        list<PR_Detail__c> PR_Details_List_ToValidate=new list<PR_Detail__c>();
        set<string> PRIOCodes_Set=new set<string>();
        set<id> PRHeaderIds_Set=new set<id>();
        for(PR_Detail__c prd: Trigger_New){            
            if(prd.StartMonth__c!=null && !Trigger_oldMap.isEmpty() && Trigger_oldMap.get(prd.id).StartMonth__c!=prd.StartMonth__c){                
                prd.Start_Date__c=calculatelastDayOfMonth(integer.valueof(prd.StartMonth__c));
            }                
            if(prd.EndMonth__c!=null && !Trigger_oldMap.isEmpty() && Trigger_oldMap.get(prd.id).EndMonth__c!=prd.EndMonth__c){                
                //integer Start_Month_Value=integer.valueof(prd.StartMonth__c);
                integer End_Month_Value=integer.valueof(prd.EndMonth__c);                              
                prd.End_Date__c=calculatelastDayOfMonth(integer.valueof(End_Month_Value));
            }
            if(prd.GL_Code2__c!=null && !Trigger_oldMap.isEmpty() && Trigger_oldMap.get(prd.id).GL_Code2__c!=prd.GL_Code2__c){
                prd.Unique_Key__c=prd.PR_Header__c+prd.Campaign_ID__c+prd.IOCode__c+prd.GL_Code2__c;
            }
            if(prd.PR_Amount_USD__c!=null && prd.PR_Amount_USD__c>0 && !Trigger_oldMap.isEmpty() && 
               Trigger_oldMap.get(prd.id).PR_Amount_USD__c!=prd.PR_Amount_USD__c && Trigger_oldMap.get(prd.id).PR_Request_Currency__c==prd.PR_Request_Currency__c){
                PR_Details_List_ToValidate.add(prd);                
            }
        }
        if(PR_Details_List_ToValidate.size()>0) validateCloned_PR_CampaignBalance(PR_Details_List_ToValidate,Trigger_oldMap);
    }    
    
    public static date calculatelastDayOfMonth(integer monthNum){
        Integer year=(integer.valueof(monthNum)>12)? system.today().year()+1 : system.today().year();
        monthNum=(integer.valueof(monthNum)>12)? monthNum-12 : monthNum;
        Integer numberOfDays = Date.daysInMonth(year, monthNum);
        Date lastDayOfMonth = Date.newInstance(year,monthNum, numberOfDays);
        return lastDayOfMonth;
    }
    public static void handleAfterUpdate(List<PR_Detail__c> Trigger_New, Map<Id, PR_Detail__c> Trigger_oldMap) {
        list<PR_Detail__c> PR_Detail_Phasing=new list<PR_Detail__c>();
        list<PR_Detail__c> update_PhasingRecordsList=new list<PR_Detail__c>();
        for(PR_Detail__c prd: Trigger_New){
            if(prd.PR_Amount__c >0 && 
               (prd.StartMonth__c!=Trigger_oldMap.get(prd.id).StartMonth__c || 
                prd.EndMonth__c!=Trigger_oldMap.get(prd.id).EndMonth__c ||
                prd.PR_Amount_USD__c != Trigger_oldMap.get(prd.id).PR_Amount_USD__c ||
                prd.CurrencyIsoCode != Trigger_oldMap.get(prd.id).CurrencyIsoCode
               )
              ){
             	PR_Detail_Phasing.add(prd);
               }
            else if(prd.Phasing_Type__c=='Straight Line' && Trigger_oldMap.get(prd.id).Phasing_Type__c=='Monthly'){
                update_PhasingRecordsList.add(prd);
            }
        }
        system.debug('deletePhasingRecords...PR_Detail_Phasing,,,,,,,,::: '+PR_Detail_Phasing);
        if(PR_Detail_Phasing.size()>0){            
            deletePhasingRecords(PR_Detail_Phasing);           
        }
        if(update_PhasingRecordsList.size()>0){            
            createPhasingRecords(update_PhasingRecordsList);           
        }
    }
    
    public static void createPhasingRecords(list<PR_Detail__c> PR_Details){
        map<string,PR_Phasing__c> PR_Phasing_CreateMap=new map<string,PR_Phasing__c>();
        for(PR_Detail__c prd: PR_Details){
            system.debug('PR_Detail__c prd...'+prd);
            if(prd.StartMonth__c!=null && prd.EndMonth__c!=null && prd.PR_Amount__c!=null){
                integer Start_Month_Value=integer.valueof(prd.StartMonth__c);
                integer End_Month_Value=integer.valueof(prd.EndMonth__c);
                //if(End_Month_Value < Start_Month_Value) End_Month_Value=End_Month_Value+12;
                integer loopvar=End_Month_Value-Start_Month_Value+1;
                decimal avg_PR_Amount=(prd.PR_Amount__c/loopvar).setScale(2);
                system.debug('Start_Month_Value...'+Start_Month_Value+'....End_Month_Value.....'+End_Month_Value+'.....loopvar....'+loopvar+'.....avg_PR_Amount.....'+avg_PR_Amount);
                decimal sumAmount=0;                
                for(integer i=Start_Month_Value;i<=End_Month_Value;i++){                    
                    integer monthNum=(i>12)? i-12 : i;
                    integer actual_monthNum=i;
                    system.debug('BEFORE UPDATE:::'+'...monthNum...'+monthNum+'...loopvar..'+loopvar+'...sumAmount...'+sumAmount+'...avg_PR_Amount...'+avg_PR_Amount);
                    PR_Phasing__c ph=new PR_Phasing__c(
                        PR_Detail__c=prd.id
                        ,Month__c=string.valueOf(monthNum)
                        ,Phasing_Amount__c=avg_PR_Amount
                        ,Delivery_Date__c=calculatelastDayOfMonth(actual_monthNum)
                        ,Unique_ID__c=prd.id+string.valueOf(monthNum)
                        ,PR_Header__c=prd.PR_Header__c
                    );                    
                    if(loopvar==1) ph.Phasing_Amount__c=prd.PR_Amount__c-sumAmount;
                    loopvar--;
                    sumAmount+=avg_PR_Amount;
                    system.debug('AFTER UPDATE::::loopvar..'+loopvar+'...sumAmount...'+sumAmount+'...avg_PR_Amount...'+avg_PR_Amount+'....ph.Phasing_Amount__c...'+ph.Phasing_Amount__c);
                    PR_Phasing_CreateMap.put(ph.Unique_ID__c,ph);
                }
            }
        }
        system.debug('PR_Phasing_CreateList.......'+PR_Phasing_CreateMap);
        if(!PR_Phasing_CreateMap.isEmpty()){
            Schema.SObjectField f = PR_Phasing__c.Fields.Unique_ID__c;            
            Database.upsertResult [] upsertResultList = database.upsert(PR_Phasing_CreateMap.values(),f,false);
        }
    }    
    public static void deletePhasingRecords(list<PR_Detail__c> PR_Details){        
        try{            
            Delete [SELECT id FROM PR_Phasing__c WHERE PR_Detail__c IN: PR_Details];    
        }catch(system.DmlException ex){
            system.debug('exception in deletion of phasing records...'+ex);
        }        
        createPhasingRecords(PR_Details);        
    }
	public static void handlebeforeDelete(Map<Id, PR_Detail__c> Trigger_oldMap) {
        try{            
            Delete [SELECT id FROM PR_Phasing__c WHERE PR_Detail__c IN: Trigger_oldMap.keyset()];    
        }catch(system.DmlException ex){
            system.debug('exception in deletion...'+ex);
        }
    }
    
    public static void validateCloned_PR_CampaignBalance(list<PR_Detail__c> PR_Details_List,Map<Id, PR_Detail__c> Trigger_oldMap){        
		for(PR_Detail__c prd:PR_Details_List){
			List<AggregateResult> groupedResults =new List<AggregateResult>();
            try{
                groupedResults=[SELECT count(id),sum(PR_Amount_USD__c) pramt FROM PR_Detail__c 
                                  WHERE PR_Header__c=:prd.PR_Header__c AND IOCode__c=:prd.IOCode__c 
                                  GROUP BY IOCode__c HAVING count(id)>1];
            }catch(exception e){
                system.debug('validateCloned_PR_CampaignBalance...AggregateResult....Exception....'+e);
            }
            if(groupedResults.size()>0){
            	decimal PR_AmountUSD=prd.PR_Amount_USD__c==null? 0:prd.PR_Amount_USD__c;
                decimal PR_AmountUSD_PriorVal=Trigger_oldMap.get(prd.id).PR_Amount_USD__c==null? 0:Trigger_oldMap.get(prd.id).PR_Amount_USD__c;
                decimal agg_PR_Amount=(Decimal)groupedResults[0].get('pramt')==null? 0:(Decimal)groupedResults[0].get('pramt');
                if(prd.Campaign_Balance_USD__c<(PR_AmountUSD+agg_PR_Amount-PR_AmountUSD_PriorVal)){					
                    prd.PR_Amount__c.addError('Sum of cloned PR Detail records Amount must be less than Campaign Balance.');
                }    
            }            
		}
    }
}