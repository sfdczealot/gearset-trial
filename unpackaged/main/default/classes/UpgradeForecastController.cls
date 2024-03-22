/* Controller of upgradeForecast component
Test class: UpgradePackageCalculatorSG_Test
Used for fetching the price forecast of an agent till the subscription period*/
public class UpgradeForecastController {

    @AuraEnabled(cacheable = true)
    public static LightningResponse getUpgradeForecast(String accId) {
        try {
            UpgradePackageCalculatorSG.WrapResponseSG objResponse = UpgradePackageCalculatorSG.getUpgradeForecast(accId,null,null,null);
            return new LightningResponse(true, 'Success', JSON.serialize(objResponse));
        
        } catch (Exception ex) { 
            return new LightningResponse(false, ex.getMessage(), '');
        
        }
    
    }     
}