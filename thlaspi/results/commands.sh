# 00) get TOTAL READS for each REPLICATE
ls ${BENCHPATH}/thlaspi/mapping | grep x$ |
while read REP; do echo $REP
echo "$(cat ${BENCHPATH}/thlaspi/reads/${REP}/bisulfite/simulated_1.fastq | paste - - - - | wc -l)+\
$(cat ${BENCHPATH}/thlaspi/reads/${REP}/bisulfite/simulated_2.fastq | paste - - - - | wc -l)" | bc -l
done | paste - - > 00-reads_total.tsv


# 01) get TIME measurements
ls ${BENCHPATH}/thlaspi/mapping/01x | grep -v razers |
while read TOOL; do ls ${BENCHPATH}/thlaspi/mapping | grep x$ |
while read REP; do cat ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/*.time |
while read LINE; do echo $TOOL; echo $REP; echo $LINE | tr " " "\t"; done | paste - - -
done; done > 01-time.tsv


# 02) get MEM measurements
ls ${BENCHPATH}/thlaspi/mapping/01x | grep -v razers |
while read TOOL; do ls ${BENCHPATH}/thlaspi/mapping | grep x$ |
while read REP; do echo $TOOL; echo $REP; cat ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/*.mem | cut -f5 | paste -s
echo $TOOL; echo $REP; cat ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/*.mem | cut -f6 | paste -s
done | paste - - -
done > 02-mem.tsv


# 03) get TOTAL MAPPING rates for each TOOL (takes a long time)
ls ${BENCHPATH}/thlaspi/mapping/01x | grep -v razers |
while read TOOL; do ls ${BENCHPATH}/thlaspi/mapping | grep x$ |
while read REP; do echo $TOOL; echo $REP
echo "(($(samtools view -F772 -f65 ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/simulated.*.bam | cut -f1 | sort | uniq | wc -l)+\
$(samtools view -F772 -f129 ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/simulated.*.bam | cut -f1 | sort | uniq | wc -l))*100)/\
$(cat 00-reads_total.tsv | grep $REP | cut -f2)" | bc -l
done | paste - - - 
done > 03-map_total.tsv


# 04) get UNIQ MAPPING rates for each relevant TOOL (takes a long time)
ls ${BENCHPATH}/thlaspi/mapping/01x | grep -v -e 'bismark' -e 'bsmap' -e 'bsseeker2' -e 'razers' |
while read TOOL; do if [ $TOOL == "bwameth" ]; then GREP=" grep -v -e 'XA:Z:' -e 'SA:Z:' |"; else GREP=" grep -w 'NH:i:1' |"; fi;
if [[ $TOOL == "last" || $TOOL == "gem-mapper" ]]; then Q=" -q20"; GREP=""; else Q=""; fi;
ls ${BENCHPATH}/thlaspi/mapping | grep x$ |
while read REP; do echo $TOOL; echo $REP
echo "(($(eval "samtools view$(echo "${Q} ")-F772 -f65 ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/simulated.${TOOL}.bam |$(echo "${GREP} ")cut -f1 | sort | uniq | wc -l")+\
$(eval "samtools view$(echo "${Q} ")-F772 -f129 ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/simulated.${TOOL}.bam |$(echo "${GREP} ")cut -f1 | sort | uniq | wc -l"))*100)/\
$(cat 00-reads_total.tsv | grep $REP | cut -f2)" | bc -l
done | paste - - -
done > 04-map_uniq.tsv


# 05) get TRUE POSITIVES for each TOOL relative to READ ORIGIN
ls ${BENCHPATH}/thlaspi/mapping/01x | grep -v 'razers' |
while read TOOL; do ls ${BENCHPATH}/thlaspi/mapping | grep x$ |
while read REP; do echo $TOOL; echo $REP
${BENCHPATH}/bin/eval_tp_origin.py ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/simulated.${TOOL}.bam | wc -l
samtools view -F772 ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/simulated.${TOOL}.bam | wc -l
cat 00-reads_total.tsv | grep $REP | cut -f2;
done | paste - - - -
done

# 06) get TRUE POSITIVES for each TOOL relative to RAZERS3 MAPPINGS
ls ${BENCHPATH}/thlaspi/mapping | grep x$ |
while read REP; do samtools view ${BENCHPATH}/thlaspi/mapping/${REP}/razers3.bam | cut -f1 | sort | uniq -c |
awk '$1>2{print $2}' > ${BENCHPATH}/thlaspi/mapping/${REP}/razers3.mults.txt
done

ls ${BENCHPATH}/thlaspi/mapping/01x | grep -v 'razers' |
while read TOOL; do ls ${BENCHPATH}/thlaspi/mapping | grep x$ |
while read REP; do echo $TOOL; echo $REP
${BENCHPATH}/bin/eval_tp_razers3.py -i ${BENCHPATH}/thlaspi/mapping/${REP}/razers3.mults.txt ${BENCHPATH}/thlaspi/mapping/${REP}/razers3.bam ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/simulated.${TOOL}.bam | wc -l
samtools view -F772 ${BENCHPATH}/thlaspi/mapping/${REP}/${TOOL}/simulated.${TOOL}.bam | wc -l
echo "$(samtools view -F772 ${BENCHPATH}/thlaspi/mapping/${REP}/razers3.bam | wc -l)-($(cat ${BENCHPATH}/thlaspi/mapping/${REP}/razers3.mults.txt | wc -l)*2)" | bc -l
done | paste - - - - -
done