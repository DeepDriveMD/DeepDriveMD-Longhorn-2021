#!/bin/bash

if [ -n "$SEG_DEBUG" ] ; then
  set -x
  env | sort
fi

cd $WEST_SIM_ROOT

RMSD=$(mktemp)
COM=$(mktemp)
#COMMAND="           parm $WEST_SIM_ROOT/CONFIG/closed.prmtop \n"
#COMMAND="${COMMAND} trajin $WEST_SIM_ROOT/CONFIG/closed.rst \n"
#COMMAND="${COMMAND} trajin $WEST_STRUCT_DATA_REF \n"
#COMMAND="${COMMAND} autoimage \n"
#COMMAND="${COMMAND} rms @CA,14090-14668,17137-17478,17747-18525,35525-36103,38572-38913,39182-39960,56640-57191,59735-60028,60319-61075 first \n"
#COMMAND="${COMMAND} rms RMSD @CA,5683-5780,5959-6135,6533-6646,7712-7883 first nofit out $RMSD \n"
#COMMAND="${COMMAND} distance RBD_COM @CA,14090-14668,17137-17478,17747-18525,35525-36103,38572-38913,39182-39960,56640-57191,59735-60028,60319-61075 @CA,5683-5780,5959-6135,6533-6646,7712-7883 out $COM \n"
#COMMAND="${COMMAND} go"

#echo -e "${COMMAND}" | $CPPTRAJ
#paste <(cat $COM | tail -n 1 | awk {'print $2'}) <(cat $RMSD | tail -n 1 | awk {'print $2'})>$WEST_PCOORD_RETURN
#rm $RMSD $COM

python_path=/scratch/06079/tg853783/ddmd/envs/pytorch.mpi/bin/python
pcoord_file=$WEST_SIM_ROOT/PCOORDS/$(uuidgen).txt
${python_path} $WEST_SIM_ROOT/deepdrivemd.py \
  --top $WEST_SIM_ROOT/CONFIG/closed.pdb \
  --coord $WEST_STRUCT_DATA_REF \
  --output_path ${pcoord_file} \
  --ref /scratch/06079/tg853783/ddmd/data/raw/spike_WE.pdb \
  --selection "protein and name CA" \
  --model_cfg /scratch/06079/tg853783/ddmd/src/DeepDriveMD-Longhorn-2021/ddp_aae_experiments/aae_template.yaml \
  --model_weights /scratch/06079/tg853783/ddmd/runs/ddp_aae_experiments/1-node_128-gbs/checkpoint/epoch-100-20210727-180344.pt \
  --batch_size 1

#cat $WEST_SIM_ROOT/pcoord.txt>$WEST_PCOORD_RETURN
cat ${pcoord_file}>$WEST_PCOORD_RETURN
rm ${pcoord_file}

if [ -n "$SEG_DEBUG" ] ; then
    head -v $WEST_PCOORD_RETURN
fi
