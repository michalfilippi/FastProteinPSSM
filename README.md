# FastProteinPSSM
This script computes PSSM (possition specific scoring matrix) for a protein sequence given in input file in FASTA format.

## Credits
Many thanks to Lukáš Jendele, auhor of original project for [protein conservation calculation](https://github.com/jendelel/calc_protein_conservation).

## Preliminaries
### Installing all necessary tools
1. Download BLAST+ suite from [here](ftp://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/LATEST/).
2. Install/unpack the BLAST+ archive and make sure your directory is PATH.
3. Download CD-HIT from [here](https://github.com/weizhongli/cdhit/releases).
4. Unpack CD-HIT archive, run make command and make sure cd-hit is in PATH.

### Installing databases
1. Download SwissProt and UniRef90 databases from [here](http://www.uniprot.org/downloads) in FASTA format.
2. Create a directory where you want to store the databases.
3. Add environmental variable BLASTDB={path to the directory}
4. cd to this directory and run these commands. This will take quite a lot of time.

```
    zcat {path to uniref90 database .gz file} | makeblastdb -out uniref90 -dbtype prot -title UniRef90 -parse_seqids
    zcat {path to swissprot database .gz file} | makeblastdb -out swissprot -dbtype prot -title SwissProt -parse_seqids
```

5) Optional: Now you can delete the .gz database files.

# Running the script
1. cd to the project directory
2. Run this command: ```./FastProtein.sh {path to your fasta file} [-s]```

Parameter -s turnes on scaling of all values using sigmoid function.

# Notes

## Output

Every line of output contains 21 values of PSSM matrix. Order or amino acids is ACDEFGHIKLMNPQRSTVWXY.

Values are scaled using sigmoid function if -s parameter was passed.

## How it works
PSIBLAST is ran with your fasta input on SwissProt database (1 iteration, eval=1e-5).   
The result is filtered (min 80% coverage and seq identity between 30% and 95%), then clustered with CD-HIT (default parameters).   
If we are left with less then 50 hits, repeat the same for UniRef90 database.  

PSSM generated by last iteration of PSI-BLAST is returned in simplier format.

