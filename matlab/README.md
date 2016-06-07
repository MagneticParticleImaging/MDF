This folder contains exemplary Matlab codes for a simple MPI reconstruction.

The data provided [here] (http://www.tuhh.de/ibi/research/mpi-data-format.html) is loaded in the Matlab script

The Matlab working directory should be
```
<your hard-drive>\MDF\matlab\
```
	
Running the script
```
reco.m
```
you should obtain after roughly one minutes two output images

It presents the results of reconstruction of the concentration map a tracer using the system matrix/calibration approach. Using the same measurements, the inconsistent system of linear equations is solved using the signal acquired by a scanner.

Two algorithms are used to solved it:
 1. a modified ART algorithm, regularizing and forcing a positive and real approximation of the solution,
 2. pseudoinverse approach.

You can try whatever you want to improve these reconstruction!
