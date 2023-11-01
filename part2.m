%% Setting up the Part 2
% loading the data
load("COVID_STL.mat");

% creating a vector that is the covid cases per day
cases_STL_prop = cases_STL/POP_STL;

% since people dont come back from the dead, the deaths_STL matches what
% the D represents in the model as D also represents cumulative deaths
deaths_STL_prop = deaths_STL/POP_STL;

%% Delta Varient
% Seperating the Delta Varient
startDelta = find(dates>=datetime("2021-06-30", 'InputFormat', "uuuu-MM-dd"));
endDelta = find(dates<=datetime("2021-10-26", 'InputFormat','uuuu-MM-dd'));
datesDelta = dates(startDelta(1):endDelta(end));
daysDelta = days(datesDelta(end) - datesDelta(1));

% Initial conditions
initial_I = cases_STL_prop(startDelta(1));
initial_R = 0.01;
initial_D = deaths_STL_prop(startDelta(1));
initial_S = 1 - (initial_D + initial_R + initial_I);

X = [initial_S initial_I initial_R initial_D]';     

% These are our paramaters make sure that each group equal to one
percentInfect = 0.0002625;
otherDeathPercent = 0;
percentNotInfect = 1 - (percentInfect + otherDeathPercent);

percentRecoverNoImmunity = 0.00015;
percentRecoverImmunity = 0.00015;
percentInfectDie = 0.0000212;
percentStayInfected = 1-(percentRecoverNoImmunity + percentRecoverImmunity + percentInfectDie);

percentRecoverLoseImmunity = 0;
percentRecoverKeepImmunity = 1;

runTime = daysDelta; % in days

% constructing the matrix
S_column = [percentNotInfect percentInfect 0 otherDeathPercent]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie]';
R_column = [percentRecoverLoseImmunity 0 percentRecoverKeepImmunity 0]';
D_column = [0 0 0 1]';
SIRD_matrix = [S_column I_column R_column D_column];

% taking out the I_row for future use
I_row = SIRD_matrix(2, :);

% fixing the issue of the model not giving cumulative data, we are going to
% get the new cases for the cumulative data and compare it to the new cases
% in the model data
deltaCases = cases_STL_prop(startDelta(1):endDelta(end));
cumluativeStart = cases_STL_prop(startDelta(1));
new_I = cumluativeStart;
for t = 2:runTime+1
    X(:, t) = SIRD_matrix*X(:, t-1);
    new_I(t) = getNew(I_row, X(:, t-1)) + new_I(t-1);
end

figure
hold on
plot(datesDelta, deltaCases);
plot(datesDelta(1):datesDelta(end), new_I);
title("Graph for Delta")
ylabel("proportion of population")
xlabel("dates")
lgd = legend("new cases", "cumulative cases through SIRD model");
lgd.Location = 'best';

figure
hold on
plot(datesDelta, deaths_STL_prop(startDelta(1):endDelta(end)));
plot(datesDelta(1):datesDelta(end), X(4, 1:end));
title("Graph for Delta")
ylabel("proportion of population")
xlabel("dates")
lgd = legend("deaths", "deaths through SIRD model");
lgd.Location = 'best';

figure
hold on
plot(X(1, :))
plot(X(2, :));
plot(X(3, :));
plot(X(4, :));
lgd = legend("Susceptible", "Infected", "Recovered (Immune)", "Dead");
lgd.Location = 'best';
title("SIRD model")
ylabel("Percentantage of People")
xlabel("Number of Days")

%% Omicron Varient
% Seperating the Omicron Varient
startOmicron = find(dates>=datetime("2021-10-27", 'InputFormat', "uuuu-MM-dd"));
endOmicron = find(dates<=datetime("2022-03-22", 'InputFormat','uuuu-MM-dd'));
datesOmicron = dates(startOmicron(1):endOmicron(end));
daysOmicron = days(datesOmicron(end) - datesOmicron(1));

% Initial conditions
initial_I = cases_STL_prop(startOmicron(1));
initial_R = 0.01;
initial_D = deaths_STL_prop(startOmicron(1));
initial_S = 1 - (initial_D + initial_R + initial_I);

X = [initial_S initial_I initial_R initial_D]';

% These are our paramaters make sure that each group equal to one
percentInfect = 0.000764;
otherDeathPercent = 0;
percentNotInfect = 1 - (percentInfect + otherDeathPercent);

percentRecoverNoImmunity = 0.00015;
percentRecoverImmunity = 0.00015;
percentInfectDie = 0.0000277;
percentStayInfected = 1-(percentRecoverNoImmunity + percentRecoverImmunity + percentInfectDie);

percentRecoverLoseImmunity = 0;
percentRecoverKeepImmunity = 1;


runTime = daysOmicron; % in days

% constructing the matrix
S_column = [percentNotInfect percentInfect 0 otherDeathPercent]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie]';
R_column = [percentRecoverLoseImmunity 0 percentRecoverKeepImmunity 0]';
D_column = [0 0 0 1]';
SIRD_matrix = [S_column I_column R_column D_column];


% taking out the I_row for future use
I_row = SIRD_matrix(2, :);

% fixing the issue of the model not giving cumulative data, we are going to
% get the new cases for the cumulative data and compare it to the new cases
% in the model data
omicronCases = cases_STL_prop(startOmicron(1):endOmicron(end));
cumluativeStart = cases_STL_prop(startOmicron(1));
new_I = cumluativeStart;
for t = 2:runTime+1
    X(:, t) = SIRD_matrix*X(:, t-1);
    new_I(t) = getNew(I_row, X(:, t-1)) + new_I(t-1);
end

