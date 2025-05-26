public class DTC_CaseDetailsResponseWrapper {
    public String result;
    public String error;
    public String message;
    public List<Case> cases;
    public DTC_CaseDetailsResponseWrapper(String result, String error, String message,
        List<Case> cases){
        this.result = result;
        this.error = error;
        this.message = message;
        this.cases = cases;
    }
}