import { LightningElement, api } from 'lwc';
import getDistributorOptionsForLead from '@salesforce/apex/DistributorController.getDistributorOptionsForLead';
import saveSelectedDistributor from '@salesforce/apex/DistributorController.saveSelectedDistributor';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DistributorSelector extends LightningElement {
    @api recordId;
    useLeadOwner = false;
    options = [];
    value = '';
    loading = false;

    handleCheckboxChange(event) {
        this.useLeadOwner = event.target.checked;
        this.value = '';
        this.options = [];
        if (this.useLeadOwner) {
            this.loadOptions();
        }
    }

    loadOptions() {
        if (!this.recordId) return;
        this.loading = true;
        getDistributorOptionsForLead({ leadId: this.recordId })
            .then((res) => {
                //this.options = res.map(r => ({ label: r.name, value: r.id }));
                this.options = res.map(r => ({ label: r.name, value: r.id }));
            })
            .catch((error) => {
                this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: error?.body?.message || error.message, variant: 'error' }));
            })
            .finally(() => { this.loading = false; });
    }

    handleChange(event) {
        this.value = event.detail.value;
    }

    handleSave() {
        if (!this.value) {
            this.dispatchEvent(new ShowToastEvent({ title: 'Select Distributor', message: 'Please choose a distributor before saving.', variant: 'warning' }));
            return;
        }
        this.loading = true;
        saveSelectedDistributor({ leadId: this.recordId, distributorId: this.value })
            .then(() => {
                this.dispatchEvent(new ShowToastEvent({ title: 'Saved', message: 'Forwarded lead to selected distributor.', variant: 'success' }));
                //window.location.reload();
                this.loadOptions(); // Refresh options in case of changes
            })
            .catch((error) => {
                this.dispatchEvent(new ShowToastEvent({ title: 'Error', message: error?.body?.message || error.message, variant: 'error' }));
            })
            .finally(() => { this.loading = false; });
    }
}