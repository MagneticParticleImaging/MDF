This folder contains exemplary Matlab codes for a simple MPI reconstruction.

The data provided [here] (http://www.tuhh.de/ibi/research/mpi-data-format.html) have to be placed in the root folder, as shown in the picture below.
![Image of the folder structure](https://gBringout.github.com/MDF/matlab/results/files.jpg)

The Matlab working directory should be
    <your harddrive>\MDF\matlab\
	
Running the script
    reco.m
you should obtain after roughly one minutes those three graphs:
![Images of the SM strucures](https://gBringout.github.com/MDF/matlab/results/SM.jpg)

![Plot of a measure](https://gBringout.github.com/MDF/matlab/results/SpectrumMeasure.jpg)

![4 reconstructions](https://gBringout.github.com/MDF/matlab/results/Reco.jpg)

The last one present the results of reconstruction of the concentration map a tracer using the system matrix/calibration approach. Using the same measurements, the inconsistent system of linear equations is solved using the signal acquired by a single channel of the scanner.

Four algorithms are used to solved it:
1. A least square approach,
2. An Algebraic Reconstruction Technique (ART) also known as the Kaczmarz's algorithm,
3. A modified ART algorithm, forcing a positive and real approximation of the solution at the start of each iteration,
3. A modified ART algorithm, regularizing and forcing a positive and real approximation of the solution.

You can try whatever you want to improve these reconstruction!