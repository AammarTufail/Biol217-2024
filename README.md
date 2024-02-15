# Biol217-2024

## Here is how to use srun for ANVIO interactive:

### Displaying stuff
```
srun --pty --mem=10G --nodes=1 --tasks-per-node=1 --cpus-per-task=1 --partition=base /bin/bash
module load gcc12-env/12.1.0
module load miniconda3/4.12.0
conda activate anvio-8
```
`Run the command to display what you want`
Then open a new terminal
```
ssh -L 8060:localhost:8080 sunam216@caucluster.rz.uni-kiel.de
```
```
ssh -L 8080:localhost:8080 n100
```
http://127.0.0.1:8060/
Then close the connection with `ctrl c`
```
exit
```
# if the host is busy, try 8080 instead of 8060
