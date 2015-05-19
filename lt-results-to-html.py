#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, getopt, operator, pystache, os.path, uuid


def process_template(template, filename, ctx):
    __location__ = os.path.realpath(os.path.join(os.getcwd(), os.path.dirname(__file__)))

    # Load template and process it.
    template = open(os.path.join(__location__, template), 'r').read()
    parsed = pystache.Renderer()
    s = parsed.render(unicode(template, "utf-8"), ctx)

    # Write output.
    f = open(filename, 'w')
    f.write(s.encode("utf-8"))
    f.close()

class rule_match(object):
   def __init__(self, error, unknownwords):
      self.msg = error.attrib['msg']
      replacements_array = error.attrib['replacements'].split("#")
      n = 0;
      replacements_str = ""
      for r in replacements_array:
         if r:
            if n > 0:
               replacements_str += "; "
            replacements_str += r 
            n += 1
            if n > 9:
               break
      self.replacements = replacements_str
      ctx = error.attrib['context']
      a = int(error.attrib['contextoffset'])
      b = a + int(error.attrib['errorlength'])
      ctxlen = len(ctx)
      spanclass = "hiddenGrammarError"
      if error.attrib['locqualityissuetype'] == "misspelling":
         spanclass = "hiddenSpellError"
      if (error.attrib['locqualityissuetype'] == "style") or (error.attrib['locqualityissuetype'] == "locale-violation"):
         spanclass = "hiddenGreenError"
      self.context = ctx[0:a]+"<span class=\""+spanclass+"\">"+ctx[a:b]+"</span>"+ctx[b:ctxlen]
      try:
         self.url = error.attrib['url']
      except KeyError:
         self.url = ""
      # get unknown words from spelling rule
      if error.attrib['ruleId'] == "MORFOLOGIK_RULE_CA_ES":
         if ctx[a:b] not in unknownwords:
            unknownwords.append(ctx[a:b])

class rule(object):
   def __init__(self, ruleId):
      self.ruleId = ruleId
      self.rule_matches = []
      self.count = 1
   def increment(self):
      self.count += 1

def getRuleById(rulelist, ruleId):
   for x in rulelist:
      if x.ruleId == ruleId:
         return x
         break

def process_file ( ifile, ofile ):
   # parxe xml
   import xml.etree.ElementTree as ET
   tree = ET.parse(ifile)
   root = tree.getroot()

   # count rules by ruleId & matches per rule
   rulelist = []
   unknownwords = []
   errors = root.findall('error')
   for error in errors:
      ruleId = error.attrib['ruleId'] #.get('ruleId')
      r = getRuleById(rulelist, ruleId)
      if r != None:
         r.increment()
      else:
         r = rule(ruleId)
         rulelist.append(r)
      r.rule_matches.append(rule_match(error, unknownwords)) 

   # sort list of rules
   rulelist.sort(key=lambda x: x.count, reverse=True);

   # unknown words from xml
   #try:
   #   for word in root.find('unknown_words').findall('word'):
   #      unknownwords.append(word.text)
   #except AttributeError:
   #   pass
   unknownwords.sort()

   r = getRuleById(rulelist, "MORFOLOGIK_RULE_CA_ES")
   if len(r.rule_matches)>20:
      rulelist.remove(r)

   ctx = {
       'filename': ifile,
       'totalmatches': len(errors),
       'rulelist': rulelist,
       'unknownwords': unknownwords,
       'hasunknownwords': len(unknownwords),
       'uuid': uuid.uuid4(),
   }

   process_template("lt-results.mustache", ofile, ctx)

def main(argv):
   inputfile = ''
   try:
      opts, args = getopt.getopt(argv,"hi:o:",["ifile=","ofile="])
   except getopt.GetoptError:
      print 'Use: lt-results-to-html.py -i <inputfile> -o <outputfile>'
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print 'Use: lt-results-to-html.py -i <inputfile> -o <outputfile>'
         sys.exit()
      elif opt in ("-i", "--ifile"):
         inputfile = arg
      elif opt in ("-o", "--ofile"):
         outputfile = arg

   process_file( inputfile, outputfile )

if __name__ == "__main__":
   main(sys.argv[1:])
