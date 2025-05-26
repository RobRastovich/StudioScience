/**
	@company : Copyright © 2020, BeamSuntory
    All rights reserved.
    Redistribution and use in source form, with or without modification, are prohibited without the express written consent of BeamSuntory,Inc.
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
    INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
    DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
    SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
    SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
    IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
    SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
    @website : https://www.beamsuntory.com/
    @author BeamSuntory
    @version V_1.0
    @date 17/04/2020
	@description This class is a general set of utilities that make accessing valuable parts of various describe information easier and more efficient. 
*/
public class UTL_Describe {
    
    @TestVisible private static final String SOBJECT_NOT_FOUND = 'An SObject with this name was not found in the Schema.';
    @TestVisible private static final String FIELDSET_NOT_FOUND = 'A fieldset with this name on this object could not be found.';
    @TestVisible private static final String FIELD_NOT_FOUND = 'A field with this API on this object could not be found.';
    @TestVisible private static Map<String, Map<String, Schema.SObjectField>> mapOfDescribesByfieldAPIByObjectAPI = 
        new Map<String, Map<String, Schema.SObjectField>>();
    @TestVisible private static Map<String, Schema.DescribeFieldResult> mapOfFieldDescribesByFieldAPIAndObjectAPI = 
        new Map<String, Schema.DescribeFieldResult>();
    
    // cache container to prevent repeated calls to getDescribe() for the same object in a single transaction
    @TestVisible private static Map<String,Schema.DescribeSObjectResult> sodResults { 
        get {
            if (sodResults == null) sodResults = new Map<String,Schema.DescribeSObjectResult>();
            return sodResults;
        }
        set;
    }
    
    @testVisible private static Map<String, Schema.SObjectType> globalDescribeMap {
        get
        {
            if (globalDescribeMap == null) globalDescribeMap = Schema.getGlobalDescribe();
            return globalDescribeMap;
        }
        set;
    }
    
    /**
    * Retrieves the describe sobject result for the passed sobject name, caching the results for the
    * length of the transaction.
    * (could be moved to a generic SObject utilities class and made public)
    * @param sobjectName String of the name of the SObject for which the describe result is being retrieved
    * @return the Schema.DescribeSObjectResult
    */  
    public static Schema.DescribeSObjectResult getSObjectDescribe(String sobjectName) {
        Schema.DescribeSObjectResult dsor;
        
        sobjectName = normalize(sobjectName);
        
        // get the describe result from the cache or generate and put into the cache
        if (sodResults.containsKey(sobjectName)) {
            dsor = sodResults.get(sobjectName);
        } else if(globalDescribeMap.containsKey(sobjectName)) {
            dsor = globalDescribeMap.get(sobjectName).getDescribe();
            sodResults.put(sobjectName,dsor);      
        }
        
        return dsor;
    }
    
    public static Schema.DescribeFieldResult getFieldDescribe(String sObjectName, String fieldAPI) {
        sObjectName = normalize(sObjectName);
        fieldAPI = normalize(fieldAPI);
        Map<String, Schema.SObjectField> normalizedMapOfDescribesByFieldAPI;
        
        if (mapOfFieldDescribesByFieldAPIAndObjectAPI.containsKey(sObjectName + fieldAPI)) {
            return mapOfFieldDescribesByFieldAPIAndObjectAPI.get(sObjectName + fieldAPI);
        }
        
        if (!mapOfDescribesByfieldAPIByObjectAPI.containsKey(sObjectName)) {
            Schema.DescribeSObjectResult objectDescribe = getSObjectDescribe(sObjectName);
            Map<String, Schema.SObjectField> mapOfDescribesByFieldAPI = objectDescribe.fields.getMap();
            normalizedMapOfDescribesByFieldAPI = new Map<String, Schema.SObjectField>();
            for (String key : mapOfDescribesByFieldAPI.keySet()) {
                normalizedMapOfDescribesByFieldAPI.put(normalize(key), mapOfDescribesByFieldAPI.get(key));
            }
            mapOfDescribesByFieldAPI = null;
            mapOfDescribesByfieldAPIByObjectAPI.put(sObjectName, normalizedMapOfDescribesByFieldAPI);
        } else {
            normalizedMapOfDescribesByFieldAPI = mapOfDescribesByfieldAPIByObjectAPI.get(sObjectName);
        }
        Schema.DescribeFieldResult fieldDescribe = normalizedMapOfDescribesByFieldAPI.get(fieldAPI).getDescribe();
        mapOfFieldDescribesByFieldAPIAndObjectAPI.put(sObjectName + fieldAPI, fieldDescribe);
        return fieldDescribe;
    }
    
    private static String normalize(String s) {
        if (s == null) s = '';
        return s.toLowerCase();
    }
}