This folder contains exemplary Matlab codes for a simple MPI reconstruction.

The data provided [here] (http://www.tuhh.de/ibi/research/mpi-data-format.html) have to be placed in the root folder, as shown in the picture below.
<img src="/matlab/results/files.jpg" height="200">

The Matlab working directory should be
```
<your harddrive>\MDF\matlab\
```
	
Running the script
```
reco.m
```
you should obtain after roughly one minutes those three graphs:
<img src="/matlab/results/SM.jpg" height="200">
<img src="/matlab/results/SpectrumMeasure.jpg" height="200">
<img src="/matlab/results/Reco.jpg" height="200">

The last one present the results of reconstruction of the concentration map a tracer using the system matrix/calibration approach. Using the same measurements, the inconsistent system of linear equations is solved using the signal acquired by a single channel of the scanner.

Three algorithm are used to solved it:
 1. A least square approach,
 2. An Algebraic Reconstruction Technique (ART) also known as the Kaczmarz's algorithm,
 3. A modified ART algorithm, forcing a positive and real approximation of the solution at the start of each iteration.

You can try whatever you want to improve these reconstruction!
