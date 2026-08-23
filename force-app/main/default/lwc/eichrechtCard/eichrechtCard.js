import { LightningElement, api, wire } from 'lwc';
import ladeEichrecht from '@salesforce/apex/EichrechtCardController.ladeEichrecht';

// The card paints every coloured mark as an inline <svg fill="currentColor"> or a text bullet,
// so a plain `color` declaration is all it takes. SLDS custom properties are deliberately not
// used for this: their inheritance across shadow boundaries is unreliable between SLDS
// generations and fails silently, leaving the mark in the default grey.
function farbstil(farbe) {
    return `color: ${farbe};`;
}

function deutschesDatum(iso) {
    if (!iso) {
        return '—';
    }
    const [jahr, monat, tag] = iso.split('-');
    return `${tag}.${monat}.${jahr}`;
}

export default class EichrechtCard extends LightningElement {
    @api recordId;

    daten;
    fehler;
    laedt = true;
    offeneNormen = {};

    @wire(ladeEichrecht, { ladepunktId: '$recordId' })
    verdrahtet({ data, error }) {
        this.laedt = false;
        if (data) {
            this.daten = data;
            this.fehler = undefined;
        } else if (error) {
            this.daten = undefined;
            this.fehler = error.body ? error.body.message : 'Der Eichrechtstatus konnte nicht geladen werden.';
        }
    }

    get statusStyle() {
        return farbstil(this.daten ? this.daten.farbe : '#747474');
    }

    get statusRandStyle() {
        return `border-left-color: ${this.daten ? this.daten.farbe : '#747474'};`;
    }

    get stichtagText() {
        return this.daten ? `Stand ${deutschesDatum(this.daten.stichtag)}` : '';
    }

    // Dates are hidden rather than shown empty for the two non-answers. A card that prints
    // "Fristende —" next to "Unbekannt" invites the reader to treat the blank as a value.
    get zeigtFristen() {
        return !!(this.daten && this.daten.fristende);
    }

    get fristbeginnText() {
        return deutschesDatum(this.daten && this.daten.fristbeginn);
    }

    get fristendeText() {
        return deutschesDatum(this.daten && this.daten.fristende);
    }

    get restlaufzeitText() {
        const tage = this.daten && this.daten.tageBisAblauf;
        if (tage === null || tage === undefined) {
            return '—';
        }
        if (tage > 0) {
            return `noch ${tage} Tage`;
        }
        if (tage === 0) {
            return 'läuft heute ab';
        }
        return `seit ${Math.abs(tage)} Tagen abgelaufen`;
    }

    get hatRechtsgrundlagen() {
        return !!(this.daten && this.daten.rechtsgrundlagen.length);
    }

    get normen() {
        if (!this.daten) {
            return [];
        }
        return this.daten.rechtsgrundlagen.map((n) => {
            const offen = !!this.offeneNormen[n.schluessel];
            return { ...n, offen, pfeil: offen ? '▾' : '▸' };
        });
    }

    get hatVerlauf() {
        return !!(this.daten && this.daten.verlauf.length);
    }

    get verlauf() {
        if (!this.daten) {
            return [];
        }
        return this.daten.verlauf.map((v) => ({
            ...v,
            datumText: deutschesDatum(v.datum),
            punktStyle: farbstil(v.farbe)
        }));
    }

    toggleNorm(event) {
        const schluessel = event.currentTarget.dataset.schluessel;
        // Reassigned rather than mutated: LWC tracks the reference, not the keys inside it.
        this.offeneNormen = {
            ...this.offeneNormen,
            [schluessel]: !this.offeneNormen[schluessel]
        };
    }
}
