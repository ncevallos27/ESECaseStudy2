load("mockdata2023.mat")

% lets start off by making a quick and easy graph
figure
hold on
plot(cumulativeDeaths)
plot(newInfections)
ylabel("percent of population")
xlabel("days")
title("Mock COVID Data")
legend("Cumulative Deaths", "new Infections")

% okay lets get to work with the real problem
% Initial conditions
initial_I = 0;
initial_R = 0;
initial_D = 0;
initial_V = 0;
initial_S = 1 - (initial_D + initial_R + initial_I + initial_V);

X = [initial_S initial_I initial_R initial_D initial_V]';     

% These are our paramaters make sure that each group equal to one
percentInfect = 0.0002625;
otherDeathPercent = 0;
percentVaccination = 0;
percentNotInfect = 1 - (percentInfect + otherDeathPercent + percentVaccination);

percentRecoverNoImmunity = 0.00015;
percentRecoverImmunity = 0.00015;
percentInfectDie = 0.0000212;
percentInfectedtoVaccination = 0;
percentStayInfected = 1-(percentRecoverNoImmunity + percentRecoverImmunity + percentInfectDie + percentInfectedtoVaccination);

percentRecoverLoseImmunity = 0;
percentRecoverKeepImmunity = 1;

percentBreakthroughInfection = 0;
percentStayVaccinated = 1-percentBreakthroughInfection;

runTime = 400; % in days

% constructing the matrix
S_column = [percentNotInfect percentInfect 0 otherDeathPercent percentVaccination]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie percentInfectedtoVaccination]';
R_column = [percentRecoverLoseImmunity 0 percentRecoverKeepImmunity 0 0]';
D_column = [0 0 0 1 0]';
V_volumn = [0 percentBreakthroughInfection 0 0 percentStayVaccinated]';
SIRD_matrix = [S_column I_column R_column D_column V_volumn];

% taking out the I_row for future use
I_row = SIRD_matrix(2, :);

% fixing the issue of the model not giving cumulative data, we are going to
% get the new cases for the cumulative data and compare it to the new cases
% in the model data
new_I = 0;
for t = 2:runTime+1
    X(:, t) = SIRD_matrix*X(:, t-1);
    new_I(t) = getNew(I_row, X(:, t-1)) + new_I(t-1);
end

figure
hold on
plot(X(1, :));
plot(X(2, :));
plot(X(3, :));
plot(X(4, :));
plot(X(5, :));
lgd = legend("Susceptible", "Infected", "Recovered (Immune)", "Dead", "Vaccinated");
lgd.Location = 'best';
title("SIRD model")
ylabel("Percentantage of People")
xlabel("Number of Days")

figure
hold on
plot(cumulativeDeaths)
plot(newInfections)
plot()
ylabel("percent of population")
xlabel("days")
title("Mock COVID Data")
legend("Cumulative Deaths", "new Infections")

%% Functions that are used in this part
function f = getNew(row, column)
    f = row(1) * column(1);
end