import { LightningElement, api, track } from 'lwc';

export default class LxcPagination extends LightningElement {
    @api startingrecord;
    @api endingrecord;
    @api totalrecordcount;
    @api page;
    @api totalpage;
    @track ispreviousdisable = false;
    @track isnextdisable = false;
    @api pagesize;

    connectedCallback(){
        if(this.totalrecordcount <= this.pagesize){
            this.isnextdisable = true;
        }
        this.ispreviousdisable = true;
    }

    previousHandler() {
        if(this.page == 2){
            this.ispreviousdisable = true;
        } else{
            this.ispreviousdisable = false;
        }
        this.isnextdisable = false;
        this.dispatchEvent(new CustomEvent('previous'));
    }

    nextHandler() {
        if(this.page == this.totalpage - 1){
            this.isnextdisable = true;
        }
        this.ispreviousdisable = false;
        this.dispatchEvent(new CustomEvent('next'));
    }

    @api handleNextPrevButton(ispreviousdisable, isnextdisable){
        this.isnextdisable = isnextdisable;
        this.ispreviousdisable = ispreviousdisable;
    }

    @api handleNextPrevButtonAccess(pagesize, totalrecordcount){
        if(totalrecordcount >  pagesize){
            this.isnextdisable = false;
            this.ispreviousdisable = true;
        }else{
            this.isnextdisable = true;
            this.ispreviousdisable = true;
        }
    }
}