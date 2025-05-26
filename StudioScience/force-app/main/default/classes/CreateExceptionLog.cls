public without sharing class CreateExceptionLog {

    public static void insertErrorLog(String className, String methodName, String msg, String errorType) {
        if (msg != null) {
            // Instantiate and populate the Error Log instance.
            Custom_Exception_Logs__c errorLog = new Custom_Exception_Logs__c();
            errorLog.Class_Name__c = className;
            errorLog.Method_Name__c = methodName;
            errorLog.Message__c = msg;
            errorLog.Error_Type__c = errorType;
            insert errorLog;
        }
    }

    public static Custom_Exception_Logs__c createExceptionLog(String className, String methodName, String msg, String errorType, Boolean insertLog) {
        Custom_Exception_Logs__c errorLog = new Custom_Exception_Logs__c();

        // Instantiate and populate the Error Log instance.
        errorLog = new Custom_Exception_Logs__c();
        errorLog.Class_Name__c = className;
        errorLog.Method_Name__c = methodName;
        errorLog.Message__c = msg;
        errorLog.Error_Type__c = errorType;


        if (insertLog) {
            insert errorLog;
        }

        return errorLog;
    }
}