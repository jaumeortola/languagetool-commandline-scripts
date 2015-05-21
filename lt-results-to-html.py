#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, getopt, operator, pystache, os.path, uuid, cgi, re, hunspell


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
   def __init__(self, error):
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
      self.context_before = ctx[0:a]
      self.context_spanclass = spanclass
      self.context_error = cgi.escape(ctx[a:b]).replace(" ","&nbsp;")
      self.context_after = ctx[b:ctxlen]
      try:
         self.url = error.attrib['url']
      except KeyError:
         self.url = ""

class rule(object):
   def __init__(self, ruleId):
      self.ruleId = ruleId
      self.rule_matches = []
      self.count = 1
      self.truncated = 0
   def increment(self):
      self.count += 1

def getRuleById(rulelist, ruleId):
   for x in rulelist:
      if x.ruleId == ruleId:
         return x
         break

_digits = re.compile('\d')
def contains_digits(d):
    return bool(_digits.search(d))

_noletter = re.compile(ur'[^a-zA-ZûêáàéèíòóúïüäöîâÄÖÁÀÈÉÍÒÓÚÏÜÎÂçÇñÑ·]', re.UNICODE)
def contains_symbols(d):
    return bool(_noletter.search(d))

def is_firstupper(s):
   return (s[0] == s[0].upper() and s[1:] == s[1:].lower())

def is_camel(s):
    return (s != s.lower() and s != s.upper() and not is_firstupper(s))

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
      ruleId = error.attrib['ruleId']
      r = getRuleById(rulelist, ruleId)
      if r != None:
         r.increment()
      else:
         r = rule(ruleId)
         rulelist.append(r)
      if (r.count > 100):
         r.truncated = 1
      else:
         r.rule_matches.append(rule_match(error))
      # get unknown words from spelling rule
      if ruleId == "MORFOLOGIK_RULE_CA_ES":
         a = int(error.attrib['contextoffset'])
         b = a + int(error.attrib['errorlength'])
         wrongword = error.attrib['context'][a:b]
         if wrongword not in unknownwords:
            unknownwords.append(wrongword)

   # sort list of rules
   rulelist.sort(key=lambda x: x.count, reverse=True);

   # unknown words from xml
   #try:
   #   for word in root.find('unknown_words').findall('word'):
   #      unknownwords.append(word.text)
   #except AttributeError:
   #   pass
   unknownwords.sort()

   hobj = hunspell.HunSpell('/usr/share/hunspell/en_US.dic', '/usr/share/hunspell/en_US.aff')
   uw_oneletter = []
   uw_digit = []
   uw_symbol = []
   uw_allupper = []
   uw_camel = []
   uw_english = []
   uw_firstupper = []
   uw_rest = []
   for uw in unknownwords:
      if contains_symbols(uw):
         if uw not in uw_symbol:
            uw_symbol.append(uw)
      elif len(uw)==1:
         if uw not in uw_oneletter:
            uw_oneletter.append(uw)
      elif hobj.spell(uw):
         if uw not in uw_english:
            uw_english.append(uw)
      elif contains_digits(uw):
         if uw not in uw_digit:
            uw_digit.append(uw)
      elif uw == uw.upper():
         if uw not in uw_allupper:
            uw_allupper.append(uw)
      elif is_camel(uw):
         if uw not in uw_camel:
            uw_camel.append(uw)
      elif is_firstupper(uw):
         if uw not in uw_firstupper:
            uw_firstupper.append(uw)
      elif uw not in uw_rest:
         uw_rest.append(uw)

   ctx = {
       'filename': ifile,
       'totalmatches': len(errors),
       'rulelist': rulelist,
       'unknownwords': unknownwords,
       'hasunknownwords': len(unknownwords),
       'uw_oneletter': uw_oneletter,
       'uw_digit': uw_digit,
       'uw_symbol': uw_symbol,
       'uw_allupper': uw_allupper,
       'uw_camel': uw_camel,
       'uw_english': uw_english,
       'uw_firstupper': uw_firstupper,
       'uw_rest': uw_rest,
       'has_uw_oneletter': len(uw_oneletter),
       'has_uw_digit': len(uw_digit),
       'has_uw_symbol': len(uw_symbol),
       'has_uw_allupper': len(uw_allupper),
       'has_uw_camel': len(uw_camel),
       'has_uw_english': len(uw_english),
       'has_uw_firstupper': len(uw_firstupper),
       'has_uw_rest': len(uw_rest),
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
