import { LightningElement, track, api } from 'lwc';

export default class LxcDisplayListInPillFormat extends LightningElement {
    @api selecteditems = [];
    @track items;
    @track flagForShow = false;
    @track itemsInMore = []
    @track iconName = "utility:chevronright";
    @track showMorePhills = false;
    
    connectedCallback() {
         this.items = [...this.selecteditems];
         if(this.selecteditems.length>7){
            this.items = [...this.selecteditems].slice(0,7);
            this.flagForShow = true;
            this.itemsInMore = [...this.selecteditems].slice(7);
        }
    }
    @api updateitems(selecteditems){
        this.selecteditems = selecteditems;
        this.items = [...this.selecteditems];
    }
    handleShow(event){
        const formatedText = this.template.querySelector("[data-id='myFormaedText']");
        if(formatedText.value === "Show More"){
            formatedText.value = "Show Less";
            this.iconName = "utility:chevrondown";
            this.showMorePhills = true;
            
        }
        else if(formatedText.value === "Show Less"){
            formatedText.value = "Show More";
            this.iconName = "utility:chevronright";
            this.showMorePhills = false;
        }
    }
    handleItemRemove(event) { 
        var deletedTopic = [];
        var name = event.detail.item.name;
        var topicID = event.detail.item.Id;
        if(name != '' && name != null && name != undefined &&
        topicID != '' && topicID != null && topicID != undefined){
            deletedTopic.push({
                Name: name,
                Id: topicID,
            });
        }
        const index = event.detail.index;
        this.items.splice(index, 1);
        if(this.itemsInMore.length > 0){
            this.items.push(this.itemsInMore[0]);
            this.itemsInMore.splice(0,1);
            if(this.itemsInMore.length === 0){
                this.flagForShow = false;
            }
        }
        const selectEvent = new CustomEvent('deletetopic', {
            detail: deletedTopic
        });
        this.dispatchEvent(selectEvent);
    }
    handleItemRemoveExpand(event) { 
        var deletedTopic = [];
        const index = event.detail.index;
        var name = event.detail.item.name;
        var topicID = event.detail.item.Id;
        if(name != '' && name != null && name != undefined &&
        topicID != '' && topicID != null && topicID != undefined){
            deletedTopic.push({
                Name: name,
                Id: topicID,
            });
        }
        this.itemsInMore.splice(index, 1);
        if(this.itemsInMore.length == 0){
            this.flagForShow = false;
        }
        const selectEvent = new CustomEvent('deletetopic', {
            detail: deletedTopic
        });
        this.dispatchEvent(selectEvent);
    }
}