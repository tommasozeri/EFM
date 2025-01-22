% Definisci il percorso del file
filename = 'C:\Users\Tomma\MATLAB Drive\EFM EXAM 2025\DBEXAM.xlsx';

% Fogli di lavoro
sheets = {'nasdaq monthly', 'nyse monthly', 'nasdaq daily', 'nyse daily'};

for s = 1:length(sheets)
    sheet = sheets{s};
    
    % Carica il file Excel
    opts = detectImportOptions(filename, 'Sheet', sheet);
    opts.VariableNamingRule = 'preserve';
    data = readtable(filename, opts);
    
    % Estrai i ticker
    tickers = data.Properties.VariableNames(2:end);
    
    % Calcola i rendimenti logaritmici
    returns = diff(log(data{:, 2:end}));
    
    % Calcola la matrice di varianza-covarianza
    cov_matrix = cov(returns);
    
    % Calcola la matrice di correlazione
    corr_matrix = corrcoef(returns);
    
    % Visualizza le matrici
    disp(['Matrice di varianza-covarianza per ', sheet]);
    disp(cov_matrix);
    
    disp(['Matrice di correlazione per ', sheet]);
    disp(corr_matrix);
    
    % Crea le heatmap
    figure;
    heatmap(tickers, tickers, cov_matrix, 'Colormap', parula, 'ColorbarVisible', 'on');
    title(['Matrice di varianza-covarianza per ', sheet]);
    ax = gca;
    ax.FontSize = ax.FontSize * 0.5; % regola la dimensione del font
    
    figure;
    heatmap(tickers, tickers, corr_matrix, 'Colormap', parula, 'ColorbarVisible', 'on');
    title(['Matrice di correlazione per ', sheet]);
    ax = gca;
    ax.FontSize = ax.FontSize * 0.5; % regola la dimensione del font
end

