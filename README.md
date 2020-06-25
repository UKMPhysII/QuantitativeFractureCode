# Quantitative Fracture Code
### For quantifying the fracture area of Z-disk lines in electron microscope images of sarcomeres.

## Getting started
To get started with this, you need MATLAB with the Image Processing Toolbox installed. If you have this, then simply download the repository and run the fractureArea.m script. The script supports a single-image mode, and a batch-mode for processing multiple files.

## Running
For detailed instructions on the program and what it does, please see [INSERT LINK TO SUPP DATA HERE](https://link.to.suppdata).

Running the script will lead to a prompt for you to choose a file, or several files. Output/s will be placed in an appropriately named folder in the same path as the file/s chosen.

The user will be prompted to click on both sides of a Z-disk line, to set the rotation as vertical as possible.

The user will be asked to modify a preliminary mask, to remove extraneous details that aren't relevant to the Z-disks. This step can be skipped by pressing any key.

The user will be prompted to click on two adjacent Z-disk lines, to estimate the sarcomere length. This value is used for calculation of bounding areas, and will not influence the length outputs.

The program will then complete running.

## Built with
MATLAB

## Authors
* **Dr. David Ing** - *Initial work* - [DrDJIng](https://github.com/DrDJIng)
