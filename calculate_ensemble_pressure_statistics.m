function [stat_data] = calculate_ensemble_pressure_statistics()
%Calculates average and standard deviation of pressure from multiple runs
%   For a given list of simulation ID's their pressure data is iteratively read from
%   multiple runs differing only by random seed. Statistical average and
%   standard deviation are then calculated and output.

%LJ dimensionless unit conversion for Argon gas
%sigma = 3.4*10^(-10); %meters
%mass = 6.69*10^(-26); %kilograms
%epsilon = 1.65*10^(-21); %joules
%tau = 2.17*10^(-12); %seconds
%timestep = tau/200; %seconds
%kb = 1.38*10^(-23); %Joules/Kelvin
%x = (0:100:1900)'*sigma*1/(10^(-9)); %nm

nTimeMax = Inf;

nTrials = 5;

%maxParam = 20;
%minParam = 1;
%stepParam = 1;
%paramList = (minParam:stepParam:maxParam);
%nParam = max(size(paramList));

%%%Make this dynamic based on dir output%%%
%simStrings = {'20W_10D'; '20W_2D'; '200W_2D'; '50W_2D'; '20W_5D'; '50W_5D'};
widthStrings = {'20W'; '200W'};  %'50W_2D'; '50W_10D'; '20W_5D'; '50W_5D'};
diameterStrings = {'10D'; '2D'};
registryStrings = {'0H'; '1H'; '5H'; '10H'; '20H'; '50H'; '100H'; '200H'};
simCount = 1;
for i = 1 : 1 : max(size(widthStrings))
    for j = 1 : 1 : max(size(diameterStrings))
        for k = 1 : 1 : max(size(registryStrings))
            simStrings{simCount,1} = strcat(widthStrings{i,1}, '_',diameterStrings{j,1}, '_', registryStrings{k,1});;
            simCount = simCount + 1;
        end
    end
end
nSims = size(simStrings,1);
%baseDir = '/home/Kevin/Documents/Dust_Data/Molecular/.../';
baseDir = '/home/Kevin/Documents/Dust_Data/Molecular/March_2018_DualFilter_Statistical/Registry_Shift';
for i = 1 : 1 : nSims
    simString = simStrings{i,1};
    for n = 1 : 1 : nTrials
        trialString = strcat(simString, '_',num2str(n-1),'T');
        directory = strcat(baseDir,'/',simString,'/',trialString);
        cd(directory);
        rawPData = read_multiple_pressure_slice_data();
        t = rawPData.t; %timesteps
        P = rawPData.P; %LJ Dimensionless
        nPressures = size(P,2);
        if max(size(t)) < nTimeMax
            nTimeMax = max(size(t));
            tF = t;
        end
        data{n,i} = {P};
    end
end
P_trial = zeros(nTimeMax,nTrials,nSims);
for n = 1 : 1 : nTrials
    for i = 1 : 1 : nSims
        for j = 1 : 1 : nPressures
            P_data = data{n,i}{1,1};
            P_trial(:,n,i,j) = data{n,i}{1,1}(1:nTimeMax,j);
        end
    end
end
P_avg(:,:,:) = mean(P_trial,2);
P_std(:,:,:) = std(P_trial,0,2);

cd(baseDir);

%----------Outputs-------------
%OUTPUTS IN SAME VARIABLE STRUCTURE
stat_data = {simStrings; tF; P_avg; P_std};
%------------------------------
end

