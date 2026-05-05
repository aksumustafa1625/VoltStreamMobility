/**
 * @description  VoltStream Mobility demo seed script. Wipes prior demo
 *               records and re-seeds a clean baseline of 6 Resellers and
 *               10 Opportunities so the OpportunityTrigger can be observed
 *               in a real org transaction (matched, no-match, inactive,
 *               direct-deal, and case-insensitive scenarios).
 *
 *               IDEMPOTENT: every run first deletes any existing demo
 *               records (Opportunities with the '[Demo]' name prefix and
 *               Resellers matching the seeded email set), so it is safe
 *               to run repeatedly during testing or right before recording
 *               the portfolio demo.
 *
 *               Run from project root:
 *                 sf apex run --file scripts/apex/seedData.apex
 *
 *               After it finishes, query Opportunity to see the trigger
 *               in action:
 *                 sf data query --query "SELECT Name, Reseller_Email__c, \
 *                                               Reseller__r.Name \
 *                                        FROM Opportunity \
 *                                        WHERE Name LIKE '[Demo]%'"
 *
 * @group        VoltStream Channel Partner Management — Scripts
 * @author       Mustafa Aksu
 * @date         2026-05-05
 */

// ============================================================
// 0. Reseller email keys — single source of truth
// ============================================================
final String EMAIL_BERLIN_ELEKTRO  = 'kontakt@berlin-elektrotechnik.de';
final String EMAIL_MERCEDES_BERLIN = 'fleet@mercedes-benz-berlin-mitte.de';
final String EMAIL_MEDIAMARKT      = 'partner@mediamarkt.de';
final String EMAIL_STEIGENBERGER   = 'partner@steigenberger.com';
final String EMAIL_APCOA           = 'b2b@apcoa-parking.de';
final String EMAIL_STADTWERKE      = 'channel@swm.de';

Set<String> seededEmails = new Set<String>{
    EMAIL_BERLIN_ELEKTRO, EMAIL_MERCEDES_BERLIN, EMAIL_MEDIAMARKT,
    EMAIL_STEIGENBERGER, EMAIL_APCOA, EMAIL_STADTWERKE
};

// ============================================================
// 1. Wipe prior demo data so the script is idempotent
// ============================================================
List<Opportunity> oldOpps = [
    SELECT Id FROM Opportunity WHERE Name LIKE '[Demo]%'
];
if (!oldOpps.isEmpty()) {
    delete oldOpps;
    System.debug('Deleted ' + oldOpps.size() + ' prior demo Opportunities.');
}

List<Reseller__c> oldResellers = [
    SELECT Id FROM Reseller__c WHERE Company_Email__c IN :seededEmails
];
if (!oldResellers.isEmpty()) {
    delete oldResellers;
    System.debug('Deleted ' + oldResellers.size() + ' prior demo Resellers.');
}

// ============================================================
// 2. Insert 6 Resellers (one per channel-partner segment)
// ============================================================
List<Reseller__c> resellers = new List<Reseller__c>{
    new Reseller__c(
        Name = 'Berlin Elektrotechnik GmbH',
        Company_Email__c = EMAIL_BERLIN_ELEKTRO,
        Reseller_Type__c = 'Electrical Contractor',
        Country__c = 'Germany',
        Phone__c = '+49 30 1234567',
        Active__c = true
    ),
    new Reseller__c(
        Name = 'Mercedes-Benz Berlin Mitte',
        Company_Email__c = EMAIL_MERCEDES_BERLIN,
        Reseller_Type__c = 'Auto Dealer',
        Country__c = 'Germany',
        Phone__c = '+49 30 2345678',
        Active__c = true
    ),
    new Reseller__c(
        Name = 'MediaMarkt Deutschland',
        Company_Email__c = EMAIL_MEDIAMARKT,
        Reseller_Type__c = 'Mall',
        Country__c = 'Germany',
        Phone__c = '+49 89 3456789',
        Active__c = true
    ),
    new Reseller__c(
        Name = 'Steigenberger Hotels',
        Company_Email__c = EMAIL_STEIGENBERGER,
        Reseller_Type__c = 'Hotel Chain',
        Country__c = 'Germany',
        Phone__c = '+49 69 4567890',
        Active__c = true
    ),
    new Reseller__c(
        Name = 'APCOA Parking Deutschland',
        Company_Email__c = EMAIL_APCOA,
        Reseller_Type__c = 'Parking Operator',
        Country__c = 'Germany',
        Phone__c = '+49 711 5678901',
        Active__c = true
    ),
    // One inactive partner so the trigger has a reason to NOT match — useful in the demo
    new Reseller__c(
        Name = 'Stadtwerke München (Legacy)',
        Company_Email__c = EMAIL_STADTWERKE,
        Reseller_Type__c = 'Energy Company',
        Country__c = 'Germany',
        Phone__c = '+49 89 6789012',
        Active__c = false
    )
};
insert resellers;
System.debug('Inserted ' + resellers.size() + ' Resellers.');

