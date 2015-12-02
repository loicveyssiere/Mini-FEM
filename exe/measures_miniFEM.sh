#!/bin/bash

# Set the parameters
EXE_DIR=$HOME/Dassault/Mini-FEM/exe
EXE_FILE=$EXE_DIR/GASPI_exe_$NB_NODES.sh
MACHINE_FILE=$EXE_DIR/GASPI_machine_file_$NB_NODES
TEST_CASE=EIB
VECTOR_LENGTH=AVX
NB_ITERATIONS=50

# Go to the appropriate directory, exit on failure
cd $EXE_DIR || exit

for VERSION in 'REF_BulkSynchronous' 'DC_BulkSynchronous_TreeCreation' \
                                     'DC_MultithreadedComm_TreeCreation'
do
    for DISTRI in 'XMPI' 'GASPI'
    do
        # Set the environment
        module load CMake/3.0.0-intel-2015b
        if [ $DISTRI == "GASPI" ]; then
            export PATH=$PATH:$HOME/Programs/GPI-2/bin
        fi

        for SHARED in 'CILK' #'OMP'
        do
            BINARY=$EXE_DIR/bin/miniFEM_$VERSION\_$DISTRI\_$SHARED
            if [ $VERSION == "DC_VEC" ]; then
                BINARY=$BINARY\_$VECTOR_LENGTH
            fi

            for OPERATOR in 'ela' #'lap'
            do
                # Create the GASPI execution script
                if [ $DISTRI == "GASPI" ]; then
                    echo "#!/bin/sh" > $EXE_FILE
                    echo "cd $EXE_DIR" >> $EXE_FILE
                    echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $EXE_FILE
                    echo "$BINARY $TEST_CASE $OPERATOR $NB_ITERATIONS" >> $EXE_FILE
                    chmod +x $EXE_FILE
                fi

                for PART_SIZE in 200 #50 200 500
                do
                    export elemPerPart=$PART_SIZE

                    #for NB_PROCESS in 1 4 8 16 #32 64 128 256 512
                    for NB_PROCESS in $NB_NODES
                    do

                        for NB_THREADS in 1 4 8 12 16 24
                        do
                            #let "nbCores=$NB_PROCESS*$NB_THREADS"
                            let "nbCores=$NB_NODES*$NB_THREADS"
                            if [ "$nbCores" -gt "$MAX_CORES" ]; then break; fi
                            #if [ $VERSION == 'REF' ] && [ $NB_THREADS -gt 1 ]; then break; fi
                            if [ $VERSION == 'REF_BulkSynchronous' ]; then
                                NB_PROCESS=$nbCores
                                NB_THREADS=1
                            fi
                            if [ $SHARED == "CILK" ]; then
                                export CILK_NWORKERS=$NB_THREADS
                            else
                                export OMP_NUM_THREADS=$NB_THREADS
                            fi

                            # Create the GASPI machine file
                            if [ $DISTRI == "GASPI" ]; then
                                cat $PBS_NODEFILE | head -n $NB_PROCESS | cut -d'.' -f1 > $MACHINE_FILE
                            fi

                            OUTPUT_FILE=$EXE_DIR/stdout_$TEST_CASE\_$NB_NODES\_$VERSION\_$DISTRI\_$SHARED\_$OPERATOR\_$PART_SIZE\_$NB_PROCESS\_$NB_THREADS

                            if [ $DISTRI == "XMPI" ]; then
       	                        mpirun -np $NB_PROCESS $BINARY $TEST_CASE $OPERATOR $NB_ITERATIONS > $OUTPUT_FILE
                            elif [ $DISTRI == "GASPI" ]; then
                                gaspi_run -m $MACHINE_FILE $EXE_FILE > $OUTPUT_FILE
                            fi

#                            mv intfRatio intfRatio_$TEST_CASE\_$NB_PROCESS\_$PART_SIZE
                        done
                    done
                done
            done
        done
    done
done

#rm $MACHINE_FILE $EXE_FILE

exit
