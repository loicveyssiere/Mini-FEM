/*  Copyright 2014 - UVSQ, Dassault Aviation
    Authors list: Loïc Thébault, Eric Petit

    This file is part of MiniFEM.

    MiniFEM is free software: you can redistribute it and/or modify it under the terms
    of the GNU Lesser General Public License as published by the Free Software
    Foundation, either version 3 of the License, or (at your option) any later version.

    MiniFEM is distributed in the hope that it will be useful, but WITHOUT ANY
    WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
    PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License along with
    MiniFEM. If not, see <http://www.gnu.org/licenses/>. */

#ifndef PRECOND_H
#define PRECOND_H

// External preconditioner Fortran functions
extern "C" {
void ela_invert_prec_ (int *dimNode, int *nbNodes, int *nodeToNodeIndex,
                       int *nodeToNodeValue, double *prec, int *error,
                       int *checkBounds, int *curNode);
void ela_comm_mpi_ (int *dimNode, int *nbNodes, double *prec, int *nbBlocks,
                    double *buffer, int *nbIntf, int *nbIntfNodes,
                    int *neighborList, int *intfIndex, int *intfNodes);
void lap_comm_mpi_ (int *nbNodes, double *prec, int *nbBlocks, double *buffer,
                    int *nbIntf, int *nbIntfNodes, int *neighborList,
                    int *intfIndex, int *intfNodes);
}

// Create preconditioner for elasticity operator
void preconditioner_ela (double *prec, double *buffer, double *nodeToNodeValue,
                         int *nodeToNodeRow, int *nodeToNodeColumn,
                         int *intfIndex, int *intfNodes, int *neighborList,
                         int *checkBounds, int nbNodes, int nbBlocks,
                         int nbIntf, int nbIntfNodes, int mpiRank);

// Create preconditioner for laplacian operator
void preconditioner_lap (double *prec, double *buffer, double *nodeToNodeValue,
                         int *nodeToNodeRow, int *nodeToNodeColumn, int *intfIndex,
                         int *intfNodes, int *neighborList, int nbNodes, int nbBlocks,
                         int nbIntf, int nbIntfNodes, int mpiRank);

// Call the appropriate function to create the preconditioner
void preconditioner (double *prec, double *buffer, double *nodeToNodeValue,
                     int *nodeToNodeRow, int *nodeToNodeColumn, int *intfIndex,
                     int *intfNodes, int *neighborList, int *checkBounds,
                     int nbNodes, int nbBlocks, int nbIntf, int nbIntfNodes,
                     int operatorDim, int operatorID, int mpiRank);

#endif
