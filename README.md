# Welcome

![histoCAT Logo ](histoCAT.png)

Histology Topography Cytometry Analysis Toolbox (histoCAT) is a package to visualize and analyse multiplexed image cytometry data interactively.

Cite: <https://www.nature.com/articles/nmeth.4391>

## Getting Started 

histoCAT is automatically installed from the web when running the app installer file corresponding to your operating system which is available at <https://github.com/SchapiroLabor/histoCAT/releases>. 

Windows users must have Visual Studio installed for features like PhenoGraph to function. If it’s not already installed on your computer download it from <https://www.visualstudio.com/downloads/>.

For further informations read the corresponding manual available at <https://github.com/SchapiroLabor/histoCAT/releases>.

## Installation

Detailed installation instructions are available in the installation manual at <https://github.com/SchapiroLabor/histoCAT/releases>.

## User instructions

We are currently working on the [histoCAT wiki](https://github.com/SchapiroLabor/histoCAT/wiki)

For further details please read the corresponding manual available at <https://github.com/BodenmillerGroup/histoCAT/releases>.

## Using histoCAT from source

- Use MATLAB 2024b, if other versions does not work.
- Make sure following are installed
    - uipickfiles
    - Image Processing Toolbox
    - Statistics and Machine Learning Toolbox
    - Parallel Computing Toolbox
    - Matlab Compiler (Only if you want to produce compiled installers)
- In the MATLAB IDE, navigate to the root of this repository, make sure you are in histoCAT/ folder and not in the `histoCAT/histoCAT/` subfolder
- In the MATLAB IDE, run `addpath(genpath(pwd))`, this makes sure all functions defined in the .m files in the subfolders are accessible.
- Run `histoCAT` to start histoCAT from source.
