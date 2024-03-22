import {
    LightningElement,
    track,
    api,
    wire
} from 'lwc';
import getUpgradeForecast from '@salesforce/apex/UpgradeForecastController.getUpgradeForecast';
import {
    getRecord
} from 'lightning/uiRecordApi';
export default class UpgradeForecast extends LightningElement {
    @track bShowModal = false;
    @api recordId;
    @wire(getUpgradeForecast, {
        accId: '$recordId'
    }) wrapperReturned;
    @track columnList = [];
    @track rowList = [];
    @track listOfForecastResponses = [];
    @track ListRecordToShow = [];

    /* javaScipt functions start */
    openModal() {
        var parseDataResponse = JSON.parse(this.wrapperReturned.data.response);
        var listOfForecastResponse = parseDataResponse.listForecast;
        var setOfRows = new Set();
        var setOfColumns = new Set();
        for (var forecastData in listOfForecastResponse) {
            var tempVar = listOfForecastResponse[forecastData];
            setOfColumns.add(tempVar.weekNumber);
            setOfRows.add(tempVar.packageName);
        }
        var ListRecordToShow = [];
        var convrtSetOfRowToList = Array.from(setOfRows);
        for (var setOfRow in convrtSetOfRowToList) {
            var tempVarRow = convrtSetOfRowToList[setOfRow];
            var listOfData = [];
            for (var forecastData in listOfForecastResponse) {
                var tempVar = listOfForecastResponse[forecastData];
                if (tempVar.packageName == tempVarRow) {
                    listOfData.push(
                        tempVar.totalAmount
                    );

                }
            }
            ListRecordToShow.push({
                pacakagename: tempVarRow,
                listdatas: listOfData
            });
        }
       
        var weekNoAndDates = [];
        var convrtSetOfColToList = Array.from(setOfColumns);
        for (var setOfcol in convrtSetOfColToList) {
            var tempVarcol = convrtSetOfColToList[setOfcol];
            // var listofData = [];
            for (var forecastData in listOfForecastResponse) {
                var tempVar = listOfForecastResponse[forecastData];
                if (tempVar.weekNumber == tempVarcol) {
                    weekNoAndDates.push({
                        weekno: (tempVarcol + 1),
                        startdate: tempVar.startDate,
                        enddate: tempVar.endDate,
                    });
                    break;
                }
            }

        }
       
        this.columnList = weekNoAndDates;
        this.rowList = ListRecordToShow;
       
        this.listOfForecastResponses = listOfForecastResponse;
        // to open modal window set 'bShowModal' tarck value as true
        this.bShowModal = true;
    }

    closeModal() {
        // to close modal window set 'bShowModal' tarck value as false
        this.bShowModal = false;
    }
    /* javaScipt functions end */
}