#!/usr/bin/python3

'''
Title: bisulfite_transform.py
Date: 20180522
Author: Adam Nunn
Description:
  Takes input *.fastq files and converts a user-defined proportion of the bases
  from C to T (or G to A, for read_2) in order to simulate reads obtained
  through bisulfite sequencing. Adapted from Sherman read simulator.

List of functions:
  int()
  open()
  .rstrip()
  list()
  range()
  len()
  random.randint()
  .join()

Procedure:
  1. iterate through lines in input *.fastq file 'reads'
  2. convert sequence lines only
  3. iterate through bases in sequence line for converting C to T
  4. generate random number and compare with conversion conversion_rate
  5. print converted sequence line to file 'bs_reads'
  6. print all other lines unchanged to file 'bs_reads'

Usage:
    ./bisulfite_transform.py [reads] [conversion_rate] [pe_number]
eg. ./bisulfite_transform.py reads_1.fastq 50 1
'''

import sys
import random

conversion_rate = int(sys.argv[2])
pe_number = int(sys.argv[3])

with open(sys.argv[1], 'r') as reads, open(sys.argv[1] + '.bs.fastq', 'w') as bs_reads:
 line_count = 0

 # 1) iterate through lines in input *.fastq file 'reads'
 for line in reads:
  line = line.rstrip()
  line_count += 1

  # 2) convert sequence lines only
  if line_count % 4 == 2:
   total_C_count = 0
   total_G_count = 0
   converted_C_count = 0
   converted_G_count = 0
   bases = list(line)

   # 3) iterate through bases in sequence line for converting C to T
   for base in range(len(bases)):
    if (pe_number == 1) and (bases[base] == 'C'):
     total_C_count += 1

     # 4) generate random number and compare with conversion conversion_rate
     random_number = int(random.randint(0,10000)+1)/100
     if random_number <= conversion_rate:
      converted_C_count += 1
      bases[base] = 'T'

    elif (pe_number == 2) and (bases[base] == 'G'):
     total_G_count += 1

     # 4) generate random number and compare with conversion conversion_rate
     random_number = int(random.randint(0,10000)+1)/100
     if random_number <= conversion_rate:
      converted_G_count += 1
      bases[base] = 'A'

   # 5) print converted sequence line to output file 'bs_reads'
   line = "".join(bases)
   print(line, file=bs_reads)

  # 6) print all other lines unchanged to output file 'bs_reads'
  else: print(line, file=bs_reads)