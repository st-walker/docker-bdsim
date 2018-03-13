#!/bin/bash

source /bdsim/geant4-install/bin/geant4.sh
source /bdsim/root-install/bin/thisroot.sh
export LD_LIBRARY_PATH=/bdsim/bdsim-install/lib/:${LD_LIBRARY_PATH}

exec /bdsim/bdsim-install/bin/bdsim --batch "$@"
