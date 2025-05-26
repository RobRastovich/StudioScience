public class Controller_Formatted_Datetime
{
public DateTime date_time { get; set; } //property that reads the datetime value from component attribute tag
public String defined_format { get; set;} //property that reads the string value from component attribute tag

    public Controller_Formatted_Datetime(){
        
    }
    
    public Controller_Formatted_Datetime(DateTime date_time, String defined_format){
        this.date_time=date_time;
        this.defined_format=defined_format;
    }    
    
public String getFormattedDatetime()
{
    if (date_time == null) 
    {
    return ''; 
    }
    else
    { 
     if(defined_format == null) {
        return date_time.format(); //return the full date/time in user's locale and time zone
        }
        else 
        { 
            return date_time.format(defined_format,'CST'); //Specify Time zone like IST,CST
        }
    }
}
}