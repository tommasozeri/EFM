% Carica i dati dal worksheet NYSEselectedD
dataD = readtable('C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx', 'Sheet', 'NYSEselectedD', 'VariableNamingRule', 'preserve');

% Normalizza i prezzi per NYSEselectedD
normalized_dataD = dataD;
for i = 2:width(dataD)
    normalized_dataD{:, i} = dataD{:, i} / dataD{1, i};
end

% Plot dei prezzi normalizzati per NYSEselectedD
figure;
hold on;
for i = 2:width(normalized_dataD)
    plot(normalized_dataD.DATE, normalized_dataD{:, i}, 'DisplayName', normalized_dataD.Properties.VariableNames{i});
end
hold off;
xlabel('Date');
ylabel('Normalized Price');
title('Normalized Stock Prices - NYSEselectedD');
legend;

% Carica i dati dal worksheet NYSEselectedM
dataM = readtable('C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx', 'Sheet', 'NYSEselectedM', 'VariableNamingRule', 'preserve');

% Normalizza i prezzi per NYSEselectedM
normalized_dataM = dataM;
for i = 2:width(dataM)
    normalized_dataM{:, i} = dataM{:, i} / dataM{1, i};
end

% Plot dei prezzi normalizzati per NYSEselectedM
figure;
hold on;
for i = 2:width(normalized_dataM)
    plot(normalized_dataM.DATE, normalized_dataM{:, i}, 'DisplayName', normalized_dataM.Properties.VariableNames{i});
end
hold off;
xlabel('Date');
ylabel('Normalized Price');
title('Normalized Stock Prices - NYSEselectedM');
legend;

