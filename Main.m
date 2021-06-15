clear all
I = xlsread('InputData.xlsx','Sheet3');
TC = (I(:,4))';
RH = (I(:,6))';
Load = (I(:,3))';
Month = (I(:,7))';
Hour = (I(:,8))';
Day = (I(:,9))';
Year = (I(:,11))';
Dew = (I(:,10))';
WS = (I(:,5))';   % In the current excel file it km/h
Load = fillmissing(Load, 'linear');
Dew = fillmissing(Dew, 'linear');
WS = fillmissing(WS, 'Linear');
WSmph = WS/1.609;
RH = fillmissing(RH, 'linear');
TC = fillmissing(TC, 'linear');
TF = (TC * 9/5) + 32; % Convert oC to oF
WeekdayHour = dummyvar([Day',Hour']);
Weekday = dummyvar(Day);
Hourday = dummyvar(Hour);
Monthyear=dummyvar(Month);
YEAR=zeros(length(Year),4);
for i=2015:1:2020
I = find(Year==i);
YEAR(I,i-2014)=1;
end
Weekend=zeros(length(Day),3);
I = find(Day==1);
Weekend(I,1)=1;
I = find(Day==7);
Weekend(I,2)=1;
I=find(sum(Weekend,2)==0);
Weekend(I,3)=1;
%% Henkel Load
LoadHenkel = [];
Lag = 24; % available lag of history
Lag1 = Lag+1; % available lag of history +1 for 1 step ahead forecast
for i=1:1:Lag1
    LoadHenkel(:,i) = Load(i:end-Lag1+i);
end
%% Henkel Temp
TempHenkel = [];
for i=1:1:Lag1
    TempHenkel(:,i) = TC(i:end-Lag1+i);
end
%% 24 Moving Average Temp
TempMA = zeros(size(TC));
for i=25:1:length(TC)
    TempMA(i) = mean(TC(i-24:i-1));
end
%% Min Max Daily Temp
Max_Temp = [];
Min_Temp = [];
for i=1:24:length(TC)-24+1
    Min_Temp(1,i:i+24-1) = ones(1,24)*min(TC(i+24-1));
    Max_Temp(1,i:i+24-1) = ones(1,24)*max(TC(i+24-1));
end

%% HumidIx
HumidIx = TC+(5/9)*(6.11*exp(5417.7530*((1/273.16)-(1./(273.15+Dew))))-10); % form https://en.wikipedia.org/wiki/Humidex
%% WindChill
WCI = TF;
WCI((TF<50)&(WSmph>3)) = 35.75+0.6125*(TF((TF<50)&(WSmph>3)))-35.75*(WSmph((TF<50)&(WSmph>3))).^0.16+0.4275*(TF((TF<50)&(WSmph>3))).*(WS((TF<50)&(WSmph>3))).^0.16;
%% Wind Chill Month  1,2,3,4,10,11,12
WindChillSeason = zeros(size(Month));
WindChillSeason = ones(size(Month)).*(Month<=4 | Month>=10);

%% corss validation 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PLEASE CHOOSE ONE OF The FOLLOWING MODELS AS Train_Matrix_Input%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

A1 = [ones(length(Day(Lag1:end)),1),(1:length(Day(Lag1:end)))',Weekday(Lag1:end,:),Hourday(Lag1:end,:),Monthyear(Lag1:end,:),TC(Lag1:end)',YEAR(Lag1:end,:)];
A2 = [ones(length(Day(Lag1:end)),1),(1:length(Day(Lag1:end)))',Weekend(Lag1:end,:),Hourday(Lag1:end,:),Monthyear(Lag1:end,:),TC(Lag1:end)',YEAR(Lag1:end,:)];
A3 = [ones(length(Day(Lag1:end)),1),(1:length(Day(Lag1:end)))',Weekday(Lag1:end,:),Weekend(Lag1:end,:),Hourday(Lag1:end,:),Monthyear(Lag1:end,:),TC(Lag1:end)',YEAR(Lag1:end,:)];
A4 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Weekend(Lag1:end,:),Hourday(Lag1:end,:),Monthyear(Lag1:end,:),TC(Lag1:end)',YEAR(Lag1:end,:)];
A5 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Weekend(Lag1:end,:),Hourday(Lag1:end,:),Monthyear(Lag1:end,:),TC(Lag1:end)',TC(Lag1:end)'.^2,TC(Lag1:end)'.^3,YEAR(Lag1:end,:)];
A6 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Weekend(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:)];
A7 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Weekend(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:)];
A8 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Weekend(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:)];
A9 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Weekend(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:)];
A10 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Weekend(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:)];
A11 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Weekend(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:)];
A12 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:)];
A13 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:)];
A14 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:),LoadHenkel(:,end-1)];
A15 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:),TC(24:end-1)'];
A16 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:),LoadHenkel(:,end-3:end-1)];
A17 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),TC(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1:end)'.^2,Monthyear(Lag1:end,:).*TC(Lag1:end)'.^3,Hourday(Lag1:end,:).*TC(Lag1:end)',Hourday(Lag1:end,:).*TC(Lag1:end)'.^2,Hourday(Lag1:end,:).*TC(Lag1:end)'.^3,YEAR(Lag1:end,:),LoadHenkel(:,end-24),LoadHenkel(:,end-1)];
A18 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:)];
A19 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),LoadHenkel(:,end-3:end-1)];
A20 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:),TempMA(Lag1:end)'];
A21 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:),TempMA(Lag1:end)',TC(Lag1-1:end-1)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*TC(Lag1-1:end-1)'.^2,Monthyear(Lag1:end,:).*TC(Lag1-1:end-1)'.^3,Hourday(Lag1:end,:).*TC(Lag1-1:end-1)',Hourday(Lag1:end,:).*TC(Lag1-1:end-1)'.^2,Hourday(Lag1:end,:).*TC(Lag1-1:end-1)'.^3];
A22 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:),TempMA(Lag1:end)',HumidIx(Lag1:end)'];
A23 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:),TempMA(Lag1:end)',WCI(Lag1:end)'];
A24 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:),TempMA(Lag1:end)',WindChillSeason(Lag1:end)'.*WCI(Lag1:end)'];
A25 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:),TempMA(Lag1:end)',WindChillSeason(Lag1:end)'.*WCI(Lag1:end)',not(WindChillSeason(Lag1:end)').*HumidIx(Lag1:end)'];
A26 = [ones(length(Day(Lag1:end)),1),Weekday(Lag1:end,:),Monthyear(Lag1:end,:),Hourday(Lag1:end,:),Max_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)',Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Max_Temp(Lag1:end)'.^3,Min_Temp(Lag1:end)'.*Monthyear(Lag1:end,:),Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Monthyear(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)',Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^2,Hourday(Lag1:end,:).*Min_Temp(Lag1:end)'.^3,YEAR(Lag1:end,:),WeekdayHour(Lag1:end,:),TempMA(Lag1:end)',WindChillSeason(Lag1:end)'.*WCI(Lag1:end)',not(WindChillSeason(Lag1:end)').*HumidIx(Lag1:end)',LoadHenkel(:,end-3:end-1)];

