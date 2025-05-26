global class PR_XML_Helper {


    public static String ParseTrackingResponse(HttpResponse HttpResp, string LookUpElement) { 
        
        String sParsedValue = '';
        String namepace='';
        Dom.Document docx = new Dom.Document();
        docx.load(HttpResp.getbody());
        
        dom.XmlNode xRoot = docx.getRootElement();
        namepace = xRoot.getNamespace();

        dom.XmlNode xContent;
        xContent = xRoot.getChildElement('content', namepace);
        if (xContent!=null){
            dom.XmlNode xProperties;
            for(Dom.XMLNode child: xContent.getChildElements()) {
                //system.debug('NAME: '+ child.getName()+ ' Namespace: ' + child.getNamespace());
                if  (child.getName()=='properties'){
                    xProperties = child;
                }
            }

            if (xProperties!=null){
                dom.XmlNode xChild;
                for(Dom.XMLNode child: xProperties.getChildElements()) {
                    //system.debug('NAME: '+ child.getName()+ ' Namespace: ' + child.getNamespace());
                    if  (child.getName()==LookUpElement){
                        xChild = child;
                        break;
                    }
                }
                sParsedValue = xChild.getText();
            }
        }
        return sParsedValue; 
       }    

    public static String ParseRequestError(HttpResponse HttpResp, string LookUpElement) { 
        
        Dom.Document docx = new Dom.Document();
        docx.load(HttpResp.getbody());

        dom.XmlNode xRoot = docx.getRootElement();
        String namepace = xRoot.getNamespace();

        dom.XmlNode xMessage = xRoot.getChildElement('message', namepace);
            //system.debug(xMessage.getText());
            String sParsedValue = xMessage.getText();
            xMessage = null;
        return sParsedValue; 
    }   

   public static String  buildXml (string prID, list<PR_detail__c> prDetails){
    
        //list<PR_detail__c> prDetails  = GetPrDetails(prID);
        string strXML = '';
        integer i = 10;    
        String itemSeq;
        String itemNum;

        string SAPUser = '';
        User userRecord=[select id, SAP_User_Name__c from User where id=:userinfo.getUserid()];
        if(userRecord.SAP_User_Name__c<>null){SAPUser = userRecord.SAP_User_Name__c;}
        
        if (prDetails.size()>0) {
            try{
                Date d = System.today();
                Datetime mDT = datetime.newInstance(d.year(), d.month(),d.day());
                String mDate = mDT.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');

                Xmlstreamwriter xStreamWriter= new Xmlstreamwriter();
                        xStreamWriter.writeStartDocument('utf-8','1.0');
                            xStreamWriter.writeStartElement(null,'entry', null);
                            xStreamWriter.writeAttribute(null, null,'xmlns', 'http://www.w3.org/2005/Atom');
                            xStreamWriter.writeAttribute(null, null,'xml:base', 'http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/'); 
                            xStreamWriter.writeAttribute(null, null,'xmlns:m', 'http://schemas.microsoft.com/ado/2007/08/dataservices/metadata'); 
                            xStreamWriter.writeAttribute(null, null,'xmlns:d','http://schemas.microsoft.com/ado/2007/08/dataservices');
                                xStreamWriter.writeStartElement(null,'id', null);
                                xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRHeaderSet(\'\')');   
                                xStreamWriter.writeEndElement(); 
                                xStreamWriter.writeStartElement(null,'title', null);
                                xStreamWriter.writeAttribute(null, null,'type','text');
                                xStreamWriter.writeCharacters('PRHeaderSet(\'\')');
                                xStreamWriter.writeEndElement(); 
                                xStreamWriter.writeStartElement(null,'updated', null);
                                xStreamWriter.writeCharacters(mDate);
                                xStreamWriter.writeEndElement(); 
                                xStreamWriter.writeStartElement(null,'category', null);
                                xStreamWriter.writeAttribute(null, null,'term','ZGSP_PR_CREATION_SRV.PRHeader');
                                xStreamWriter.writeAttribute(null, null,'scheme','http://schemas.microsoft.com/ado/2007/08/dataservices/scheme');
                                xStreamWriter.writeEndElement(); 
                                xStreamWriter.writeStartElement(null,'link', null);
                                xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')'); xStreamWriter.writeAttribute(null, null,'rel','self'); xStreamWriter.writeAttribute(null, null,'title','PRHeader');
                                xStreamWriter.writeEndElement(); 
                                xStreamWriter.writeStartElement(null,'link', null);
                                xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRItem'); xStreamWriter.writeAttribute(null, null,'rel','http://schemas.microsoft.com/ado/2007/08/dataservices/related/PRHeaderToPRItem');
                                xStreamWriter.writeAttribute(null, null,'type','application/atom+xml;type=feed'); xStreamWriter.writeAttribute(null, null,'title','PRHeaderToPRItem');
                                    xStreamWriter.writeStartElement(null,'m:inline', null);
                                        xStreamWriter.writeStartElement(null,'feed', null);
                                        xStreamWriter.writeAttribute(null, null,'xml:base','http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/');
                                            xStreamWriter.writeStartElement(null,'id', null);
                                            xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRHeaderSet(\'\')/PRHeaderToPRItem');
                                            xStreamWriter.writeEndElement(); 
                                            xStreamWriter.writeStartElement(null,'title', null);
                                            xStreamWriter.writeAttribute(null, null,'type','text'); 
                                            xStreamWriter.writeCharacters('PRItemsSet');
                                            xStreamWriter.writeEndElement(); 
                                            xStreamWriter.writeStartElement(null,'updated', null);   
                                                xStreamWriter.writeCharacters(mDate); 
                                            xStreamWriter.writeEndElement();
                                            xStreamWriter.writeStartElement(null,'author', null);
                                                xStreamWriter.writeStartElement(null,'name', null); xStreamWriter.writeEndElement();
                                            xStreamWriter.writeEndElement(); 
                                            
                                            xStreamWriter.writeStartElement(null,'link', null);
                                            xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRItem');
                                            xStreamWriter.writeAttribute(null, null,'rel','self');
                                            xStreamWriter.writeAttribute(null, null,'title','PRItemsSet');
                                            xStreamWriter.writeEndElement(); 

                                            i = 10;
                                            for (PR_detail__c prDetail : prDetails){     
                                                for (PR_Phasing__c prPhasing : prDetail.PR_Phasings__r ){
                                                    itemSeq =i.format();
                                                    itemSeq= itemSeq.replace(',', '');
                                                    itemNum = itemSeq.leftPad(5,'00000');
                                                        xStreamWriter.writeStartElement(null,'entry', null);
                                                            xStreamWriter.writeStartElement(null,'id', null);
                                                                xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRItemsSet(PreqNo='+itemNum+ ')');
                                                            xStreamWriter.writeEndElement(); //id
                                                            xStreamWriter.writeStartElement(null,'title', null);
                                                                xStreamWriter.writeAttribute(null, null,'type', 'text'); xStreamWriter.writeCharacters('PRItemsSet(PreqNo=\'\',PreqItem='+itemNum+ ')');
                                                            xStreamWriter.writeEndElement(); //title
                                                            xStreamWriter.writeStartElement(null,'updated', null); xStreamWriter.writeCharacters(mDate); 
                                                            xStreamWriter.writeEndElement(); 
                                                            xStreamWriter.writeStartElement(null,'category', null);
                                                                xStreamWriter.writeAttribute(null, null,'term','ZGSP_PR_CREATION_SRV.PRItems'); 
                                                                xStreamWriter.writeAttribute(null, null,'scheme','http://schemas.microsoft.com/ado/2007/08/dataservices/scheme');
                                                            xStreamWriter.writeEndElement();//category
                                                            xStreamWriter.writeStartElement(null,'link', null);
                                                                xStreamWriter.writeAttribute(null, null,'href','PRItemsSet(PreqNo=\'\',PreqItem='+itemNum +')'); 
                                                                xStreamWriter.writeAttribute(null, null,'rel','self'); 
                                                                xStreamWriter.writeAttribute(null, null,'title','PRItems');
                                                            xStreamWriter.writeEndElement();
                                                            xStreamWriter.writeStartElement(null,'content', null);  
                                                                xStreamWriter.writeAttribute(null, null,'type','application/xml');
                                                                xStreamWriter.writeStartElement(null,'m:properties', null);
                                                                    xStreamWriter.writeStartElement(null,'d:PreqItem', null); xStreamWriter.writeCharacters(itemNum); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:DocType', null); xStreamWriter.writeCharacters('NB'); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:PurGroup', null); xStreamWriter.writeCharacters('U12'); xStreamWriter.writeEndElement();
                                                                    
                                                                    string reqName = system.UserInfo.getFirstName().left(1)+ system.UserInfo.getLastName();
                                                                    integer maxSize = 12;
                                                                    if(reqName.length() > maxSize){reqName = reqName.substring(0, maxSize);}
                                                                   
                                                                    xStreamWriter.writeStartElement(null,'d:CreatedBy', null); xStreamWriter.writeCharacters(reqName); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:PreqName', null); xStreamWriter.writeCharacters(SAPUser); xStreamWriter.writeEndElement();

                                                                    string pMonth = prPhasing.Month__c;
                                                                    String sDescription= (String.isBlank(prDetail.Description__c)? '' : prDetail.Description__c);
                                                                    string shortText = pMonth.left(3) + ' ' + prDetail.campaign__r.SAP_Territory_Abbreviation__c + ' ' +  prDetail.campaign__r.SAP_Brand_Abbreviation__c + ' ' + sDescription;

                                                                    xStreamWriter.writeStartElement(null,'d:ShortText', null); xStreamWriter.writeCharacters(shortText ); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:Plant', null); xStreamWriter.writeCharacters(prDetail.plant__c); xStreamWriter.writeEndElement();                                                                    
                                                                    string Trackingno = prDetail.PR_Header__r.CreatedBy.Firstname.left(1)+ prDetail.PR_Header__r.CreatedBy.Lastname;                                                    				
                                                                    maxSize = 10;
                                                                    if(Trackingno.length() > maxSize){Trackingno = Trackingno.substring(0, maxSize);}

                                                                    xStreamWriter.writeStartElement(null,'d:Trackingno', null); xStreamWriter.writeCharacters(Trackingno); xStreamWriter.writeEndElement();
                                                                    
                                                                    xStreamWriter.writeStartElement(null,'d:MatlGroup', null); xStreamWriter.writeCharacters(prDetail.Material_Group__c); xStreamWriter.writeEndElement();
                                                                    
                                                                    decimal cAmount = prPhasing.Phasing_Amount__c;
                                                                    if (cAmount==null) { cAmount= 0; }
                                                                    string sAmount=cAmount.format();
                                                                    sAmount= sAmount.replace(',','');

                                                                    xStreamWriter.writeStartElement(null,'d:Quantity', null); xStreamWriter.writeCharacters(sAmount); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:Unit', null); xStreamWriter.writeCharacters('EA'); xStreamWriter.writeEndElement();
                                                                    
                                                                    date dd = prPhasing.Delivery_date__c;
                                                                    Datetime dDT = datetime.newInstance(dd.year(), dd.month(),dd.day());
                                                                    String dDate = dDT.format('yyyy-MM-dd\'T\'hh:mm:ss');

                                                                    xStreamWriter.writeStartElement(null,'d:DelivDate', null); xStreamWriter.writeCharacters(dDate); xStreamWriter.writeEndElement();

                                                                    xStreamWriter.writeStartElement(null,'d:PreqPrice', null); xStreamWriter.writeCharacters('1'); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:PriceUnit', null); xStreamWriter.writeCharacters('1'); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:Acctasscat', null); xStreamWriter.writeCharacters(prDetail.Account_Assignment_Category2__c); xStreamWriter.writeEndElement();                                                                    
                                                    				xStreamWriter.writeStartElement(null,'d:DesVendor', null); xStreamWriter.writeCharacters(prDetail.PR_Header__r.Vendor_Number__c); xStreamWriter.writeEndElement();																	
                                                                    xStreamWriter.writeStartElement(null,'d:FixedVend', null); xStreamWriter.writeCharacters(prDetail.PR_Header__r.Vendor_Number__c); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:PurchOrg', null); xStreamWriter.writeCharacters('US20'); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeStartElement(null,'d:Currency', null); xStreamWriter.writeCharacters(prDetail.pr_header__r.pr_currency__c); xStreamWriter.writeEndElement();
                                                                xStreamWriter.writeEndElement();// m:properties
                                                            xStreamWriter.writeEndElement(); //content
                                                        xStreamWriter.writeEndElement(); //entry
                                                    i = i+10;
                                                }
                                            }
                                        xStreamWriter.writeEndElement();// feed
                                    xStreamWriter.writeEndElement(); //'m:inline'
                                xStreamWriter.writeEndElement(); //'link','PRHeaderToPRItem'

                                xStreamWriter.writeStartElement(null,'link', null);
                                xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRAccounts'); xStreamWriter.writeAttribute(null, null,'rel','http://schemas.microsoft.com/ado/2007/08/dataservices/related/PRHeaderToPRAccounts');
                                xStreamWriter.writeAttribute(null, null,'type','application/atom+xml;type=feed'); xStreamWriter.writeAttribute(null, null,'title','PRHeaderToPRAccounts');
                                    xStreamWriter.writeStartElement(null,'m:inline', null);
                                        xStreamWriter.writeStartElement(null,'feed', null);
                                        xStreamWriter.writeAttribute(null, null,'xml:base','http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/');
                
                                                xStreamWriter.writeStartElement(null,'id', null);
                                                    xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRHeaderSet(\'\')/PRHeaderToPRAccounts');
                                                xStreamWriter.writeEndElement(); //id

                                                xStreamWriter.writeStartElement(null,'title', null);
                                                    xStreamWriter.writeAttribute(null, null,'type', 'text'); 
                                                    xStreamWriter.writeCharacters('PRAccountSet');
                                                xStreamWriter.writeEndElement(); //title

                                                xStreamWriter.writeStartElement(null,'updated', null);   
                                                    xStreamWriter.writeCharacters(mDate); 
                                                xStreamWriter.writeEndElement();

                                                xStreamWriter.writeStartElement(null,'author', null);
                                                    xStreamWriter.writeStartElement(null,'name', null); 
                                                    xStreamWriter.writeEndElement();
                                                xStreamWriter.writeEndElement(); 

                                                xStreamWriter.writeStartElement(null,'link', null);
                                                    xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRAccounts');
                                                    xStreamWriter.writeAttribute(null, null,'rel','self');
                                                    xStreamWriter.writeAttribute(null, null,'title','PRAccountSet');
                                                xStreamWriter.writeEndElement(); //link

                                                i = 10; 
                                                for (PR_detail__c prDetail : prDetails){
                                                    for (PR_Phasing__c prPhasing : prDetail.PR_Phasings__r ){
                                                        itemSeq =i.format();
                                                        itemSeq= itemSeq.replace(',', '');
                                                        itemNum = itemSeq.leftPad(5,'00000');

                                                            xStreamWriter.writeStartElement(null,'entry', null);
                                                                xStreamWriter.writeStartElement(null,'id', null);
                                                                    xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRAccountSet(PreqNo=\'\',PreqItem='+ itemNum + ',SerialNo=\'01\')');
                                                                xStreamWriter.writeEndElement(); //id
                                                                
                                                                xStreamWriter.writeStartElement(null,'title', null);
                                                                    xStreamWriter.writeAttribute(null, null,'type', 'text'); 
                                                                    xStreamWriter.writeCharacters('PRAccountSet(PreqNo=\'\',PreqItem='+ itemNum + ',SerialNo=\'01\')');
                                                                xStreamWriter.writeEndElement(); //title

                                                                xStreamWriter.writeStartElement(null,'updated', null);   
                                                                    xStreamWriter.writeCharacters(mDate); 
                                                                xStreamWriter.writeEndElement();
                                                                
                                                                xStreamWriter.writeStartElement(null,'category', null);
                                                                    xStreamWriter.writeAttribute(null, null,'term','ZGSP_PR_CREATION_SRV.PRAccount'); 
                                                                    xStreamWriter.writeAttribute(null, null,'scheme','http://schemas.microsoft.com/ado/2007/08/dataservices/scheme');
                                                                xStreamWriter.writeEndElement();//category

                                                                xStreamWriter.writeStartElement(null,'link', null);
                                                                    xStreamWriter.writeAttribute(null, null,'href','PRAccountSet(PreqNo=\'\',PreqItem='+ itemNum + ', ,SerialNo=\'01\')'); 
                                                                    xStreamWriter.writeAttribute(null, null,'rel','self'); 
                                                                    xStreamWriter.writeAttribute(null, null,'title','PRAccount');
                                                                xStreamWriter.writeEndElement();
                                                                
                                                                xStreamWriter.writeStartElement(null,'link', null);
                                                                    xStreamWriter.writeAttribute(null, null,'href','PRAccountSet(PreqNo=\'\',PreqItem='+ itemNum + ', ,SerialNo=\'01\')/PRHeader'); 
                                                                    xStreamWriter.writeAttribute(null, null,'rel','http://schemas.microsoft.com/ado/2007/08/dataservices/related/PRHeader'); 
                                                                    xStreamWriter.writeAttribute(null, null,'type','application/atom+xml;type=entry');
                                                                    xStreamWriter.writeAttribute(null, null,'title','PRHeader');
                                                                xStreamWriter.writeEndElement();
                                                                
                                                                xStreamWriter.writeStartElement(null,'content', null);  
                                                                    xStreamWriter.writeAttribute(null, null,'type','application/xml');
                                                                    xStreamWriter.writeStartElement(null,'m:properties', null);
                                                                        xStreamWriter.writeStartElement(null,'d:PreqItem', null); xStreamWriter.writeCharacters(itemNum); xStreamWriter.writeEndElement();
                                                                        xStreamWriter.writeStartElement(null,'d:SerialNo', null); xStreamWriter.writeCharacters('01'); xStreamWriter.writeEndElement();
                                                                        xStreamWriter.writeStartElement(null,'d:GlAccount', null); xStreamWriter.writeCharacters(prDetail.GL_Code2__c); xStreamWriter.writeEndElement();
                                                                        xStreamWriter.writeStartElement(null,'d:Orderid', null); xStreamWriter.writeCharacters(prDetail.IOCode__C); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeEndElement();// m:properties
                                                                xStreamWriter.writeEndElement(); //content              
                                                            xStreamWriter.writeEndElement();//entry
                                                        i = i+10;
                                                    }
                                                }   

                                        xStreamWriter.writeEndElement();//feed   
                                    xStreamWriter.writeEndElement(); //m:inline' 
                                xStreamWriter.writeEndElement(); //Link

                                xStreamWriter.writeStartElement(null,'link', null);
                                xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRAccProitNav'); 
                                xStreamWriter.writeAttribute(null, null,'rel','http://schemas.microsoft.com/ado/2007/08/dataservices/related/PRHeaderToPRAccProitNav');
                                xStreamWriter.writeAttribute(null, null,'type','application/atom+xml;type=feed'); 
                                xStreamWriter.writeAttribute(null, null,'title','PRHeaderToPRAccProitNav');
                                    xStreamWriter.writeStartElement(null,'m:inline', null); 
                                        xStreamWriter.writeStartElement(null,'feed', null);
                                        xStreamWriter.writeAttribute(null, null,'xml:base','http://bljbbsapapp3.resource.bgsw.com:8007/sap/opu/odata/sap/ZGSP_PURCH_REQU_CREATION_V1_SRV_01/');

                                                xStreamWriter.writeStartElement(null,'id', null);
                                                    xStreamWriter.writeCharacters('http://bljbbsapapp3.resource.bgsw.com:8007/sap/opu/odata/sap/ZGSP_PURCH_REQU_CREATION_V1_SRV_01/PRHeaderSet(\'\')/PRHeaderToPRAccProitNav');
                                                xStreamWriter.writeEndElement(); //id

                                                xStreamWriter.writeStartElement(null,'title', null);
                                                    xStreamWriter.writeAttribute(null, null,'type', 'text'); 
                                                    xStreamWriter.writeCharacters('PRAccProitSet');
                                                xStreamWriter.writeEndElement(); //title

                                                xStreamWriter.writeStartElement(null,'updated', null);   
                                                    xStreamWriter.writeCharacters(mDate); 
                                                xStreamWriter.writeEndElement();

                                                xStreamWriter.writeStartElement(null,'author', null);
                                                    xStreamWriter.writeStartElement(null,'name', null); xStreamWriter.writeEndElement();
                                                xStreamWriter.writeEndElement(); 

                                                xStreamWriter.writeStartElement(null,'link', null);
                                                    xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRAccProitNav');
                                                    xStreamWriter.writeAttribute(null, null,'rel','self');
                                                    xStreamWriter.writeAttribute(null, null,'title','PRAccProitSet');
                                                xStreamWriter.writeEndElement(); //link

                                                i = 10; 
                                                for (PR_detail__c prDetail : prDetails){                                        
                                                    for (PR_Phasing__c prPhasing : prDetail.PR_Phasings__r ){
                                                        itemSeq =i.format();
                                                        itemSeq= itemSeq.replace(',', '');
                                                        itemNum = itemSeq.leftPad(5,'00000');

                                                            xStreamWriter.writeStartElement(null,'entry', null);
                                                                xStreamWriter.writeStartElement(null,'id', null);
                                                                    xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRAccProitSet(PreqNo=\'\',PreqItem='+ itemNum + ')');
                                                                xStreamWriter.writeEndElement(); //id
                                                                
                                                                xStreamWriter.writeStartElement(null,'title', null);
                                                                    xStreamWriter.writeAttribute(null, null,'type', 'text'); 
                                                                    xStreamWriter.writeCharacters('PRAccProitSet(PreqNo=\'\',PreqItem='+ itemNum + ')');
                                                                xStreamWriter.writeEndElement(); //title

                                                                xStreamWriter.writeStartElement(null,'updated', null);   
                                                                    xStreamWriter.writeCharacters(mDate); 
                                                                xStreamWriter.writeEndElement();
                                                                
                                                                xStreamWriter.writeStartElement(null,'category', null);
                                                                    xStreamWriter.writeAttribute(null, null,'term','ZGSP_PR_CREATION_SRV.PRAccProit'); 
                                                                    xStreamWriter.writeAttribute(null, null,'scheme','http://schemas.microsoft.com/ado/2007/08/dataservices/scheme');
                                                                xStreamWriter.writeEndElement();//category

                                                                xStreamWriter.writeStartElement(null,'link', null);
                                                                    xStreamWriter.writeAttribute(null, null,'href','PRAccProitSet(PreqNo=\'\',PreqItem='+ itemNum + ')'); 
                                                                    xStreamWriter.writeAttribute(null, null,'rel','self'); 
                                                                    xStreamWriter.writeAttribute(null, null,'title','PRAccProit');
                                                                xStreamWriter.writeEndElement();
                                                                
                                                                xStreamWriter.writeStartElement(null,'content', null);  
                                                                    xStreamWriter.writeAttribute(null, null,'type','application/xml');
                                                                    xStreamWriter.writeStartElement(null,'m:properties', null);
                                                                        xStreamWriter.writeStartElement(null,'d:PreqItem', null); xStreamWriter.writeCharacters(itemNum); xStreamWriter.writeEndElement();
                                                                        xStreamWriter.writeStartElement(null,'d:SerialNo', null); xStreamWriter.writeCharacters('01'); xStreamWriter.writeEndElement();
                                                                        xStreamWriter.writeStartElement(null,'d:Fieldname', null); xStreamWriter.writeCharacters('BZIRK'); xStreamWriter.writeEndElement(); // need to be derived from  IO first 2
                                                                        xStreamWriter.writeStartElement(null,'d:Value', null); xStreamWriter.writeCharacters(prDetail.campaign__r.SAP_Sales_District__c); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeEndElement();// m:properties
                                                                xStreamWriter.writeEndElement(); //content              
                                                            xStreamWriter.writeEndElement();//entry

                                                            xStreamWriter.writeStartElement(null,'entry', null);
                                                                xStreamWriter.writeStartElement(null,'id', null);
                                                                    xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRAccProitSet(PreqNo=\'\',PreqItem='+ itemNum + ')');
                                                                xStreamWriter.writeEndElement(); //id
                                                                
                                                                xStreamWriter.writeStartElement(null,'title', null);
                                                                    xStreamWriter.writeAttribute(null, null,'type', 'text'); 
                                                                    xStreamWriter.writeCharacters('PRAccProitSet(PreqNo=\'\',PreqItem='+ itemNum + ')'); 
                                                                xStreamWriter.writeEndElement(); //title

                                                                xStreamWriter.writeStartElement(null,'updated', null);   
                                                                    xStreamWriter.writeCharacters(mDate); 
                                                                xStreamWriter.writeEndElement();
                                                                
                                                                xStreamWriter.writeStartElement(null,'category', null);
                                                                    xStreamWriter.writeAttribute(null, null,'term','ZGSP_PR_CREATION_SRV.PRAccProit'); 
                                                                    xStreamWriter.writeAttribute(null, null,'scheme','http://schemas.microsoft.com/ado/2007/08/dataservices/scheme');
                                                                xStreamWriter.writeEndElement();//category

                                                                xStreamWriter.writeStartElement(null,'link', null);
                                                                    xStreamWriter.writeAttribute(null, null,'href','PRAccProitSet(PreqNo=\'\',PreqItem='+ itemNum + ')'); 
                                                                    xStreamWriter.writeAttribute(null, null,'rel','self'); 
                                                                    xStreamWriter.writeAttribute(null, null,'title','PRAccProit');
                                                                xStreamWriter.writeEndElement();
                                                                
                                                                xStreamWriter.writeStartElement(null,'content', null);  
                                                                    xStreamWriter.writeAttribute(null, null,'type','application/xml');
                                                                    xStreamWriter.writeStartElement(null,'m:properties', null);
                                                                        xStreamWriter.writeStartElement(null,'d:PreqItem', null); xStreamWriter.writeCharacters(itemNum); xStreamWriter.writeEndElement();
                                                                        xStreamWriter.writeStartElement(null,'d:SerialNo', null); xStreamWriter.writeCharacters('01'); xStreamWriter.writeEndElement();
                                                                        xStreamWriter.writeStartElement(null,'d:Fieldname', null); xStreamWriter.writeCharacters('PRODH'); xStreamWriter.writeEndElement(); //  SAP Product Hierarchy
                                                                        xStreamWriter.writeStartElement(null,'d:Value', null); xStreamWriter.writeCharacters(prDetail.campaign__r.SAP_Product_Hierarchy__c); xStreamWriter.writeEndElement();
                                                                    xStreamWriter.writeEndElement();// m:properties
                                                                xStreamWriter.writeEndElement(); //content  
                                                            xStreamWriter.writeEndElement();// entry

                                                        i = i+10;
                                                    }
                                                }

                                        xStreamWriter.writeEndElement();//feed
                                    xStreamWriter.writeEndElement(); //m:inline'            
                                xStreamWriter.writeEndElement();//Link

                                xStreamWriter.writeStartElement(null,'link', null);
                                xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRAttachNav'); 
                                xStreamWriter.writeAttribute(null, null,'rel','http://schemas.microsoft.com/ado/2007/08/dataservices/related/PRHeaderToPRAttachNav');
                                xStreamWriter.writeAttribute(null, null,'type','application/atom+xml;type=feed'); xStreamWriter.writeAttribute(null, null,'title','PRHeaderToPRAttachNav');
                                xStreamWriter.writeEndElement();//Link
                                
                                xStreamWriter.writeStartElement(null,'link', null);
                                xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRItemText'); 
                                xStreamWriter.writeAttribute(null, null,'rel','http://schemas.microsoft.com/ado/2007/08/dataservices/related/PRHeaderToPRItemText');
                                xStreamWriter.writeAttribute(null, null,'type','application/atom+xml;type=feed'); xStreamWriter.writeAttribute(null, null,'title','PRHeaderToPRItemText');
                                

                                    xStreamWriter.writeStartElement(null,'m:inline', null); 
                                        xStreamWriter.writeStartElement(null,'feed', null);
                                        xStreamWriter.writeAttribute(null, null,'xml:base','http://bljbbsapapp3.resource.bgsw.com:8007/sap/opu/odata/sap/ZGSP_PURCH_REQU_CREATION_V1_SRV_01/');

                                                xStreamWriter.writeStartElement(null,'id', null);
                                                    xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRHeaderSet(\'\')/PRHeaderToPRItemText');
                                                xStreamWriter.writeEndElement(); //id

                                                xStreamWriter.writeStartElement(null,'title', null);
                                                    xStreamWriter.writeAttribute(null, null,'type', 'text'); 
                                                    xStreamWriter.writeCharacters('PRItemTextSet');
                                                xStreamWriter.writeEndElement(); //title

                                                xStreamWriter.writeStartElement(null,'updated', null);   
                                                    xStreamWriter.writeCharacters(mDate); 
                                                xStreamWriter.writeEndElement();

                                                xStreamWriter.writeStartElement(null,'author', null);
                                                    xStreamWriter.writeStartElement(null,'name', null); xStreamWriter.writeEndElement();
                                                xStreamWriter.writeEndElement(); 

                                                xStreamWriter.writeStartElement(null,'link', null);
                                                    xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRItemText');
                                                    xStreamWriter.writeAttribute(null, null,'rel','self');
                                                    xStreamWriter.writeAttribute(null, null,'title','PRItemTextSet');   
                                                xStreamWriter.writeEndElement(); //link
                                        xStreamWriter.writeEndElement();//feed
                                    xStreamWriter.writeEndElement(); //m:inline'    
                                xStreamWriter.writeEndElement();//Link

                                xStreamWriter.writeStartElement(null,'link', null);
                                xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRHeaderTextNav'); xStreamWriter.writeAttribute(null, null,'rel','http://schemas.microsoft.com/ado/2007/08/dataservices/related/PRHeaderToPRHeaderTextNav');
                                xStreamWriter.writeAttribute(null, null,'type','application/atom+xml;type=feed'); xStreamWriter.writeAttribute(null, null,'title','PRHeaderToPRHeaderTextNav');

                                    xStreamWriter.writeStartElement(null,'m:inline', null); 
                                        xStreamWriter.writeStartElement(null,'feed', null);
                                        xStreamWriter.writeAttribute(null, null,'xml:base','http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/');

                                                xStreamWriter.writeStartElement(null,'id', null);
                                                    xStreamWriter.writeCharacters('http://bljbbsapapp3.resource.bgsw.com:8007/sap/opu/odata/sap/ZGSP_PURCH_REQU_CREATION_V1_SRV_01/PRHeaderSet(\'\')/PRHeaderToPRHeaderTextNav');
                                                xStreamWriter.writeEndElement(); //id

                                                xStreamWriter.writeStartElement(null,'title', null);
                                                    xStreamWriter.writeAttribute(null, null,'type', 'text'); 
                                                    xStreamWriter.writeCharacters('PRHeaderTextSet');
                                                xStreamWriter.writeEndElement(); //title

                                                xStreamWriter.writeStartElement(null,'updated', null);   
                                                    xStreamWriter.writeCharacters(mDate); 
                                                xStreamWriter.writeEndElement();

                                                xStreamWriter.writeStartElement(null,'author', null);
                                                    xStreamWriter.writeStartElement(null,'name', null); xStreamWriter.writeEndElement();
                                                xStreamWriter.writeEndElement(); 

                                                xStreamWriter.writeStartElement(null,'link', null);
                                                    xStreamWriter.writeAttribute(null, null,'href','PRHeaderSet(\'\')/PRHeaderToPRHeaderTextNav');
                                                    xStreamWriter.writeAttribute(null, null,'rel','self');
                                                    xStreamWriter.writeAttribute(null, null,'title','PRHeaderTextSet');
                                                xStreamWriter.writeEndElement(); //link

                                                xStreamWriter.writeStartElement(null,'entry', null);
                                                    xStreamWriter.writeStartElement(null,'id', null);
                                                        xStreamWriter.writeCharacters('http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/PRHeaderTextSet(PreqNo=\'\',PreqItem=\'00010\')');
                                                    xStreamWriter.writeEndElement(); //id
                                                    
                                                    xStreamWriter.writeStartElement(null,'title', null);
                                                        xStreamWriter.writeAttribute(null, null,'type', 'text'); 
                                                        xStreamWriter.writeCharacters('PRHeaderTextSet(PreqNo=\'\',PreqItem=\'00010\')');
                                                    xStreamWriter.writeEndElement(); //title

                                                    xStreamWriter.writeStartElement(null,'updated', null);   
                                                        xStreamWriter.writeCharacters(mDate); 
                                                    xStreamWriter.writeEndElement();
                                                    
                                                    xStreamWriter.writeStartElement(null,'category', null);
                                                        xStreamWriter.writeAttribute(null, null,'term','ZGSP_PR_CREATION_SRV.PRHeaderText'); 
                                                        xStreamWriter.writeAttribute(null, null,'scheme','http://schemas.microsoft.com/ado/2007/08/dataservices/scheme');
                                                    xStreamWriter.writeEndElement();//category

                                                    xStreamWriter.writeStartElement(null,'link', null);
                                                        xStreamWriter.writeAttribute(null, null,'href','PRHeaderTextSet(PreqNo=\'\',PreqItem=\'00000\')'); 
                                                        xStreamWriter.writeAttribute(null, null,'rel','self'); 
                                                        xStreamWriter.writeAttribute(null, null,'title','PRHeaderText');
                                                    xStreamWriter.writeEndElement();
                                                    
                                                    xStreamWriter.writeStartElement(null,'content', null);  
                                                        xStreamWriter.writeAttribute(null, null,'type','application/xml');
                                                        xStreamWriter.writeStartElement(null,'m:properties', null);
                                                            xStreamWriter.writeStartElement(null,'d:PreqItem', null); xStreamWriter.writeCharacters('00000'); xStreamWriter.writeEndElement();
                                                            xStreamWriter.writeStartElement(null,'d:TextId', null); xStreamWriter.writeCharacters('B01'); xStreamWriter.writeEndElement();
                                                            xStreamWriter.writeStartElement(null,'d:TextForm', null); xStreamWriter.writeCharacters('*'); xStreamWriter.writeEndElement();

                                                            PR_detail__c prDet = prDetails.get(0);
                                                            string textLine  = prDet.PR_Header__r.Payment_Terms__c + ' ' + prDet.PR_Header__r.pr_currency__c;

                                                            xStreamWriter.writeStartElement(null,'d:TextLine', null); xStreamWriter.writeCharacters(textLine); xStreamWriter.writeEndElement();
                                                        xStreamWriter.writeEndElement();// m:properties
                                                    xStreamWriter.writeEndElement(); //content              
                                                xStreamWriter.writeEndElement();//entry
                                        xStreamWriter.writeEndElement();//feed
                                    xStreamWriter.writeEndElement(); //m:inline'            
                                xStreamWriter.writeEndElement();//Link

                                xStreamWriter.writeStartElement(null,'content', null);
                                xStreamWriter.writeAttribute(null, null,'type','application/xml');
                                        xStreamWriter.writeStartElement(null,'m:properties', null);
                                                        xStreamWriter.writeStartElement(null,'d:PrType', null); xStreamWriter.writeCharacters('NB'); xStreamWriter.writeEndElement();
                                                        xStreamWriter.writeStartElement(null,'d:ItemIntvl', null); xStreamWriter.writeCharacters(itemNum); xStreamWriter.writeEndElement();
                                                        //system.debug('itemNum: '+ itemNum);
                                                        xStreamWriter.writeStartElement(null,'d:LastItem', null); xStreamWriter.writeCharacters(itemNum); xStreamWriter.writeEndElement();
                                                        xStreamWriter.writeStartElement(null,'d:Memorytype', null); xStreamWriter.writeEndElement();
                                        xStreamWriter.writeEndElement(); //m:properties
                                xStreamWriter.writeEndElement(); //content
                        xStreamWriter.writeEndDocument(); //entry

            strXML = xStreamWriter.getXmlString();
            xStreamWriter.close();
            }
            catch(Exception e){
                system.debug('error:'+ e.getMessage());
            }

        }
        return strXML;
	}
	
	/*
	static void updateCampaignSpend (map <id, list<string>> prDetails){
		Campaign_Spend__C campSpend  = new Campaign_Spend__C();
		list <Campaign_Spend__C> UpdatecampSpend = new list<Campaign_Spend__C>();
		
		//update UpdatecampSpend; 
	}*/

       public static String  buildAttachmentXml (id attId, string prNumber){ //(blob body, string file_name, string prNum){

            transient Attachment att = [SELECT id, name, Body FROM Attachment WHERE ID =: attID];

            transient string file_name = att.name;
            system.debug('after query = '+ limits.getHeapSize());

            transient string bodyEncoded = EncodingUtil.base64Encode(att.body);
            system.debug('after encode = '+ limits.getHeapSize());

            att = null;
            transient String strXML='';
            transient string[] arrName = file_name.split('\\.');
            transient integer i = arrName.size() -1;
            transient string sExtention = arrName[i].toUpperCase();
           
            arrName = null;
            //body = null;
            transient string prNum = prNumber.leftPad(10,'00000');
        
            Xmlstreamwriter xStreamWriter= new Xmlstreamwriter();
                xStreamWriter.writeStartDocument('utf-8','1.0');
                    xStreamWriter.writeStartElement(null,'entry', null);
                    xStreamWriter.writeAttribute(null, null,'xml:base', 'http://bljbbsapapp2.resource.bgsw.com:8008/sap/opu/odata/sap/ZGSP_PR_CREATION_SRV/'); 
                    xStreamWriter.writeAttribute(null, null,'xmlns', 'http://www.w3.org/2005/Atom');
                    xStreamWriter.writeAttribute(null, null,'xmlns:m', 'http://schemas.microsoft.com/ado/2007/08/dataservices/metadata'); 
                    xStreamWriter.writeAttribute(null, null,'xmlns:d','http://schemas.microsoft.com/ado/2007/08/dataservices');
                        
                        xStreamWriter.writeStartElement(null,'category', null);
                        xStreamWriter.writeAttribute(null, null,'term','ZGSP_PR_CREATION_SRV.PRAttach');
                        xStreamWriter.writeAttribute(null, null,'scheme','http://schemas.microsoft.com/ado/2007/08/dataservices/scheme');
                        xStreamWriter.writeEndElement(); 

                        xStreamWriter.writeStartElement(null,'link', null);
                            xStreamWriter.writeAttribute(null, null,'title','PRAttach');
                            xStreamWriter.writeAttribute(null, null,'href','PRAttachSet(PreqNo='+prNum + ',FileName='+file_name+ ')'); 
                            xStreamWriter.writeAttribute(null, null,'rel','self'); 
                        xStreamWriter.writeEndElement(); 

                        xStreamWriter.writeStartElement(null,'link', null);
                            xStreamWriter.writeAttribute(null, null,'title','PRHeaderToPRAttachNav');
                            xStreamWriter.writeAttribute(null, null,'href','PRAttachSet(PreqNo='+prNum + ',FileName='+file_name+')/PRHeaderToPRAttachNav'); 
                            xStreamWriter.writeAttribute(null, null,'rel','http://schemas.microsoft.com/ado/2007/08/dataservices/related/PRHeaderToPRAttachNav');
                            xStreamWriter.writeAttribute(null, null,'type', 'application/atom+xml;type=entry');
                        xStreamWriter.writeEndElement();
                        xStreamWriter.writeStartElement(null,'content', null);
                        xStreamWriter.writeAttribute(null, null,'type','application/xml');
                                xStreamWriter.writeStartElement(null,'m:properties', null);
                                                xStreamWriter.writeStartElement(null,'d:PreqNo', null); xStreamWriter.writeCharacters(prNum); xStreamWriter.writeEndElement();
                                                xStreamWriter.writeStartElement(null,'d:FileName', null); xStreamWriter.writeCharacters(file_name); xStreamWriter.writeEndElement();
                                                xStreamWriter.writeStartElement(null,'d:extension', null); xStreamWriter.writeCharacters(sExtention); xStreamWriter.writeEndElement();
                                                xStreamWriter.writeStartElement(null,'d:cont_Format', null); xStreamWriter.writeCharacters('BIN'); xStreamWriter.writeEndElement();
                                                xStreamWriter.writeStartElement(null,'d:content', null); xStreamWriter.writeCharacters(bodyEncoded); xStreamWriter.writeEndElement();
                                                bodyEncoded = null;
                                xStreamWriter.writeEndElement(); //m:properties
                        xStreamWriter.writeEndElement(); //content
                xStreamWriter.writeEndDocument(); //entry
                strXML = xStreamWriter.getXmlString();
            xStreamWriter.close();
            xStreamWriter = null;
            system.debug('end xml = '+ limits.getHeapSize());
            return strXML;
       }

       
}