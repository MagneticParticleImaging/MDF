# MDF
Magnetic Particle Imaging Data Format

This repository contains the specification of the Magnetic Particle Imaging Data Format (MDF) and example code that shows how to perform a simple reconstruction. In order to getting started run one of the Julia/Python/Matlab example scripts which will download experimental test datasets and performs a simple reconstruction.

** Note: We are currently working on a major upgrade of the MDF to address shortcomings. Please look at the v2 branch for the current status **

## arXiv
As of version 1.0.1 the most recent release of these specifications can also be also found on the arXiv http://arxiv.org/abs/1602.06072. If you use MDF please cite us using the arXiv reference, which is also available for download as `MDF.bib`.

## Sanity Check
As of version 1.0.1 a sanity check to test and debug MDF files is provided. It is written in the Julia programming language, which is availible on http://julialang.org/. For more details we refer to the README within the `julia` folder.

## Example Code
Alongside the MDF specifications code examples written in Julia, Matlab and Python are provided. These can be used as example for basic interaction with MDF files. For more details please take a look into the respective README files within the language subfolders.
