#!/bin/bash

#-
#-      bash run_blyp-pcs0.sh -N numbernodes -np numberoftasks -c chainlength
#-
#- 	comet has 24 nodes per core.
#-      stampede has 16 nodes per core.

allocation=XXXXXXXXXXXXX

# INPUT
while [[ $# > 1 ]]; do
        key="$1"

	case $key in
        	-N|--nodes)
            	nodes="$2"
            	shift # past argument
            	;;
            	-np|--procs)
            	procs="$2"
            	shift # past argument
            	;;
            	-c|--chain)
            	length="$2"
            	shift # past argument
            	;;
            	*)
		echo "Unkown option."
                exit
                    # unknown option
         	;;
        esac
        shift # past argument or value
done
echo "bash run_blyp-pcs0.sh -N $nodes -np $procs -c $length" > README

# Determine the host
host=$(hostname)
set -- "$host"
IFS="."; declare -a array=($*)
echo "${array[@]}"
flag="${array[1]}"

case "$flag" in
        "stampede")
                cluster="$flag"
		partition=normal
		cpern=16
		
		echo "Running on sampede.tacc.xsede.org"

		runfiles=/scratch/03561/alarcj/NWCHEM
		structures=/scratch/03561/alarcj/NWCHEM/CHAINS
		cp ${runfiles}/raman_run_blyp-pcs0.sh .
		cp ${runfiles}/restart_raman.sh .
		cp ${runfiles}/blyp-pcs0_acetylene.nw .
		cp ${runfiles}/acetylene_restart.nw .
		cp ${structures}/c${length}.xyz .
		;;
        "sdsc")
                cluster=comet
                files=/oasis/scratch/comet/alarcj/temp_project/AMINO/data/op_run
                partition=compute
                echo "Running on comet.sdsc.xsede.org"
                ;;
        *)
                echo "Unkown option."
                exit
esac
# Determine allocation size
# nodes=`expr $np / $cpern`
# minnodes=$(( $nodes * $cpern ))
# if [ "$np" -gt "$minnodes" ]; then
#	nodes=$(( $nodes + 1 ))
# fi

# Proper Naming
sed -i "s/monomer/c${length}/g" blyp-pcs0_acetylene.nw
sed -i "s/monomer/c${length}/g" acetylene_restart.nw


sbatch -A $allocation -p $partition -N $nodes -n $procs -J c${length} raman_run_blyp-pcs0.sh $procs > submit.txt
id=`awk 'END {print $NF}' submit.txt`
sbatch -A $allocation --dependency=afterok:${id} -p $partition -N $nodes -n $procs -J c${length} restart_raman.sh $procs



# FOR debugging purposes
echo "Allocated: $nodes nodes and $procs cores." >> README
echo "Check that ${id} is the same id as in submit.txt" >> README