// ============================================================
// 3. Insert 10 Opportunities — trigger will auto-link Reseller__c
// ============================================================
// Mix of stages, amounts, and matching scenarios so the report/dashboard
// has visual variety. Amounts roughly reflect VoltStream's price catalog.
List<Opportunity> opps = new List<Opportunity>{
    // Hotel chain — large rollout, late stage
    new Opportunity(
        Name = '[Demo] Steigenberger Frankfurt — 12x AC Pro 22kW',
        StageName = 'Negotiation/Review',
        CloseDate = Date.today().addDays(14),
        Amount = 37056,
        Reseller_Email__c = EMAIL_STEIGENBERGER
    ),
    // Auto dealer — mid stage, mid size
    new Opportunity(
        Name = '[Demo] Mercedes Berlin — 4x DC 50kW Showroom',
        StageName = 'Proposal/Price Quote',
        CloseDate = Date.today().addDays(30),
        Amount = 72000,
        Reseller_Email__c = EMAIL_MERCEDES_BERLIN
    ),
    // Electrical contractor — small wallbox bundle
    new Opportunity(
        Name = '[Demo] Berlin Elektrotechnik — 8x Home AC 11kW',
        StageName = 'Qualification',
        CloseDate = Date.today().addDays(45),
        Amount = 9600,
        Reseller_Email__c = EMAIL_BERLIN_ELEKTRO
    ),
    // Mall — case-insensitive email test (UPPERCASE input!)
    new Opportunity(
        Name = '[Demo] MediaMarkt Köln — 6x Pro AC 22kW (case test)',
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(60),
        Amount = 15000,
        Reseller_Email__c = 'PARTNER@MEDIAMARKT.DE'
    ),
    // Parking operator — large DC rollout
    new Opportunity(
        Name = '[Demo] APCOA Stuttgart — 3x DC Ultra 150kW',
        StageName = 'Value Proposition',
        CloseDate = Date.today().addDays(75),
        Amount = 135000,
        Reseller_Email__c = EMAIL_APCOA
    ),
    // Hotel chain second deal — closed won
    new Opportunity(
        Name = '[Demo] Steigenberger Berlin — 6x AC Pro 22kW',
        StageName = 'Closed Won',
        CloseDate = Date.today().addDays(-7),
        Amount = 18000,
        Reseller_Email__c = EMAIL_STEIGENBERGER
    ),
    // Auto dealer second deal — closed won
    new Opportunity(
        Name = '[Demo] Mercedes Berlin — 1x HyperCharge 350kW Flagship',
        StageName = 'Closed Won',
        CloseDate = Date.today().addDays(-30),
        Amount = 95000,
        Reseller_Email__c = EMAIL_MERCEDES_BERLIN
    ),
    // INACTIVE reseller — trigger should leave Reseller__c null
    new Opportunity(
        Name = '[Demo] Stadtwerke München — should not match (inactive)',
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(90),
        Amount = 25000,
        Reseller_Email__c = EMAIL_STADTWERKE
    ),
    // NO MATCH — unknown email, lookup stays null silently
    new Opportunity(
        Name = '[Demo] Unknown reseller deal — no match expected',
        StageName = 'Prospecting',
        CloseDate = Date.today().addDays(45),
        Amount = 5000,
        Reseller_Email__c = 'unknown@nobody-knows-this.de'
    ),
    // DIRECT DEAL — null email, lookup stays null
    new Opportunity(
        Name = '[Demo] Direct enterprise deal — no reseller channel',
        StageName = 'Negotiation/Review',
        CloseDate = Date.today().addDays(20),
        Amount = 50000,
        Reseller_Email__c = null
    )
};
insert opps;
System.debug('Inserted ' + opps.size() + ' Opportunities.');

// ============================================================
// 4. Verify trigger results
// ============================================================
List<Opportunity> verify = [
    SELECT Name, Reseller_Email__c, Reseller__c, Reseller__r.Name, Reseller__r.Reseller_Type__c
    FROM Opportunity
    WHERE Id IN :opps
    ORDER BY Name
];

Integer matched   = 0;
Integer unmatched = 0;
for (Opportunity o : verify) {
    if (o.Reseller__c != null) {
        matched++;
        System.debug('  MATCH: ' + o.Name + ' -> ' + o.Reseller__r.Name + ' (' + o.Reseller__r.Reseller_Type__c + ')');
    } else {
        unmatched++;
        System.debug('  no match: ' + o.Name + ' (email=' + o.Reseller_Email__c + ')');
    }
}

System.debug('==========================================');
System.debug('Seed complete. ' + verify.size() + ' Opportunities total.');
System.debug('  Matched to a reseller: ' + matched);
System.debug('  No match (expected for 3 records): ' + unmatched);
System.debug('==========================================');
