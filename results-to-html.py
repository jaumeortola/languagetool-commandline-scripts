#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys, getopt, operator

def process_file ( ifile ):
   # parxe xml
   import xml.etree.ElementTree as ET
   tree = ET.parse(ifile)
   root = tree.getroot()
   # count rules by ruleId
   rulecounters = dict()
   for error in root.findall('error'):
      ruleId = error.get('ruleId')
      if ruleId in rulecounters:
         rulecounters[ruleId] += 1
      else:
         rulecounters[ruleId] = 1
   for key in sorted(rulecounters, key=rulecounters.get, reverse=True):
      print key, rulecounters[key]

#   for child in root:
#      print child.tag, child.attrib
   

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