B = (LoadHenkel(:,end)-min(Load))/(max(Load)-min(Load));

%% Testing forecasting.m
load('MinMaxTemp.mat')
for i=1:7*24:length(B)-7*24+1
    for j=1:1:7*24
        if j==1
            Forecast(ceil(i/(7*24)),j) = forecasting(MinMaxTemp,A19(i+j-1,1:end-3),(Load(i+Lag-3:i+Lag-1)))*((max(Load)-min(Load)))+min(Load);
            Actual(ceil(i/(7*24)),j) = Load(i+j-1+24);
        elseif j==2
            Forecast(ceil(i/(7*24)),j) = forecasting(MinMaxTemp,A19(i+j-1,1:end-3),[(Load(i+Lag-2:i+Lag-1)),Forecast(ceil(i/(7*24)),j-1)])*((max(Load)-min(Load)))+min(Load);
            Actual(ceil(i/(7*24)),j) = Load(i+j-1+24);
        elseif j==3
            Forecast(ceil(i/(7*24)),j) = forecasting(MinMaxTemp,A19(i+j-1,1:end-3),[(Load(i+Lag-1)),Forecast(ceil(i/(7*24)),j-2:j-1)])*((max(Load)-min(Load)))+min(Load);
            Actual(ceil(i/(7*24)),j) = Load(i+j-1+24);
        else
            Forecast(ceil(i/(7*24)),j) = forecasting(MinMaxTemp,A19(i+j-1,1:end-3),[Forecast(ceil(i/(7*24)),j-3:j-1)])*((max(Load)-min(Load)))+min(Load);
            Actual(ceil(i/(7*24)),j) = Load(i+j-1+24); 
        end
    end
end







Train_Matrix_Input = A26;
Train_Matrix_Output = B;
nc = 5; % number of cross validation
set1=[];
set2 = [];
for i=1:1:nc
    if i<nc
        Idx= floor(rand(floor(ceil(size(Train_Matrix_Input,1)/nc)),1)*size(Train_Matrix_Input,1)+1);
        set1{i} = [Train_Matrix_Input(Idx,:)];
        set2{i} = [Train_Matrix_Output(Idx)];
        Train_Matrix_Input(Idx,:) = [];
        Train_Matrix_Output(Idx,:) = [];
    else
        set1{i} = Train_Matrix_Input;
        set2{i} = Train_Matrix_Output;
    end
end
for i=1:1:nc
    Idx = 1:1:nc;
    Idx = find(Idx~=i);
    A = [];
    B = [];
    for j=1:1:length(Idx)
        A = [A;set1{Idx(j)}];
        B = [B;set2{Idx(j)}];
    end
    test_in = set1{i};
    test_out = set2{i};
    X = A\B;
    Train_estimate = A*X;
    Train_estimate = Train_estimate*((max(Load)-min(Load)))+min(Load);
    Train_actual = B*((max(Load)-min(Load)))+min(Load);
    Test_estimate = test_in*X;
    Test_estimate = Test_estimate*((max(Load)-min(Load)))+min(Load);
    Test_actual = test_out*((max(Load)-min(Load)))+min(Load);
    Eval(i,:) = [mape(Train_estimate,Train_actual),mape(Test_estimate,Test_actual)];
    
end

