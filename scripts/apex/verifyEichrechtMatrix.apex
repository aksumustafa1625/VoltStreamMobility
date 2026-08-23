// Sixteen cases against the declarative layer.
//
// Two expectations per case on purpose. wantEnde is the CONTRACT of the formula - what the
// declarative layer is built to produce, so this stays a real regression test. statuteEnde is
// what § 34 MessEV actually requires. Where they differ the case is DEFERRED, not PASS and not
// FAIL: the gap is real, it is owned by EichrechtService, and printing both numbers keeps it
// from being quietly rounded into a green run.
Map<String, String> wantStatus = new Map<String, String>{
  'A' => 'GUELTIG',                     'B' => 'ABGELAUFEN',
  'C' => 'GESCHUETZT (S 38)',           'D' => 'ERMESSEN (S 38)',
  'E' => 'GUELTIG',                     'F' => 'BETRIEB GESPERRT (S 37 VI)',
  'G' => 'VORZEITIG BEENDET (S 37 II)', 'H' => 'GUELTIG',
  'I' => 'UNBEKANNT',                   'J' => 'VORZEITIG BEENDET (S 37 II)',
  'K' => 'GUELTIG',                     'L' => 'VORZEITIG BEENDET (S 37 II)',
  'M' => 'GUELTIG',                     'N' => 'GUELTIG',
  'O' => 'GUELTIG',                     'P' => 'GUELTIG'
};
Map<String, Boolean> want14a = new Map<String, Boolean>{
  'A' => true,  'B' => true,  'C' => false, 'D' => false, 'E' => false, 'F' => false,
  'G' => false, 'H' => false, 'I' => false, 'J' => false, 'K' => false, 'L' => false,
  'M' => false, 'N' => false, 'O' => false, 'P' => false
};
// what the formula is contracted to produce
Map<String, String> wantEnde = new Map<String, String>{
  'A' => '2027-12-31', 'B' => '2023-12-31', 'C' => '2023-12-31', 'D' => '2023-12-31',
  'E' => '2032-12-31', 'F' => '2027-12-31', 'G' => '2027-12-31', 'H' => '2031-12-31',
  'I' => '-',          'J' => '2027-12-31', 'K' => '2027-12-31', 'L' => '2027-12-31',
  'M' => '2027-12-31', 'N' => '2027-12-31', 'O' => '2027-12-31', 'P' => '2032-12-31'
};
// what the statute requires. E differs: calibrated 2024-03-10, after the old period ended
// 2023-12-31, so § 34 Abs. 1 Satz 3 backdates the new period to that end - one year less than
// the formula grants. P is the same fact pattern with the Satz 4 dormancy relief proven, where
// the Tag der Eichung governs and the formula happens to be right.
Map<String, String> statuteEnde = new Map<String, String>{
  'A' => '2027-12-31', 'B' => '2023-12-31', 'C' => '2023-12-31', 'D' => '2023-12-31',
  'E' => '2031-12-31', 'F' => '2027-12-31', 'G' => '2027-12-31', 'H' => '2031-12-31',
  'I' => '-',          'J' => '2027-12-31', 'K' => '2027-12-31', 'L' => '2027-12-31',
  'M' => '2027-12-31', 'N' => '2027-12-31', 'O' => '2027-12-31', 'P' => '2032-12-31'
};

List<Ladepunkt__c> rows = [
  SELECT Standort_Adresse__c, Eichfrist_Ende__c, Eichstatus__c, Paragraph_14a_pflichtig__c,
         Letzte_Eichung__c, Letzter_beendender_Eingriff__c, Sperrende_Eingriffe__c,
         Offene_Nacheichungsantraege__c
  FROM Ladepunkt__c WHERE Standort_Adresse__c LIKE 'PRUEFMATRIX%'
  ORDER BY Standort_Adresse__c LIMIT 50000];

Integer pass = 0, deferred = 0, fail = 0;
System.debug(LoggingLevel.ERROR, 'K | Eichstatus                   | 14a   | Ende(Formel) | Ende(Gesetz) | Eich       | Beend      | Sp | Off | RESULT');
for (Ladepunkt__c r : rows) {
  String k = r.Standort_Adresse__c.substringAfterLast(' ');
  String got = (r.Eichstatus__c == null ? '' : r.Eichstatus__c)
      .replace('Ü','UE').replace('ü','ue').replace('§','S');
  String ende  = (r.Eichfrist_Ende__c              == null) ? '-' : String.valueOf(r.Eichfrist_Ende__c);
  String eich  = (r.Letzte_Eichung__c              == null) ? '-' : String.valueOf(r.Letzte_Eichung__c);
  String beend = (r.Letzter_beendender_Eingriff__c == null) ? '-' : String.valueOf(r.Letzter_beendender_Eingriff__c);
  String sp    = (r.Sperrende_Eingriffe__c         == null) ? '-' : String.valueOf(r.Sperrende_Eingriffe__c.intValue());
  String off   = (r.Offene_Nacheichungsantraege__c == null) ? '-' : String.valueOf(r.Offene_Nacheichungsantraege__c.intValue());
  String law   = statuteEnde.get(k);

  Boolean okS  = got == wantStatus.get(k);
  Boolean ok14 = r.Paragraph_14a_pflichtig__c == want14a.get(k);
  Boolean okE  = ende == wantEnde.get(k);
  Boolean gap  = wantEnde.get(k) != law;

  String verdict;
  if (!(okS && ok14 && okE)) {
    fail++;
    verdict = 'FAIL'
      + (okS  ? '' : ' status<want ' + wantStatus.get(k) + '>')
      + (ok14 ? '' : ' 14a<want '    + want14a.get(k)    + '>')
      + (okE  ? '' : ' ende<want '   + wantEnde.get(k)   + '>');
  } else if (gap) {
    deferred++;
    verdict = 'DEFERRED -> EichrechtService (S 34 I 3 backdating; formula is 1 year generous)';
  } else {
    pass++;
    verdict = 'PASS';
  }
  System.debug(LoggingLevel.ERROR, k + ' | ' + got.rightPad(28) + ' | '
      + String.valueOf(r.Paragraph_14a_pflichtig__c).rightPad(5) + ' | ' + ende.rightPad(12) + ' | '
      + law.rightPad(12) + ' | ' + eich.rightPad(10) + ' | ' + beend.rightPad(10) + ' | '
      + sp.rightPad(2) + ' | ' + off.rightPad(3) + ' | ' + verdict);
}
System.debug(LoggingLevel.ERROR, '=== ' + pass + ' PASS / ' + deferred + ' DEFERRED / ' + fail + ' FAIL  of ' + rows.size() + ' ===');
