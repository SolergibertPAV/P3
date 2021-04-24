#!/bin/bash

# Put here the program (maybe with path)

for ur in 0.88 0.89 0.9 0.91; do
for urm in 0.18 0.19 0.2 0.21; do
for up in -36 -37 -38 -39 -40; do
for thc in 0.001 0.0001 0.0005 0.01; do

GETF0="get_pitch --umbralR1=$ur --umbralRm=$urm --umbralP=$up --clipping=$thc"

echo "Parametros: Umbral R1: $ur, Umbral Rm: $urm Umbral P: $up, TH_CLIPPING: $thc"
for fwav in pitch_db/train/*.wav; do
    ff0=${fwav/.wav/.f0}
    echo "$GETF0 $fwav $ff0 ----"
    $GETF0 $fwav $ff0 > /dev/null || (echo "Error in $GETF0 $fwav $ff0"; exit 1)
done
    pitch_evaluate pitch_db/train/*f0ref
done
done
done
done

exit 0
