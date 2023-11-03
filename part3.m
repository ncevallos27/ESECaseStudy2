%% Setting up the Part 2
% loading the data
load("COVID_STL.mat");

% creating a vector that is the covid cases per day
cases_STL_prop = cases_STL/POP_STL;

% since people dont come back from the dead, the deaths_STL matches what
% the D represents in the model as D also represents cumulative deaths
deaths_STL_prop = deaths_STL/POP_STL;

startDelta = find(dates>=datetime("2021-06-30", 'InputFormat', "uuuu-MM-dd"));
endDelta = find(dates<=datetime("2021-10-26", 'InputFormat','uuuu-MM-dd'));
datesDelta = dates(startDelta(1):endDelta(end));
daysDelta = days(datesDelta(end) - datesDelta(1)) + 1;

% Initial conditions
initial_I = cases_STL_prop(startDelta(1));
initial_R = 0.01;
initial_D = deaths_STL_prop(startDelta(1));
initial_S = 1 - (initial_D + initial_R + initial_I);

X = [initial_S initial_I initial_R initial_D]';    
X1 = [initial_S initial_I initial_R initial_D]'; 
X2 = [initial_S initial_I initial_R initial_D]';

% These are our paramaters make sure that each group equal to one
% constructing the matrix
S_column = [0.9997375 0.0002625 0 0]';
I_column = [0.00015 0.9996788 0.00015 0.0000212]';
R_column = [0 0 1 0]';
D_column = [0 0 0 1]';
SIRD_matrix = [S_column I_column R_column D_column];

% B matrix is the SIRD model that accounts for travel.
B=[0.95 0.04 0.6 0;
   0.05 0.85 0   0;
   0    0.10 0.4 0;
   0    0.01 0   1];

%% ALERT HERE
rng(20); % change this to make the data make sense REMOVE THE COMMENT WHEN YOU PUBLISH THIS CODE
% Creating the Ut for Susceptible People
    
% Generate a matrix of random numbers between 0 and 1
randomMatrixS = rand(1, daysDelta);

% Scale the random numbers to be between -.1 and .1
randomMatrixS = .2 * randomMatrixS - .1;

    % Creating the Ut for Infected People
% Generate a matrix of random numbers between 0 and 1
randomMatrixI = rand(1, daysDelta);

% Scale the random numbers to be between -0.005 and 0.005 because much fewer
% people would be traveling when infected.
randomMatrixI = 0.01 * randomMatrixI - 0.005;

    % Creating the Ut for Recovered People
% Generate a matrix of random numbers between 0 and 1
randomMatrixR = rand(1, daysDelta);

% Scale the random numbers to be between -0.05 and 0.05.
randomMatrixR = 0.1 * randomMatrixR - 0.05;

% No dead people are traveling
matrixD = zeros([1,daysDelta]);

SIRDTravelMatrix= [randomMatrixS; randomMatrixI; randomMatrixR; matrixD];

withPolicyTravel1= 0.80*SIRDTravelMatrix;
withPolicyTravel2= 0.60*SIRDTravelMatrix;
withPolicyTravel3= 0.40*SIRDTravelMatrix;
withPolicyTravel4= 0.05*SIRDTravelMatrix;

runTime = daysDelta; % in days

% Default CLOSED SYSTEM
for t = 2:runTime
    X(:, t) = SIRD_matrix*X(:, t-1);
end

% OPEN system traveling
for t = 2:runTime
    X1(:, t) = SIRD_matrix*X1(:, t-1) + B*SIRDTravelMatrix(:,t-1);
end

% OPEN system with travel policy
for t = 2:28
    X2(:, t) = SIRD_matrix*X2(:, t-1) + B*withPolicyTravel1(:,t-1);
end

for t=29:56
     X2(:, t) = SIRD_matrix*X2(:, t-1) + B*withPolicyTravel2(:,t-1);
end

for t=57:84
    X2(:, t) = SIRD_matrix*X2(:, t-1) + B*withPolicyTravel3(:,t-1);
end

for t=85:runTime
    X2(:, t) = SIRD_matrix*X2(:, t-1) + B*withPolicyTravel4(:,t-1);
end

figure()
hold on
plot(X(2,:),LineWidth=2);
plot(X1(2,:),LineWidth=2);
plot(X2(2,:),LineWidth=2);
title("Infection Percentage Over Time Delta")
ylabel("Percentantage of People")
xlabel("Number of Days")
lgd = legend("Closed System", "Population with Traveling", "Population with Travel Policy");
lgd.Location = 'best';

