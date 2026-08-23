// Sixteen cases across three columns: what the formula produces, what § 34 MessEV requires,
// and what EichrechtService computes. The three-column form is the point - it shows where the
// declarative layer is right, where it is not, and that the gap is closed rather than excused.
//
// This runs against the live org and is a demonstration, not the regression suite. The durable
// checks are EichrechtServiceTest and EichrechtKonsistenzTest, whose fixtures are relative to
// today; the fixed dates here will need revisiting once the calendar passes them.
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

// The engine's answer for the same records, on the same day the formula is evaluated.
Map<Id, DecisionResult> motor = EichrechtService.bewerteEichfrist(
    new Map<Id, Ladepunkt__c>(rows).keySet(), Date.today());

Integer pass = 0, geloest = 0, fail = 0;
System.debug(LoggingLevel.ERROR, 'K | Eichstatus                   | Ende(Formel) | Ende(Gesetz) | Ende(Motor)  | Motor-Status       | RESULT');
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

  DecisionResult d = motor.get(r.Id);
  String motorEnde   = (d.fristende == null) ? '-' : String.valueOf(d.fristende);
  String motorStatus = String.valueOf(d.ergebnis);

  Boolean okS  = got == wantStatus.get(k);
  Boolean ok14 = r.Paragraph_14a_pflichtig__c == want14a.get(k);
  Boolean okE  = ende == wantEnde.get(k);
  Boolean formelStimmt = (ende == law);
  Boolean motorStimmt  = (motorEnde == law);

  String verdict;
  if (!(okS && ok14 && okE)) {
    fail++;
    verdict = 'FAIL'
      + (okS  ? '' : ' status<want ' + wantStatus.get(k) + '>')
      + (ok14 ? '' : ' 14a<want '    + want14a.get(k)    + '>')
      + (okE  ? '' : ' ende<want '   + wantEnde.get(k)   + '>');
  } else if (!formelStimmt && motorStimmt) {
    geloest++;
    verdict = 'GELOEST vom Motor (S 34 I 3 Rueckdatierung; Formel 1 Jahr zu grosszuegig)';
  } else if (!formelStimmt) {
    fail++;
    verdict = 'FAIL - weder Formel noch Motor treffen das Gesetz';
  } else {
    pass++;
    verdict = 'PASS';
  }
  System.debug(LoggingLevel.ERROR, k + ' | ' + got.rightPad(28) + ' | ' + ende.rightPad(12)
      + ' | ' + law.rightPad(12) + ' | ' + motorEnde.rightPad(12) + ' | '
      + motorStatus.rightPad(18) + ' | ' + verdict);
}
System.debug(LoggingLevel.ERROR, '=== ' + pass + ' PASS / ' + geloest + ' GELOEST / ' + fail + ' FAIL  of ' + rows.size() + ' ===');
