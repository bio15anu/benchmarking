wget ftp://ftp.bioinfo.wsu.edu/species/Fragaria_vesca/Fvesca-genome.v4.0.a1/assembly/Fragaria_vesca_v4.0.a1.fasta.gz
gunzip -c Fragaria_vesca_v4.0.a1.fasta.gz | sed -e 's/\r//g' | tr -s "\n" > fragaria.fa


# 1) Bismark 0.20.0 (bowtie 2.3.4.2)
${BISMARK_DIR}/bismark_genome_preparation --path_to_bowtie ${BOWTIE2_DIR} ${BENCHPATH}/fragaria/genome/

# 2) BS-Seeker 2.1.5 (bowtie 2.3.4.2)
mkdir bsseeker2
source ~/venv2/bin/activate # python 2.7 environment required
python ${BSSEEKR_DIR}/bs_seeker2-build.py -f ${BENCHPATH}/fragaria/genome/fragaria.fa \
--aligner=bowtie2 -p ${BOWTIE2_DIR} -d ${BENCHPATH}/fragaria/genome/bsseeker2
deactivate

# 3) BWA-meth 0.2.2 (bwa 0.7.17)
mkdir bwameth
ln -s ${BENCHPATH}/fragaria/genome/fragaria.fa bwameth
export PYTHONPATH=${BWAMETH_DIR}
${BWAMETH_DIR}/bin/bwameth.py index ${BENCHPATH}/fragaria/genome/bwameth/fragaria.fa
unset PYTHONPATH

# 4) ERNE-BS5 2.1.1
mkdir erne-bs5
${ERNEBS5_DIR}/erne-create --methyl-hash --output-prefix ${BENCHPATH}/fragaria/genome/erne-bs5/fragaria \
--fasta ${BENCHPATH}/fragaria/genome/fragaria.fa

# 5) GEM 3.6
mkdir gem-mapper
${GEM3MAP_DIR}/gem-indexer -i ${BENCHPATH}/fragaria/genome/fragaria.fa -b -t 8 \
-o ${BENCHPATH}/fragaria/genome/gem-mapper/fragaria

# 6) GSNAP 2018-07-04 # do this with conda instead
mkdir gsnap
${GSNAP_DIR}/gmap_build -D ${BENCHPATH}/fragaria/genome/gsnap -d fragaria ${BENCHPATH}/fragaria/genome/fragaria.fa
${GSNAP_DIR}/cmetindex -F ${BENCHPATH}/fragaria/genome/gsnap -d fragaria

# 7) Last 950
mkdir last
${LASTMAP_DIR}/lastdb -uBISF last/fragaria_f ${BENCHPATH}/fragaria/genome/fragaria.fa
${LASTMAP_DIR}/lastdb -uBISR last/fragaria_r ${BENCHPATH}/fragaria/genome/fragaria.fa

# 8) Segemehl 0.3.2
mkdir segemehl
${SEGEMAP_DIR}/segemehl.x -x segemehl/fragaria.ctidx -y segemehl/fragaria.gaidx \
-d ${BENCHPATH}/fragaria/genome/fragaria.fa -F 1