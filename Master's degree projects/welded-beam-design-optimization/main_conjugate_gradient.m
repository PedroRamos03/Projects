%% Problem Data
P = 6000;           % Applied load [lb]
L = 14;             % Cantilever length [in]
E = 30e6;           % Young's modulus [psi]
G = 12e6;           % Shear modulus [psi]
tau_max = 13.6e3;   % Maximum allowable shear stress [psi]
sigma_max = 30e3;   % Maximum allowable bending stress [psi]
delta_max = 0.25;   % Maximum allowable tip deflection [in]

%% Initial Parameters
xx1 = 0.4;
xx2 = 6;
xx3 = 9;
xx4 = 0.5;
x = [xx1; xx2; xx3; xx4];   % Initial design point [h; l; t; b]
lambda = zeros(6, 1);       % Initial Lagrange multipliers
epsilon = 1.0;              % Initial penalty parameter
tol = 1e-6;                 % Convergence tolerance
max_iter = 1000;            % Maximum iterations
rho = 0.5;                  % Penalty reduction factor
epsilon_low = 1e-4;         % Minimum penalty threshold

%% Objective Function & Symbolic Gradient
syms x1 x2 x3 x4

fsym(x1,x2,x3,x4) = 1.10471*x1^2*x2 + 0.04811*x3*x4*(14.0 + x2);
f = matlabFunction(fsym);
gradfsym(x1,x2,x3,x4) = gradient(fsym);
gradf = matlabFunction(gradfsym);

%% Normalized Inequality Constraints & Gradients

% g1: Weld shear stress
tl = P / (sqrt(2)*x1*x2);
M = P * (L + x2/2);
R = sqrt((x2^2)/4 + ((x1 + x3)/2)^2);
J = 2 * ((x1*x2)/sqrt(2) * ((x2^2)/12 + (x1 + x3)^2 / 4));
t2l = (M * R) / J;
tau = sqrt(tl^2 + 2 * tl * t2l * (x2/(2*R)) + t2l^2);

g1sym(x1,x2,x3,x4) = tau/tau_max - 1;
g1 = matlabFunction(g1sym);
gradg1sym(x1,x2,x3,x4) = gradient(g1sym);
gradg1 = matlabFunction(gradg1sym);

% g2: Beam bending stress
sigma = 6*P*L / (x4*x3^2);
g2sym(x1,x2,x3,x4) = sigma/sigma_max - 1;
g2 = matlabFunction(g2sym);
gradg2sym(x1,x2,x3,x4) = gradient(g2sym);
gradg2 = matlabFunction(gradg2sym);

% g3: Weld thickness vs. beam width
g3sym(x1,x2,x3,x4) = x1/x4 - 1;
g3 = matlabFunction(g3sym);
gradg3sym = gradient(g3sym);
gradg3 = matlabFunction(gradg3sym);

% g4: Material cost constraint
g4sym(x1,x2,x3,x4) = (0.10471*x1^2 + 0.04811*x3*x4*(14.0 + x2))/5 - 1;
g4 = matlabFunction(g4sym);
gradg4sym = gradient(g4sym);
gradg4 = matlabFunction(gradg4sym);

% g6: Tip deflection
delta = (4*P*L^3) / (E*x4*x3^3);
g6sym(x1,x2,x3,x4) = delta/delta_max - 1;
g6 = matlabFunction(g6sym);
gradg6sym = gradient(g6sym);
gradg6 = matlabFunction(gradg6sym);

% g7: Buckling load
Pc = 4.013*sqrt(E*G * x3^2 * x4^6 / 36) / (L^2) * (1 - x3/(2*L) * sqrt(E/(4*G)));
g7sym(x1,x2,x3,x4) = 1 - Pc/P;
g7 = matlabFunction(g7sym);
gradg7sym = gradient(g7sym);
gradg7 = matlabFunction(gradg7sym);

g = @(x)[g1(x(1),x(2),x(3),x(4)); g2(x(1),x(2),x(3),x(4)); g3(x(1),x(2),x(3),x(4)); ...
         g4(x(1),x(2),x(3),x(4)); g6(x(1),x(2),x(3),x(4)); g7(x(1),x(2),x(3),x(4))];
gradg = @(x)[gradg1(x(1),x(2),x(3),x(4)), gradg2(x(1),x(2),x(3),x(4)), gradg3(x(1),x(2),x(3),x(4)), ...
             gradg4(x(1),x(2),x(3),x(4)), gradg6(x(1),x(2),x(3),x(4)), gradg7(x(1),x(2),x(3),x(4))];

%% Minimize Augmented Lagrangian (Conjugate Gradient)
i = 0;
mode = 1; % 1 = Fletcher-Reeves, 2 = Polak-Ribiere
xprev = x;
dprev = -grad_augmented_lagrangian(x, epsilon, lambda, g, gradf, gradg);
g_val = g(x);
lambda_new = zeros(length(g_val), 1);

while i < max_iter    
    % Conjugate gradient descent direction
    d = conjugate_gradient_dir(x, xprev, dprev, epsilon, lambda, g, gradf, gradg, i, mode);

    % Step size via Armijo backtracking line search
    alpha = armijo_line_search(x, d, epsilon, lambda, f, g, gradf, gradg);
    x_new = x + alpha * d;
    lagrangenew = augmented_lagrangian(x_new, epsilon, lambda, g, f);

    xprev = x;
    dprev = d;
    
    % Lagrange multiplier update
    g_val = g(x_new);
    for j = 1:length(g_val)
        if lambda(j,1) + (2/epsilon)*g_val(j,1) >= 0
            lambda_new(j,1) = lambda(j,1) + (2/epsilon)*g_val(j,1);
        else
            lambda_new(j,1) = 0;
        end
    end

    % Penalty parameter update
    epsilon = max(rho*epsilon, epsilon_low);

    % Convergence check
    if norm(x_new - x) < tol
        break;
    end    

    % Update state for next iteration
    x = x_new;
    i = i + 1;
    lambda = lambda_new;
end

%% Final Results
disp('Optimal design variables [h; l; t; b]:');
disp(x);
disp('Optimal objective value (Cost):');
disp(f(x(1),x(2),x(3),x(4)));
disp('Normalized constraints (must be <= 0):');
disp(g(x));