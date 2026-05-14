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
import uploadDocument from '@salesforce/apex/DocumentController.uploadDocument';

const CATEGORIES = ['Application Forms', 'Statements', 'Reports', 'Uncategorized'];
const COLOR_CLASSES = {
    'Application Forms': 'dm-icon_orange',
    'Statements':        'dm-icon_green',
    'Reports':           'dm-icon_purple',
    'Uncategorized':     'dm-icon_gray'
};

export default class DocumentManager extends NavigationMixin(LightningElement) {
    selectedCategory = 'Application Forms';
    searchTerm = '';
    sortField = 'date';

    // Upload modal state
    showUploadModal = false;
    uploadCategory = 'Application Forms';
    uploadFileName = '';
    uploadFileBase64 = null;
    uploadFileSizeKB = 0;
    uploadFileType = 'PDF';
    isUploading = false;

    // New folder modal state
    showNewFolderModal = false;

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
            const colorClass = COLOR_CLASSES[name] || 'dm-icon_gray';
            return {
                name,
                fileCount,
                fileLabel: fileCount === 1 ? '1 file' : `${fileCount} files`,
                cssClass: isSelected
                    ? `folder-card folder-card_selected ${colorClass}`
                    : `folder-card ${colorClass}`,
                iconClass: `folder-icon ${colorClass}`
            };
        });
    }

    get selectedFolderIconClass() {
        const colorClass = COLOR_CLASSES[this.selectedCategory] || 'dm-icon_gray';
        return `folder-icon-inline ${colorClass}`;
    }

    get folderOptions() {
        return CATEGORIES.map((c) => ({ label: c, value: c }));
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
        return filtered.map((r) => {
            const links = r.ContentDocumentLinks || {};
            const linkRows = Array.isArray(links) ? links : (links.records || []);
            const cdId = linkRows.length > 0 ? linkRows[0].ContentDocumentId : null;
            return {
                id: r.Id,
                name: r.Name,
                type: r.File_Type__c || 'FILE',
                size: r.File_Size_KB__c ? `${r.File_Size_KB__c} KB` : '—',
                uploadedBy: r.CreatedBy ? r.CreatedBy.Name : '—',
                date: r.CreatedDate ? r.CreatedDate.substring(0, 10) : '—',
                contentDocumentId: cdId
            };
        });
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

    get isUploadDisabled() {
        return this.isUploading || !this.uploadFileBase64 || !this.uploadFileName;
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

    handleNameClick(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset.id;
        const cdId = event.currentTarget.dataset.cdid;
        this._openDocument(recordId, cdId);
    }

    handleMenuAction(event) {
        const action = event.detail.value;
        const recordId = event.currentTarget.dataset.id;
        const recordName = event.currentTarget.dataset.name;
        const cdId = event.currentTarget.dataset.cdid;

        switch (action) {
            case 'View':
                this._openDocument(recordId, cdId);
                break;
            case 'Delete':
                this._deleteDocument(recordId, recordName);
                break;
            case 'Download':
                if (cdId) {
                    this._downloadDocument(cdId);
                } else {
                    this._toast('Download', 'This is a metadata-only record (no file content). Upload a real file via Upload Files.', 'info');
                }
                break;
            case 'Share':
                this._toast('Share', 'Sharing arrives in phase 3 (Chatter/external link).', 'info');
                break;
            default:
                break;
        }
    }

    // ---- Upload modal ----

    handleUploadClick() {
        this.showUploadModal = true;
        this.uploadCategory = this.selectedCategory;
        this.uploadFileName = '';
        this.uploadFileBase64 = null;
        this.uploadFileSizeKB = 0;
        this.uploadFileType = 'PDF';
    }

    closeUploadModal() {
        this.showUploadModal = false;
    }

    handleUploadCategoryChange(event) {
        this.uploadCategory = event.detail.value;
    }

    handleFilePicked(event) {
        const file = event.target.files && event.target.files[0];
        if (!file) {
            return;
        }
        this.uploadFileName = file.name;
        this.uploadFileSizeKB = Math.max(1, Math.round(file.size / 1024));
        const ext = (file.name.split('.').pop() || 'FILE').toUpperCase();
        this.uploadFileType = ext.substring(0, 10);

        const reader = new FileReader();
        reader.onload = () => {
            const result = reader.result || '';
            this.uploadFileBase64 = result.split(',')[1] || null;
        };
        reader.onerror = () => {
            this._toast('Error', 'Could not read the selected file.', 'error');
        };
        reader.readAsDataURL(file);
    }

    async handleUploadSubmit() {
        if (this.isUploadDisabled) return;
        this.isUploading = true;
        try {
            await uploadDocument({
                fileName: this.uploadFileName,
                category: this.uploadCategory,
                fileType: this.uploadFileType,
                fileSizeKB: this.uploadFileSizeKB,
                base64Content: this.uploadFileBase64
            });
            this._toast('Uploaded', `${this.uploadFileName} uploaded to ${this.uploadCategory}.`, 'success');
            this.showUploadModal = false;
            this.selectedCategory = this.uploadCategory;
            this.refresh();
        } catch (error) {
            const msg = (error && error.body && error.body.message) || 'Upload failed.';
            this._toast('Error', msg, 'error');
        } finally {
            this.isUploading = false;
        }
    }

    // ---- New Folder modal ----

    handleNewFolderClick() {
        this.showNewFolderModal = true;
    }

    closeNewFolderModal() {
        this.showNewFolderModal = false;
    }

    // ---- Helpers ----

    _openDocument(recordId, contentDocumentId) {
        // If the document has a real linked file, open the Salesforce file preview;
        // otherwise fall back to the record detail page.
        if (contentDocumentId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: { pageName: 'filePreview' },
                state: { selectedRecordId: contentDocumentId }
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId,
                    objectApiName: 'Document__c',
                    actionName: 'view'
                }
            });
        }
    }

    _downloadDocument(contentDocumentId) {
        // Salesforce serves the latest file binary at this servlet path.
        const url = `/sfc/servlet.shepherd/document/download/${contentDocumentId}`;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: { url }
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
