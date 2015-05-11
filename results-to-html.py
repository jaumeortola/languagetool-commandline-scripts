#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, getopt, operator, pystache

def process_template(template, filename, ctx):
    # Load template and process it.
    template = open(template, 'r').read()
    parsed = pystache.Renderer()
    s = parsed.render(unicode(template, "utf-8"), ctx)

    # Write output.
    f = open(filename, 'w')
    f.write(s.encode("utf-8"))
    f.close()

class rule_match(object):
   def __init__(self, error):
      self.msg = error.attrib['msg']
      self.replacements = error.attrib['replacements'].replace("#", "; ")
      self.context = error.attrib['context']
      if hasattr(error, 'url'):
         self.url = error.attrib['url']

class rule(object):
   def __init__(self, ruleId):
      self.ruleId = ruleId
      self.rule_matches = []
      self.count = 1
   def increment(self):
      self.count += 1

def process_file ( ifile ):
   # parxe xml
   import xml.etree.ElementTree as ET
   tree = ET.parse(ifile)
   root = tree.getroot()

   # count rules by ruleId
   rulelist = []
   totalmatches = 0
   for error in root.findall('error'):
      ruleId = error.get('ruleId')
      for x in rulelist:
         if x.ruleId == ruleId:
            x.increment()
            totalmatches += 1
            break
      else:
         rulelist.append(rule(ruleId))

   # sort list of rules
   rulelist.sort(key=rulelist.count, reverse=True);

   # matches per rule
   errors = root.findall('error')
   for error in errors:
      for x in rulelist:
         if x.ruleId == error.attrib['ruleId']:
            x.rule_matches.append(rule_match(error)) 
            break

   # Unknown words
   unknownwords = []
   for word in  root.find('unknown_words').findall('word'):
      unknownwords.append(word.text)

   ctx = {
       'filename': ifile,
       'totalmatches': totalmatches,
       'rulelist': rulelist,
       'unknownwords': unknownwords,
   }

   process_template("lt_results.mustache", ifile + "-lt.html", ctx)

def main(argv):
   inputfile = ''
   outputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
   except getopt.GetoptError:
      print 'test.py -i <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'test.py -i <inputfile> -o <outputfile>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile = arg
      elif opt in ("-o", "--ofile"):
         outputfile = arg
   process_file( inputfile )
   #print 'Input file is:', inputfile
   #print 'Output file is:', outputfile

if __name__ == "__main__":
   main(sys.argv[1:])
