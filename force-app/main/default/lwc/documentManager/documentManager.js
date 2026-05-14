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
import getRecentActivity from '@salesforce/apex/DocumentController.getRecentActivity';
import uploadDocument from '@salesforce/apex/DocumentController.uploadDocument';
import shareToChatter from '@salesforce/apex/DocumentController.shareToChatter';

const CATEGORIES = ['Application Forms', 'Statements', 'Reports', 'Uncategorized'];
const CATEGORY_COLORS = {
    'Application Forms': '#f59e0b', // orange
    'Statements':        '#10b981', // emerald
    'Reports':           '#8b5cf6', // purple
    'Uncategorized':     '#6b7280'  // gray
};
const TITLE_COLOR    = '#f59e0b';   // top 'Documents' header — amber to match the mockup
const SELECTED_COLOR = '#ffffff';   // selected folder card — icon stays white on the blue fill

// Folder icons are rendered as inline <svg fill="currentColor">, so a plain
// `color` declaration is enough — no SLDS CSS variables, no shadow DOM issues.
function iconStyle(color) {
    return `color: ${color};`;
}

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

    // Share modal state
    showShareModal = false;
    shareRecordId = null;
    shareRecordName = '';
    shareMessage = '';
    isSharing = false;

    @track _wiredDocs;
    @track _wiredCounts;
    @track _wiredRecent;

    // ---- Wires ----

    @wire(getDocuments, { category: '$selectedCategory' })
    wiredDocuments(result) {
        this._wiredDocs = result;
    }

    @wire(getCategoryCounts)
    wiredCounts(result) {
        this._wiredCounts = result;
    }

    @wire(getRecentActivity)
    wiredRecent(result) {
        this._wiredRecent = result;
    }

    // ---- Computed: folder cards ----

    get folderCards() {
        const counts = (this._wiredCounts && this._wiredCounts.data) || {};
        return CATEGORIES.map((name) => {
            const fileCount = counts[name] || 0;
            const isSelected = name === this.selectedCategory;
            const baseColor = CATEGORY_COLORS[name] || CATEGORY_COLORS.Uncategorized;
            return {
                name,
                fileCount,
                fileLabel: fileCount === 1 ? '1 file' : `${fileCount} files`,
                cssClass: isSelected ? 'folder-card folder-card_selected' : 'folder-card',
                iconStyle: iconStyle(isSelected ? SELECTED_COLOR : baseColor)
            };
        });
    }

    get titleIconStyle() {
        return iconStyle(TITLE_COLOR);
    }

    get selectedFolderIconStyle() {
        const color = CATEGORY_COLORS[this.selectedCategory] || CATEGORY_COLORS.Uncategorized;
        return iconStyle(color);
    }

    // ---- Computed: Recent Activity strip ----

    get recentActivity() {
        const rows = (this._wiredRecent && this._wiredRecent.data) || [];
        return rows.map((r) => {
            const color = CATEGORY_COLORS[r.Category__c] || CATEGORY_COLORS.Uncategorized;
            return {
                id: r.Id,
                text: `${r.Name} uploaded to ${r.Category__c}`,
                time: this._relativeTime(r.CreatedDate),
                iconStyle: iconStyle(color)
            };
        });
    }

    get hasRecentActivity() {
        return this.recentActivity.length > 0;
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
                this._openShareModal(recordId, recordName);
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

    // ---- Share modal ----

    _openShareModal(recordId, recordName) {
        this.shareRecordId = recordId;
        this.shareRecordName = recordName;
        this.shareMessage = `Sharing ${recordName} for review.`;
        this.showShareModal = true;
    }

    closeShareModal() {
        this.showShareModal = false;
    }

    handleShareMessageChange(event) {
        this.shareMessage = event.target.value;
    }

    get isShareDisabled() {
        return this.isSharing || !this.shareMessage || !this.shareMessage.trim();
    }

    async handleShareSubmit() {
        if (this.isShareDisabled) return;
        this.isSharing = true;
        const sharedRecordId = this.shareRecordId;
        const sharedRecordName = this.shareRecordName;
        try {
            await shareToChatter({
                recordId: sharedRecordId,
                message: this.shareMessage.trim()
            });
            this._toast('Shared', `Posted to ${sharedRecordName}'s Chatter feed. Opening it now…`, 'success');
            this.showShareModal = false;
            this.refresh();
            // Land the user on the document's record page so they immediately
            // see the Chatter conversation their post just started.
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: sharedRecordId,
                    objectApiName: 'Document__c',
                    actionName: 'view'
                }
            });
        } catch (error) {
            const msg = (error && error.body && error.body.message) || 'Share failed.';
            this._toast('Error', msg, 'error');
        } finally {
            this.isSharing = false;
        }
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
        if (this._wiredRecent) refreshApex(this._wiredRecent);
    }

    _relativeTime(dateString) {
        if (!dateString) return '';
        const then = new Date(dateString).getTime();
        const now = Date.now();
        const diffSec = Math.max(0, Math.floor((now - then) / 1000));
        if (diffSec < 60) return 'just now';
        const diffMin = Math.floor(diffSec / 60);
        if (diffMin < 60) return `${diffMin}m ago`;
        const diffHr = Math.floor(diffMin / 60);
        if (diffHr < 24) return `${diffHr}h ago`;
        const diffDay = Math.floor(diffHr / 24);
        if (diffDay < 30) return `${diffDay}d ago`;
        const diffMon = Math.floor(diffDay / 30);
        return `${diffMon}mo ago`;
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
