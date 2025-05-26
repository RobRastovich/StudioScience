public with sharing virtual class PageControllerBase {
	
  private ComponentControllerBase myComponentController;
	
  public virtual ComponentControllerBase getMyComponentController() {
    return myComponentController;
  }

  public virtual void setComponentController(ComponentControllerBase compController) {
    myComponentController = compController;
  }
	
  public PageControllerBase getThis() {
    return this;
  }
  
  public virtual void RefreshPage() {
  	
  }	
}