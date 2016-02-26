# MDF
Magnetic Particle Imaging Data Format

This repository contains the specification of the Magnetic Particle Imaging Data Format (MDF) and example code that shows how to perform a simple reconstruction.

In order to apply the example code, one has to download examplary MPI data from http://www.tuhh.de/ibi/research/mpi-data-format.html into the root directory of this repository.

## arXiv
As of version 1.0.1 the most recent release of these specifications can also be also found on the arXiv http://arxiv.org/abs/1602.06072. If you use MDF please cite us using the arXiv reference, which is also available for download as `MDF.bib`.

## Sanity Check
As of version 1.0.1 a sanity check to test and debug MDF files is provided. It is written in the Julia programming language, which is availible on http://julialang.org/. For more details we refer to the README within the `julia` folder.

## Example Code
Alongside the MDF specifications code examples written in Julia, Matlab and Python are provided. These can be used as example for basic interaction with MDF files. For more details please take a look into the respective README files within the language subfolders.
