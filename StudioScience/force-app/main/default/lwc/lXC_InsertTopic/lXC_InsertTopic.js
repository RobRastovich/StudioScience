import { LightningElement, track, api } from 'lwc';
import insertTopic from '@salesforce/apex/CNT_TopicList.insertTopic';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
export default class LXC_InsertTopic extends LightningElement {
    @track isShowModal = true;
    @track isDisable = true;
    @track isLoading = false;
    @api topicnamesset = new Set();
    @api topicscount;

    hideModalBox(){
        const isShowModal = new CustomEvent('isshowmodal', { detail: "" });
        this.dispatchEvent(isShowModal);
    }

    handleInsertTopic(){
        let topic_Name = this.template.querySelector('lightning-input').value.trim();
        if(topic_Name.length >= 2  && topic_Name.length <= 80){
            if(this.topicnamesset.has(topic_Name.toUpperCase())){
                this.template.querySelector('c-custom-toast').showToast('success', 'The Topic is already added.');
                this.template.querySelector('lightning-input').value = null;
                this.isDisable = true;
                return;
            }
        }else{
            this.template.querySelector('c-custom-toast').showToast('error', 'Please Enter Minimum 2 and Maximum 80 Characters.');
            this.template.querySelector('lightning-input').value = null;
            this.isDisable = true;
            return;
        }
        this.isLoading = true;
        insertTopic({topicName: topic_Name,
        topicscount : this.topicscount})
            .then((result)=>{
                this.isLoading = false;
                const toastEvent = new CustomEvent('showtoast', { detail: result });
                this.dispatchEvent(toastEvent);
            })
            .catch((error)=>{
                this.isLoading = false;
                console.log("error insert topic",error);
        });
        this.template.querySelector('lightning-input').value = null;
        this.isDisable = true;
    }

    handleInsertButton(event) {
        let entred_string = JSON.parse(JSON.stringify(event.detail.value)).trim();
        if(entred_string != null && entred_string != ''){
            if(entred_string.length>0) {
                this.isDisable = false;
            }
            else {
                this.isDisable = true;
            }
        }else{
            this.isDisable = true;
        }
    }
}