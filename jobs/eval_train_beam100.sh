#!/bin/bash
#SBATCH -n 1                                # number of comands issued in batch script at any times
#SBATCH --cpus-per-task=8                  # number of cores to allocate each task
#SBATCH -N 1                                # Request 1 node
#SBATCH --time=24:00:00

#SBATCH --gres=gpu:1                      # specify GPU count
#SBATCH -p sched_mit_ccoley                 # sched_mit_hill #Run on sched_engaging_default partition
#SBATCH --mem-per-cpu=8000                 # Request 4G of memory per CPU

#SBATCH -o logs/seed77777777_output_%x_%j.txt               # redirect output to output_JOBNAME_JOBID.txt
#SBATCH -e logs/seed77777777_error_%x_%j.txt                # redirect errors to error_JOBNAME_JOBID.txt
#SBATCH -J MEGAN_eval_train77777777_beam100_bs5                           # name of job
#SBATCH --mail-type=ALL               # Mail when job starts and ends
#SBATCH --mail-user=linmin001@e.ntu.edu.sg  # email address

source /cm/shared/engaging/anaconda/2018.12/etc/profile.d/conda.sh
source env_seed77777777.sh

# this fixes RDKit problem
module load gcc/8.3.0

# propose train, beam100, ~8 hours?
SECONDS=0
python3 bin/eval.py models/uspto_50k --beam-size 100 --show-every 1000 --split-key train --beam-batch-size 5
duration=$SECONDS
echo "$(($duration / 3600)) hours, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."