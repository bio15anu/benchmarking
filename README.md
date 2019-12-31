# HOW-TO

First, clone or download the repository to a location on your system.

Second, define environmental variables within your system architecture.

1) Export the path to the benchmarking base directory:

```
export BENCHPATH=/path/to/benchmarking
```

2) Export the number of threads to use for testing:
```
export THREADS=8
```

3) Export the path to these tools in your working environment:
```
export BOWTIE2_DIR=/usr/local/bowtie2/2.3.4.2/binary
export SAMTOOLS_DIR=/usr/local/samtools/1.9/binary/bin
```

4) Export the path to these aligners in your working environment:
```
export RAZERS3_DIR=/usr/local/razers3/3.5.8/binary/bin
export BISMARK_DIR=/usr/local/bismark/0.20.0/binary
export BSSEEKR_DIR=/usr/local/bsseeker/2.1.5/binary
export BWAMETH_DIR=/usr/local/bwameth/0.2.2/binary
export ERNEBS5_DIR=/usr/local/erne/2.1.1/binary/bin
export GEM3MAP_DIR=/usr/local/gem/3.6/binary/bin
export GSNAP_DIR=/usr/local/gsnap/2018-07-04/binary/bin
export LASTMAP_DIR=/usr/local/last/950/binary/bin
export SEGEMAP_DIR=/usr/local/segemehl/0.3.2/binary
export BSMAP_DIR=/usr/local/bsmap/2.6/binary
```


Third, now follow each step sequentially for the species of interest:

**For each species**

1. Navigate to `reads` directory, follow `commands.sh` to generate reads
2. Navigate to `genome` directory, follow `commands.sh` to build genome indexes
3. Navigate to `mapping` directory, follow `commands.sh` to carry out read alignments
4. Navigate to `analysis` directory, follow `commands.sh` to generate tables/graphics

