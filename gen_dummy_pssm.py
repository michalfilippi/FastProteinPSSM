#
# Script for creating dummy PSSM for cases when psiblast cant create any PSSM,
# because no similar noidentical sequences are found (happens mostly for very
# short sequences).
#
# Takes one argument, a path to a fasta file with query sequence.
#
# Usage: python dummy_pssm.py seq.fasta
#


from __future__ import print_function
import sys

from blosum62 import BLOSUM62


def read_seq(seq_file):
    seq = None
    with open(seq_file, 'r') as fin:
        _ = fin.readline()
        seq = fin.readline()
        seq = seq[:-1] if seq[-1] == '\n' else seq

    return seq


def main():
    seq_file = sys.argv[1]

    pssm_order = 'ARNDCQEGHILKMFPSTWYV'

    seq = read_seq(seq_file)

    print('Dummy PSSM created just based on sequence and BLOSUM62\n')
    print('            A   R   N   D   C   Q   E   G   H   I   L   K   M   F   P   S   T   W   Y   V')

    for i, c in enumerate(seq):
        print('{: 5d} {}  '.format(i + 1, c), end='')
        if c == 'X':
            # row as psiblast calculates it for letter X
            for v in [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
                      -1, -1, -1, -1, -1, -1, -1, -1, -1, -1]:
                print('{: 4d}'.format(v), end='')
        else:
            for c2 in pssm_order:
                print('{: 4d}'.format(BLOSUM62[c][c2]), end='')
        print()

    print()
    print()

if __name__ == "__main__":
    main()

