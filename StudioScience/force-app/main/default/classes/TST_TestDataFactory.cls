@isTest
public class TST_TestDataFactory {
    public static Case createCase(Id recordTypeId, Boolean isInsert) {
        Case newcase = new Case();
        newcase.Status = DTC_Constants.NEW_STATUS;
        newcase.RecordTypeId = recordTypeId;
        newcase.First_name__c = 'test';
        newcase.Last_name__c = 'customer 1';
        newcase.Email_Address__c = 'test@example.com';
        newcase.Cancelation_Reason__c = 'Other';
        newcase.Notes__c = 'customer notes';
        newcase.Brand__c = 'Jim Beam';
        newcase.OrderID__c = 'testO123';
        newcase.ProductID__c = 'testP123';
        newcase.Batch_Billing__c = date.valueOf('2022-02-02');
        newcase.How_can_we_help__c = 'API';
        newcase.AdditionalInformation__c = 'Membership Cancellation';
        newCase.Automated_Notification_Email__c = System.Label.DTC_EmailToCaseEmail;
        newCase.Program_subscription__c = 'Jim Beam';
        newCase.Consumer_Street__c = 'testStreet';
        newCase.Consumer_City__c = 'testCity';
        newCase.Consumer_State__c = 'testState';
        newCase.Consumer_Postal_Code__c = 'testPostalCode';
        newCase.Consumer_Country__c = 'testCountry';
        newCase.UPS_Tracking_Number__c = 'UPS123';
        newCase.UPS_Reason_For_Return__c = 'Damage';
        newCase.Customer_Phone_Number__c = '1234567890';
        newCase.Damage_Issue__c = 'Lost';
        newCase.DisputeID__c = 'TestDispute123';
        newCase.Transaction_Amount__c = 100;
        newCase.TransactionID__c = 'TestTran123';
        newCase.Received_Date__c = System.today();
        newCase.Response_Deadline__c = System.today();
        newCase.Next_Notification_Date__c = System.today();
        newCase.Send_Bell_Notification__c = false;
        newcase.Braintree_Status__c = 'Open';
        if(recordTypeId == null){
            newcase.RecordTypeId = DTC_Constants.CASE_DTC_RECORDTYPEID;
        }
        if(isInsert){
            insert newcase;
        }
        return newcase;
    }

    public static Account createAccount(Id recordTypeId, Boolean isInsert) {
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'paccount';
        if (recordTypeId != null) {
            acc.RecordTypeId = recordTypeId;
        }
        if(isInsert) {
            insert acc;
        }
        return acc;
    }

    public static Account createPersonAccount(Id recordTypeId, Boolean isInsert) {
        Account acc = new Account();
        acc.FirstName = 'test';
        acc.LastName = 'paccount';
        acc.PersonEmail = 'test@example.com';
        acc.PersonMailingCountry = 'India';
        acc.PersonMailingState = 'Rajasthan';
        acc.PersonMailingCity = 'Jaipur';
        acc.PersonMailingPostalCode = '302015';
        acc.PersonMailingStreet = 'Test street 1';
        if (recordTypeId != null) {
            acc.RecordTypeId = recordTypeId;
        }
        if(isInsert) {
            insert acc;
        }
        return acc;
    }

    public static Contact createContact(Id recordTypeId, Boolean isInsert) {
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'contact';
        con.Email = 'test@example.com';
        con.MagentoID__c = 'test123';
        if (recordTypeId != null) {
            con.RecordTypeId = recordTypeId;
        }
        if(isInsert) {
            insert con;
        }
        return con;
    }

    public static Group createGroup(Boolean isInsert, String developerName) {
        Group grp = new Group();
        grp.Type = 'Queue';
        if (String.isBlank(developerName)) {
            grp.Name = DTC_Constants.QUEUE_DTC_DHL;
        } else {
            grp.Name = developerName;
        }
        if(isInsert) {
            insert grp;
        }
        return grp;
    }

    public static CustomNotificationType createCustomNotificationType(String developerName, Boolean isInsert) {
        CustomNotificationType custom = new CustomNotificationType();
        custom.CustomNotifTypeName ='NotificationBellForCaseComment';
        if (String.isBlank(developerName)) {
            custom.DeveloperName = DTC_Constants.DTC_CUSTOM_NOTIFICATION;
        }
        return custom;
    }

    public static DTC_Settings__c createDTCSettings(Boolean isInsert) {
        DTC_Settings__c settings = new DTC_Settings__c();
        settings.Name = 'GBS Emails';
        settings.Emails__c = 'abc@beamsuntory.com';
        if(isInsert) {
            insert settings;
        }
        return settings;
    }
    public static Announcement__c createAnnouncement(Boolean isInsert) {
        Announcement__c announcement = new Announcement__c();
        announcement.Message__c = 'This is the test Message';
        if(isInsert) {
            insert announcement;
        }
        return announcement;
    }

    public static Innovation_Project_Master__c createInnovationMaster(Boolean isInsert) {
        Innovation_Project_Master__c innovationMaster = new Innovation_Project_Master__c();
        innovationMaster.Name = 'Test Project Master';
        innovationMaster.Start_Date__c = Date.today();
        innovationMaster.End_Date__c = Date.today();
        innovationMaster.Status__c = SOI_Constants.STATUS_ACTIVE;
        if(isInsert) {
            insert innovationMaster;
        }
        return innovationMaster;
    }

    public static Sample_Kit_Shipping_Address__c createshippingAddress(Boolean isInsert) {
        Sample_Kit_Shipping_Address__c shippingAddress = new Sample_Kit_Shipping_Address__c();
        shippingAddress.Name = 'Test Shipping Address';
        shippingAddress.Country__c = 'USA';
        shippingAddress.State__c = 'AR';
        shippingAddress.City__c = 'Test City';
        shippingAddress.Company__c = 'Test Company';
        shippingAddress.Street__c = 'Test Street';
        shippingAddress.Zip_Code__c = '563004';
        if(isInsert) {
            insert shippingAddress;
        }
        return shippingAddress;
    }

    public static Innovation_Project_Details__c createInnovationDetail(Boolean isInsert) {
        Innovation_Project_Details__c innovationDetail = new Innovation_Project_Details__c();
        Sample_Kit_Shipping_Address__c shippingAddress = createshippingAddress(true);
        innovationDetail.Name = 'Test Innovation Detail';
        innovationDetail.Phone__c = '9897969594';
        innovationDetail.Recipient_Email__c = 'test@gmail.com';
        innovationDetail.Quantity__c = 100;
        innovationDetail.Attention_To__c = 'attention';
        innovationDetail.AddressId__c = shippingAddress.Id;
        if(isInsert) {
            insert innovationDetail;
        }
        return innovationDetail;
    }

    public static Innovation_Sample_Requests__c createInnovationRequest(Boolean isInsert) {
        Innovation_Sample_Requests__c innovationRequest = new Innovation_Sample_Requests__c();
        innovationRequest.Name = 'Test Innovation Request';
        innovationRequest.Submitted_By__c = 'Test';
        innovationRequest.Email__c = 'test@gmail.com';
        innovationRequest.Region__c = 'Other';
        innovationRequest.Sold_to__c = 'Innovation samples';
        innovationRequest.Notes__c = 'Test notes';
        if(isInsert) {
            insert innovationRequest;
        }
        return innovationRequest;
    }
}