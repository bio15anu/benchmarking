
# 1) Bismark 0.20.0 (bowtie 2.3.4.2)
${BISMARK_DIR}/bismark_genome_preparation --path_to_bowtie ${BOWTIE2_DIR} ${BENCHPATH}/thlaspi/genome/

# 2) BS-Seeker 2.1.5 (bowtie 2.3.4.2)
mkdir bsseeker2
source ~/venv2/bin/activate # python 2.7 environment required
python ${BSSEEKR_DIR}/bs_seeker2-build.py -f ${BENCHPATH}/thlaspi/genome/thlaspi.fa \
--aligner=bowtie2 -p ${BOWTIE2_DIR} -d ${BENCHPATH}/thlaspi/genome/bsseeker2
deactivate

# 3) BWA-meth 0.2.2 (bwa 0.7.17)
mkdir bwameth
ln -s ${BENCHPATH}/thlaspi/genome/thlaspi.fa bwameth
export PYTHONPATH=${BWAMETH_DIR}
${BWAMETH_DIR}/bin/bwameth.py index ${BENCHPATH}/thlaspi/genome/bwameth/thlaspi.fa
unset PYTHONPATH

# 4) ERNE-BS5 2.1.1
mkdir erne-bs5
${ERNEBS5_DIR}/erne-create --methyl-hash --output-prefix ${BENCHPATH}/thlaspi/genome/erne-bs5/thlaspi \
--fasta ${BENCHPATH}/thlaspi/genome/thlaspi.fa

# 5) GEM 3.6
mkdir gem-mapper
${GEM3MAP_DIR}/gem-indexer -i ${BENCHPATH}/thlaspi/genome/thlaspi.fa -b -t 8 \
-o ${BENCHPATH}/thlaspi/genome/gem-mapper/thlaspi

# 6) GSNAP 2018-07-04 # do this with conda instead
mkdir gsnap
${GSNAP_DIR}/gmap_build -D ${BENCHPATH}/thlaspi/genome/gsnap -d thlaspi ${BENCHPATH}/thlaspi/genome/thlaspi.fa
${GSNAP_DIR}/cmetindex -F ${BENCHPATH}/thlaspi/genome/gsnap -d thlaspi

# 7) Last 950
mkdir last
${LASTMAP_DIR}/lastdb -uBISF last/thlaspi_f ${BENCHPATH}/thlaspi/genome/thlaspi.fa
${LASTMAP_DIR}/lastdb -uBISR last/thlaspi_r ${BENCHPATH}/thlaspi/genome/thlaspi.fa

# 8) Segemehl 0.3.2
mkdir segemehl
${SEGEMAP_DIR}/segemehl.x -x segemehl/thlaspi.ctidx -y segemehl/thlaspi.gaidx \
-d ${BENCHPATH}/thlaspi/genome/thlaspi.fa -F 1