#!/bin/bash

# Put here the program (maybe with path)
PE="pitch_evaluate pitch_db/train/*f0ref" #Solucionar chapuza

for up in 0.91 0.915; do
for thc in 0.001 0.0001 0.0005; do

GETF0="get_pitch --umbral=$up --clipping=$thc"

echo "Parametros: Umbral: $up, TH_CLIPPING: $thc"
for fwav in pitch_db/train/*.wav; do
    ff0=${fwav/.wav/.f0}
    echo "$GETF0 $fwav $ff0 ----"
    $GETF0 $fwav $ff0 > /dev/null || (echo "Error in $GETF0 $fwav $ff0"; exit 1)
done
    pitch_evaluate pitch_db/train/*f0ref
done
done

exit 0
