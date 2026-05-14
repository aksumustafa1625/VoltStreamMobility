/**
 * @description  Documents LWC. Renders the folder-card header, the filtered
 *               documents table, and a small recent-activity placeholder.
 *               Wires DocumentController for both the table rows and the
 *               folder-card counts.
 *
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */
import { LightningElement, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { NavigationMixin } from 'lightning/navigation';
import { deleteRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getDocuments from '@salesforce/apex/DocumentController.getDocuments';
import getCategoryCounts from '@salesforce/apex/DocumentController.getCategoryCounts';

const CATEGORIES = ['Application Forms', 'Statements', 'Reports', 'Uncategorized'];

export default class DocumentManager extends NavigationMixin(LightningElement) {
    selectedCategory = 'Application Forms';
    searchTerm = '';
    sortField = 'date';

    @track _wiredDocs;
    @track _wiredCounts;

    // ---- Wires ----

    @wire(getDocuments, { category: '$selectedCategory' })
    wiredDocuments(result) {
        this._wiredDocs = result;
    }

    @wire(getCategoryCounts)
    wiredCounts(result) {
        this._wiredCounts = result;
    }

    // ---- Computed: folder cards ----

    get folderCards() {
        const counts = (this._wiredCounts && this._wiredCounts.data) || {};
        return CATEGORIES.map((name) => {
            const fileCount = counts[name] || 0;
            const isSelected = name === this.selectedCategory;
            return {
                name,
                fileCount,
                fileLabel: fileCount === 1 ? '1 file' : `${fileCount} files`,
                cssClass: isSelected ? 'folder-card folder-card_selected' : 'folder-card'
            };
        });
    }

    // ---- Computed: totals shown in the header line ----

    get totalFiles() {
        const counts = (this._wiredCounts && this._wiredCounts.data) || {};
        return Object.values(counts).reduce((a, b) => a + b, 0);
    }

    get totalFolders() {
        return CATEGORIES.length;
    }

    get headerSummary() {
        return `${this.totalFiles} total files across ${this.totalFolders} folders`;
    }

    // ---- Computed: documents table ----

    get filteredDocuments() {
        const rows = (this._wiredDocs && this._wiredDocs.data) || [];
        const term = (this.searchTerm || '').trim().toLowerCase();
        const filtered = term
            ? rows.filter((r) => (r.Name || '').toLowerCase().includes(term))
            : rows;
        return filtered.map((r) => ({
            id: r.Id,
            name: r.Name,
            type: r.File_Type__c || 'FILE',
            size: r.File_Size_KB__c ? `${r.File_Size_KB__c} KB` : '—',
            uploadedBy: r.CreatedBy ? r.CreatedBy.Name : '—',
            date: r.CreatedDate ? r.CreatedDate.substring(0, 10) : '—'
        }));
    }

    get hasFiles() {
        return this.filteredDocuments.length > 0;
    }

    get selectedFolderTitle() {
        return this.selectedCategory;
    }

    get selectedFolderCount() {
        const counts = (this._wiredCounts && this._wiredCounts.data) || {};
        return counts[this.selectedCategory] || 0;
    }

    // ---- Event handlers ----

    handleFolderClick(event) {
        this.selectedCategory = event.currentTarget.dataset.category;
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleSortChange(event) {
        this.sortField = event.detail.value;
    }

    handleUploadClick() {
        this._toast('Upload Files', 'File upload arrives in the next phase.', 'info');
    }

    handleNewFolderClick() {
        this._toast('New Folder', 'Custom folders arrive in the next phase.', 'info');
    }

    handleMenuAction(event) {
        const action = event.detail.value;
        const recordId = event.currentTarget.dataset.id;
        const recordName = event.currentTarget.dataset.name;

        switch (action) {
            case 'View':
                this._navigateToRecord(recordId);
                break;
            case 'Delete':
                this._deleteDocument(recordId, recordName);
                break;
            case 'Download':
                this._toast('Download', 'File download arrives once real file storage is wired up (phase 2).', 'info');
                break;
            case 'Share':
                this._toast('Share', 'Sharing arrives once real file storage is wired up (phase 2).', 'info');
                break;
            default:
                break;
        }
    }

    _navigateToRecord(recordId) {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                objectApiName: 'Document__c',
                actionName: 'view'
            }
        });
    }

    async _deleteDocument(recordId, recordName) {
        try {
            await deleteRecord(recordId);
            this._toast('Deleted', `${recordName} was deleted.`, 'success');
            this.refresh();
        } catch (error) {
            const msg = (error && error.body && error.body.message) || 'Could not delete the record.';
            this._toast('Error', msg, 'error');
        }
    }

    refresh() {
        if (this._wiredDocs) refreshApex(this._wiredDocs);
        if (this._wiredCounts) refreshApex(this._wiredCounts);
    }

    // ---- Helpers ----

    _toast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }

    get sortOptions() {
        return [
            { label: 'Date',  value: 'date' },
            { label: 'Name',  value: 'name' },
            { label: 'Size',  value: 'size' }
        ];
    }
}
