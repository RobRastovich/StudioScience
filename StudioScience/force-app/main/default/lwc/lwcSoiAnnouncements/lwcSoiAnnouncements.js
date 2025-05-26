import { LightningElement, wire, track } from 'lwc';
import getAnnouncementsRecords from '@salesforce/apex/CNT_SOI_Announcement.getAnnouncementsRecords';
export default class LwcSoiAnnouncements extends LightningElement {
    announcementsData
    @wire(getAnnouncementsRecords) wiredAnnouncements({ data, error }) {
        if (data) {
            this.announcementsData = data;
        } else if (error) {
            console.log(error);
        }
    }
}