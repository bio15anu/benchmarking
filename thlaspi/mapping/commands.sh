
# build initial directories for each sample
mkdir {01,05,10,15,20}x


###########################################
### STANDARD READ MAPPING WITH RAZER S3 ### 

# 1) make directories
mkdir {01,05,10,15,20}x/razers3

# 2) generate razers3.txt file for each sample, based on the number of chunks
ls | grep x$ | while read file;
do ls ${BENCHPATH}/thlaspi/reads/${file}/100000_1/ | cut -d "." -f1 | sort -n | while read chunk;
do echo "${RAZERS3_DIR}/razers3 -rr 100 -i 95 -tc 1 -dr 0 -m 5 -ll 750 -le 750 -ds \
-o ${BENCHPATH}/thlaspi/mapping/${file}/razers3/${chunk}.bam \
${BENCHPATH}/thlaspi/genome/thlaspi.fa \
${BENCHPATH}/thlaspi/reads/${file}/100000_1/${chunk}.fastq.gz \
${BENCHPATH}/thlaspi/reads/${file}/100000_2/${chunk}.fastq.gz";
done > ${file}/razers3.txt; done

# 3) run Razer S3 on chunked reads from each sample
ls | grep x$ | while read file; do parallel -j 20 --noswap --nice 10 < ${file}/razers3.txt; done

# 4) merge all chunks into a single bam file
ls | grep x$ | while read file; do samtools merge ${file}/razers3.bam ${file}/razers3/*.bam; done


############################################################
### BISULFITE READ MAPPING WITH BISULFITE-AWARE ALIGNERS ###

# 1) Bismark 0.20.0 (bowtie 2.3.4.2)
mkdir {01,05,10,15,20}x/bismark
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/bismark; ${BENCHPATH}/bin/runBismark.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done

# 2) BS-Seeker 2.1.5 (bowtie 2.3.4.2)
mkdir {01,05,10,15,20}x/bsseeker2
source ~/venv2/bin/activate # python 2.7 environment required
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/bsseeker2; ${BENCHPATH}/bin/runBSSeeker2.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done
deactivate

# 3) BWA-meth 0.2.2 (bwa 0.7.17)
mkdir {01,05,10,15,20}x/bwameth
export PYTHONPATH=${BWAMETH_DIR}
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/bwameth; ${BENCHPATH}/bin/runBWAmeth.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done
unset PYTHONPATH

# 4) ERNE-BS5 2.1.1
mkdir {01,05,10,15,20}x/erne-bs5
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/erne-bs5; ${BENCHPATH}/bin/runERNE.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done

# 5) GEM 3.6
mkdir {01,05,10,15,20}x/gem-mapper
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/gem-mapper; ${BENCHPATH}/bin/runGEM3.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done

# 6) GSNAP 2018-07-04 # do this with conda instead
mkdir {01,05,10,15,20}x/gsnap
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/gsnap; ${BENCHPATH}/bin/runGSNAP.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done

# 7) Last 950
mkdir {01,05,10,15,20}x/last
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/last; ${BENCHPATH}/bin/runLast.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done

# 8) Segemehl 0.3.2
mkdir {01,05,10,15,20}x/segemehl
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/segemehl; ${BENCHPATH}/bin/runSegemehl.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done

# 9) BSMAP 2.6 
mkdir {01,05,10,15,20}x/bsmap
ls | grep x$ | while read rep;
do cd ${BENCHPATH}/thlaspi/mapping/${rep}/bsmap; ${BENCHPATH}/bin/runBSmap.sh \
${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_1.fastq ${BENCHPATH}/thlaspi/reads/${rep}/bisulfite/simulated_2.fastq \
thlaspi; cd ${BENCHPATH}/thlaspi/mapping; done

#######################
### POST-PROCESSING ###

# merge GSNAP files
ls ${BENCHPATH}/thlaspi/mapping | grep x$ | while read rep; \
do id=$(ls ${rep}/gsnap/* | grep -Ev "log|time|mem" | while read file; \
do echo ${file}; samtools view $file | wc -l; done | paste - - | awk '$2!=0 {print $1}' | tr "\n" " "); \
samtools merge ${rep}/gsnap/simulated.gsnap.bam $id; echo "finished with: ${rep}/gsnap/simulated.gsnap.bam"; done

# convert maf to sam
ls ${BENCHPATH}/thlaspi/mapping/*/last/*.maf | while read maf;
do sam=$(echo $maf | sed 's/\.maf$/\.sam/'); python2 ${LASTMAP_DIR}/maf-convert sam -d $maf > $sam; \
echo "finished with: ${maf}"; rm $maf; done

# convert sam to bam
ls ${BENCHPATH}/thlaspi/mapping/*/{bsmap,bwameth,gem-mapper,last,segemehl}/*.sam | while read sam; \
do bam=$(echo $sam | sed 's/\.sam$/\.bam/'); samtools view -Sb $sam > $bam; \
echo "finished with: ${sam}"; rm $sam; done
