%% Script para Detetar Discos Duplicados (Beta/ST)
clc; clear;
opts = detectImportOptions('hard_drive_failure_data.csv');
opts.VariableNamingRule = 'preserve';
data = readtable('hard_drive_failure_data.csv', opts);

% Filtrar apenas as falhas reais
falhas = data(data.failure == 1, :);

% Filtrar apenas o fornecedor BETA (ST)
% Usa startsWith para garantir que se apanha todos os ST...
idx_st = startsWith(string(falhas.model), 'ST', 'IgnoreCase', true);
st_data = falhas(idx_st, :);

fprintf('Total de linhas Beta (ST): %d\n', height(st_data));

% 1. Encontrar Indices Únicos e Repetidos
[~, idx_unique] = unique(st_data.serial_number, 'first');

% Criar vetor com todos os índices
all_idx = (1:height(st_data))';

% A diferença entre "Todos" e "Únicos" são os duplicados
idx_duplicates = setdiff(all_idx, idx_unique);

% 2. Mostrar Resultados
if isempty(idx_duplicates)
    fprintf('Não foram encontrados duplicados.\n');
else
    fprintf('--- DISCOS DUPLICADOS ENCONTRADOS (%d) ---\n', length(idx_duplicates));
    duplicados = st_data(idx_duplicates, :);
    disp(duplicados(:, {'date', 'model', 'serial_number', 'lifetime'}));
    
    fprintf('\nNota: Estes registos devem ser ignorados na contagem de fiabilidade.\n');
    fprintf('Contagem correta para o relatório: %d - %d = %d falhas únicas.\n', ...
        height(st_data), length(idx_duplicates), height(st_data) - length(idx_duplicates));
end