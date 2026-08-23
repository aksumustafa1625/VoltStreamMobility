// Eichrecht status matrix - seeds the fifteen cases the declarative layer has to get right.
// Real DML, no mocks: the roll-ups only fire on an actual child save.
final String MARK = 'PRUEFMATRIX';
delete [SELECT Id FROM Ladepunkt__c WHERE Standort_Adresse__c LIKE 'PRUEFMATRIX%'];

Map<String, Ladepunkt__c> p = new Map<String, Ladepunkt__c>();
p.put('A', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15), Ladeleistung_kW__c = 11,  Stromart__c = 'AC'));
p.put('B', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2015,6,1),  Ladeleistung_kW__c = 22,  Stromart__c = 'AC'));
p.put('C', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2015,6,1),  Nacheichung_beantragt_am__c = Date.newInstance(2023,9,1)));
p.put('D', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2015,6,1),  Nacheichung_beantragt_am__c = Date.newInstance(2023,12,15)));
p.put('E', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2015,6,1)));
p.put('F', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15)));
p.put('G', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15)));
p.put('H', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15)));
p.put('I', new Ladepunkt__c());
p.put('J', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15)));
p.put('K', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15)));
p.put('L', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15)));
p.put('M', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15), Ladeleistung_kW__c = 11, Oeffentlich_zugaenglich__c = true));
p.put('N', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15), Ladeleistung_kW__c = 3.7));
p.put('O', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2019,3,15), Ladeleistung_kW__c = 4.2));
p.put('P', new Ladepunkt__c(Inverkehrbringen__c = Date.newInstance(2015,6,1)));
for (String k : p.keySet()) { p.get(k).Standort_Adresse__c = MARK + ' ' + k; }
insert p.values();

List<Eingriff__c> es = new List<Eingriff__c>{
  new Eingriff__c(Ladepunkt__c = p.get('E').Id, Typ__c = 'Nacheichung',     Datum__c = Date.newInstance(2024,3,10)),
  new Eingriff__c(Ladepunkt__c = p.get('F').Id, Typ__c = 'Software-Update', Datum__c = Date.newInstance(2025,2,1)),
  new Eingriff__c(Ladepunkt__c = p.get('G').Id, Typ__c = 'Eingriff',        Datum__c = Date.newInstance(2022,5,1)),
  new Eingriff__c(Ladepunkt__c = p.get('H').Id, Typ__c = 'Eingriff',        Datum__c = Date.newInstance(2022,5,1)),
  new Eingriff__c(Ladepunkt__c = p.get('H').Id, Typ__c = 'Nacheichung',     Datum__c = Date.newInstance(2023,1,20)),
  new Eingriff__c(Ladepunkt__c = p.get('J').Id, Typ__c = 'Instandsetzung',  Datum__c = Date.newInstance(2023,4,4),
      Instandsetzer_befugt__c = true, Nacheichung_beantragt__c = true,  Kennzeichnung_41__c = true, Behoerde_informiert__c = false),
  new Eingriff__c(Ladepunkt__c = p.get('K').Id, Typ__c = 'Instandsetzung',  Datum__c = Date.newInstance(2023,4,4),
      Instandsetzer_befugt__c = true, Nacheichung_beantragt__c = true,  Kennzeichnung_41__c = true, Behoerde_informiert__c = true),
  new Eingriff__c(Ladepunkt__c = p.get('L').Id, Typ__c = 'Instandsetzung',  Datum__c = Date.newInstance(2023,4,4),
      Instandsetzer_befugt__c = true, Nacheichung_beantragt__c = false, Kennzeichnung_41__c = true, Behoerde_informiert__c = true),
  // E and P are the same late Nacheichung; only P can prove the § 34 I 4 dormancy relief
  new Eingriff__c(Ladepunkt__c = p.get('P').Id, Typ__c = 'Nacheichung',     Datum__c = Date.newInstance(2024,3,10),
      Stilllegung_nachgewiesen__c = true)
};
insert es;
System.debug(LoggingLevel.ERROR, 'SEEDED ' + p.size() + ' Ladepunkte, ' + es.size() + ' Eingriffe');
