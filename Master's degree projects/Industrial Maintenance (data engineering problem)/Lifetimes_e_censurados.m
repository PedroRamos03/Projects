%% Script Preparação Weibull (Falhas + Censuras)
% Objetivo: Extrair lifetime final de cada disco e classificar como Falha ou Censura
% Input: 'hard_drive_failure_data.csv'
% Output: 'dados_weibull.xlsx'

clc; clear; close all;

% 1. LER DADOS
fprintf('A ler dados \n');
opts = detectImportOptions('hard_drive_failure_data.csv');
opts.VariableNamingRule = 'preserve';
raw_data = readtable('hard_drive_failure_data.csv', opts);

% 2. IDENTIFICAR DISCOS ÚNICOS
% Agrupar por Serial Number para saber o destino final de cada disco
[G, serials] = findgroups(raw_data.serial_number);

% Para cada disco, calculamos:
% - MaxFailure: Se for 1, o disco falhou. Se for 0, sobreviveu (Censurado).
% - MaxLifetime: A idade máxima que o disco atingiu no estudo.
max_fail = splitapply(@max, raw_data.failure, G);
max_life = splitapply(@max, raw_data.lifetime, G);

% Recuperar o modelo correspondente a cada serial (usamos o primeiro registo encontrado)
% (Logica auxiliar para mapear serial -> model)
[~, idx_first] = unique(raw_data.serial_number);
model_map = raw_data.model(idx_first);
% Reordenar model_map para alinhar com a ordem dos 'serials' do findgroups
% Nota: O findgroups ordena alfabeticamente, o unique 'first' não necessariamente.
% Vamos fazer um join seguro.
Table_Summary = table(serials, max_fail, max_life);
Table_Models = table(raw_data.serial_number(idx_first), raw_data.model(idx_first), 'VariableNames', {'serials', 'model'});
Table_Final = outerjoin(Table_Summary, Table_Models, 'Keys', 'serials', 'MergeKeys', true);

% 3. SEPARAR POR FORNECEDOR
data_Alpha_Life = []; data_Alpha_Censor = [];
data_Beta_Life  = []; data_Beta_Censor  = [];
data_Gamma_Life = []; data_Gamma_Censor = [];

fprintf('A processar %d discos únicos...\n', height(Table_Final));

for i = 1:height(Table_Final)
    mod = string(Table_Final.model{i});
    life = Table_Final.max_life(i);
    is_fail = Table_Final.max_fail(i); % 1 = Falha, 0 = Censura (Suspensão)
    
    % Inverter lógica para Weibull em alguns softwares? 
    % Normalmente: 1=Falha, 0=Censura. O Matlab 'wblfit' aceita vetor de censura onde 1=Censurado.
    % Vamos guardar o padrão: Is_Fail (1=Falhou). Depois ajustas conforme o software.
    
    if contains(mod, 'WDC', 'IgnoreCase', true)
        data_Alpha_Life = [data_Alpha_Life; life];
        data_Alpha_Censor = [data_Alpha_Censor; is_fail];
        
    elseif startsWith(mod, 'ST', 'IgnoreCase', true)
        data_Beta_Life = [data_Beta_Life; life];
        data_Beta_Censor = [data_Beta_Censor; is_fail];
        
    elseif contains(mod, 'Hitachi', 'IgnoreCase', true) || contains(mod, 'HGST', 'IgnoreCase', true)
        data_Gamma_Life = [data_Gamma_Life; life];
        data_Gamma_Censor = [data_Gamma_Censor; is_fail];
    end
end

data_Alpha_Life(data_Alpha_Life == 0) = 0.5;
data_Beta_Life(data_Beta_Life == 0)   = 0.5;
data_Gamma_Life(data_Gamma_Life == 0) = 0.5;

fprintf('Correção aplicada: Lifetimes de 0 dias alterados para 0.5 dias.\n');

% 4. EXPORTAR RESULTADOS
% Preparar colunas para Excel (preencher com NaN para ficarem do mesmo tamanho)
max_len = max([length(data_Alpha_Life), length(data_Beta_Life), length(data_Gamma_Life)]);
pad = @(v) [v; nan(max_len - length(v), 1)];

T_Export = table(...
    pad(data_Alpha_Life), pad(data_Alpha_Censor), ...
    pad(data_Beta_Life), pad(data_Beta_Censor), ...
    pad(data_Gamma_Life), pad(data_Gamma_Censor), ...
    'VariableNames', {...
    'Alpha_Lifetime', 'Alpha_IsFailure', ...
    'Beta_Lifetime',  'Beta_IsFailure', ...
    'Gamma_Lifetime', 'Gamma_IsFailure'});

writetable(T_Export, 'dados_weibull.xlsx');

% 5. ESTATÍSTICAS RÁPIDAS
fprintf('\n--- RESUMO PARA WEIBULL ---\n');
fprintf('Alpha (WDC):     %d Falhas, %d Suspensões (Total: %d)\n', sum(data_Alpha_Censor==1), sum(data_Alpha_Censor==0), length(data_Alpha_Life));
fprintf('Beta (ST):       %d Falhas, %d Suspensões (Total: %d)\n', sum(data_Beta_Censor==1), sum(data_Beta_Censor==0), length(data_Beta_Life));
fprintf('Gamma (Hitachi): %d Falhas, %d Suspensões (Total: %d)\n', sum(data_Gamma_Censor==1), sum(data_Gamma_Censor==0), length(data_Gamma_Life));
fprintf('\nFicheiro "dados_weibull.xlsx" gerado.\nColunas "IsFailure": 1 = Falhou, 0 = Censurado.\n');