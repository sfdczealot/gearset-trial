/**
 * Utility class to hold tab information for Technical product MLE editor.
 */
public class TechnicalProductTabInformation implements Comparable {

    public Boolean active{get;set;}
    public String htmlId{get;set;}
    public String configurationId {get;set;}
    public String url{get;set;}
    public String name{get;set;}
    public String classAdditionTab{get;set;}
    public String classAdditionLi{get;set;}
    public Integer tabOrder {get;set;}
    public Boolean loadOnSelect {get;set;}
    public Integer configurationNumber {get;set;}
    public Boolean isValid { get; set; }

    /**
     * Constructor.
     */
    public TechnicalProductTabInformation(String name, Id idForHtml, String configurationId, String url, Integer tabOrder, Boolean loadOnSelect, Integer configurationNumber) {
        this.active = false;
        this.htmlId = idForHtml;
        this.url = url;
        this.name = name;
        this.tabOrder = tabOrder;
        this.loadOnSelect = loadOnSelect;
        this.configurationId = configurationId;
        this.configurationNumber = configurationNumber;
        this.isValid = true; //TODO: ask Kristijan what is behind this property and why it is not populated? it causes errors on client side

        classAdditionTab = 'slds-hide';
        classAdditionLi = '';
    }

    public Integer compareTo(Object compareTo) {
        TechnicalProductTabInformation compareToTab = (TechnicalProductTabInformation)compareTo;

        if (tabOrder == compareToTab.tabOrder) return 0;
        if (tabOrder > compareToTab.tabOrder) return 1;
        return -1;
    }
    public void setActive() {
        active = true;
        classAdditionTab = 'slds-show';
        classAdditionLi = 'slds-active';
    }
}