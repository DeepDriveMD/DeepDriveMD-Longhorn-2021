#!/bin/bash
#SBATCH -J 1-gpu_32-gbs            # Job name
#SBATCH -o 1-gpu_32-gbs_%j.out     # Name of stdout output file
#SBATCH -e 1-gpu_32-gbs_%j.err     # Name of stderr error file
#SBATCH -p v100                    # Queue (partition) name
#SBATCH -N 1                       # Total # of nodes (must be 1 for serial)
#SBATCH -n 1                       # Total # of mpi tasks (should be 1 for serial)
#SBATCH -t 24:00:00                # Run time (hh:mm:ss)
 
# Other commands must follow all #SBATCH directives ...
module load conda
conda activate /scratch/06079/tg853783/ddmd/envs/pytorch.mpi
export HDF5_USE_FILE_LOCKING='FALSE'

bash_script="/scratch/06079/tg853783/ddmd/src/DeepDriveMD-Longhorn-2021/ddp_aae_experiments/aae_run.sh"
python_exe="/scratch/06079/tg853783/ddmd/envs/pytorch.mpi/bin/python"
train_script="/scratch/06079/tg853783/ddmd/src/DeepDriveMD-Longhorn-2021/ddp_aae_experiments/train.py"
config_file="/scratch/06079/tg853783/ddmd/src/DeepDriveMD-Longhorn-2021/ddp_aae_experiments/aae_template.yaml"
output_path="/scratch/06079/tg853783/ddmd/runs/ddp_aae_experiments/1-gpu_32-gbs"
data_path="/scratch/06079/tg853783/ddmd/data/preprocessed/spike-all-AAE.h5"
tmp_data_path="/tmp/spike-all-AAE.h5"

# Copy input data to each node's local storage /tmp
ntask_cnt=4
cnt=0
for i in `hostlist -e $SLURM_JOB_NODELIST`
do
    ibrun -n 1 -o $(expr $ntask_cnt '*' $cnt) cp ${data_path} ${tmp_data_path} &
    cnt=$(expr $cnt + 1)
done
wait

# Launch MPI code ...
ibrun -n 1 ${bash_script} ${python_exe} ${train_script} "-c" ${config_file} "--output_path" ${output_path} "--data_path" ${tmp_data_path}
