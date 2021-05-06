#!/bin/bash
#SBATCH -n 1                                # number of comands issued in batch script at any times
#SBATCH --cpus-per-task=8                  # number of cores to allocate each task
#SBATCH -N 1                                # Request 1 node
#SBATCH --time=48:00:00

#SBATCH --gres=gpu:1                      # specify GPU count
#SBATCH -p sched_mit_ccoley                 # sched_mit_hill #Run on sched_engaging_default partition
#SBATCH --mem-per-cpu=8000                 # Request 4G of memory per CPU

#SBATCH -o logs/seed0_output_%x_%j.txt               # redirect output to output_JOBNAME_JOBID.txt
#SBATCH -e logs/seed0_error_%x_%j.txt                # redirect errors to error_JOBNAME_JOBID.txt
#SBATCH -J MEGAN_eval0_ep56_bs2                           # name of job
#SBATCH --mail-type=ALL               # Mail when job starts and ends
#SBATCH --mail-user=linmin001@e.ntu.edu.sg  # email address

source /cm/shared/engaging/anaconda/2018.12/etc/profile.d/conda.sh
source env_seed0.sh

# this fixes RDKit problem
module load gcc/8.3.0

# preprocess training data from 3 csv files, only need to run once, DONE
# python3 bin/acquire.py uspto_50k

# get graphfeat, only need to run once (i think?) DONE, takes about 2 mins on 8 cores
# python3 bin/featurize.py uspto_50k megan_16_bfs_randat

# train, to run. Authors said 10 hours but it is way longer...about 20 hours on 1 GPU, bcos of the 16-epoch early-stopping patience.
# python3 bin/train.py uspto_50k models/uspto_50k

# evaluate on test set, beam50 (40 mins), DONE
# SECONDS=0
# python3 bin/eval.py models/uspto_50k_ep56 --beam-size 50 --show-every 100 --split-key test
# duration=$SECONDS
# echo "$(($duration / 3600)) hours, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

# --beam-batch-size 2 (need to be less than 10, maybe 5, maybe 2, for --beam-size 200 due to OOM on some samples)
# propose test, beam200 (4 hours w bs 10), RERUN w/ smaller bs of 2, ~7 hours
SECONDS=0
python3 bin/eval.py models/uspto_50k_ep56 --beam-size 200 --show-every 100 --split-key test --beam-batch-size 2
duration=$SECONDS
echo "$(($duration / 3600)) hours, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

# propose valid, beam200 (4 hours w bs 10), RERUN w/ smaller bs of 2, ~7 hours
SECONDS=0
python3 bin/eval.py models/uspto_50k_ep56 --beam-size 200 --show-every 100 --split-key valid --beam-batch-size 2
duration=$SECONDS
echo "$(($duration / 3600)) hours, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

# propose train, beam50, <8 hours
SECONDS=0
python3 bin/eval.py models/uspto_50k_ep56 --beam-size 50 --show-every 100 --split-key train
duration=$SECONDS
echo "$(($duration / 3600)) hours, $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."