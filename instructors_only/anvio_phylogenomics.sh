# setup a place to download CONCOCT source code
mkdir -p ~/github/ && cd ~/github/

# get a clone of the CONCOCT codebase from the fork
# that is tailored for the anvi'o conda environment
git clone https://github.com/merenlab/CONCOCT.git

# build and install
cd CONCOCT
# mamba install anaconda::cython
python setup.py build
python setup.py install
