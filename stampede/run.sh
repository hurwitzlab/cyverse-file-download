#!/bin/bash

#SBATCH -A iPlant-Collabs
#SBATCH -p normal
#SBATCH -t 24:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -J cyvrsup

module load launcher

set -u

FILES_LIST=""
DEST_DIR=""
PARAMRUN="$TACC_LAUNCHER_DIR/paramrun"

export LAUNCHER_PLUGIN_DIR="$TACC_LAUNCHER_DIR/plugins"
export LAUNCHER_WORKDIR="$PWD"
export LAUNCHER_RMI="SLURM"
export LAUNCHER_SCHED="interleaved"


function lc() {
    FILE=$1
    [[ -f "$FILE" ]] && wc -l "$FILE" | cut -d ' ' -f 1
}


function USAGE() {
    printf "Usage:\\n  %s -f FILES_LIST -d DEST_DIR\\n\\n" "$(basename "$0")"

    echo "Required arguments:"
    echo " -d DEST_DIR"
    echo " -f FILES_LIST"
    echo
    exit "${1:-0}"
}

[[ $# -eq 0 ]] && USAGE 1

while getopts :d:f:h OPT; do
    case $OPT in
        d)
            DEST_DIR="$OPTARG"
            ;;
        f)
            FILES_LIST="$OPTARG"
            ;;
        h)
            USAGE
            ;;
        :)
            echo "Error: Option -$OPTARG requires an argument."
            exit 1
            ;;
        \?)
            echo "Error: Invalid option: -${OPTARG:-""}"
            exit 1
    esac
done

if [[ -z "$DEST_DIR" ]]; then
    echo "-d DEST_DIR is required"
    exit 1
fi

if [[ -z "$FILES_LIST" ]]; then
    echo "-f FILES_LIST is required"
    exit 1
fi

if [[ ! -f "$FILES_LIST" ]]; then
    echo "FILES_LIST \"$FILES_LIST\" is not a regular file"
    exit 1
fi

imkdir "$DEST_DIR"

PARAM="$$.param"

i=0
while read -r FILE; do
    i=$((i+1))
    BASENAME=$(basename "$FILE")
    printf "%3d: %s\\n" $i "$BASENAME"
    echo "get.sh $FILE $DEST_DIR" >> "$PARAM"
done < "$FILES_LIST"

NJOBS=$(lc "$PARAM")
echo "Starting NJOBS \"$NJOBS\" $(date)"
LAUNCHER_JOB_FILE="$PARAM"

if [[ $NJOBS -gt 16 ]]; then
    LAUNCHER_PPN=16
else
    LAUNCHER_PPN=$NJOBS
fi

export LAUNCHER_JOB_FILE
export LAUNCHER_PPN
$PARAMRUN
echo "Ended LAUNCHER $(date)"
rm "$PARAM"

echo "Done, comments to Ken Youens-Clark kyclark@email.arizona.edu"
