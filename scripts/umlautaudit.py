# -*- coding: utf-8 -*-
"""Find umlauts that sit in code rather than inside a German sentence.

Strings and comments may hold umlauts; Apex identifiers may not. Walking the line and tracking
quote state leaves only the code, so an umlaut surviving that walk is a broken identifier.
"""
import io
import os
import sys

UMLAUTE = set('aouAOU') and set(u'äöüÄÖÜß')

DATEIEN = ['EichrechtService.cls', 'PruefeEichfristen.cls', 'EichrechtCardController.cls',
           'DateUtils.cls', 'DecisionResult.cls', 'LadepunktSelector.cls',
           'EichrechtCardControllerTest.cls', 'PruefeEichfristenTest.cls',
           'EichrechtServiceTest.cls', 'EichrechtKonsistenzTest.cls',
           'DateUtilsTest.cls', 'DecisionResultTest.cls', 'RechtsnormKorpusTest.cls',
           'GermanTextSerializationTest.cls', 'TestDataFactory.cls']

os.chdir(sys.argv[1] if len(sys.argv) > 1 else '.')

treffer = []
for pfad in DATEIEN:
    if not os.path.exists(pfad):
        continue
    in_block = False
    for nummer, zeile in enumerate(io.open(pfad, encoding='utf-8'), 1):
        rein = []
        in_string = False
        i = 0
        gestrichen = zeile
        if in_block:
            if '*/' in zeile:
                in_block = False
                gestrichen = zeile.split('*/', 1)[1]
            else:
                continue
        if '/*' in gestrichen:
            vor, rest = gestrichen.split('/*', 1)
            if '*/' in rest:
                gestrichen = vor + rest.split('*/', 1)[1]
            else:
                in_block = True
                gestrichen = vor
        if '//' in gestrichen:
            gestrichen = gestrichen.split('//', 1)[0]
        for zeichen in gestrichen:
            if zeichen == "'":
                in_string = not in_string
                continue
            if not in_string:
                rein.append(zeichen)
        code = ''.join(rein)
        if any(z in UMLAUTE for z in code):
            treffer.append((pfad, nummer, zeile.strip()[:110]))

for pfad, nummer, zeile in treffer:
    print('%s:%d  %s' % (pfad, nummer, zeile))
print('%d Treffer' % len(treffer))
