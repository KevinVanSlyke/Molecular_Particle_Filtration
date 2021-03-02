function [t,x,y,outVal] = chunkConvert(chunkData, nBinsX, nBinsY)
% [t,x,y,meshData] = chunkVectorConvert(vcmChunkData, nBinsX, nBinsY) Converts
% LAMMPS 'chunk' data format to MATLAB 'mesh' data format for a vector value
% grid.
%   Takes as input the LAMMPS output data in 'chunk' format followed by the
%   number of horizontal and vertical grid values. Chunk data is then parsed
%   based on the number of x and y bins into a pair of MATLAB mesh data structures.
%   Returns time series vector, horizontal and vertical spatial value matrix
%   and one or two scalar component value mesh data structures for 2D.


nSteps = size(chunkData,1); %Standard domain full time series chunk output
nVars = size(chunkData,2);
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
val = zeros(nBinsX,nBinsY,nSteps);

if nVars == 2
    val2 = zeros(nBinsX,nBinsY,nSteps);
end

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
        
        val(i,j,n)=chunkData(n,k,1); %x vel component
        if nVars == 2
            val2(i,j,n)=chunkData(n,k,2); %y vel component
        end
        if n == 1
            x(i,j)=20*(i-1); %convert indices to spatial value
            y(i,j)=20*(j-1);
            %Depricated: Shift spatial data to simulation domain coordinates, 
            %x(i,j)=20*(i-1)+800;
            %y(i,j)=20*(j-1)+700;
        end
    end
end
%Optional save during run to supplement function return
% save(strcat(outputName, '.mat'), 't', 'x', 'y', 'u', 'v');
if nVars == 1
    outVal = val;
    clear val i j k n;
elseif nVars == 2
    outVal = [val, val2];
    clear val val2 i j k n;
end

end