%% OMICRON STUFFS
% Seperating the Omicron Varient
startOmicron = find(dates>=datetime("2021-10-27", 'InputFormat', "uuuu-MM-dd"));
endOmicron = find(dates<=datetime("2022-03-22", 'InputFormat','uuuu-MM-dd'));
datesOmicron = dates(startOmicron(1):endOmicron(end));
daysOmicron = days(datesOmicron(end) - datesOmicron(1)) + 1;

% Initial conditions
initial_I = cases_STL_prop(startOmicron(1));
initial_R = 0.01;
initial_D = deaths_STL_prop(startOmicron(1));
initial_S = 1 - (initial_D + initial_R + initial_I);

X = [initial_S initial_I initial_R initial_D]';    
X1 = [initial_S initial_I initial_R initial_D]'; 
X2 = [initial_S initial_I initial_R initial_D]';

% These are our paramaters make sure that each group equal to one
% constructing the matrix
S_column = [0.9997375 0.0002625 0 0]';
I_column = [0.00015 0.9996788 0.00015 0.0000212]';
R_column = [0 0 1 0]';
D_column = [0 0 0 1]';
SIRD_matrix = [S_column I_column R_column D_column];

% B matrix is the SIRD model that accounts for travel.
B=[0.95 0.04 0.6 0;
   0.05 0.85 0   0;
   0    0.10 0.4 0;
   0    0.01 0   1];

%% ALERT HERE
rng(20); % change this to make the data make sense REMOVE THE COMMENT WHEN YOU PUBLISH THIS CODE
% Creating the Ut for Susceptible People
    
% Generate a matrix of random numbers between 0 and 1
randomMatrixS = rand(1, daysOmicron);

% Scale the random numbers to be between -.1 and .1
randomMatrixS = .2 * randomMatrixS - .1;

    % Creating the Ut for Infected People
% Generate a matrix of random numbers between 0 and 1
randomMatrixI = rand(1, daysOmicron);

% Scale the random numbers to be between -0.005 and 0.005 because much fewer
% people would be traveling when infected.
randomMatrixI = 0.01 * randomMatrixI - 0.005;

    % Creating the Ut for Recovered People
% Generate a matrix of random numbers between 0 and 1
randomMatrixR = rand(1, daysOmicron);

% Scale the random numbers to be between -0.05 and 0.05.
randomMatrixR = 0.1 * randomMatrixR - 0.05;

% No dead people are traveling
matrixD = zeros([1,daysOmicron]);

SIRDTravelMatrix= [randomMatrixS; randomMatrixI; randomMatrixR; matrixD];

withPolicyTravel1= 0.80*SIRDTravelMatrix;
withPolicyTravel2= 0.60*SIRDTravelMatrix;
withPolicyTravel3= 0.40*SIRDTravelMatrix;
withPolicyTravel4= 0.05*SIRDTravelMatrix;

runTime = daysOmicron; % in days

% Default CLOSED SYSTEM
for t = 2:runTime
    X(:, t) = SIRD_matrix*X(:, t-1);
end

% OPEN system traveling
for t = 2:runTime
    X1(:, t) = SIRD_matrix*X1(:, t-1) + B*SIRDTravelMatrix(:,t-1);
end

% OPEN system with travel policy
for t = 2:35
    X2(:, t) = SIRD_matrix*X2(:, t-1) + B*withPolicyTravel1(:,t-1);
end

for t=36:70
     X2(:, t) = SIRD_matrix*X2(:, t-1) + B*withPolicyTravel2(:,t-1);
end

for t=71:105
    X2(:, t) = SIRD_matrix*X2(:, t-1) + B*withPolicyTravel3(:,t-1);
end

for t=106:runTime
    X2(:, t) = SIRD_matrix*X2(:, t-1) + B*withPolicyTravel4(:,t-1);
end

figure()
hold on
plot(X(2,:),LineWidth=2);
plot(X1(2,:),LineWidth=2);
plot(X2(2,:),LineWidth=2);
title("Infection Percentage Over Time Omicron")
ylabel("Percentantage of People")
xlabel("Number of Days")
lgd = legend("Closed System", "Population with Traveling", "Population with Travel Policy");
lgd.Location = 'best';
