# Magnetic Particle Imaging Data Format (MDF)
This repository contains the specification of the MDF and example code that shows how to handle MDF files and how to perform a simple reconstruction. In order to getting started run one of the Julia/Python/Matlab example scripts which will download experimental test datasets and perform a simple reconstruction.

In 08/2017 version 2 of the MDF has been released. It is a major breaking update that was necessary due to several shortcommings in the first version. The open source Julia package https://github.com/MagneticParticleImaging/MPIFiles.jl contains converters from MDF V1 to MDF V2.

## Related Publication
As of version 1.0.1 the most recent release of these specifications can also be also found on the arXiv http://arxiv.org/abs/1602.06072. If you use MDF please cite us using the arXiv reference, which is also available for download as `MDF.bib`.

## Example Code
Alongside the MDF specifications several small code examples written in **Julia**, **Matlab** and **Python** are provided. Irrespective of the language all examples implement the same algorithm. The example code can be used as a reference for basic interaction with MDF files. For more details please take a look into the respective README files within the language subfolders.

## MPIFiles.jl
We provide a reference implementation for a high level MDF access in the Julia package https://github.com/MagneticParticleImaging/MPIFiles.jl. It can read MDF V2, MDF V2, and the dataformat of Bruker MPI system using a common interface.This allows to write reconstruction code that can handle all three data formats.
