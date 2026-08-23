# -*- coding: utf-8 -*-
"""Find umlauts that sit in Apex code rather than inside a German sentence.

Strings and comments may hold umlauts and in this project they must: the agent speaks German and
the corpus quotes statutes verbatim. Identifiers may not — Apex rejects them — and a blunt
search-and-replace restoring German reaches into field API names and method names without saying
so. This audit strips the quoted parts and the comments; anything with an umlaut left standing is
an identifier, and therefore a defect.

Exits non-zero on any finding so a CI job can fail on it.

Usage: python scripts/umlautaudit.py [verzeichnis]
"""
import glob
import io
import os
import re
import sys

UMLAUTE = set(u'äöüÄÖÜß')


def nur_code(zeile, im_block):
    """Return the line with strings and comments removed, plus the new block-comment state."""
    rest = zeile
    if im_block:
        if '*/' not in rest:
            return '', True
        rest = rest.split('*/', 1)[1]
        im_block = False
    if '/*' in rest:
        vor, nach = rest.split('/*', 1)
        if '*/' in nach:
            rest = vor + nach.split('*/', 1)[1]
        else:
            return vor, True
    if '//' in rest:
        rest = rest.split('//', 1)[0]

    code = []
    im_string = False
    for zeichen in rest:
        if zeichen == "'":
            im_string = not im_string
            continue
        if not im_string:
            code.append(zeichen)
    return ''.join(code), im_block


def pruefe(pfad):
    treffer = []
    im_block = False
    for nummer, zeile in enumerate(io.open(pfad, encoding='utf-8'), 1):
        code, im_block = nur_code(zeile, im_block)
        if any(z in UMLAUTE for z in code):
            treffer.append((nummer, zeile.strip()[:110]))
    return treffer


def main():
    wurzel = sys.argv[1] if len(sys.argv) > 1 else 'force-app'
    dateien = sorted(glob.glob(os.path.join(wurzel, '**', '*.cls'), recursive=True))
    if not dateien:
        print('Keine .cls-Dateien unter %s gefunden.' % wurzel)
        return 2

    gesamt = 0
    for pfad in dateien:
        for nummer, zeile in pruefe(pfad):
            gesamt += 1
            print('%s:%d  %s' % (pfad.replace(os.sep, '/'), nummer, zeile))

    if gesamt:
        print('\n%d Umlaut(e) in Bezeichnern — Apex akzeptiert sie nicht.' % gesamt)
        return 1
    print('%d Klassen geprüft, keine Umlaute in Bezeichnern.' % len(dateien))
    return 0


if __name__ == '__main__':
    sys.exit(main())
