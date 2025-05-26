public class ShipmentResponseWrapper{
    public String trackDetailNotificationCode {get; set;}
    public String code {get; set;}
    public String description {get; set;}
    public String severity {get; set;}
    public Date estimatedDeliveryDate {get; set;}
    
    public ShipmentResponseWrapper(String trackDetailNotificationCode, 
                                   String code,
                                   String description,
                                   String severity,
                                   Date estimatedDeliveryDate){
                                       this.trackDetailNotificationCode = trackDetailNotificationCode;
                                       this.code = code;
                                       this.description = description;
                                       this.severity  = severity;
                                       this.estimatedDeliveryDate = estimatedDeliveryDate;
                                   }
}