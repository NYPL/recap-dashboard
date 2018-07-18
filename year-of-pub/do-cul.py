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
def get_year(arecord):
    this = arecord.xpath('content/collection/record/datafield[@tag="260"]/subfield[@code="c"]')[0]
    this = re.search("([12]\d{3})", this.text).group(1)
    return this




xmlfiles = glob.glob("../scsb-data/CUL/*.xml")
THELENGTH = len(xmlfiles)


with open("../computed-data/year-of-pub/cul-years.txt", "w") as fh:
    for index, anxmlfile in enumerate(xmlfiles):
        print("On {} of {}".format(index+1, THELENGTH))
        current_doc = etree.parse(anxmlfile)
        for arecord in current_doc.xpath("/bibRecords/bibRecord/bib"):
            bib_id = get_bibid(arecord)
            year = get_year(arecord)
            outstr = "{}\t{}\n".format(bib_id, year)
            fh.write(outstr)
            sys.stdout.flush()


