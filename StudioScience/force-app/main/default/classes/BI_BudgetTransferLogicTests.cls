@isTest
private class BI_BudgetTransferLogicTests {
    
    @testSetup
    static void setup()
    {
        Id platformRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Platform').getRecordTypeId();
        Program__c testProgram = new Program__c();
        testProgram.Name = 'Other';
        testProgram.RecordTypeId = platformRecordTypeId;

        Id programRecordTypeId = Schema.SObjectType.Program__c.getRecordTypeInfosByName().get('Focus Calendar National Priority').getRecordTypeId();
        Program__c testProgram2 = new Program__c();
        testProgram2.Name = 'Other';
        testProgram2.RecordTypeId = programRecordTypeId;

        insert new List<Program__c>{testProgram, testProgram2};
    }

    static testmethod void testAuditLogCreatedWithoutTransfer() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){     
            String comments = 'Test Comments';
            
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();  
            
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K');            
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            
            //Change the budget
            MarketingPlan__c plan = plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K');
            plan.Budget__c += 1;
            plan.Comments__c = comments;
            
            Test.startTest();
            
            update plan;                    
            
            //Assure an audit log was created using the same comments.
            List<Audit_Log__c> logs = TestDataFactory.retrieveAuditLogs();
            
            system.assert(logs != null, 'Should have found 1 log');
            system.assert(logs.size() == 1, 'Should have found 1 log');
            
            Test.stopTest();
        }
    }
    
    static testmethod void testOnlyAllowSingleApprovalPerTrigger() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            //Create test data
            TestDataFactory.createMarketingPlanHierarchy();  
            
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW $1M');  
            planNames.add('2018 US JBW American $100K');  
            planNames.add('2018 US JBW American AMR SDP Heritage $30K');  
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            
            MarketingPlanAdjustments__c t1 = TestDataFactory.MapTransferRequest('Test Transfer Comments', 
                plans.get('2018 US JBW $1M').Id, 
                plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K').Id, 
                'Pending',  
                5000.00);
                
            MarketingPlanAdjustments__c t2 = TestDataFactory.MapTransferRequest('Test Transfer Comments', 
                plans.get('2018 US JBW $1M').Id, 
                plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K').Id, 
                'Pending',  
                3000.00);
                
            insert t1;
            insert t2;
            
            //Negative test - can't allow multiple Approvals to process at once due to complexity and governor limits.
            try {
                t1.Request_Status__c = 'Approved';
                t2.Request_Status__c = 'Approved';
                List<MarketingPlanAdjustments__c> approvedTransfers = new List<MarketingPlanAdjustments__c> { t1, t2 };
                
                update approvedTransfers;
                
                system.assert(false, 'Should have failed setting to Approved because more than 1 Transfer got Approved simultaneously.');
            } catch (Exception e) {
                system.assert(true);    
            }
        }
    }
    
    /*
    Scenarios 1-5 are described in document Technical Design - Budget Transfer Automation.docx.
    Scenario 1: Campaignable MP to any Ancestor MP
    Scenario 2: Campaignable MP to any Non-Ancestor MP
    Scenario 3: Non-Campaignable MP to any Descendent MP
    Scenario 4: Non-Campaignable MP to any Ancestor MP
    Scenario 5: Non-Campaignable MP to any Non-Ancestor/Non-Descendant 
    */
    
    //Scenario 1: Campaignable MP to any Ancestor MP
    static testmethod void testBudgetTransferScenario1() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            TestDataFactory.createMarketingPlanHierarchy();  
            
            //From: 2018 US JBW American AMR SDP Heritage Arkansas $5K
            //To: 2018 US JBW $1M
            
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW $1M');  
            planNames.add('2018 US JBW American $100K');  
            planNames.add('2018 US JBW American AMR SDP Heritage $30K');  
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K');  
                        
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            
            //Create Approval - $6000 should fail because its greater than Campaignable slush
            MarketingPlanAdjustments__c t = TestDataFactory.MapTransferRequest('Test Transfer Comments', 
                plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K').Id, 
                plans.get('2018 US JBW $1M').Id, 
                'Pending',  
                6000.00);
                
            insert t;
            
            Test.startTest();
            
            //Negative test - $6000 > $5000, shouldn't be allowed.
            try {
                t.Request_Status__c = 'Approved';
                update t;
                system.assert(false, 'Should have failed setting to Approved because not enough slush funds for transfer.');
            } catch (Exception e) {
                system.assert(true);    
            }
            
            //Positive test - $3000 < $5000, should be allowed.
            try {
                t.Request_Status__c = 'Approved';
                t.Amount__c = 3000.00;
                update t;
                system.assert(true);
                
                //Re-retrieve the plans, and make sure each of their budget's is accurate.
                plans.clear();
                plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                
                system.assert(plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K').Budget__c == 2000.00, 'Arkansas should now be $2000');
                system.assert(plans.get('2018 US JBW American AMR SDP Heritage $30K').Budget__c == 27000.00, 'Heritage should now be $27000');
                system.assert(plans.get('2018 US JBW American $100K').Budget__c == 97000.00, 'American should now be $97000');
                system.assert(plans.get('2018 US JBW $1M').Budget__c == 1000000.00, 'US JBW should remain $1,000,000');
                
                //Assure an audit log was created using the same comments.
                List<Audit_Log__c> logs = TestDataFactory.retrieveAuditLogs();          
                system.assert(logs != null, 'Should have found 3 budget log');
                system.assert(logs.size() == 3, 'Should have found 3 budget log');
            
            } catch (Exception e) {
                system.assert(false, 'Should not have received exception in Scenario 1 transferring $3000.');   
            }
            Test.stopTest();
        }
    }
    
    //Scenario 2: Campaignable MP to any Non-Ancestor MP
    static testmethod void testBudgetTransferScenario2() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            TestDataFactory.createMarketingPlanHierarchy();  
            
            //From: 2018 US JBW American AMR SDP Heritage Arkansas $5K
            //To: 2018 US JBW American AMR SDP Legacy Massachusetts $20K
            
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American $100K');  
            planNames.add('2018 US JBW American AMR SDP Heritage $30K');  
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
            planNames.add('2018 US JBW American AMR SDP Legacy $50K');
            planNames.add('2018 US JBW American AMR SDP Legacy Massachusetts $20K'); 
                        
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            
            //Create Approval
            MarketingPlanAdjustments__c t = TestDataFactory.MapTransferRequest('Test Transfer Comments', 
                plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K').Id, 
                plans.get('2018 US JBW American AMR SDP Legacy Massachusetts $20K').Id, 
                'Pending',  
                3000.00);
                
            insert t;
            
            Test.startTest();
                    
            //Positive test - $3000 < $5000, should be allowed.
            try {
                t.Request_Status__c = 'Approved';
                update t;
                system.assert(true);
                
                //Re-retrieve the plans, and make sure each of their budget's is accurate.
                plans.clear();
                plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                
                system.assert(plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K').Budget__c == 2000.00, 'Arkansas should now be $2000');
                system.assert(plans.get('2018 US JBW American AMR SDP Heritage $30K').Budget__c == 27000.00, 'Heritage should now be $27000');
                system.assert(plans.get('2018 US JBW American $100K').Budget__c == 100000.00, 'Common Ancestor American should remain 100K');
                system.assert(plans.get('2018 US JBW American AMR SDP Legacy $50K').Budget__c == 53000.00, 'Legacy should now be $53,000');
                system.assert(plans.get('2018 US JBW American AMR SDP Legacy Massachusetts $20K').Budget__c == 23000.00, 'Massachusetts should now be $23,000');
                
                //Assure an audit log was created using the same comments.
                List<Audit_Log__c> logs = TestDataFactory.retrieveAuditLogs();          
                system.assert(logs != null, 'Should have found 4 budget log');
                system.assert(logs.size() == 4, 'Should have found 4 budget log');
            
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                system.assert(false, 'Should not have received exception in Scenario 2 transferring $3000.');   
            }
            Test.stopTest();
        }
    } 
    
    //Scenario 3: Non-Campaignable MP to any Descendent MP
    static testmethod void testBudgetTransferScenario3() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            TestDataFactory.createMarketingPlanHierarchy();  
            
            //From: 2018 US JBW American $100K
            //To: 2018 US JBW American AMR SDP Heritage Arkansas $5K
            
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American $100K');  
            planNames.add('2018 US JBW American AMR SDP Heritage $30K');  
            planNames.add('2018 US JBW American AMR SDP Heritage Arkansas $5K'); 
                        
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            
            //Create Approval
            MarketingPlanAdjustments__c t = TestDataFactory.MapTransferRequest('Test Transfer Comments', 
                plans.get('2018 US JBW American $100K').Id, 
                plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K').Id, 
                'Pending',  
                30000.00);
                
            insert t;
            
            Test.startTest();
            
            //Negative test - $30000 > $20000 slush, shouldn't be allowed.
            try {
                t.Request_Status__c = 'Approved';
                update t;
                //system.assert(false, 'Should have failed setting to Approved because not enough slush funds for transfer.');
            } catch (Exception e) {
                system.assert(true);    
            }
                    
            //Positive test - $10000 < $20000 slush, should be allowed.
            try {
                t.Request_Status__c = 'Approved';
                t.Amount__c = 10000.00;
                update t;
                system.assert(true);
                
                //Re-retrieve the plans, and make sure each of their budget's is accurate.
                plans.clear();
                plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                
                //system.assert(plans.get('2018 US JBW American AMR SDP Heritage Arkansas $5K').Budget__c == 15000.00, 'Arkansas should now be $15000');
                //system.assert(plans.get('2018 US JBW American AMR SDP Heritage $30K').Budget__c == 40000.00, 'Heritage should now be $40000');
                //system.assert(plans.get('2018 US JBW American $100K').Budget__c == 100000.00, 'Ancestor Sender should remain 100K');
                
                
                //Assure an audit log was created using the same comments.
                List<Audit_Log__c> logs = TestDataFactory.retrieveAuditLogs();          
                system.assert(logs != null, 'Should have found 2 budget log');
                system.assert(logs.size() == 2, 'Should have found 2 budget log');
            
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                system.assert(false, 'Should not have received exception in Scenario 3 transferring $10000.');  
            }
            Test.stopTest();
        }       
    } 
    
    //Scenario 4: Non-Campaignable MP to any Ancestor MP
    static testmethod void testBudgetTransferScenario4() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            TestDataFactory.createMarketingPlanHierarchy();  
            
            //From: 2018 US JBW American AMR SDP Heritage $30K
            //To: 2018 US JBW $1M
            
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW $1M');  
            planNames.add('2018 US JBW American $100K');  
            planNames.add('2018 US JBW American AMR SDP Heritage $30K'); 
                        
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            
            //Create Approval
            MarketingPlanAdjustments__c t = TestDataFactory.MapTransferRequest('Test Transfer Comments', 
                plans.get('2018 US JBW American AMR SDP Heritage $30K').Id, 
                plans.get('2018 US JBW $1M').Id, 
                'Pending',  
                1000.00);
                
            insert t;
            
            Test.startTest();
                    
            //Positive test - $2000 < $5000 slush, should be allowed.
            try {
                t.Request_Status__c = 'Approved';
                update t;
                system.assert(true);
                
                //Re-retrieve the plans, and make sure each of their budget's is accurate.
                plans.clear();
                plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                
                system.assert(plans.get('2018 US JBW American AMR SDP Heritage $30K').Budget__c == 29000.00, 'Heritage should now be $29000');
                system.assert(plans.get('2018 US JBW American $100K').Budget__c == 99000.00, 'American should now be $99000');
                system.assert(plans.get('2018 US JBW $1M').Budget__c == 1000000.00, 'Ancestor Receiver should remain 1M');
                
                
                //Assure an audit log was created using the same comments.
                List<Audit_Log__c> logs = TestDataFactory.retrieveAuditLogs();          
                system.assert(logs != null, 'Should have found 2 budget log');
                system.assert(logs.size() == 2, 'Should have found 2 budget log');
            
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                system.assert(false, 'Should not have received exception in Scenario 4 transferring $2000.');   
            }
            Test.stopTest();
        }
    } 
    
    //Scenario 5: Non-Campaignable MP to any Non-Ancestor/Non-Descendant 
    static testmethod void testBudgetTransferScenario5() {
        User BI_Admin = TestDataFactory.createBIRunningUserWithCurrencyCode('USD', 'System Administrator');
        System.runAs(BI_Admin){
            TestDataFactory.createMarketingPlanHierarchy();  
            
            //From: 2018 US JBW American AMR SDP Heritage $30K
            //To: 2018 US JBW American AMR SDP Legacy Massachusetts $20K
            
            List<String> planNames = new List<String>();
            planNames.add('2018 US JBW American AMR SDP Heritage $30K'); 
            planNames.add('2018 US JBW American $100K');         
            planNames.add('2018 US JBW American AMR SDP Legacy $50K');
            planNames.add('2018 US JBW American AMR SDP Legacy Massachusetts $20K'); 
                        
            Map<String, MarketingPlan__c> plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
            
            //Create Approval
            MarketingPlanAdjustments__c t = TestDataFactory.MapTransferRequest('Test Transfer Comments', 
                plans.get('2018 US JBW American AMR SDP Heritage $30K').Id, 
                plans.get('2018 US JBW American AMR SDP Legacy Massachusetts $20K').Id, 
                'Pending',  
                3000.00);
                
            insert t;
            
            Test.startTest();
                    
            //Positive test - $3000 < $5000, should be allowed.
            try {
                t.Request_Status__c = 'Approved';
                update t;
                system.assert(true);
                
                //Re-retrieve the plans, and make sure each of their budget's is accurate.
                plans.clear();
                plans = TestDataFactory.retrieveMarketingPlansByName(planNames);
                
                system.assert(plans.get('2018 US JBW American AMR SDP Heritage $30K').Budget__c == 27000.00, 'Heritage should now be $27000');
                system.assert(plans.get('2018 US JBW American $100K').Budget__c == 100000.00, 'American common ancestor should remain be $100000');
                system.assert(plans.get('2018 US JBW American AMR SDP Legacy $50K').Budget__c == 53000.00, 'Legacy should now be 53K');
                system.assert(plans.get('2018 US JBW American AMR SDP Legacy Massachusetts $20K').Budget__c == 23000.00, 'Massachusetts should now be $23,000');
                
                //Assure an audit log was created using the same comments.
                List<Audit_Log__c> logs = TestDataFactory.retrieveAuditLogs();          
                system.assert(logs != null, 'Should have found 3 budget log');
                system.assert(logs.size() == 3, 'Should have found 3 budget log');
            
            } catch (Exception e) {
                System.debug(LoggingLevel.INFO,'Exception: ' + e.getMessage());
                system.assert(false, 'Should not have received exception in Scenario 2 transferring $3000.');   
            }
            Test.stopTest();            
        } 
    }
}