figure
hold on
plot(datesOmicron, omicronCases);
plot(datesOmicron(1):datesOmicron(end), new_I);
title("Graph for Omicron")
ylabel("proportion of population")
xlabel("dates")
lgd = legend("new cases", "cumulative cases through SIRD model");
lgd.Location = 'best';

figure
hold on
plot(datesOmicron, deaths_STL_prop(startOmicron(1):endOmicron(end)));
plot(datesOmicron(1):datesOmicron(end), X(4, :));
title("Graph for Omicron")
ylabel("proportion of population")
xlabel("dates")
lgd = legend("deaths", "deaths through SIRD model");
lgd.Location = 'best';

figure
hold on
plot(X(1, :))
plot(X(2, :));
plot(X(3, :));
plot(X(4, :));
lgd = legend("Susceptible", "Infected", "Recovered (Immune)", "Dead");
lgd.Location = 'best';
title("SIRD model")
ylabel("Percentantage of People")
xlabel("Number of Days")

% Saving some variables to memory for future use and comparison
X_omicron = X;
I_omicron = new_I;

%% What-If Section of Part 2
% The policy that we will try to model will be vacination. This policy will
% affect the infection rate, and will affect the death rate, it will affect
% the suscepitable to recovery rate as well
% Seperating the Omicron Varient
startOmicron = find(dates>=datetime("2021-10-27", 'InputFormat', "uuuu-MM-dd"));
endOmicron = find(dates<=datetime("2022-03-22", 'InputFormat','uuuu-MM-dd'));
datesOmicron = dates(startOmicron(1):endOmicron(end));
daysOmicron = days(datesOmicron(end) - datesOmicron(1));

% Initial conditions
initial_I = cases_STL_prop(startOmicron(1));
initial_R = 0.01;
initial_D = deaths_STL_prop(startOmicron(1));
initial_S = 1 - (initial_D + initial_R + initial_I);

X = [initial_S initial_I initial_R initial_D]';

vaccineEfficacy = 0.9; % this is a measure of how effective the vaccine is at doing its job

% These are our paramaters make sure that each group equal to one
percentInfect = 0.000764 - (vaccineEfficacy * 0.0004); % second argument is adjusting rate that happens because of the vaccine
otherDeathPercent = 0;
percentVaccineRecover = vaccineEfficacy * 0.0004; % second is the rate of vaccination
percentNotInfect = 1 - (percentInfect + otherDeathPercent + percentVaccineRecover);

percentRecoverNoImmunity = 0.00015;
percentRecoverImmunity = 0.00015;
percentInfectDie = 0.0000277 - (vaccineEfficacy * 0.00001); % second argument is the adjusting rate that happens because of the vaccine on deaths
percentStayInfected = 1-(percentRecoverNoImmunity + percentRecoverImmunity + percentInfectDie);

percentRecoverLoseImmunity = 0;
percentRecoverKeepImmunity = 1;

runTime = daysOmicron; % in days

% constructing the matrix
S_column = [percentNotInfect percentInfect percentVaccineRecover otherDeathPercent]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie]';
R_column = [percentRecoverLoseImmunity 0 percentRecoverKeepImmunity 0]';
D_column = [0 0 0 1]';
SIRD_matrix = [S_column I_column R_column D_column];


% taking out the I_row for future use
I_row = SIRD_matrix(2, :);

% fixing the issue of the model not giving cumulative data, we are going to
% get the new cases for the cumulative data and compare it to the new cases
% in the model data
omicronCases = cases_STL_prop(startOmicron(1):endOmicron(end));
omicronDeaths = deaths_STL_prop(startOmicron(1):endOmicron(end));
cumluativeStart = cases_STL_prop(startOmicron(1));
new_I = cumluativeStart;
for t = 2:runTime+1
    X(:, t) = SIRD_matrix*X(:, t-1);
    new_I(t) = getNew(I_row, X(:, t-1)) + new_I(t-1);
end

changeCases = omicronCases(end) - omicronCases(1);
changeDeaths = omicronDeaths(end) - omicronDeaths(1);

figure
hold on
plot(datesOmicron, omicronCases);
plot(datesOmicron(1):datesOmicron(end), I_omicron);
plot(datesOmicron(1):datesOmicron(end), new_I);
plot(datesOmicron(1):datesOmicron(end), (0.75*changeCases*ones(t))+ omicronCases(1), '--');
title("Graph for Omicron")
ylabel("proportion of population")
xlabel("dates")
lgd = legend("new cases", "cumulative cases through old SIRD model", "cumulative cases through new SIRD model", "threshold");
lgd.Location = 'best';

figure
hold on
plot(datesOmicron, deaths_STL_prop(startOmicron(1):endOmicron(end)));
plot(datesOmicron(1):datesOmicron(end), X_omicron(4, :));
plot(datesOmicron(1):datesOmicron(end), X(4, :));
plot(datesOmicron(1):datesOmicron(end), (0.75*changeDeaths*ones(t)) + omicronDeaths(1), '--');
title("Graph for Omicron")
ylabel("proportion of population")
xlabel("dates")
lgd = legend("deaths", "deaths through old SIRD model", "deaths through new SIRD model", 'threshold');
lgd.Location = 'best';

figure
hold on
plot(X(1, :));
plot(X(2, :));
plot(X(3, :));
plot(X(4, :));
lgd = legend("Susceptible", "Infected", "Recovered (Immune)", "Dead");
lgd.Location = 'best';
title("SIRD model")
ylabel("Percentantage of People")
xlabel("Number of Days")

%% Functions that are used in this part
function f = getNew(row, column)
    f = row(1) * column(1);
end