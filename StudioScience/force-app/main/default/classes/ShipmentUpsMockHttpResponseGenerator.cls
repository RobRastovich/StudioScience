@isTest
global class ShipmentUpsMockHttpResponseGenerator implements HttpCalloutMock{
   
    global final String trackNumber;  

    public ShipmentUpsMockHttpResponseGenerator(string trackNum) {
        this.trackNumber = trackNum;
    }
    
    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'text/xml');
        response.setBody(responseBody()); 
        response.setStatusCode(200);
        return response;
    }

    static String responseBody(){
		/**
        Xmlstreamwriter xmlReq = new Xmlstreamwriter();
    
        xmlReq.writeStartElement(null,'Envelope', null);
          xmlReq.writeStartElement(null,'Body', null);
              xmlReq.writeStartElement(null,'TrackReply', null);
        		xmlReq.writeStartElement(null,'Notifications', null);
                 xmlReq.writeStartElement(null,'HighestSeverity', null);
                    xmlReq.writeCharacters('SUCCESS');
                        xmlReq.writeStartElement(null,'Code', null);
                            xmlReq.writeStartElement(null,'Severity', null);
                                xmlReq.writeCharacters('Success');
                            xmlReq.writeEndElement();
                        xmlReq.writeEndElement();
                    xmlReq.writeEndElement();
                 xmlReq.writeStartElement(null,'CompletedTrackDetails', null);
                     xmlReq.writeStartElement(null,'TrackDetails', null);
                        xmlReq.writeStartElement(null,'TrackingNumber', null);
                                xmlReq.writeCharacters('774216566448');
                            xmlReq.writeEndElement();
    
                        xmlReq.writeStartElement(null,'Notification', null);
                            xmlReq.writeStartElement(null,'Severity', null);
                                xmlReq.writeCharacters('Success');
                            xmlReq.writeEndElement();
                            xmlReq.writeStartElement(null,'Code', null);
                                xmlReq.writeCharacters('0');
                            xmlReq.writeEndElement();
                        xmlReq.writeEndElement();
    
                        xmlReq.writeStartElement(null,'StatusDetail', null);
                            xmlReq.writeStartElement(null,'Code', null);
                                xmlReq.writeCharacters('DL');
                            xmlReq.writeEndElement();
                            xmlReq.writeStartElement(null,'Description', null);
                                xmlReq.writeCharacters('Delivered');
                            xmlReq.writeEndElement();
                        xmlReq.writeEndElement();
                    xmlReq.writeEndElement();
                   xmlReq.writeEndElement();
              xmlReq.writeEndElement();
          xmlReq.writeEndElement();
        xmlReq.writeEndElement();
       */ 
     String re = '<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/">' +
    '<SOAP-ENV:Header/>' +
    '<SOAP-ENV:Body>' +
        '<TrackReply xmlns="http://fedex.com/ws/track/v19">' +
            '<HighestSeverity>SUCCESS</HighestSeverity>'+
            '<Notifications>'+
                '<Severity>SUCCESS</Severity>'+
                '<Source>trck</Source>'+
                '<Code>0</Code>'+
                '<Message>Request was successfully processed.</Message>'+
                '<LocalizedMessage>Request was successfully processed.</LocalizedMessage>'+
            '</Notifications>'+
            '<Version>'+
                '<ServiceId>trck</ServiceId>'+
                '<Major>19</Major>'+
                '<Intermediate>0</Intermediate>'+
                '<Minor>0</Minor>'+
            '</Version>'+
            '<CompletedTrackDetails>'+
                '<HighestSeverity>SUCCESS</HighestSeverity>'+
                '<Notifications>'+
                    '<Severity>SUCCESS</Severity>'+
                    '<Source>trck</Source>'+
                    '<Code>0</Code>'+
                    '<Message>Request was successfully processed.</Message>'+
                    '<LocalizedMessage>Request was successfully processed.</LocalizedMessage>'+
                '</Notifications>'+
                '<DuplicateWaybill>false</DuplicateWaybill>'+
                '<MoreData>false</MoreData>'+
                '<TrackDetailsCount>0</TrackDetailsCount>'+
                '<TrackDetails>'+
                    '<Notification>'+
                        '<Severity>SUCCESS</Severity>'+
                        '<Source>trck</Source>'+
                        '<Code>0</Code>'+
                        '<Message>Request was successfully processed.</Message>'+
                        '<LocalizedMessage>Request was successfully processed.</LocalizedMessage>'+
                    '</Notification>'+
                    '<TrackingNumber>773735677473</TrackingNumber>'+
                    '<TrackingNumberUniqueIdentifier>12013~070358180009382~FDEG</TrackingNumberUniqueIdentifier>'+
                    '<StatusDetail>'+
                        '<CreationTime>2014-01-07T00:00:00</CreationTime>'+
                        '<Code>CA</Code>'+
                        '<Description>Shipment cancelled by sender</Description>'+
                        '<Location>'+
                            '<City>Hayward</City>'+
                            '<StateOrProvinceCode>CA</StateOrProvinceCode>'+
                            '<CountryCode>US</CountryCode>'+
                            '<CountryName>United States</CountryName>'+
                            '<Residential>false</Residential>'+
                        '</Location>'+
                        '<AncillaryDetails>'+
                            '<Reason>IN002</Reason>'+
                            '<ReasonDescription>FedEx notified to void this shipment</ReasonDescription>'+
                        '</AncillaryDetails>'+
                    '</StatusDetail>'+
                    '<ServiceCommitMessage>FedEx notified to void this shipment</ServiceCommitMessage>'+
                    '<DestinationServiceArea>CA</DestinationServiceArea>'+
                    '<CarrierCode>FDXG</CarrierCode>'+
                    '<OperatingCompanyOrCarrierDescription>FedEx Ground</OperatingCompanyOrCarrierDescription>'+
                    '<OtherIdentifiers>'+
                        '<PackageIdentifier>'+
                            '<Type>GROUND_SHIPMENT_ID</Type>'+
                            '<Value>070358180009382</Value>'+
                        '</PackageIdentifier>'+
                    '</OtherIdentifiers>'+
                    '<OtherIdentifiers>'+
                        '<PackageIdentifier>'+
                            '<Type>TRACKING_NUMBER_OR_DOORTAG</Type>'+
                            '<Value>DT702040788974</Value>'+
                        '</PackageIdentifier>'+
                    '</OtherIdentifiers>'+
                    '<OtherIdentifiers>'+
                        '<PackageIdentifier>'+
                            '<Type>CUSTOMER_REFERENCE</Type>'+
                            '<Value>15241402</Value>'+
                        '</PackageIdentifier>'+
                    '</OtherIdentifiers>'+
                    '<Service>'+
                        '<Type>GROUND_HOME_DELIVERY</Type>'+
                        '<Description>FedEx Home Delivery</Description>'+
                        '<ShortDescription>HD</ShortDescription>'+
                    '</Service>'+
                    '<PackageWeight>'+
                        '<Units>LB</Units>'+
                        '<Value>2.0</Value>'+
                    '</PackageWeight>'+
                    '<PackageDimensions>'+
                        '<Length>15</Length>'+
                        '<Width>12</Width>'+
                        '<Height>5</Height>'+
                        '<Units>IN</Units>'+
                    '</PackageDimensions>'+
                    '<Packaging>'+
                        '<Type>YOUR_PACKAGING</Type>'+
                        '<Description>Package</Description>'+
                    '</Packaging>'+
                    '<PhysicalPackagingType>PACKAGE</PhysicalPackagingType>'+
                    '<PackageSequenceNumber>1</PackageSequenceNumber>'+
                    '<PackageCount>1</PackageCount>'+
                    '<ShipmentContentPieceCount>0</ShipmentContentPieceCount>'+
                    '<PackageContentPieceCount>0</PackageContentPieceCount>'+
                    '<Payments>'+
                        '<Classification>TRANSPORTATION</Classification>'+
                        '<Type>THIRD_PARTY_ACCOUNT</Type>'+
                        '<Description>Third Party</Description>'+
                    '</Payments>'+
                    '<ShipperAddress>'+
                        '<City>Itasca</City>'+
                        '<StateOrProvinceCode>IL</StateOrProvinceCode>'+
                        '<CountryCode>US</CountryCode>'+
                        '<CountryName>United States</CountryName>'+
                        '<Residential>false</Residential>'+
                    '</ShipperAddress>'+
                    '<OriginLocationAddress>'+
                        '<City>CAROL STREAM</City>'+
                        '<StateOrProvinceCode>IL</StateOrProvinceCode>'+
                        '<CountryCode>US</CountryCode>'+
                        '<CountryName>United States</CountryName>'+
                        '<Residential>false</Residential>'+
                    '</OriginLocationAddress>'+
                    '<DatesOrTimes>'+
                        '<Type>ACTUAL_PICKUP</Type>'+
                        '<DateOrTimestamp>2016-08-01T00:00:00</DateOrTimestamp>'+
                    '</DatesOrTimes>'+
                    '<DatesOrTimes>'+
                        '<Type>SHIP</Type>'+
                        '<DateOrTimestamp>2020-08-15T00:00:00</DateOrTimestamp>'+
                    '</DatesOrTimes>'+
                    '<LastUpdatedDestinationAddress>'+
                        '<City>Hayward</City>'+
                        '<StateOrProvinceCode>CA</StateOrProvinceCode>'+
                        '<CountryCode>US</CountryCode>'+
                        '<CountryName>United States</CountryName>'+
                        '<Residential>false</Residential>'+
                    '</LastUpdatedDestinationAddress>'+
                    '<DestinationAddress>'+
                        '<City>HAYWARD</City>'+
                        '<StateOrProvinceCode>CA</StateOrProvinceCode>'+
                        '<CountryCode>US</CountryCode>'+
                        '<CountryName>United States</CountryName>'+
                        '<Residential>false</Residential>'+
                    '</DestinationAddress>'+
                    '<DeliveryAttempts>0</DeliveryAttempts>'+
                    '<TotalUniqueAddressCountInConsolidation>0</TotalUniqueAddressCountInConsolidation>'+
                    '<DeliveryOptionEligibilityDetails>'+
                        '<Option>INDIRECT_SIGNATURE_RELEASE</Option>'+
                        '<Eligibility>INELIGIBLE</Eligibility>'+
                    '</DeliveryOptionEligibilityDetails>'+
                    '<DeliveryOptionEligibilityDetails>'+
                        '<Option>REDIRECT_TO_HOLD_AT_LOCATION</Option>'+
                        '<Eligibility>INELIGIBLE</Eligibility>'+
                    '</DeliveryOptionEligibilityDetails>'+
                    '<DeliveryOptionEligibilityDetails>'+
                        '<Option>REROUTE</Option>'+
                        '<Eligibility>INELIGIBLE</Eligibility>'+
                    '</DeliveryOptionEligibilityDetails>'+
                    '<DeliveryOptionEligibilityDetails>'+
                        '<Option>RESCHEDULE</Option>'+
                        '<Eligibility>INELIGIBLE</Eligibility>'+
                    '</DeliveryOptionEligibilityDetails>'+
                    '<Events>'+
                        '<Timestamp>2014-01-02T18:45:00-06:00</Timestamp>'+
                        '<EventType>CA</EventType>'+
                        '<EventDescription>Shipment cancelled by sender</EventDescription>'+
                        '<Address>'+
                            '<PostalCode>60188</PostalCode>'+
                            '<CountryCode>US</CountryCode>'+
                            '<CountryName>United States</CountryName>'+
                            '<Residential>false</Residential>'+
                        '</Address>'+
                        '<ArrivalLocation>CUSTOMER</ArrivalLocation>'+
                    '</Events>'+
                '</TrackDetails>'+
            '</CompletedTrackDetails>'+
        '</TrackReply>'+
    '</SOAP-ENV:Body>'+
'</SOAP-ENV:Envelope>';
        
    //return xmlReq.getXmlString();
    return re;
    }
}