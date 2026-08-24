// A live call to the public Overpass API. No key, no fixture, no mock.
//
// Bounding box: central Berlin around Alexanderplatz. Whatever OpenStreetMap holds for that square
// today is what lands in the org - including the gaps, which are the point.
OsmLadepunktImport.Ergebnis e = OsmLadepunktImport.importiereBereich(52.51, 13.38, 52.53, 13.42, 25);

System.debug(LoggingLevel.ERROR, '');
System.debug(LoggingLevel.ERROR, 'Spiegel      : ' + e.spiegel);
System.debug(LoggingLevel.ERROR, 'Gelesen      : ' + e.gelesen);
System.debug(LoggingLevel.ERROR, 'Uebernommen  : ' + e.uebernommen);
System.debug(LoggingLevel.ERROR, 'Ohne Betreiber: ' + e.ohneBetreiber);
System.debug(LoggingLevel.ERROR, e.hinweis);
System.debug(LoggingLevel.ERROR, '');

for (Ladepunkt__c lp : [SELECT Name, Quell_ID__c, Betreiber__r.Name, Ladeleistung_kW__c,
                               Stromart__c, Standort_Adresse__c, Eichstatus__c
                        FROM Ladepunkt__c WHERE Datenquelle__c = 'OpenStreetMap'
                        ORDER BY Betreiber__r.Name NULLS LAST, Name LIMIT 12]) {
  System.debug(LoggingLevel.ERROR, String.format('{0} | {1} | {2} | {3} kW {4} | {5}',
    new List<String>{
      lp.Name,
      (lp.Betreiber__r.Name == null ? '(ohne Betreiber)' : lp.Betreiber__r.Name).abbreviate(24),
      lp.Eichstatus__c,
      String.valueOf(lp.Ladeleistung_kW__c),
      (lp.Stromart__c == null ? '--' : lp.Stromart__c),
      lp.Standort_Adresse__c.abbreviate(40)
    }));
}
