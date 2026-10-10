%% Script de Processamento de Falhas de HDD
% Objetivo: Calcular tempos acumulados de falha por fornecedor
% Input: 'hard_drive_failure_data.csv'
% Output: 'resultados_fiabilidade.xlsx' e variáveis no Workspace

clc; clear; close all;

% 1. LER O FICHEIRO
fprintf('A ler o ficheiro CSV\n');
opts = detectImportOptions('hard_drive_failure_data.csv'); %detetar se está a ler texto, números, ou datas
opts.VariableNamingRule = 'preserve'; % Manter nomes originais das colunas
data = readtable('hard_drive_failure_data.csv', opts); %Tabela com os dados do excel

% 2. FILTRAR DADOS
% Manter apenas linhas onde failure == 1
falhas = data(data.failure == 1, :); %cria tabela apenas com as falhas

% Converter a coluna 'date' para formato datetime
% Formato esperado no CSV: 'yyyy-MM-ddTHH:mm:ss.SSSZ' (ISO 8601)
try
    falhas.date = datetime(falhas.date, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss.SSS''Z''');
    %passar data em texto para datetime, assim dá para fazer contas
catch
    % Fallback genérico caso o formato varie
    falhas.date = datetime(falhas.date);
end

% 3. REMOVER DUPLICADOS
% Se o mesmo disco (serial_number) falhar várias vezes, consideramos apenas a 1ª
[~, idx_unique] = unique(falhas.serial_number, 'first');
falhas = falhas(idx_unique, :);

fprintf('Total de falhas únicas identificadas: %d\n', height(falhas));

% 4. DEFINIR TEMPO ZERO (INÍCIO DO ESTUDO)
t0 = datetime(2015, 12, 31);

% Inicializar vetores para armazenar os tempos acumulados
T_Alpha = []; % WDC
T_Beta  = []; % ST
T_Gamma = []; % Hitachi/HGST

% 5. PROCESSAMENTO E AGRUPAMENTO
for i = 1:height(falhas)
    modelo = string(falhas.model{i});
    data_falha = falhas.date(i);
    
    % Calcular dias desde o inicio de 2016 (pode ser fracionário, arredondamos ou mantemos)
    % Usamos 'days' para converter a duração em número.
    tempo_acumulado = days(data_falha - t0);
    
    % Filtrar por Fornecedor
    if contains(modelo, 'WDC', 'IgnoreCase', true)
        % Fornecedor Alpha (Western Digital)
        T_Alpha = [T_Alpha; tempo_acumulado];
        
    elseif startsWith(modelo, 'ST', 'IgnoreCase', true)
        % Fornecedor Beta (Seagate)
        % Usamos 'startsWith' para não confundir com HGST (que contem 'ST')
        T_Beta = [T_Beta; tempo_acumulado];
        
    elseif contains(modelo, 'Hitachi', 'IgnoreCase', true) || contains(modelo, 'HGST', 'IgnoreCase', true)
        % Fornecedor Gamma (Hitachi Global Storage Technologies)
        T_Gamma = [T_Gamma; tempo_acumulado];
    end
end

% 6. ORDENAR CRONOLOGICAMENTE (Essencial para Laplace)
T_Alpha = sort(T_Alpha);
T_Beta  = sort(T_Beta);
T_Gamma = sort(T_Gamma);

% 7. APRESENTAR RESULTADOS
fprintf('\n--- RESULTADOS (Nº de Falhas) ---\n');
fprintf('Alpha (WDC):     %d falhas\n', length(T_Alpha));
fprintf('Beta (ST):       %d falhas\n', length(T_Beta));
fprintf('Gamma (Hitachi): %d falhas\n', length(T_Gamma));

%%
% 8. EXPORTAR PARA EXCEL
% Cria uma tabela com colunas de tamanhos diferentes (preenche com NaN)
max_len = max([length(T_Alpha), length(T_Beta), length(T_Gamma)]);

% Função auxiliar para preencher com NaN até ao tamanho máximo
pad_nan = @(v) [v; nan(max_len - length(v), 1)];

T_Output = table(pad_nan(T_Alpha), pad_nan(T_Beta), pad_nan(T_Gamma), ...
    'VariableNames', {'Tempos_Alpha_WDC', 'Tempos_Beta_ST', 'Tempos_Gamma_Hitachi'});

filename = 'resultados_fiabilidade.xlsx';
writetable(T_Output, filename);
fprintf('\nFicheiro "%s" criado com sucesso!\nPodes copiar as colunas deste Excel para a tua ferramenta de Laplace.\n', filename);