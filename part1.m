% code for no re-infections
% this is the start of our simulation where all of the population is suceptible
X = [0.9 0.1 0 0]';

% These are our paramaters make sure that each group equal to one
percentNotInfect = 0.95;
percentInfect = 0.05;
otherDeathPercent = 0;

percentRecoverNoImmunity = 0;
percentStayInfected = 0.85;
percentRecoverImmunity = 0.14;
percentInfectDie = 0.01;

percentRecoverLoseImmunity = 0;
percentRecoverKeepImmunity = 1;

runTime = 200; % in days

% constructing the matrix
S_column = [percentNotInfect percentInfect 0 otherDeathPercent]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie]';
R_column = [percentRecoverLoseImmunity 0 percentRecoverKeepImmunity 0]';
D_column = [0 0 0 1]';
SIRD_matrix = [S_column I_column R_column D_column];

for t = 2:runTime
    X(:, t) = SIRD_matrix*X(:, t-1);
end

figure
hold on
plot(X(1, :))
plot(X(2, :));
plot(X(3, :));
plot(X(4, :));
legend("Susceptible", "Infected", "Recovered (Immune)", "Dead")
title("SIRD model no re-infections possible")
ylabel("Percentantage of People")
xlabel("Number of Days")


% code for re-infections, this will be a similar graph to the text book as
% well
percentRecoverNoImmunity = 0.04;
percentStayInfected = 0.85;
percentRecoverImmunity = 0.1;
percentInfectDie = 0.01;

S_column = [percentNotInfect percentInfect 0 otherDeathPercent]';
I_column = [percentRecoverNoImmunity percentStayInfected percentRecoverImmunity percentInfectDie]';
R_column = [percentRecoverLoseImmunity 0 percentRecoverKeepImmunity 0]';
D_column = [0 0 0 1]';
SIRD_matrix = [S_column I_column R_column D_column];

for t = 2:runTime
    X(:, t) = SIRD_matrix*X(:, t-1);
end

figure
hold on
plot(X(1, :))
plot(X(2, :));
plot(X(3, :));
plot(X(4, :));
legend("Susceptible", "Infected", "Recovered (Immune)", "Dead")
title("SIRD model re-infections possible")
ylabel("Percentantage of People")
xlabel("Number of Days")

% running the included lsim function and comparing with reinfections
% possible to compare to homemade function
figure
base_sir