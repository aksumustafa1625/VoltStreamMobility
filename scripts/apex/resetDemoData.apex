/**
 * resetDemoData.apex
 *
 * Clears the org of the stock Salesforce sample dataset (United Oil, Grand
 * Hotels, GenWatt generators) plus the first-generation VoltStream demo records,
 * so seedGermanCatalog.apex can rebuild a coherent German world on top.
 *
 * Reseller__c and Document__c are deliberately left alone — they are VoltStream's
 * own objects and are re-seeded separately.
 *
 * Safe to re-run: every delete is driven by a query, so a second run finds
 * nothing and reports zeros.
 *
 * Run:  sf apex run --file scripts/apex/resetDemoData.apex -o VoltStreamDev
 */

// The standard pricebook ships inactive in this org and CPQ pricing needs it on.
Pricebook2 std = [SELECT Id, Name, IsActive FROM Pricebook2 WHERE IsStandard = true LIMIT 1];
if (!std.IsActive) {
    std.IsActive = true;
    update std;
    System.debug(LoggingLevel.ERROR, 'Standard Price Book activated.');
}

Integer cases = 0, leads = 0, opps = 0, contacts = 0, accts = 0, pbes = 0, prods = 0;

// Order matters: children first, then parents, then catalog.
List<Case> cs = [SELECT Id FROM Case LIMIT 50000];
if (!cs.isEmpty()) { delete cs; cases = cs.size(); }

List<Lead> ls = [SELECT Id FROM Lead LIMIT 50000];
if (!ls.isEmpty()) { delete ls; leads = ls.size(); }

List<Opportunity> os = [SELECT Id FROM Opportunity LIMIT 50000];
if (!os.isEmpty()) { delete os; opps = os.size(); }

List<Contact> cts = [SELECT Id FROM Contact LIMIT 50000];
if (!cts.isEmpty()) { delete cts; contacts = cts.size(); }

// Entitlements hold a hard lock on their Account and block the delete outright.
List<Entitlement> ents = [SELECT Id FROM Entitlement LIMIT 50000];
if (!ents.isEmpty()) { delete ents; }

// allOrNone = false: one undeletable account must not abort the whole purge.
List<Account> accs = [SELECT Id FROM Account LIMIT 50000];
if (!accs.isEmpty()) {
    for (Database.DeleteResult dr : Database.delete(accs, false)) {
        if (dr.isSuccess()) {
            accts++;
        } else {
            System.debug(LoggingLevel.ERROR, 'Account kept: ' + dr.getErrors()[0].getMessage());
        }
    }
}

// PricebookEntry must go before Product2 or the product delete is blocked.
List<PricebookEntry> pes = [SELECT Id FROM PricebookEntry LIMIT 50000];
if (!pes.isEmpty()) { delete pes; pbes = pes.size(); }

List<Product2> ps = [SELECT Id FROM Product2 LIMIT 50000];
if (!ps.isEmpty()) { delete ps; prods = ps.size(); }

System.debug(LoggingLevel.ERROR, String.format(
    'PURGED -> Case:{0} Lead:{1} Opportunity:{2} Contact:{3} Account:{4} PricebookEntry:{5} Product2:{6}',
    new List<Object>{ cases, leads, opps, contacts, accts, pbes, prods }));

System.debug(LoggingLevel.ERROR, String.format(
    'KEPT   -> Reseller__c:{0} Document__c:{1}',
    new List<Object>{ [SELECT COUNT() FROM Reseller__c], [SELECT COUNT() FROM Document__c] }));
