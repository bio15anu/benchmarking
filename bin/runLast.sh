#!/bin/sh
# usage ${BENCHPATH}/bin/runLast.sh /path/to/read_1.fastq /path/to/read_2.fastq fragaria 
# MUST RUN FROM OUTPUT DIRECTORY

# test input arguments
if test \( $# -ne 3 \) -o \( ! -e "$1" -o ! -e "$2" -o ! -d "${BENCHPATH}/$3" \)
then
    echo "Invalid call with '$*'" && exit 1
fi

source ${BENCHPATH}/bin/error.sh

SDIR=${BENCHPATH}/bin
BDIR=${BENCHPATH}/$3
GDIR=${BDIR}/genome
IDIR=${GDIR}/last
#TDIR=/usr/local
DIR="."

## program-specific parameters
CMD=${SDIR}/last-bisulfite-paired.sh
CMDSH=$(basename $CMD)
CMDSUF=last
#REF=${GDIR}/fragaria.fa
#INDEX=${IDIR}/fragaria
#THR=8

QRY=$1 # eg. ${BENCHPATH}/fragaria/reads/01x/bisulfite/simulated_1.fastq.gz
MATE=$2 # eg. ${BENCHPATH}/fragaria/reads/01x/bisulfite/simulated_2.fastq.gz
QRYBASE=$(basename $QRY | sed 's/\.gz//' | sed 's/\..*$//' | sed 's/_[0-9]$//')

BASE=${DIR}/${QRYBASE}.${CMDSUF}
OUT=${BASE}.maf
OUTGZ=${OUT}.gz
MEM=${BASE}.mem
TIME=${BASE}.time
LOG=${BASE}.log

ARGS=" ${IDIR}/${3}_f ${IDIR}/${3}_r $QRY $MATE"

## run
echo -n "" > $LOG
echo "CALL:"${CMD}" "${ARGS} >> $LOG
${SDIR}/memusage.sh $CMD $QRY > $MEM &
/usr/bin/time -p -o $TIME $CMD $ARGS > $OUT 2>> $LOG

## coordinate-sorted SAM file (for runEval.sh)
#$SAMTOOLS view -bS $OUT 2>> $LOG | $SAMTOOLS sort - $OUT 2>> $LOG
#$SAMTOOLS view -h $OUT".bam" 2>> $LOG | gzip -c > $OUTGZ
#rm -f $OUT $OUT".bam"