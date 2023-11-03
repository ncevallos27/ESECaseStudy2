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
% Model 1, Pre vaccine
% Initial conditions
initial_S = 1;
initial_I = 0;
initial_R = 0;
initial_D = 0;
initial_V = 0;
initial_BI = 0;
initial_RV = 0;

X = [initial_S initial_I initial_R initial_D initial_V initial_BI initial_RV]';     

% These are our paramaters make sure that each group equal to one
percentInfect = 0.0065;
percentOtherDie = 0;
percentNotInfect = 1 - (percentInfect + percentOtherDie);

percentRecoverNoImmunity = percentInfect- 0.005;
percentRecoverImmunity = 0.003;
percentInfectDie = 0.002;
percentStayInfected = 1-(percentRecoverNoImmunity + percentRecoverImmunity + percentInfectDie);


% We know when the vaccine must have been implemented is before day 100 as
% that is when breakout infections start to happen at a constant rate. We
% also know that vaccines take about 3-4 weeks to be effective. We also 
% know that vaccines are best not at preveneting infections but preveting 
% serious cases of covid and deaths from covid. This means that it will 
% be 3-4 weeks before when the deaths lines starts to flat line. This is
% around day 120. This means that vaccines were rolled out before the 100
% day mark and before 3-4 weeks from day 130. Assuming in this scenario,
% vaccines take 4 weeks to be effective we know that that vaccines were
% rolled out 28 days before 120. This means that vaccines were rolled out
% on day 92. 

% we can also think about how vaccines reduce the effects of the pandemic.
% Vaccines mostly effect deaths and stop deaths, that means vaccines roll
% out when deaths go down so that means that is around day 125.
firstrunTime = 130; % in days

% constructing the matrix
S_column = [percentNotInfect percentInfect 0 percentOtherDie 0 0 0]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie 0 0 0]';
R_column = [0 0 1 0 0 0 0]';
D_column = [0 0 0 1 0 0 0]';
V_column = [0 0 0 0 0 0 0]'; % this changes per day so for when we are trying to find percent vaccinated per day take the cummulative sum of this
BI_column = [0 0 0 0 0 0 0]'; % this is what we want to display, to tune this since it is only getting added by the vaccinated, make this look like a smaller version of the infected graph
RV_column = [0 0 0 0 0 0 0]';
SIRD_matrix = [S_column I_column R_column D_column V_column BI_column RV_column];

% taking out the I_row for future use
I_row = SIRD_matrix(2, :);

% fixing the issue of the model not giving cumulative data, we are going to
% get the new cases for the cumulative data and compare it to the new cases
% in the model data
new_I = [0];
for t = 2:firstrunTime
    X(:, t) = SIRD_matrix*X(:, t-1);
    new_I(t) = getNew(I_row, X(:, t-1));
end

%% Model 2
% Model 2
% okay lets get to work with the real problem
% Initial conditions
vaccineEfficacy = 0.90;

% These are our paramaters make sure that each group equal to one
% we are making it so that breakout infections are only defined as those
% infections that vaccinated people get, cuz thats the definintion of the
% term.
percentInfect = 0.045;
percentVaccination = 0.00375;
percentNotInfect = 1 - (percentInfect + percentVaccination);

percentRecoverNoImmunity = 0.25;
percentRecoverImmunity = 0.2;
percentInfectDie = 0.00245;
percentStayInfected = 1-(percentRecoverNoImmunity + percentRecoverImmunity + percentInfectDie);

percentRecoverKeepImmunity = 1 - (percentVaccination);

percentBreakthroughInfection = (percentInfect - 0.01)*(vaccineEfficacy - 0.2);
percentStayVaccinated = 1-percentBreakthroughInfection;

percentDieBI = percentInfectDie*(1-vaccineEfficacy);
percentRecoverVaccineNoImmunity = (percentRecoverNoImmunity - 0.2)*(vaccineEfficacy);
percentRecoverVaccineImmunity = (percentRecoverImmunity)*(1+vaccineEfficacy);
percentStayBI = 1 - (percentDieBI + percentRecoverVaccineNoImmunity + percentRecoverVaccineImmunity);

percentStayRecoverVaccinated = 1;

% vaccinations make the case less severe

secondrunTime = 400; % in days

% constructing the matrix
S_column = [percentNotInfect percentInfect 0 0 percentVaccination 0 0]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie 0 0 0]';
R_column = [0 0 percentRecoverKeepImmunity 0 0 0 percentVaccination]';
D_column = [0 0 0 1 0 0 0]';
V_column = [0 0 0 0 percentStayVaccinated percentBreakthroughInfection 0]'; % this changes per day so for when we are trying to find percent vaccinated per day take the cummulative sum of this
BI_column = [0 0 0 percentDieBI percentRecoverVaccineNoImmunity percentStayBI percentRecoverVaccineImmunity]'; % this is what we want to display, to tune this since it is only getting added by the vaccinated, make this look like a smaller version of the infected graph
RV_column = [0 0 0 0 0 0 percentStayRecoverVaccinated]';
SIRD_matrix = [S_column I_column R_column D_column V_column BI_column RV_column];

% taking out the I_row and BI_row for future use
I_row = SIRD_matrix(2, :);
BI_row = SIRD_matrix(6, :);

% fixing the issue of the model not giving cumulative data, we are going to
% get the new cases for the cumulative data and compare it to the new cases
% in the model data
for t = firstrunTime:secondrunTime+1
    X(:, t) = SIRD_matrix*X(:, t-1);
    new_I(t) = getNew(I_row, X(:, t-1)) + (BI_row(5) * X(5, t-1)); % adding the vaccination to breakthrough infection pipeline
end


%% these are the graphs for the part 4
figure
hold on
plot(X(1, :));
plot(X(2, :));
plot(X(3, :));
plot(X(4, :));
plot(X(5, :));
plot(X(6, :));
plot(X(7, :));
plot(X(5, :) + X(6, :) + X(7, :));
lgd = legend("Susceptible", "Infected", "Recovered (Immune)", "Dead", "Vaccinated", "Breakthrough Infection", "Vaccinated and Recovered", 'Vaccinated PURE');
lgd.Location = 'best';
title("SIRD model")
ylabel("Percentantage of People")
xlabel("Number of Days")

figure
hold on
plot(newInfections)
plot(new_I)
ylabel("percent of population")
xlabel("days")
title("Mock COVID Data")
lgd = legend("new infections per day", "new Infections from model per day");
lgd.Location = 'best';

figure
hold on
plot(cumulativeDeaths)
plot(X(4, :))
ylabel("percent of population")
xlabel("days")
title("Mock COVID Data")
lgd = legend("Cumulative Deaths", "deaths from model");
lgd.Location = 'best';

figure
plot(X(5, :) + X(6, :) + X(7, :));
ylabel("percent of population")
xlabel("days")
title("Total People Vaccinated")

figure
plot(X(6, :));
ylabel("percent of population")
xlabel("days")
title("People expirencing Break Through infections")

%% Functions that are used in this part
function f = getNew(row, column)
    f = row(1) * column(1);
end