#!/bin/bash

zcat reports/allele_number.csv.gz |
    grep -v control |
    sed 1d |
    cut -d, -f 2,5 |
    sort |
    uniq |
    cut -d, -f 2 |
    sort |
    uniq -c |
    awk '{print toupper($2)","$1}' >reports/sample_number.csv

zcat reports/allele_number.csv.gz |
    grep -v control |
    grep target |
    sed 1d |
    cut -d, -f 2,5 |
    sort |
    uniq -c >tmp

cat tmp |
    cut -d, -f 2 |
    sort |
    uniq -c |
    awk '{print toupper($2)","$1}' >reports/sample_number_with_deletion.csv

cat reports/sample_number.csv
cat reports/sample_number_with_deletion.csv

cat reports/sample_number.csv |
    awk -F, '{sum+=$2} END {print sum}'
