#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, getopt, re

class ltrulematch(object):
   def __init__(self, ruleID, message, suggestions, moreinfo, context, underline):
      self.ruleID = ruleID
      self.message = message
      self.suggestions = suggestions
      self.moreinfo = moreinfo
      self.context = context
      self.underline = underline

class rulecounter:
   count = 1
   def __init__(self, ruleID):
      self.ruleID = ruleID
   def increment(self):
      self.count = self.count + 1

def process_file ( ifile ):
   ltrulematches = []
   rulecounters = []
   moreinfo = ''
   message = ''
   suggestions = ''
   moreinfo = ''
   context = ''
   underline = ''
   previousline = ''
   with open(ifile) as f:
      for line in f:
         line = line.rstrip()
         matchObj = re.match( r'^(\d+)\.\) Line .+ column .+ Rule ID: ([^[]+)(\[(\d+)\])?$', line, 0)
         if matchObj:
            ruleID = matchObj.group(2)
            for x in rulecounters:
               if x.ruleID == ruleID:
                  x.increment()
                  break
            else:
               rulecounters.append(rulecounter(ruleID))
         matchObj = re.match( r'^Message: (.+)$', line, 0)
         if matchObj:
            message = matchObj.group(1)
         matchObj = re.match( r'^Suggestion: (.+)$', line, 0)
         if matchObj:
            suggestions = matchObj.group(1)
         matchObj = re.match( r'^More info: (.+)$', line, 0)
         if matchObj:
            moreinfo = matchObj.group(1)
         matchObj = re.match( r'^(\s*)([\^]+)', line, 0)
         if matchObj:
            underline = matchObj.group()
            context = previousline
            myltrulematch = ltrulematch(ruleID, message, suggestions, moreinfo, context, underline)
            ltrulematches.append(myltrulematch)
            message = ''
            suggestions = ''
            moreinfo = ''
            context = ''
            underline = ''
         previousline = line
   rulecounters.sort(key=lambda x: x.count, reverse=True)
   
   for rc in rulecounters:
      print rc.ruleID, rc.count
   for rc in rulecounters:
      print rc.ruleID
      for rm in ltrulematches:
         if rm.ruleID == rc.ruleID:
            print "Missatge: ",rm.message
            print "Suggeriments: ",rm.suggestions
            if rm.moreinfo:
               print u'Més informació: ', rm.moreinfo
            print rm.context
            print rm.underline

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
