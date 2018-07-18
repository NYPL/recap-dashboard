#!/usr/bin/env python -tt

from lxml import etree
import glob
import io
import sys
import re




def cop_out(f):
    def inner(*args, **kargs):
        try:
            return f(*args, **kargs)
        except:
            return("")
            message = f.__name__.replace("_", " ")
            sys.stderr.write("\nFailed to {}\n".format(message))
    return inner

@cop_out
def get_bibid(arecord):
    this = arecord.xpath('owningInstitutionBibId')[0]
    return this.text

@cop_out
def get_lang(arecord):
    this = arecord.xpath('content/collection/record/controlfield[@tag="008"]')[0]
    this = re.search("[|\s]([a-z]{3}).{1,3}$", this.text)
    return this.group(1)




xmlfiles = glob.glob("../scsb-data/PUL/*.xml")
THELENGTH = len(xmlfiles)


with open("../computed-data/language/pul-languages.txt", "w") as fh:
    for index, anxmlfile in enumerate(xmlfiles):
        print("On {} of {}".format(index+1, THELENGTH))
        current_doc = etree.parse(anxmlfile)
        for arecord in current_doc.xpath("/bibRecords/bibRecord/bib"):
            bib_id = get_bibid(arecord)
            lang = get_lang(arecord)
            outstr = "{}\t{}\n".format(bib_id, lang)
            fh.write(outstr)
            sys.stdout.flush()


