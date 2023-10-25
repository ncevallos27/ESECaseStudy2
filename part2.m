load("COVID_STL.mat");

COVID_STL_proportional = COVID_STL/POP_STL;

% Seperating the Delta Varient
startDelta = find(dates>=datetime("2021-06-30", 'InputFormat', "uuuu-MM-dd"));
endDelta = find(dates<=datetime("2021-10-26", 'InputFormat','uuuu-MM-dd'));
datesDelta = dates(startDelta(1):endDelta(end));




%Seperating the Omicron Varient
startOmicron = find(dates>=datetime("2021-10-27", 'InputFormat', "uuuu-MM-dd"));
endOmicron = find(dates<=datetime("2022-03-22", 'InputFormat','uuuu-MM-dd'));
datesOmicron = dates(startOmicron(1):endOmicron(end));