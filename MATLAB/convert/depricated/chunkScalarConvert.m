function [t,x,y,meshData] = chunkScalarConvert(chunkData, nBinsX, nBinsY)
% [t,x,y,meshData] = chunkScalarConvert(chunkData, nBinsX, nBinsY) Converts
% LAMMPS 'chunk' data format to MATLAB 'mesh' data format for a scalar value
% grid.
%   Takes as input the LAMMPS output data in 'chunk' format followed by the
%   number of horizontal and vertical grid values. Chunk data is then parsed
%   based on the number of x and y bins into a MATLAB mesh data structure.
%   Returns time series vector, horizontal and vertical spatial value matrix
%   and scalar simulation value mesh data structure.

%TODO: Overload so that scalar and vector aren't seperate
%functions

nSteps = size(chunkData,1); %Standard domain full time series chunk output

debug = 0;
if debug == 1 %Hardcode number of bins and time values for debugging
    nBinsX = 102;
    nBinsY = 100;
    nSteps = 300;
end


%Calculate total number of mesh cells then create spatial, time and mesh data
%series.
nBins = nBinsX*nBinsY;
t = zeros(nSteps,1);
x = zeros(nBinsX,nBinsY);
y = zeros(nBinsX,nBinsY);
meshData = zeros(nBinsX,nBinsY,nSteps);

%Chunk data is a series of lists containing simulation values, lists are
%ordered sequentially by timestep. List is ordered as
%(x1,y1),(x1,y2),(x1,y3)...(x2,y1),(x2,y2),(x2,y3)... such that 
%y is the most rapidly varying bin coordinate/index
for n=1:1:nSteps
    t(n)=(n-1)*1000/200; %Convert timestep to LJ time
    for k=1:1:nBins
        if debug == 1
            fprintf(num2str(k));
            fprintf('\n');
        end
        i=floor(k/nBinsY)+1; %x value is determined by number of fully read y index ranges
        j=mod(k,nBinsY); %y value is modulus of bin index to number of x bins
        if j == 0 %zero modulus means last element of previous x bin index
            i = i-1;
            j = nBinsY;
        end
        meshData(i,j,n)=chunkData(n,k,1); %scalar mesh data could be count, temp, internalTemp
        if n == 1
            x(i,j)=20*(i-1);
            y(i,j)=20*(j-1);
            %Depricated: Shift spatial data to simulation domain coordinates
            %x(i,j)=20*(i-1)+800;
            %y(i,j)=20*(j-1)+700;
        end
    end
end
%Optional save during run to supplement function return
% save(strcat(outputName, '.mat'), 't', 'x', 'y', 'count');
clear chunkData i j k n;
end
