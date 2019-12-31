# 1) generate standard sequencing reads with Sherman
parallel -j 5 --noswap --nice 10 < sherman.txt

# 2) repair ID lines in fastq files prior to cutadapt   
ls | grep x$ | while read file;
do for i in {1,2};
do cat ${file}/simulated_${i}.fastq | awk '{if(NR%4==1) {split($0,ID,"_"); print ID[1]"_"ID[2]} else {print $0}}' > ${file}/simulated_${i}.fixed.fastq;
done; done

# 3) compress files
gzip */simulated*

# 4) trim all files with cutadapt
ls | grep x$ | while read file;
do cutadapt -a AGCAGAAGACGGCATACGAGATCGGTCTCGGCATTCCTGCTGAACCGCTCTTCCGATCT -A AGATCGGAAGAGCGGTTCAGCAGGAATGCCGAGACCGATCTCGTATGCCGTCTTCTGCT \
-q 20 -O 10 -m 100 -o ${file}/simulated_1.clipped.fastq.gz -p ${file}/simulated_2.clipped.fastq.gz \
${file}/simulated_1.fixed.fastq.gz ${file}/simulated_2.fixed.fastq.gz &> ${file}/cutadapt.log;
done

# 5) make directories and split fastq files into chunks of 100000 ready for parallel processing
mkdir {01,05,10,15,20}x/100000_{1,2}
ls | grep x$ | while read file;
do for i in {1,2};
do for j in $(seq 400000 400000 $(echo $(gunzip -c ${file}/simulated_${i}.clipped.fastq.gz | wc -l)+400000 | bc -l));
do gunzip -c ${file}/simulated_${i}.clipped.fastq.gz | tail -n +$((${j}-399999)) | head -400000 > ${file}/100000_${i}/$(echo "scale=0; ${j}/4" | bc -l).fastq;
done; done; done

# 6) compress all chunk files
gzip *x/100000*/*

# 7) make directories and generate bisulfite reads (99% conversion rate)
mkdir {01,05,10,15,20}x/bisulfite
ls | grep x$ | while read file;
do for i in {1,2};
do gunzip -c ${file}/simulated_${i}.clipped.fastq.gz > ${file}/bisulfite/simulated_${i}.fastq;
${BENCHPATH}/bin/bisulfite_transform.py ${file}/bisulfite/simulated_${i}.fastq 99 ${i};
echo "finished ${file}/simulated_${i}.fastq";
done; done
