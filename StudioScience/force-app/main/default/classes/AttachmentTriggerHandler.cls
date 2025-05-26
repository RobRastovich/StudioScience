/**************************************************************************************
Apex Class Name     : AttachmentTriggerHandler
Created Date        : 5/2021
Function            : Handles events from the AttachmentTrigger trigger
*************************************************************************************/

public class AttachmentTriggerHandler {
    
	/**************************************************************************************************************
    Method name:    handleAfterInsert
    Object:         Attachment
    Event:          after insert
    Date:           5/2021
    Details and Notes: Handles all after insert triggers
    ***************************************************************************************************************/
    
    public static void handleAfterInsert(Map<ID, Attachment> newMap) {
       AttachmentServices.updateSingleBarrelCaseRecordTypeWithAttachment(newMap); 
    }
}