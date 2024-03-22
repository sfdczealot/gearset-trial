/**
 * @description Sales Order hook implementation that enables Sales Order to a custom Apex code bridge. The class can be
 * invoked from a JavaScript code in a Sales Order, e.g.:
 * <pre>
 * Visualforce.remoting.Manager.invokeAction(
 *	 'csmso.CSRemoteActionDelegation.performAction',
 *	 'FulfilmentItemActionInvoker',
 *	 JSON.stringify(dfParams),
 *	 function(result, event) {
 *	 callback(result, event);
 *	 },
 *	 {escape: false}
 * );
 * </pre>
 * Where <em>dfParams</em> is an object that has to be serialised and sent to the Apax class,
 * <em>callback</em> is a function that handles the response. Important: the hook class must be global!
 *
 */
global with sharing class CS_ExchangeRateCalculation implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {

	@TestVisible
	private static Map<String, Double> currencyMap = new Map<String, Double>();

	/**
	 * @description Implementation of the interface. The method receives JSON serialised request and responses with a
	 * JSON structure that can be processed from JavaScript code within a Sales Order.
	 * This method compares Currencies on Sales Order and related RCIP record. If there is a difference function will 
	 * return exchange rate for those currencies. Action will store this in 'Exchange Rate' attribute.
	 *
	 * @param parameters serialised JSON structure as a request
	 * @return serialised JSON structure as a response
	 */
	global String performAction(String params) {

		ExchangeRateAttributes paramsDeserialized = (ExchangeRateAttributes)JSON.deserialize(params, CS_ExchangeRateCalculation.ExchangeRateAttributes.class);

		if(String.isBlank(paramsDeserialized.rcCurrencyIsoCode) || String.isBlank(paramsDeserialized.soCurrencyIsoCode)) {
			return null;
		}
		Decimal exchangeRate = 1.00;

		if ( paramsDeserialized.rcCurrencyIsoCode != paramsDeserialized.soCurrencyIsoCode ){
			exchangeRate = convertCurrency( paramsDeserialized.rcCurrencyIsoCode, paramsDeserialized.soCurrencyIsoCode, 1);
		}

		return JSON.serialize(exchangeRate);
	}

	public class ExchangeRateAttributes {
		public String rcCurrencyIsoCode {get; set;}
		public String soCurrencyIsoCode {get; set;}
	}

	private static Map<String,Double> getCurrencyMap(){
		if (currencyMap.size() == 0){
			for( CurrencyType curr: [SELECT IsoCode, ConversionRate FROM CurrencyType WHERE isActive = true]){			
					currencyMap.put( curr.IsoCode, curr.ConversionRate);		
			}
		}
		return currencyMap;
	}

	// Taken from CurrencyConverterUtility
	public static Decimal convertCurrency( String targetCurrency, String sourceCurrency, Decimal value){
		if ( value == null ) {
			return null;
		}
		currencyMap = getCurrencyMap();

		if( currencyMap.get(targetCurrency) == currencyMap.get(sourceCurrency)){
			return value;
		}
		else if( currencyMap.get(sourceCurrency) == 1){
			return (value * currencyMap.get(targetCurrency)).setscale(6);
		}
		else if( currencyMap.get(targetCurrency) == 1){
			return (value / currencyMap.get(sourceCurrency)).setscale(6);
		}
		else{
			return (value / currencyMap.get(sourceCurrency) * currencyMap.get(targetCurrency)).setscale(6);
		}
	}
}