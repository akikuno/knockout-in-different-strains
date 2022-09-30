#!/bin/bash

: >tmp_dajin_prediction
find . -name "DAJIN_prediction_result*.txt.gz" |
    while read -r line; do
        run=$(echo "${line%.txt.gz}" | awk -F_ '{print $NF}')
        gzip -dc "$line" |
            awk -v run="$run" '{print run"_"$2, $3, $1}' >>tmp_dajin_prediction
    done

sed 1d data/barcode_strain.csv |
    sed "s/,/_/" |
    tr "," " " |
    sort >tmp_barcode_strain

cat data/available_mice.csv |
    tr , - |
    sort >tmp_available_mice

cat tmp_dajin_prediction |
    sort |
    join - tmp_barcode_strain |
    tr "_ " "," |
    awk -F, 'BEGIN{OFS=","}{$1=$2"-"$5","$1}1' |
    sort -t , |
    join -t , - tmp_available_mice |
    cut -d, -f 2- |
    awk 'BEGIN{OFS=","; print "run","barcode","allele","read_id","strain","condition"}1' |
    gzip -c >reports/allele_number.csv.gz

rm tmp_*
