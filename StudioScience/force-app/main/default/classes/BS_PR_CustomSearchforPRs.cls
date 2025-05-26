public with sharing class BS_PR_CustomSearchforPRs{
	
	//fetch the PR headers and it's detail & attachment based upon the custom search key and dates 
	@AuraEnabled(cacheable = true)
	public static List<PRWrapper> fetchPRWrapper(String searchKey, String startDate, String endDate){
		
		String key = '%' + searchKey + '%';
		Date startDateVal = Date.valueOf(startDate);
		Date endDateVal = Date.valueOf(endDate);
		List<PRWrapper> prWrapperList = new List<PRWrapper>();

		List<PR_Header__c> prHeaderList = [SELECT ID, Name, Total_PR_Amount__c, Status__c, Date_Time_Approval_Submission__c, CreatedDate, Owner.Name, (
		                                   SELECT ID, Name, Vendor_Name__c, Brand__c, GLDescription2__c, GL_Code2__c, PR_Amount__c
		                                   FROM PR_Details__r where Vendor_Name__c LIKE :key OR Brand__c LIKE :key OR GLDescription2__c LIKE :key), (
		                                   SELECT Name, Attachment_Id__c, PR_Header__r.Name, CreatedDate
		                                   FROM PR_Attachments__r)
		                                   FROM PR_Header__c
										   WHERE ID IN (SELECT PR_Header__c from PR_Detail__c WHERE Vendor_Name__c LIKE :key OR Brand__c LIKE :key OR GLDescription2__c LIKE :key)
										   AND Status__c IN ('Submitted', 'Approved By Procurement', 'Approved By Finance', 'Completed')
										   AND (CreatedDate >= :startDateVal AND CreatedDate <= :endDateVal)
		                                   ORDER BY CreatedDate DESC
										   Limit 4000];
										   
		system.debug('prHeaderList ' + prHeaderList);

		if (prHeaderList.isEmpty() == false){
			for (PR_Header__c prHeader : prHeaderList){
				if (prHeader.PR_Details__r.isEmpty() == false){
					PRWrapper prWrapper = new PRWrapper();
					
					prWrapper.prAttachments = new List<PRAttachment>();

					for (PR_Attachment__c prAttachment : prHeader.PR_Attachments__r){			
						PRAttachment prAttachmentObj = new PRAttachment();
						prAttachmentObj.Id = prAttachment.Id;
						prAttachmentObj.pr_name = prAttachment.PR_Header__r.Name;
						prAttachmentObj.pr_link = '/' + prHeader.Id;
						prAttachmentObj.pra_name = prAttachment.Name;
						prAttachmentObj.pra_link = '/' + prAttachment.Id;
						prAttachmentObj.pra_attachment =  URL.getSalesforceBaseUrl().toExternalForm() + '/servlet/servlet.FileDownload?file=' + prAttachment.Attachment_Id__c;
						prAttachmentObj.pra_createddate = prAttachment.CreatedDate.format('MM/dd/yyyy');
						prWrapper.prAttachments.add(prAttachmentObj);
					}
				
					prWrapper.prdetails = new List<PRDetail>();

					for (PR_Detail__c prDetail : prHeader.PR_Details__r){
						PRDetail prdetailObj = new PRDetail();
						prdetailObj.Id = (string)prDetail.Id;
						prdetailObj.pr_name = (string)prHeader.Name;
						prdetailObj.pr_link = '/' + prHeader.Id;
						prdetailObj.gl_code = (string)prDetail.GL_Code2__c;
						prdetailObj.pr_requestor = (String)prHeader.Owner.Name;
						prdetailObj.prd_brand = (string)prDetail.Brand__c;
						prdetailObj.pr_vendor = (string)prDetail.Vendor_Name__c;
						prdetailObj.pr_amount = (double)prHeader.Total_PR_Amount__c;
						prdetailObj.pr_detail_amount = (double)prDetail.PR_Amount__c;
						prdetailObj.pr_status = (string)prHeader.Status__c;
						prdetailObj.prd_gldescription2 = (string)prDetail.GLDescription2__c;
						 						
						prWrapper.prdetails.add(prdetailObj);
					}

					prWrapperList.add(prWrapper);
				} 	
			}
		}

		system.debug('prWrapperList ' + prWrapperList);
		return prWrapperList;
	}

	//prop declaration
	public class PRDetail{

		@AuraEnabled
		public string Id{
			get;

			set;
		}

		@AuraEnabled
		public string pr_name{
			get;

			set;
		}	

		@AuraEnabled
		public string prd_brand{
			get;

			set;
		}

		@AuraEnabled
		public string pr_vendor{
			get;

			set;
		}

		@AuraEnabled
		public double pr_amount{
			get;

			set;
		}

		@AuraEnabled
		public string pr_status{
			get;

			set;
		}

		@AuraEnabled
		public string prd_gldescription2{
			get;

			set;
		}

		@AuraEnabled
		public string pr_link{
			get;

			set;
		}
	
		@AuraEnabled
		public string gl_code{
			get;

			set;
		}

		@AuraEnabled
		public string pr_requestor{
			get;

			set;
		}

		@AuraEnabled
		public double pr_detail_amount{
			get;

			set;
		}	
	}

	public class PRAttachment{
		@AuraEnabled
		public string Id{
			get;

			set;
		}

		@AuraEnabled
		public string pr_name{
			get;

			set;
		}

		@AuraEnabled
		public string pra_name{
			get;

			set;
		}

		@AuraEnabled
		public string pra_attachment{
			get;

			set;
		}

		@AuraEnabled
		public String pra_createddate{
			get;

			set;
		}

		@AuraEnabled
		public string pr_link{
			get;

			set;
		}
		
		@AuraEnabled
		public string pra_link{
			get;

			set;
		}
	}

	public class PRWrapper{
		@AuraEnabled
		public List<PRAttachment> prattachments{
			get;

			set;
		}

		@AuraEnabled
		public List<PRDetail> prdetails{
			get;

			set;
		}

		//CONSTRUCTOR#1
		public PRWrapper(){
		}
		
		//CONSTRUCTOR#2
		public PRWrapper(List<PRAttachment> prattachments,  List<PRDetail> prdetails){
			this.prattachments = prattachments;
			this.prdetails = prdetails;
		}
		
	}
}