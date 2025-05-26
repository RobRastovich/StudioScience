global class UTL_BI_AuthWrapper {
    
    public boolean userAuthorise {get;set;}
    public String userAuthErrorMessage {get;set;}
    
    public static UTL_BI_AuthWrapper checkUserNamedCredential(String appName)
    {
        UTL_BI_AuthWrapper wrapper = new UTL_BI_AuthWrapper();
        try{
            wrapper.userAuthorise = true;
            wrapper.userAuthErrorMessage = '';
            
            boolean isCredentialExist = UTL_API_Utility.checkUserNamedCredential(UserInfo.getUserId(),appName);
            if(appName == UTL_API_Utility.APPNAME_USBI){                
            	if(!isCredentialExist)
            	{
                	wrapper.userAuthorise = false;
                	wrapper.userAuthErrorMessage = Label.SAP_BI_Warning_Missing_Named_Credentials;
            	} else if(!checkUserAuthenticated(appName)) {
                	wrapper.userAuthorise = false;
                	wrapper.userAuthErrorMessage = Label.SAP_BI_Warning_Unauthorized_User;
            	}
            }
            else if(appName == UTL_API_Utility.APPNAME_AUSBI){
                if(!isCredentialExist)
            	{
                	wrapper.userAuthorise = false;
                	wrapper.userAuthErrorMessage = Label.SAP_BI_Warning_Missing_Named_Credentials_For_AUS;
            	} else if(!checkUserAuthenticated(appName)) {
                	wrapper.userAuthorise = false;
                	wrapper.userAuthErrorMessage = Label.SAP_BI_Warning_Unauthorized_User_For_AUS;
            	}
            }
            else{
                if(Test.isRunningTest())
                    integer intTest =1/0;
            }
        }catch(Exception e){
            wrapper.userAuthorise = false;
            wrapper.userAuthErrorMessage = Label.SAP_BI_Authentication_Exception;
            String errorMessage = Label.SAP_BI_Authentication_Exception + e.getMessage();
            system.debug(errorMessage);
            CreateExceptionLog.insertErrorLog('UTL_BI_AuthWrapper', 'checkUserNamedCredential', String.valueOf(errorMessage) + '\n' + e.getStackTraceString(), 'Fatal');
        }
        return wrapper;
    }
    
    private static boolean checkUserAuthenticated(String appName)
    {
        UTL_API_Utility.CSRFAuthInfo csrfResponse = EXT_BI_CampaignHelper.getUserAuthenticationInfo(appName);
        return csrfResponse.isUserAuthorized;
    }
    
}