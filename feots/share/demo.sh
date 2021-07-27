#!/bin/bash

export FEOTS_DBROOT=/opt/feots-db/E3SMV0-HILAT-5DAVG
export REGIONAL_DB=/opt/feots-db/argentine-basin
export DEMO_DIR=/opt/feots/examples/zapiola
export OUTDIR=~/feots

mkdir -p $OUTDIR
cp ${DEMO_DIR}/genmask ${OUTDIR}/genmask
cp ${DEMO_DIR}/init ${OUTDIR}/init
cp ${DEMO_DIR}/runtime.params ${OUTDIR}/runtime.params


cd ${OUTDIR}

echo ""
echo "================================================"
echo "Creating mask for FEOTS simulation database"
echo ""
./genmask --dbroot ${FEOTS_DBROOT}  \
          --regional-db ${REGIONAL_DB} \
          --out ${OUTDIR} \
          --param-file ./runtime.params

echo ""
echo "================================================"
echo "Creating regional maps to map with global mesh"
echo ""
mpirun -np 1 feots genmaps --out ${OUTDIR} \
                           --regional-db ${REGIONAL_DB} \
                           --dbroot ${FEOTS_DBROOT} \
                           --param-file ./runtime.params


echo ""
echo "================================================"
echo "Creating initial conditions"
echo ""
mpirun -np 6 --map-by core --bind-to core ./init --out ${OUTDIR} \
                    --regional-db ${REGIONAL_DB} \
                    --dbroot ${FEOTS_DBROOT} \
                    --param-file ./runtime.params

echo ""
echo "================================================"
echo "Creating initial conditions"
echo ""
mpirun -np 6 --map-by core --bind-to core feots integrate ${FEOTS_FLAGS} \
                             --regional-db ${REGIONAL_DB} \
                             --out ${OUTDIR} \
                             --param-file ./runtime.params
