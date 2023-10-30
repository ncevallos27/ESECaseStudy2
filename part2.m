% loading the data
load("COVID_STL.mat");

% creating a vector that is the covid cases per day
cases_STL_prop = cases_STL/POP_STL;

% since people dont come back from the dead, the deaths_STL matches what
% the D represents in the model as D also represents cumulative deaths
deaths_STL_prop = deaths_STL/POP_STL;

% Seperating the Delta Varient
startDelta = find(dates>=datetime("2021-06-30", 'InputFormat', "uuuu-MM-dd"));
endDelta = find(dates<=datetime("2021-10-26", 'InputFormat','uuuu-MM-dd'));
datesDelta = dates(startDelta(1):endDelta(end));
daysDelta = days(datesDelta(end) - datesDelta(1));

% Initial conditions
initial_I = 0.1;
initial_R = 0.01;
initial_D = deaths_STL_prop(startDelta(1));
initial_S = 1 - (initial_D + initial_R + initial_I);

X = [initial_S initial_I initial_R initial_D]';

% These are our paramaters make sure that each group equal to one
percentNotInfect = 0.9995;
percentInfect = 0.0005;
otherDeathPercent = 0;

percentRecoverNoImmunity = 0.00015;
percentRecoverImmunity = 0.00015;
percentInfectDie = 0.00001;
percentStayInfected = 1-(percentRecoverNoImmunity + percentRecoverImmunity + percentInfectDie);

percentRecoverLoseImmunity = 0.1;
percentRecoverKeepImmunity = 0.9;

runTime = daysDelta; % in days

% constructing the matrix
S_column = [percentNotInfect percentInfect 0 otherDeathPercent]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie]';
R_column = [percentRecoverLoseImmunity 0 percentRecoverKeepImmunity 0]';
D_column = [0 0 0 1]';
SIRD_matrix = [S_column I_column R_column D_column];



for t = 2:runTime + 2
    X(:, t) = SIRD_matrix*X(:, t-1);
end

% fixing the issue of the model not giving cumulative data, we are going to
% get the new cases for the cumulative data and compare it to the new cases
% in the model data
deltaCases = cases_STL_prop(startDelta(1)-1:endDelta(end));
for g = 2:length(deltaCases)
    deltaCases_New(g-1) = deltaCases(g) - deltaCases(g-1);
end

for g = 2:length(X)
    X_new(:, g-1) = X(:, g);
    X_new(2, g-1) = X(2, g) - X(2, g-1);
end

figure
hold on
plot(datesDelta, deltaCases_New);
plot(datesDelta, deaths_STL_prop(startDelta(1):endDelta(end)));
plot(X_new(2, :));
plot(X_new(4, :));
title("Graph for Delta")
ylabel("proportion of population")
xlabel("dates")
legend("new cases", "deaths", "new cases through SIRD model", "deaths through SIRD model")

figure
hold on
plot(X(1, :))
plot(X(2, :));
plot(X(3, :));
plot(X(4, :));
legend("Susceptible", "Infected", "Recovered (Immune)", "Dead")
title("SIRD model")
ylabel("Percentantage of People")
xlabel("Number of Days")

% % Seperating the Omicron Varient
% startOmicron = find(dates>=datetime("2021-10-27", 'InputFormat', "uuuu-MM-dd"));
% endOmicron = find(dates<=datetime("2022-03-22", 'InputFormat','uuuu-MM-dd'));
% datesOmicron = dates(startOmicron(1):endOmicron(end));
% figure
% hold on
% plot(datesOmicron, cases_STL_prop(startOmicron(1):endOmicron(end)));
% plot(datesOmicron, deaths_STL_prop(startOmicron(1):endOmicron(end)));
% title("Graph for Omicron")
% ylabel("proportion of population")
% xlabel("dates")
% legend("cases", "deaths")