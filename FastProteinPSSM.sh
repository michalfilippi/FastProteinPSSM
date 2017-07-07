#!/bin/sh

# reads fasta file with only one sequence from file $1.
# all intermidiate results are stored in directory $2

if test $# -ne 1
then
    echo "Usage: FastProteinPSSM.sh query_fasta_file [-s]"
    exit 1
fi

file=$1
scale=$2

# Create ouput files.
pssm_file="./pssm"

# Create temp files which are deleted before terminating.
psiblast_seq=$(tempfile)
psiblast_output=$(tempfile)
psiblast_pssm=$(tempfile)

# Function that searches a database and filters the results $1 - database name for psiblast
search () {
    db=$1

    echo "Searching $db."

    # Run PSI-BLAST to find ids all similar sequences.
    psiblast < $file -db $db -outfmt '6 sallseqid qcovs pident' -evalue 1e-5 -save_pssm_after_last_round -out_ascii_pssm "$psiblast_pssm"  | ./filter.awk > "$psiblast_output"

    # Get full sequences.
    blastdbcmd -db $db -entry_batch $psiblast_output > $psiblast_seq

    # Filter using CD-HIT.
    cd-hit -i $psiblast_seq -o $psiblast_output >&2
}

# Search for similar sequences in SwissProt db.
search swissprot
# Get number of sequences found.
numSeq=$(grep < $blastResFile '^>' | wc -l)
echo "Found $numSeq proteins."

# If less than 50 seqs found, fallback to search in UniRef90.
[ $((numSeq >= 50)) = 0 ] && search uniref90

python process_pssm "$psiblast_pssm" "$scale" > pssm_file

# Delete temp files.
echo $psiblast_output $psiblast_seq $psiblast_pssm
rm $psiblast_output $psiblast_seq $psiblast_pssm

