/*************************************************************
 * Class Name: BS_PR_FileUploader_ctrl
 * Component: BS_PR_File_Uploader
 * Test Class Name: BS_PR_FileUploader_ctrl_Test
 * Authour: Harikrishna P
 * Description: This class is used for uploadig attachments
 * Modification Logs:
  
**************************************************************/
public class BS_PR_FileUploader_ctrl{
    
    public string Parent_id{set;get;}
    public string attachment_id{set;get;}
    public list<Attachment> getAttachmentsList(){
        system.debug('value in methof....Parent_id.....'+Parent_id);
        if(Parent_id!=null) return [SELECT id,Name,Owner.Name,CreatedDate FROM Attachment WHERE ParentId=:Parent_id ORDER BY CreatedDate Desc];
        else return null;
    }
    
    public pagereference deleteFile(){
        system.debug('attachment_id....'+attachment_id);
        delete [SELECT id from attachment where id=:attachment_id];
        return null;
    }
}