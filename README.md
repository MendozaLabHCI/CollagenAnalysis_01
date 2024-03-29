This analysis code was run using MATLAB R2022b with the following toolboxes: Statistics and Machine Learning, Signal Processing, Image Processing, and Curve Fitting. 

The following functions from MATLAB Central File Exchange were also used: fit_ellipse (1), and CoherenceFilter (2).

Main file to run: Collagen_PoreSize_Thickness_and_Anisotropy_Analysis01.m

Anisotropy calculation (FourierBased2DFiberAnisotropy.m) is based on a method developed by J. Pablo Marquez (3).

The script ListOfDataFilesToAnalyze03.m lists all the 3D confocal image stack file names, locations, cubic voxel size, starting z-slice (sZ), ending z-slice (eZ). Substitute your own data file under idx = 1 to test the code.

References:
  1.  Ohad Gal (2024). fit_ellipse (https://www.mathworks.com/matlabcentral/fileexchange/3215-fit_ellipse), MATLAB Central File Exchange. Retrieved January 11, 2024.
  2.	Dirk-Jan Kroon (2019). Image Edge Enhancing Coherence Filter Toolbox (https://www.mathworks.com/matlabcentral/fileexchange/25449-image-edge-enhancing-coherence-filter-toolbox), MATLAB Central File Exchange. Retrieved 2019.
  3. 	J. Pablo Marquez, Fourier analysis and automated measurement of cell and fiber angular orientation distributions. International Journal of Solids and Structures, volume 43, issue 21, 2006, pages 6413-6423.
