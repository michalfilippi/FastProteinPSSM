#!/bin/bash


file="$1"

tmp_file=$(tempfile)

# find position of start of second protein
l_num=`grep -n '^>' "$file" | head -n 2 | tail -n 1 | cut -d ':' -f 1`

# end of first protein
l_num_prev=$(($l_num - 1))

# move first protein to the end
tail -n +$l_num $file > $tmp_file
head -n $l_num_prev $file >> $tmp_file

# overwrite previous fasta file
cp $tmp_file $file


rm $tmp_file

