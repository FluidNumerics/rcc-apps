#!/bin/bash
 
echo "Usage : Port, Slurm Partition, Num-MPI-procs, Memory-per-rank, Hours needed"
 
LOGIN=$(hostname -s)
JOB=$RANDOM
TEMP_FILE="/tmp/sbatch-script.$JOB.slurm"
 
echo "Temporary job file: $TEMP_FILE" # show file name

cat >$TEMP_FILE << EOL
#!/bin/bash                                           
#SBATCH --partition=$2                                           
#SBATCH --ntasks=$3                                         
#SBATCH --cpus-per-task=1                                      
#SBATCH --mem-per-cpu=$4g                                      
#SBATCH --time=$5:00:00                                        
#SBATCH --job-name=paraview-$JOB                               
#SBATCH -o paraview-$JOB.log                               
#SBATCH -e paraview-$JOB.log                               
                                                               
mpirun -np \${SLURM_NTASKS} /opt/paraview/bin/pvserver --reverse-connection --client-host=$LOGIN --server-port=$1 --force-offscreen-rendering 
EOL
 
# display the job submission
cat $TEMP_FILE

# submit the job
sbatch --get-user-env $TEMP_FILE

echo 'Waiting for Slurm job to begin..'
while true; do
 export JOB_STATUS=$(squeue -n paraview-$JOB --format="%.2t" | tail -n1 | xargs)
 echo "Job Status : $JOB_STATUS"
 if [ "$JOB_STATUS" == "R" ]; then
   echo "Job started!"
   break
 else
   sleep 10
 fi
done

echo "Waiting for pvserver to start..."
while true; do
  PV_STATUS=$(grep "Client connected." paraview-$JOB.log)
  if [ "$PV_STATUS" = "Client connected." ]; then
    echo "Paraview Server connected!"
    break
  else
    echo "Waiting for pvserver to connect to client..."
    sleep 5
  fi
done
