public with sharing class CalendarController{ 
    public String viewVal { get; set; } {viewVal='1';}
    public transient String objJSON { get; set; } {objJSON='{}';}
    public String selectedSortVal { get; set; }    
    public String selectedGroupVal { get; set; } 
    public Map<string,Calendar_Settings__c> programCalendarMap;
    public Map<string,string> apliLabelMap{get;set;} {apliLabelMap = new Map<string,string>();}
    public map<string,string> programTypeMap;
    public String monthStart { get; set; }
    public String monthEnd { get; set; }
    public String yearStart { get; set; }
    public String yearEnd { get; set; }
    public String startQuarter ;
    public String endQuarter ;
    public Map<Integer,String> monthMap = new Map<Integer,String>();
    public integer currQuarter{get;set;} {currQuarter = ((System.today().month()-1) / 3 + 1);}
    public integer currentYear{get;set;} {currentYear = System.today().year();} 
    public List<string> searchFields{get;set;} {searchFields=new List<string>();}
    public list<Calendar_View__c> calendarViewRecord;
    public user userRecord;
    public string filterJSONString {get;set;}
    public string userJson{get;set;}
    public string filterString{get;set;}
    public string errLabel{get;set;}
    public string myViewJSON{get;set;} {myViewJSON='{}';}
    public string ReportStartDate {get;set;}
    public string ReportEndDate {get;set;}
    public String UserViewJson{get;set;}
    public String delViewId{get;set;}
    public String delViewResult{get;set;} {delViewResult = 'undefined';}
    List<Calendar_Dependent_Values__c> dependendLst;
    public list<SelectOption> groupByItem{get;set;}
    public list<SelectOption> sortByItem{get;set;}
    private string defaultSortBy='';
    public string errorText{get;set;}

    /*This method provides report start and end date during export*/
    @testvisible private void reportDateUpdate(){
        if(viewVal=='1'){
            ReportStartDate =(date.valueOf(yearStart)).format();  
            ReportEndDate =((date.valueOf(yearEnd)).addMonths(-1)).format();  
            system.debug('@yearStart'+yearStart);
         }
         else if(viewVal=='2'){
             ReportStartDate =(date.valueOf(startQuarter)).format();
             ReportEndDate =(date.valueOf(endQuarter)).format();
             system.debug('@startQuarter'+startQuarter);
         }
         else{
             ReportStartDate =(date.valueOf(monthStart)).format();
             ReportEndDate =(date.valueOf(monthEnd).addDays(-1)).format();
             system.debug('@monthStart'+monthStart);
         }    
  
         system.debug('@ReportStartDate '+ReportStartDate +'@ReportEndDate'+ReportEndDate );
    }
    
    /*This period prepares the time frame label*/
    public String getperiod (){
        String timePeriod;
        if (viewVal=='1'){
                timePeriod = 'January '+yearStart.substring(0,4)+' - December '+yearStart.substring(0,4);
        }
        else if(viewVal=='3'){
                timePeriod = monthMap.get(Date.valueOf(monthStart).month())+' '+ String.valueOf(Date.valueOf(monthStart).year()).substring(0,4);
        }
        else if(viewVal=='2'){
                if(currQuarter == 1){
                        timePeriod = 'January '+String.valueOf(currentYear).substring(0,4)+' - March '+String.valueOf(currentYear).substring(0,4);
                }
                else if(currQuarter == 2){
                        timePeriod = 'April '+String.valueOf(currentYear).substring(0,4)+' - June '+String.valueOf(currentYear).substring(0,4);
                }
                else if(currQuarter == 3){
                        timePeriod = 'July '+String.valueOf(currentYear).substring(0,4)+' - September '+String.valueOf(currentYear).substring(0,4);
                }
                else{
                        timePeriod = 'October '+String.valueOf(currentYear).substring(0,4)+' - December '+String.valueOf(currentYear).substring(0,4);
                }
        }
        return timePeriod;
    }
    
    /*This method prepares the start date of a querter*/
    public String getquarterStart(){
        String startDateQuarter;
        if(currQuarter == 1){
            startDateQuarter = String.valueOf(Date.newInstance(currentYear , 01, 01));
        }
        else if(currQuarter == 2){
            startDateQuarter = String.valueOf(Date.newInstance(currentYear , 04, 01));
        }
        else if(currQuarter == 3){
            startDateQuarter = String.valueOf(Date.newInstance(currentYear , 07, 01));
        }
        else{
            startDateQuarter = String.valueOf(Date.newInstance(currentYear , 10, 01));
        }
        startQuarter=startDateQuarter ;
        system.debug('@'+startDateQuarter );
        return startDateQuarter;
    }
    
    /*This method prepares the end date of a querter*/
    public String getquarterEnd(){
        String endDateQuarter;
        if(currQuarter == 1){
            endDateQuarter = String.valueOf(Date.newInstance(currentYear , 03, 31));
        }
        else if(currQuarter == 2){
            endDateQuarter = String.valueOf(Date.newInstance(currentYear , 06, 30));
        }
        else if(currQuarter == 3){
            endDateQuarter = String.valueOf(Date.newInstance(currentYear , 09, 30));
        }
        else{
            endDateQuarter = String.valueOf(Date.newInstance(currentYear , 12, 31));
        }
        system.debug('@'+endDateQuarter );
        endQuarter=endDateQuarter ;
        return endDateQuarter;
    }
    
    /* This method will return color map for programs*/
    public String getColorMap() {
        string cmap = '{}';
        if( programTypeMap!=null && programTypeMap.size()>0 ){
            cmap = JSON.serialize(programTypeMap);
        }
        return cmap;
    }
    
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('1','Year'));
        options.add(new SelectOption('2','Quarter'));
        options.add(new SelectOption('3','Month'));
        return options;
    }

    
    
    /* This Method will show the Sort By Picklist Values by fetching it from Program Calendar Settings Custom settings */
    public List<SelectOption> populateSortItems() {
        sortByItem= new List<SelectOption>();
        List<integer> sortMapLst= new List<integer>();
        Map<integer, string> sortByOrdermap= new Map<integer,string>();
        for(string calendraSettings: ProgramCalendarMap.keyset()){
                if(programCalendarMap.get(calendraSettings).SortBy__c==true){
                        sortByOrdermap.put(Integer.valueOf(ProgramCalendarMap.get(calendraSettings).SortOrder__c),ProgramCalendarMap.get(calendraSettings).Label__c);
                }
        }
        sortMapLst.addall(sortByOrdermap.keyset());
        sortMapLst.sort();
        
        for(Integer key: sortMapLst){
            sortByItem.add(new SelectOption(apliLabelMap.get(sortByOrdermap.get(key)),sortByOrdermap.get(key)));       
        }  
        selectedSortVal =apliLabelMap.get(sortByOrdermap.get(0));
        return sortByItem;
    }
    
     public List<SelectOption> populateGroupByItem(){
        groupByItem= new List<SelectOption>();
        List<integer> sortMapLst= new List<integer>();
        Map<integer, string> groupByOrdermap= new Map<integer,string>();
        groupByItem.add(new SelectOption('none','None'));
        for(string calendraSettings: ProgramCalendarMap.keyset()){
        
            if(programCalendarMap.get(calendraSettings).SortBy__c==true){
                 groupByOrdermap.put(Integer.valueOf(ProgramCalendarMap.get(calendraSettings).GroupOrder__c),ProgramCalendarMap.get(calendraSettings).Label__c); 
            }
            if(ProgramCalendarMap.get(calendraSettings).GroupByDefault__c==true){
                
                selectedGroupVal=ProgramCalendarMap.get(calendraSettings).JSON__c;
                system.debug('inside default '+selectedGroupVal);
            }
        }
        sortMapLst.addall(groupByOrdermap.keyset());
        sortMapLst.sort();
        for(Integer key: sortMapLst){
            groupByItem.add(new SelectOption(apliLabelMap.get(groupByOrdermap.get(key)),groupByOrdermap.get(key)));       
        }  
        system.debug('@@ groupByItem '+groupByItem);
        return groupByItem;
    }
    
    public Integer getMonthName() {
        system.debug('@@Date.valueOf(monthStart)'+ Date.valueOf(monthStart).month());
        return Date.valueOf(monthStart).month();
    }
        
        
    /*Constructor*/
    public CalendarController()
    {
        programCalendarMap= Calendar_Settings__c.getall();
        dependendLst= Calendar_Dependent_Values__c.getall().values();

        monthMap.put(1,'January');
        monthMap.put(2,'February');
        monthMap.put(3,'March');
        monthMap.put(4,'April');
        monthMap.put(5,'May');
        monthMap.put(6,'June');
        monthMap.put(7,'July');
        monthMap.put(8,'August');
        monthMap.put(9,'September');
        monthMap.put(10,'October');
        monthMap.put(11,'November');
        monthMap.put(12,'December');
        
        Date thisDay = System.today();
        monthStart = String.valueOf(thisDay.toStartOfMonth());
        monthEnd = String.valueOf(thisDay.toStartOfMonth().addMonths(1));
        system.debug('@@@ monthStart '+monthStart + '@@@ monthEnd '+monthEnd );
        
        yearStart =  String.valueOf(Date.newInstance(currentYear , 01, 01));
        yearEnd =  String.valueOf(Date.newInstance(currentYear , 12, 31).addMonths(1));
        
        getquarterEnd();
        getquarterStart();
        
                
        system.debug('@@@ currentQtr '+currQuarter +'@currentYear'+currentYear+'@yearStart'+yearStart +'@yearEnd'+yearEnd );
        
        for(Calendar_Settings__c p : programCalendarMap.values()){
            if(p.SearchBy__c){
                searchFields.add(p.JSON__c);
            }
        }
        calendarViewRecord=[select id,Type__c,User__c,Calendar_Setting__c,Filter_Query__c from Calendar_View__c where User__c=:userinfo.getuserId() and Is_Default__c=true];
        userRecord=[select id, firstName, LastName from User where id=:userinfo.getUserid()];
      
        
        getFinalFilterValues();
        populateSortItems();
        populateGroupByItem(); 
        if(calendarViewRecord!=null && !calendarViewRecord.isEmpty()){
            if(calendarViewRecord[0].Filter_Query__c!=null && calendarViewRecord[0].Filter_Query__c!=''){
                filterstring=calendarViewRecord[0].Filter_Query__c;
                myViewJSON=calendarViewRecord[0].Calendar_Setting__c;
                getPrograms();
            }
        }  
        getUserView();  
       
         
        
    }   
  
    /*This Method changes the calendar timeframe in forward direction.*/
    public pagereference nextView(){
        if(viewVal=='3'){
            monthStart = String.valueOf(Date.valueOf(monthStart).addMonths(1));
            monthEnd = String.valueOf(Date.valueOf(monthEnd).addMonths(1).toStartOfMonth());        
            currentYear=(Date.valueOf(monthStart)).year();         
            system.debug('@@monthStart '+monthStart );
        }
        else if(viewVal=='1'){                    
            yearStart = String.valueOf(Date.valueOf(yearStart).addYears(1));
            yearEnd =  String.valueOf(Date.valueOf(yearEnd).addYears(1));
            system.debug(yearEnd+'### year next'+yearstart); 
            currentYear=(Date.valueOf(yearStart)).year();               
        }
        else{           
            if (currQuarter!=4){
                currQuarter++;
            }
            else{
                currQuarter = 1;
                currentYear++;
            }
            getquarterStart();
            getquarterEnd();
        }
        getPrograms();
        return null;
    }

    /*This Method changes the calendar timeframe in backward direction.*/
    public pagereference previousView(){
        if(viewVal=='3'){
            monthStart = String.valueOf(Date.valueOf(monthStart).addMonths(-1));
            monthEnd = String.valueOf(Date.valueOf(monthEnd).addMonths(-1).toStartOfMonth()); 
            currentYear=(Date.valueOf(monthStart)).year();             
        }
        else if(viewVal=='1'){            
            yearStart = String.valueOf(Date.valueOf(yearStart).addYears(-1));
            yearEnd =  String.valueOf(Date.valueOf(yearEnd).addYears(-1));
            system.debug(yearEnd+'### year previos'+yearstart);   
            currentYear=(Date.valueOf(yearStart)).year();        
        }
        else {           
            if (currQuarter!=1){
                currQuarter--;
            }
            else{
                currQuarter = 4;
                currentYear--;
            }
            getquarterStart();
            getquarterEnd();
        }
        getPrograms();
        return null;
    }
    
    public void getPrograms(){
        objJSON  = '{}';
        errorText='';
        reportDateUpdate();
        Integer rowLimit = Integer.valueOf(Label.CalendarDataLimit);
        Integer countRowLimit = rowLimit+1;
        
        if( filterstring!=null ){
                        transient List<Object> records = new List<Object>();
                        string programStartdate ;
                        string programEnddate ;
                        string queryCampaign = 'SELECT Id';
                        system.debug('@@filterString'+filterString);
                           
                        Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe(); 
                        Schema.SObjectType objType = globalDescribe.get('Program__c');
                   
                        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                        Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();                
                        for(Calendar_Settings__c p : programCalendarMap.values()){
                                if(p.Object__c=='Program__c' && fieldMap.containsKey(p.field__c) && p.JSON__c!='Parent' && p.JSON__c!='Owner.Name'){                       
                                                queryCampaign = queryCampaign+','+p.field__c;                       
                                }
                        }
                        
                        if(viewVal=='1'){
                                programStartdate= string.valueOf(yearstart).split(' ')[0];
                                programEnddate=string.valueOf(Date.valueof(yearEnd).addmonths(-1)).split(' ')[0];
                                currentYear=(Date.valueOf(yearstart)).year();            
                        }
                        if(viewVal=='2'){
                                programStartdate= string.valueOf(startQuarter).split(' ')[0];
                                programEnddate=string.valueOf(Date.valueOf(endQuarter)).split(' ')[0];     
                                currentYear=(Date.valueOf(startQuarter)).year();
                                             
                        }
                        if(viewVal=='3'){
                                programStartdate= string.valueOf(monthStart).split(' ')[0];
                                programEnddate=string.valueOf(Date.valueOf(monthEnd).addDays(-1)).split(' ')[0];
                                currentYear=(Date.valueOf(monthStart)).year(); 
                        }
                        system.debug('@programStartdate'+programStartdate+'@programEnddate'+programEnddate);
                        String querLimit = Label.CalendarDataLimitExceed;
                        
                        String queryString = 'SELECT count() FROM Program__c WHERE  ((StartDate__c>='+programStartdate +' and StartDate__c<='+programEnddate+ ') OR ( EndDate__c>='+programStartdate+' and EndDate__c<='+programEnddate+') OR ( StartDate__c<='+programStartdate+' and EndDate__c>='+programEnddate+')) '+filterString+' LIMIT '+String.valueOf(countRowLimit);
                        system.debug('@@@@queryString'+queryString );
                        Integer countLimit = Database.countQuery(queryString);
                        system.debug('@@@@countLimit '+countLimit );
                        if(countLimit>rowLimit){
                                //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING, (Label.CalendarDataLimitExceed+' '+String.valueOf(rowLimit) +'.')));
                                errorText=Label.CalendarDataLimitExceed+' '+String.valueOf(rowLimit) +'.';
                                system.debug('@@@@countLimit '+countLimit );
                        }
                        
                        else{
                                queryCampaign = queryCampaign +',Owner_Name__c,RecordTypeName__c,SpendDescription__c,Budget__c,DistributorQuotaDetails__c,Duration__c,CreatedByName__c,LastModifiedByName__c,Related_Priority__c,YTDActual__c FROM Program__c where  ((StartDate__c>='+programStartdate +' and StartDate__c<='+programEnddate+ ') OR ( EndDate__c>='+programStartdate+' and EndDate__c<='+programEnddate+') OR ( StartDate__c<='+programStartdate+' and EndDate__c>='+programEnddate+')) '+filterString+  ' order by '+selectedSortVal +' limit  '+String.valueOf(rowLimit);
                                system.debug('@@@@queryCampaign'+queryCampaign );
                                
                                records =  Database.Query(queryCampaign);
                                system.debug('@@records'+records.size());
                                
                                if(records.size() > 0 ){
                                        objJSON  = JSON.serialize(records);
                                }
                        }
        }
        system.debug('@@objJSON  '+objJSON  );
    }
    
   
    
    /*This method fetches the error message from custom label to show in apex page message*/
    public void errorMessage(){
        String errorTxt;
        if(errLabel=='ReportURLError'){
            errorTxt = Label.ReportURLError;
        }
        else if(errLabel=='SearchStringError'){
            errorTxt = Label.SearchStringError;
        }
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,errorTxt ));
        system.debug('@@@@ in errormessage ');
    }
   
    /*This method saves user specific calendar views */
    public void saveview(){
       system.debug('@@@ UserViewJson :'+UserViewJson);
 
       List<Calendar_View__c> deserializelst= new List<Calendar_View__c>();
       deserializelst=(List<Calendar_View__c>)JSON.deserialize(UserViewJson,List<Calendar_View__c>.class );
        system.debug('@@@ deserialize'+ deserializelst );
        List<Calendar_View__c> finalUpdateView= new List<Calendar_View__c>();
        for(Calendar_View__c view: deserializelst){
            system.debug('printing ID :' + view.Id);
            Calendar_View__c updateView= new Calendar_View__c();
            updateView.Name=view.Name;
            updateView.Calendar_Setting__c=view.Calendar_Setting__c;
            updateView.Filter_Query__c=view.Filter_Query__c;
            if(string.valueof(view.Id)!='newlyCreated'){
                //system.debug('Inside if newly created');
                updateView.Id=view.Id;
            }
            updateView.Is_Default__c=View.Is_Default__c;
            updateView.User__c=userinfo.getUserid();
            finalUpdateView.add(updateView);
           }
    
    
        if(finalUpdateView.size()>0){
            upsert finalUpdateView id;
            getUserView();
        } 
    }
        
    /*This method fetches calendar views if the user has any calendar view */
    public void getSavedViewForUser(){
        List<Calendar_View__c> calendarMyViewRecord=[select id,Type__c,User__c,Calendar_Setting__c,Filter_Query__c from Calendar_View__c where User__c=:userinfo.getuserId()];
        if(calendarMyViewRecord!=null && !calendarMyViewRecord.isEmpty()){
            filterstring=calendarMyViewRecord[0].Filter_Query__c;
            myViewJSON=calendarMyViewRecord[0].Calendar_Setting__c;
            system.debug('@@myViewJSON'+myViewJSON);
            getPrograms();
        }    
    }
    
    /*This method prepares the filter JSON in initial page load */
    public void getFinalFilterValues(){
        List<Calendar_Values__c> filterValuelst= Calendar_Values__c.getall().values();
        List<Calendar_Dependent_Values__c> ditributorLst= Calendar_Dependent_Values__c.getall().values();
        
        Map<string,Calendar_Settings__c> programCalendarMap= Calendar_Settings__c.getall();
        Map<Integer,Calendar_Settings__c> filterbyOrderMap= new Map<Integer,Calendar_Settings__c>();
        Map<string,List<string>> filterValueMap= new  Map<string,List<string>>();
        List<Integer> sortMaplst = new list<Integer>();
        Map<string,List<string>> territoryDistributorMap=getDistributorVal();
        Map<string,List<string>> brandfamilyMap=getBrandFamilyVal();
        List<FilterWrapper> finalFilterList= new List<FilterWrapper>();
        apliLabelMap= new  Map<string,string>();
        programTypeMap= new Map<string,string>();
        for(string calendraSettings: ProgramCalendarMap.keyset()){
            if(programCalendarMap.get(calendraSettings).FilterBy__c==true){
                filterbyOrderMap.put(Integer.valueOf(programCalendarMap.get(calendraSettings).FilterOrder__c),programCalendarMap.get(calendraSettings));
            }
            apliLabelMap.put(programCalendarMap.get(calendraSettings).Label__c, programCalendarMap.get(calendraSettings).JSON__c); 
        }

        for(Calendar_Values__c pVal: filterValuelst){
            if(filterValueMap.get(pVal.Setting__c)!=null){
                filterValueMap.get(pVal.Setting__c).add(pVal.Value__c);
            }
            else{
                List<string> valList= new List<string>();
                valList.add(pVal.Value__c);
                filterValueMap.put(pVal.Setting__c,valList);
            }
            if(pVal.Color_Code__c!='' && pVal.Color_Code__c!=null){
                programTypeMap.put(pVal.Value__c,pVal.Color_Code__c);
            }
        }
        
        sortMaplst.addall(filterbyOrderMap.keyset());
        sortMaplst.sort();
        
        for(Integer intg:sortMaplst){
            if(filterbyOrderMap.get(intg).Label__c=='Territory'){
                FilterWrapper territoryWrapper= new FilterWrapper();
                territoryWrapper.header= 'Territory';
                territoryWrapper.depthCrawl=true;
                territoryWrapper.apiName=apliLabelMap.get(filterbyOrderMap.get(intg).Label__c);
                territoryWrapper.value=false;
                territoryWrapper.fieldID='Territory';
                List<FilterWrapper> territoryList= new List<FilterWrapper>();
                List<string> sortFilter= new List<string>();
                sortFilter.addall(filterValueMap.get(filterbyOrderMap.get(intg).Name));
                sortFilter.sort();
        
                for(string filVal: sortFilter){
                    FilterWrapper territoryVal= new FilterWrapper();
                    territoryVal.header= filVal;
                    territoryVal.depthCrawl=false;
                    territoryVal.apiName=apliLabelMap.get(filterbyOrderMap.get(intg).Label__c);
                    territoryVal.value=false;                    
                    territoryVal.fieldID='Territory'+removeSplChar(filVal).replaceAll( '\\s+', '');
                    List<FilterWrapper> distributorList= new List<FilterWrapper>();
                   
                    if(territoryDistributorMap.get(filVal)!=null){                        
                        for(string distrVal: territoryDistributorMap.get(filVal)){                            
                            FilterWrapper distributorVal= new FilterWrapper();
                            distributorVal.header= distrVal;
                            distributorVal.depthCrawl=false;
                            distributorVal.childElements=null;
                            distributorVal.apiName='DistributorName__c';
                            distributorVal.value=false;
                            distributorVal.fieldID=removeSplChar(filVal).replaceAll( '\\s+', '')+removeSplChar(distrVal).replaceAll( '\\s+', '');
                            distributorList.add(distributorVal);
                        }                        
                    }
                    else{
                        FilterWrapper distributorVal= new FilterWrapper();
                        distributorVal.header= '*No Distributor';
                        distributorVal.depthCrawl=false;
                        distributorVal.childElements=null;
                        distributorVal.apiName='DistributorName__c';
                        distributorVal.value=false;
                        distributorVal.fieldID=removeSplChar(filVal).replaceAll( '\\s+', '')+removeSplChar('*No Distributor').replaceAll( '\\s+', '');
                        distributorList.add(distributorVal);
                    }
                    territoryVal.childElements=distributorList;
                    territoryList.add(territoryVal);
                }
                territoryWrapper.childElements=territoryList;
                finalFilterList.add(territoryWrapper);
            }
            else if(filterbyOrderMap.get(intg).Label__c=='Brand Family'){
                FilterWrapper brandfamilyWrapper= new FilterWrapper();
                brandfamilyWrapper.header= 'Brand Family';
                brandfamilyWrapper.depthCrawl=true;
                brandfamilyWrapper.apiName=apliLabelMap.get(filterbyOrderMap.get(intg).Label__c);
                brandfamilyWrapper.value=false;
                brandfamilyWrapper.fieldID='BrandFamily';
                List<FilterWrapper> brandFamilyList= new List<FilterWrapper>();
                List<string> sortFilter= new List<string>();
                sortFilter.addall(filterValueMap.get(filterbyOrderMap.get(intg).Name));
                sortFilter.sort();
                for(string filVal: sortFilter){
                    if(brandfamilyMap.get(filVal)!=null){
                        FilterWrapper brandFamilyVal= new FilterWrapper();
                        brandFamilyVal.header= filVal;
                        brandFamilyVal.depthCrawl=false;
                        brandFamilyVal.apiName=apliLabelMap.get(filterbyOrderMap.get(intg).Label__c);
                        brandFamilyVal.value=false;                    
                        brandFamilyVal.fieldID='BrandFamily'+removeSplChar(filVal).replaceAll( '\\s+', '');
                        List<FilterWrapper> brandList= new List<FilterWrapper>();
                       
                        //if(brandfamilyMap.get(filVal)!=null){                        
                            for(string pl4BrandVal: brandfamilyMap.get(filVal)){                            
                                FilterWrapper brandVal= new FilterWrapper();
                                brandVal.header= pl4BrandVal;
                                brandVal.depthCrawl=false;
                                brandVal.childElements=null;
                                brandVal.apiName='BrandFamilyName__c';
                                brandVal.value=false;
                                brandVal.fieldID=removeSplChar(filVal).replaceAll( '\\s+', '')+removeSplChar(pl4BrandVal).replaceAll( '\\s+', '');
                                brandList.add(brandVal);
                            }                        
                       // }
                        brandFamilyVal.childElements=brandList;
                        brandFamilyList.add(brandFamilyVal);
                    }    
                }
                brandfamilyWrapper.childElements=brandFamilyList;
                finalFilterList.add(brandfamilyWrapper);    
                
             }
            else{
                FilterWrapper wrapObj= new FilterWrapper();
                wrapObj.header= filterbyOrderMap.get(intg).Label__c;
                wrapObj.depthCrawl=false;
                wrapObj.apiName=apliLabelMap.get(filterbyOrderMap.get(intg).Label__c);
                wrapObj.value=false;
                wrapObj.fieldID=removeSplChar((apliLabelMap.get(filterbyOrderMap.get(intg).Label__c))).replaceAll( '\\s+', '');
                List<FilterWrapper> elementList= new List<FilterWrapper>();
                system.debug('child element '+ filterValueMap.get(filterbyOrderMap.get(intg).Name));
                List<string> sortFilter= new List<string>();
                sortFilter.addall(filterValueMap.get(filterbyOrderMap.get(intg).Name));
                sortFilter.sort();
                for(string filVal: sortFilter){ 
                    FilterWrapper elementVal= new FilterWrapper();
                    elementVal.header= filVal;
                    elementVal.depthCrawl=false;
                    elementVal.apiName=apliLabelMap.get(filterbyOrderMap.get(intg).Label__c);
                    elementVal.value=false;
                    elementVal.fieldID=removeSplChar((filterbyOrderMap.get(intg).Label__c)).replaceAll( '\\s+', '')+removeSplChar(filVal).replaceAll( '\\s+', '');
                    elementList.add(elementVal);
                }
                wrapObj.childElements=elementList;
                finalFilterList.add(wrapObj);
            }      
        }
        filterJSONString = JSON.serializePretty(finalFilterList);
    }
    
    /*This method fetcehes distributor values from custom settings "Calendar_Dependent_Values__c" */
    public Map<string,List<string>> getDistributorVal(){
        Map<string,List<string>>territoryDistributorMap= new Map<string,List<string>>();
        //set<string> territorySet= new set<string>();      
       
        for(Calendar_Dependent_Values__c distributor: dependendLst){
            if(distributor.Object__c=='Account'){
                //territorySet.add(distributor.Controlling_Value__c);
                if(territoryDistributorMap.get(distributor.Controlling_Value__c)!=null){
                    territoryDistributorMap.get(distributor.Controlling_Value__c).add(distributor.Value__c);
                }
                else{
                    List<string> distributorNameLst= new List<string>();
                    distributorNameLst.add(distributor.Value__c);
                    territoryDistributorMap.put(distributor.Controlling_Value__c,distributorNameLst);        
                }
            }    
        }
        return territoryDistributorMap;
    }
    
     
    /*This method fetcehes Brand Family values from custom settings "Calendar_Dependent_Values__c" */
    public Map<string,List<string>> getBrandFamilyVal(){
        Map<string,List<string>> brandfamilyMap= new Map<string,List<string>>();
       
        for(Calendar_Dependent_Values__c brandFamily: dependendLst){
            if(brandFamily.Object__c=='Tags__c'){
               
                if(brandfamilyMap.get(brandFamily.Controlling_Value__c)!=null){
                    brandfamilyMap.get(brandFamily.Controlling_Value__c).add(brandFamily.Value__c);
                }
                else{
                    List<string> brandNameLst= new List<string>();
                    brandNameLst.add(brandFamily.Value__c);
                    brandfamilyMap.put(brandFamily.Controlling_Value__c,brandNameLst);        
                }
            }    
        }
        return brandfamilyMap;
    }
    
    /*This is a helper method for "getFinalFilterValues" method to remove some special character from string */
    public string removeSplChar(string val){
        string valString=val;
        String result = valString.replaceAll('[.(),/&*#\']','');
        return result ;
    }
    
        public void getUserView(){
                List<Calendar_View__c> viewRecords=[select name,id,Calendar_Setting__c,Filter_Query__c,User__c,is_default__c from Calendar_View__c where User__c=:userinfo.getuserId()];
                UserViewJson= JSON.Serialize(viewRecords);
                system.debug('@@@@ UserViewJson'+UserViewJson);
        } 
   
        public void delCalendarView(){
                Id delId;
                delViewResult = '';
                if(delViewId!=null && delViewId!=''){
                        delId = Id.valueOf(delViewId.trim());
                
                        Calendar_View__c viewToDel = new Calendar_View__c();
                        viewToDel.Id = delId;
                        
                        try{
                                delete viewToDel;
                        }
                        catch(exception e){
                                delViewResult = 'exception has occurred: '+e.getMessage();
                        }
                        delViewResult = 'true'; 
                }
                else{
                        delViewResult = 'invalid view delete request';  
                }
        }
      
    /*This wrapper class has been used in "getFinalFilterValues" method */    
    public class FilterWrapper{
        public string header{get;set;}
        public boolean depthCrawl{get;set;}
        public boolean value{get;set;}
        public List<FilterWrapper> childElements{get;set;}
        public string apiName{get;set;}
        public string fieldID{get;set;}
    }   
}