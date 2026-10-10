%% Dados
P = 6000; % Carga lb
L = 14; % Comprimento in
E = 30e6; % Módulo de young psi
G = 12e6; % Módulo de corte psi
tau_max = 13.6e3; % Tensão de corte máxima psi
sigma_max = 30e3; % Tensão máxima psi
delta_max = 0.25; % Deflexão máxima in


% Parâmetros iniciais
xx1=0.4;
xx2=6;
xx3=9;
xx4=0.5;
x = [xx1;xx2;xx3;xx4]; % ponto inicial
lambda = zeros(1, 6)'; % Multiplicadores de Lagrange iniciais
epsilon=0.05; % Parametro de penalidade inicial
tol = 1e-6; % Tolerância de convergência
max_iter = 1000;% Máximo de iterações
rho=0.5;
epsilon_low=0.3;

% Função objetivo
syms x1 x2 x3 x4

fsym(x1,x2,x3,x4)= 1.10471*x1^2*x2 + 0.04811*x3*x4*(14.0 + x2);
f = matlabFunction(fsym); %definir função f
gradfsym(x1,x2,x3,x4) = gradient(fsym);
gradf = matlabFunction(gradfsym); %definir gradiente de f

% definir as funcoes restricoes

%definir g1
tl= P / (sqrt(2)*x1*x2);
M= P * (L + x2 /2);
R= sqrt((x2^2)/4 + ((x1 + x3)/2)^2);
J= 2* ((x1*x2)/sqrt(2) * ((x2^2)/12 + (x1 + x3)^2 / 4));
t2l = (M * R) / J;
tau = sqrt(tl^2 + 2 * tl * t2l *(x2 /(2*R)) + t2l^2);

g1sym(x1,x2,x3,x4)= tau-tau_max;
g1=matlabFunction(g1sym);
gradg1sym(x1,x2,x3,x4)=gradient(g1sym);
gradg1=matlabFunction(gradg1sym);

%definir g2
sigma = 6*P*L / (x4*x3^2);
g2sym(x1,x2,x3,x4)= sigma-sigma_max;
g2=matlabFunction(g2sym);
gradg2sym(x1,x2,x3,x4)=gradient(g2sym);
gradg2=matlabFunction(gradg2sym);

%definir g3
g3sym(x1,x2,x3,x4)=x1-x4;
g3=matlabFunction(g3sym);
gradg3sym=gradient(g3sym);
gradg3=matlabFunction(gradg3sym);

%definir g4
g4sym(x1,x2,x3,x4)=0.10471*x1^2 + 0.04811*x3*x4*(14.0 + x2)-5;
g4=matlabFunction(g4sym);
gradg4sym=gradient(g4sym);
gradg4=matlabFunction(gradg4sym);

%definir g6
delta = (4*P*L^3) / (E*x4*x3^3);
g6sym(x1,x2,x3,x4) =delta-delta_max;
g6= matlabFunction(g6sym);
gradg6sym=gradient(g6sym);
gradg6=matlabFunction(gradg6sym);

% definir g7
Pc=4.013*sqrt(E*G * x3^2 * x4^6 / 36) / (L^2) * (1 - x3/(2*L) * sqrt(E/(4*G)));
g7sym(x1,x2,x3,x4)=P-Pc;
g7=matlabFunction(g7sym);
gradg7sym=gradient(g7sym);
gradg7=matlabFunction(gradg7sym);


g=@(x)[g1(x(1),x(2),x(3),x(4));g2(x(1),x(2),x(3),x(4));g3(x(1),x(2),x(3),x(4));g4(x(1),x(2),x(3),x(4));g6(x(1),x(2),x(3),x(4));g7(x(1),x(2),x(3),x(4));];
gradg=@(x)[gradg1(x(1),x(2),x(3),x(4)),gradg2(x(1),x(2),x(3),x(4)),gradg3(x(1),x(2),x(3),x(4)),gradg4(x(1),x(2),x(3),x(4)),gradg6(x(1),x(2),x(3),x(4)),gradg7(x(1),x(2),x(3),x(4))];


% Minimizar o lagrange com o gradiente conjugado
i = 0;
mode=1; %se mode for 1 usa o Fletcher-Reeves, se for 2 usa o Polak-Ribiére
xprev=x;
dprev=-GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg);
g_val=g(x);
lambda_new=zeros(length(g_val),0);
while i < max_iter    
    % Método do gradiente conjugado
    d = conjugado_trabalho_entregar(x,xprev,dprev,epsilon,lambda,g,gradf,gradg,i,mode); % Direção de descida

    % Passo para atualização usando linha de busca
    alpha = armijo_trabalho_entregar(x,d,epsilon, lambda,f,g,gradf,gradg);
    x_new = x + alpha * d;       % Atualização das variáveis de design
    lagrangenew=LagrangeComparar(x_new,epsilon,lambda,g,f);

    xprev=x;
    dprev=d;
    
    % Atualização dos multiplicadores de Lagrange
    g_val = g(x_new);
    %lambda = max(0, lambda + 2/epsilon.*g_val);  % Projeção para valores não negativos    
    %como a função max não da (esta a fazer o max entre dois vetores) fazer o ciclo
    for j=1:length(g_val)
        if lambda(j,1) + (2/epsilon)*g_val(j,1) >= 0
            lambda_new(j,1)=lambda(j,1) + (2/epsilon)*g_val(j,1);
        else
            lambda_new(j,1)=0;
        end
    end
    % Atualização do parametro de penalidade
    epsilon=min(rho*epsilon,epsilon_low);

    % Critério de convergência
    if norm(x_new - x) < tol
        break;
    end    
    % Atualizar x para próxima iteração
    x = x_new;
    i = i + 1;
    lambda=lambda_new;
end
% Resultados finais
disp('Solução ótima:');
disp(x);
disp('Valor da função objetivo:');
disp(f(x(1),x(2),x(3),x(4)));
