#!/bin/sh

# reads fasta file with only one sequence from file $1.
# all intermidiate results are stored in directory $2

if test $# -ne 2
then
    echo "Usage: calc_conservation.sh query_fasta_file out_directory"
    exit 1
fi

file=$1
out_dir=$2

# Create ouput files.
blastResFile="$2/psiblast_output"
blastSeq="$2/psiblast_fullseq"
muscleResultFile="$2/msa"
conservationExtractorInput="$2/conservation_list"
conservationFile="$2/conservation_full"
pssmFile="$2/pssm"
conservation_output="$2/conservation_query"

# Create temp files which are deleted before terminating.
modifiedInputFile=$(tempfile)

# Function that searches a database and filters the results $1 - database name for psiblast
search () {
    db=$1

    # Run PSI-BLAST to find ids all similar sequences.
    psiblast < $file -db $db -outfmt '6 sallseqid qcovs pident' -evalue 1e-5 -save_pssm_after_last_round -out_ascii_pssm "$pssmFile" | ./filter.awk > $blastResFile

    # Get full sequences.
    blastdbcmd -db $db -entry_batch $blastResFile > $blastSeq

    # Filter using CD-HIT.
    cd-hit -i $blastSeq -o $blastResFile >&2
}

# Search for similar sequences in SwissProt db.
search swissprot
# Get number of sequences found.
numSeq=$(grep < $blastResFile '^>' | wc -l)

# If less than 50 seqs found, fallback to search in UniRef90.
[ $((numSeq >= 50)) = 0 ] && search uniref90

# Change the description from the file to find it later.
sed < $file 's/^>/>query_sekvence|/' > $modifiedInputFile

# Run muscle. Note we need to concat the query sequence in order to get its conservation later.
cat $blastResFile $modifiedInputFile | muscle > $muscleResultFile

# conservationExtractorInput should look somewhat like this:
# number: >Sequence header 
# .
# query sequence has query_sekvence prefix that will be removed later in awk script.
# .
grep < $muscleResultFile '^>' | nl > $conservationExtractorInput
# >separator for awk to know that this is EOF
echo ">separator" >> $conservationExtractorInput

# Run conservation script (Jensen-Shannon divergence: http://compbio.cs.princeton.edu/conservation/)

python score_conservation.py $muscleResultFile > $conservationFile 
cat $conservationFile | cat $conservationExtractorInput - | ./getCol.awk > $conservation_output

rm $modifiedInputFile

