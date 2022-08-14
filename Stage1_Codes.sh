#to download the file
wget https://raw.githubusercontent.com/HackBio-Internship/wale-home-tasks/main/DNA.fa

#to count the number of sequences in the DNA.fa file
grep -c ">" DNA.fa

#to get the total A, T, G & C counts
grep -v ">" DNA.fa | grep -E -o "G|C|T|A" | wc -l

#to download the softwares:
wget https://github.com/HackBio-Internship/wale-home-tasks/blob/main/softwares.txt

#to set up miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
chmod +x Miniconda3-py39_4.12.0-Linux-x86_64.sh
./ Miniconda3-py39_4.12.0-Linux-x86_64.sh

#to activate miniconda
conda activate base

#to create an environment:
conda create -n HB_genomics
conda activate HB_genomics

#to installing the software:
conda install -c bioconda fastqc
conda install -c bioconda bwa
conda install -c bioconda samtools

#to download datasets:
mkdir datasets
cd datasets
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Alsen_R1.fastq.gz?raw=true -O Alsen_R1.fastq.gz 
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Alsen_R2.fastq.gz?raw=true -O Alsen_R2.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Baxter_R1.fastq.gz?raw=true -O Baxter_R1.fastq.gz
wget https://github.com/josoga2/yt-dataset/blob/main/dataset/raw_reads/Baxter_R2.fastq.gz?raw=true -O Baxter_R2.fastq.gz

#to create a folder called output:
cd ..
mkdir Output

#To implement the softwares on the datasets:
#using fastqc (to check for quality of the data):
ls datasets/ -lh
fastqc datasets/*.fastq.gz -o Output
ls Output

#using multiqc (to aggregate all the html files into a single file):
conda install -c bioconda multiqc
multiqc Output/ 

#using fastp (to trim adapters and poor quality reads):
conda install -c bioconda fastp
touch trim.sh
nano trim.sh
#copy the codes from the Github and paste in trim.sh 
cp trim.sh datasets/
cd datasets/
bash trim.sh
ls
mv qc_reads trimmed_reads
ls

#using BWA(to aligns relatively short sequences to a sequnce base):
ls trimmed_reads
touch reference.fasta
nano reference.fasta
mkdir references
mv reference.fasta references/
bwa index references/reference.fasta
ls references

conda install -c bioconda bbmap
repair.sh in1=trimmed_reads/Alsen_R1.fastq.gz in2=trimmed_reads/Alsen_R2.fastq.gz out1=Alsen_R1_rep.fastq.gz out2=Alsen_R2_rep.fastq.gz outsingle=single.fq
repair.sh in1=trimmed_reads/Baxter_R1.fastq.gz in2=trimmed_reads/Baxter_R2.fastq.gz out1=Baxter_R1_rep.fastq.gz out2=Baxter_R2_rep.fastq.gz outsingle=single.fq

mkdir alignment
bwa mem references/reference.fasta Alsen_R1_rep.fastq.gz Alsen_R2_rep.fastq.gz > alignment/Alsen.sam
bwa mem references/reference.fasta Baxter_R1_rep.fastq.gz Baxter_R2_rep.fastq.gz > alignment/Baxter.sam

touch aligner.sh
nano aligner.sh
bash aligner.sh
ls -lh repaired
ls -lh alignment_map

#using samtools(for manipulating alignments in SAM/BAM format, including sorting, merging, indexing and generating of alignments):
cd alignment_map
samtools view Alsen.bam | less
samtools sort Alsen.bam -o Alsen.sorted.bam
samtools view Alsen.sorted.bam | head -n 5
samtools sort Baxter.bam -o Baxter.sorted.bam
samtools view Baxter.sorted.bam | head -n 5

Done
