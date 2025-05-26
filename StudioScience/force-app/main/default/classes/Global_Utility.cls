/*---------------------------------------------------------------
Class developed by: Priyankar Saha
Company: TCS
Date: 02/15/2019
Description: This class will be used for global utility purposes
----------------------------------------------------------------*/

public class Global_Utility {
    
    /*------------------------------------------------------------
Method Description: This method will let us know which ORG
is getting called from the API.
Method developed by: Priyankar Saha
Company: TCS
Date: 02/15/2019
-------------------------------------------------------------*/
    public static Boolean isProd(){
        Organization ordType=[SELECT Id, IsSandbox FROM Organization];
        if(ordType.IsSandbox==true)
            return false;
        return true;
    }
    
    public static Map<Integer, String> monthsMap = new Map<Integer, String>{
        1 =>'Jan ' 
            ,2 =>'Feb' 
            ,3 =>'Mar' 
            ,4 =>'APR'
            ,5 =>'May'
            ,6=>'Jun'
            ,7 =>'Jul' 
            ,8 =>'Aug' 
            ,9 =>'Sep'
            ,10 =>'Oct'
            ,11 =>'Nov'
            ,12 =>'Dec'             
    };
	public static String convertMonthNumtoAbvText(integer month){
    	return monthsMap.get( month );
    }
    
    
}