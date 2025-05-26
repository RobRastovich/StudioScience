import { LightningElement, api } from 'lwc';

export default class LxcSearchComponent extends LightningElement {

    @api tabledata

    filterData(search_string, table_data) {
        let filter = {};

        try{
            if(search_string.length > 0) {
                table_data.forEach(element => {
                    let keys = Object.keys(element);
                    keys.forEach(k => {
                        if(!filter.hasOwnProperty(element.Id)) {
                            if(element["Name"].toString().toLowerCase().includes(search_string.toLowerCase())){
                                filter[element.Id] = element;
                            }
                        }
                    });
                });
            }
        }
        catch(error){
            console.error(error);
        }

        return filter;
    }
    sendDataToParent(filter, strLen) {
        const selectedEvent = new CustomEvent('eventname', { detail: [Object.values(filter), strLen]});
        this.dispatchEvent(selectedEvent);
    }

    async handleChange(event) {
        let search_string = JSON.parse(JSON.stringify(event.detail.value));
        search_string = search_string.toLowerCase();
        let table_data = JSON.parse(JSON.stringify(this.tabledata));
        let filter = [];
        filter = await this.filterData(search_string, table_data);
        console.log('filter ', filter)
        this.sendDataToParent(filter, search_string.length);
    }
}