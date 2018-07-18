#!/usr/bin/env python -tt

from lxml import etree
import glob
import io
import sys




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
    this = arecord.xpath('controlfield[@tag="009"]')[0]
    return this.text

@cop_out
def get_oh50(arecord):
    thexpath = 'datafield[@tag="050" and @ind1="0" and @ind2="0"]/subfield[@code="a"]'
    this = arecord.xpath(thexpath)[0]
    return this.text

@cop_out
def get_oh90(arecord):
    thexpath = 'datafield[@tag="090" and @ind1="0" and @ind2="0"]/subfield[@code="a"]'
    this = arecord.xpath(thexpath)[0]
    return this.text

@cop_out
def get_908(arecord):
    thexpath = 'datafield[@tag="908" and @ind1="0" and @ind2="0"]/subfield[@code="a"]'
    this = arecord.xpath(thexpath)[0]
    return this.text



xmlfiles = glob.glob("../scsb-data/NYPL/*.xml")
THELENGTH = len(xmlfiles)


with open("../computed-data/lc-call-numbers/nypl-lc-calls.txt", "w") as fh:
    for index, anxmlfile in enumerate(xmlfiles):
        print("On {} of {}".format(index+1, THELENGTH))
        current_doc = open(anxmlfile).read()
        current_doc = current_doc.replace("marcxml:", "")
        current_doc = etree.parse(io.BytesIO(current_doc.encode("utf-8")))
        for arecord in current_doc.xpath("/collection/record"):
            bib_id = get_bibid(arecord)
            oh50 = get_oh50(arecord)
            oh90 = get_oh90(arecord)
            nine08 = get_908(arecord)
            outstr = "{}\t{}\t{}\t{}\n".format(bib_id, oh50, oh90, nine08)
            fh.write(outstr)
            sys.stdout.flush()


