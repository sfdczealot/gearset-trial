/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to handle update of Currency ISO Code for PC
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2020-11-04      Initial version
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_PCCurrencyIsoCodeUpdate extends CS_ProcessBase {
	@TestVisible
	Map<Id, cscfga__Product_Configuration__c> applicableObjects;

	@TestVisible
	Map<Id, cscfga__Product_Configuration__c> oldObjects;

	public CS_P_PCCurrencyIsoCodeUpdate(Map<Id, cscfga__Product_Configuration__c> oldObjects) {
		super(CS_ProcessDefinition.CONFIGURATION_CURRENCYISOCODEUPDATE, 'CS_P_PCCurrencyIsoCodeUpdate');

		applicableObjects = new Map<Id, cscfga__Product_Configuration__c>();
		this.oldObjects = oldObjects;
	}

	public override void isRecordEligible(SObject obj) {
		cscfga__Product_Configuration__c newPC = (cscfga__Product_Configuration__c) obj;
		applicableObjects.put(newPC.Id, newPC);
		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {
		for (cscfga__Product_Configuration__c newPC : applicableObjects.values()) {
			if (oldObjects.get(newPC.Id) != null
					&& oldObjects.get(newPC.Id).CurrencyIsoCode != null) {
				newPC.CurrencyIsoCode = oldObjects.get(newPC.Id).CurrencyIsoCode;
			} else {
				newPC.CurrencyIsoCode = 'SGD';
			}
		}
	}
}