%% 1. Input Data
tic
% 1.1 Global plate dimensions [m]
a = 1;          % Length along x1 direction
b = 1;          % Height along x2 direction (larger base)
c = 0.7;        % Height along x2 direction (smaller base)
h = 0.002;      % Plate thickness

% 1.2 Material properties [Pa]
E = 210e9;      % Young's modulus [Pa]
poiss = 0.29;   % Poisson's ratio

% 1.3 Plate flexural rigidity
D = (E * h^3) / (12 * (1 - poiss^2));
fprintf('D = %.6f N*m\n', D);

% 1.4 Yield strength reference [Pa]
sigma_y = 300e6;
fprintf('sigma_y = %.0f Pa\n', sigma_y);

%% 2. Boundary Conditions
boundarycase = 2;  % 1 = SSSS (Simply Supported), 2 = CCCC (Clamped)
if boundarycase == 1
    fprintf('Boundary condition: SSSS (Simply Supported)\n');
elseif boundarycase == 2
    fprintf('Boundary condition: CCCC (Clamped)\n');
else
    error('Invalid boundary condition. Use 1 for SSSS or 2 for CCCC.');
end

%% 3. Loading Conditions
loadcase = 1;  % 1 = Uniform pressure, 2 = Patch pressure, 3 = Line load, 4 = Point load
switch loadcase
    case 1
        fprintf('Load case: Uniform pressure over entire plate\n');
    case 2
        fprintf('Load case: Patch pressure over sub-region\n');
    case 3
        fprintf('Load case: Line load\n');
    case 4
        fprintf('Load case: Point load\n');
    otherwise
        error('Invalid load case. Use 1, 2, 3, or 4.');
end

p = 0; F = 0; L = 0; xl = 0; yl = 0;
x1_inf = 0; x1_sup = 0; x2_inf = 0; x2_sup = 0; dir = 0;

switch loadcase
    case 1
        p = 1000;
        fprintf('Pressure magnitude: %.2f N/m^2\n', p);
    case 2
        x1_inf = 0.2; x1_sup = 0.8; x2_inf = 0.2; x2_sup = 0.6;
        p = 1000;
        fprintf('Pressure zone: x1 from %.2f to %.2f m, x2 from %.2f to %.2f m\n', x1_inf, x1_sup, x2_inf, x2_sup);
        fprintf('Pressure magnitude: %.2f N/m^2\n', p);
    case 3
        xl = 0.5; yl = 0; L = 500; % [N/m]
        if yl == 0
            dir = 1; % Vertical
        elseif xl == 0
            dir = 0; % Horizontal
        end
        fprintf('Line load at (x1 = %.2f, x2 = %.2f), direction: %d\n', xl, yl, dir);
        fprintf('Line load magnitude: %.2f N/m\n', L);
    case 4
        xp = 0.5; yp = 0.5; F = 1000;
        fprintf('Point load at (x1 = %.2f, x2 = %.2f)\n', xp, yp);
        fprintf('Force magnitude: %.2f N\n', F);
end

%% 4. Approximation Basis Functions
po = 3;         % Number of 1D approximation functions per direction
po2 = po * po;  % Total number of 2D basis functions
fprintf('Number of 1D basis functions (po): %d\n', po);
fprintf('Total number of 2D basis functions (po2): %d\n', po2);

syms xi eta;

if boundarycase == 1
    max_shapes = 25;
    if po > max_shapes
        warning('Requested number of functions (%d) exceeds limit of 25. Using first 25.', po);
        po = max_shapes;
        po2 = po * po;
    end
    f = sym(zeros(po, 1));
    for ishape = 1:po
        f(ishape) = sin(ishape * pi * 0.5 * (xi + 1));
    end
elseif boundarycase == 2
    f = sym(zeros(25, 1));
    % Symmetric 1D basis functions
    f(1) = (1/8) - (1/4)*xi^2 + (1/8)*xi^4;
    f(3) = -(1/48) + (3/16)*xi^2 - (5/16)*xi^4 + (7/48)*xi^6;
    f(5) = (3/384) - (15/96)*xi^2 + (35/64)*xi^4 - (63/96)*xi^6 + (99/384)*xi^8;
    f(7) = -(1/256) + (35/256)*xi^2 - (105/128)*xi^4 + (231/128)*xi^6 - (429/256)*xi^8 + (143/256)*xi^10;
    f(9) = (7/3072) - (63/512)*xi^2 + (1155/1024)*xi^4 - (1001/256)*xi^6 + (6435/1024)*xi^8 - (2431/512)*xi^10 + (4199/3072)*xi^12;
    f(11) = -(3/2048) + (231/2048)*xi^2 - (3003/2048)*xi^4 + (15015/2048)*xi^6 - (36465/2048)*xi^8 + (46189/2048)*xi^10 - (29393/2048)*xi^12;
    f(13) = (33/32768) - (429/4096)*xi^2 + (15015/8192)*xi^4 - (51051/4096)*xi^6 + (692835/16384)*xi^8 - (323323/4096)*xi^10 + (676039/8192)*xi^12 - (185725/4096)*xi^14 + (334305/32768)*xi^16;
    f(15) = -(143/196608) + (6435/65536)*xi^2 - (36465/16384)*xi^4 + (323323/16384)*xi^6 - (2909907/32768)*xi^8 + (7436429/32768)*xi^10 - (16900975/49152)*xi^12 + (5014575/16384)*xi^14 - (9694845/65536)*xi^16 + (1964315/65536)*xi^18;
    f(17) = (143/262144) - (12155/131072)*xi^2 + (692835/262144)*xi^4 - (969969/32768)*xi^6 + (22309287/131072)*xi^8 - (37182145/65536)*xi^10 + (152108775/131072)*xi^12 - (48474225/32768)*xi^14 + (300540195/262144)*xi^16 - (64822395/131072)*xi^18 + (23881935/262144)*xi^20;
    f(19) = -(221/524288) + (46189/524288)*xi^2 - (1616615/524288)*xi^4 + (22309287/524288)*xi^6 - (79676025/262144)*xi^8 + (334639305/262144)*xi^10 - (882230895/262144)*xi^12 + (1502700975/262144)*xi^14 - (3305942145/524288)*xi^16 + (2268783825/524288)*xi^18 - (883631595/524288)*xi^20 + (149184555/524288)*xi^22;
    f(21) = (4199/12582912) - (88179/1048576)*xi^2 + (7436429/2097152)*xi^4 - (185910725/3145728)*xi^6 + (2151252675/4194304)*xi^8 - (1386362835/524288)*xi^10 + (9116385915/1048576)*xi^12 - (9917826435/524288)*xi^14 + (115707975075/4194304)*xi^16 - (27981667175/1048576)*xi^18 + (34461632205/2097152)*xi^20 - (6116566755/1048576)*xi^22 + (3811773485/4194304)*xi^24;
    f(23) = -(2261/8388608) + (676039/8388608)*xi^2 - (16900975/4194304)*xi^4 + (334639305/4194304)*xi^6 - (6931814175/8388608)*xi^8 + (42977247885/8388608)*xi^10 - (42977247885/2097152)*xi^12 + (115707975075/2097152)*xi^14 - (856239015555/8388608)*xi^16 + (1091285019825/8388608)*xi^18 - (470975640135/4194304)*xi^20 + (263012370465/4194304)*xi^22 - (171529806825/8388608)*xi^24 + (24805848987/8388608)*xi^26;
    f(25) = (7429/33554432) - (1300075/16777216)*xi^2 + (152108775/33554432)*xi^4 - (882230895/8388608)*xi^6 + (42977247885/33554432)*xi^8 - (157583242245/16777216)*xi^10 + (1504203675975/33554432)*xi^12 - (611599296825/4194304)*xi^14 + (11131107202215/33554432)*xi^16 - (8948537162565/16777216)*xi^18 + (20251952525805/33554432)*xi^20 - (3945185556975/8388608)*xi^22 + (8061900920775/33554432)*xi^24 - (1215486600363/16777216)*xi^26 + (327988447717/33554432)*xi^28;
    
    % Antisymmetric 1D basis functions
    f(2) = (1/8)*xi - (1/4)*xi^3 + (1/8)*xi^5;
    f(4) = -(1/16)*xi + (5/16)*xi^3 - (7/16)*xi^5 + (3/16)*xi^7;
    f(6) = (5/128)*xi - (35/96)*xi^3 + (63/64)*xi^5 - (33/32)*xi^7 + (143/384)*xi^9;
    f(8) = -(7/256)*xi + (105/256)*xi^3 - (231/128)*xi^5 + (429/128)*xi^7 - (715/256)*xi^9 + (221/256)*xi^11;
    f(10) = (21/1024)*xi - (231/512)*xi^3 + (3003/1024)*xi^5 - (2145/256)*xi^7 + (12155/1024)*xi^9 - (4199/512)*xi^11 + (2261/1024)*xi^13;
    f(12) = -(33/2048)*xi + (1001/2048)*xi^3 - (9009/2048)*xi^5 + (36465/2048)*xi^7 - (230945/6144)*xi^9 + (88179/2048)*xi^11 - (52003/2048)*xi^13 + (37145/6144)*xi^15;
    f(14) = (429/32768)*xi - (2145/4096)*xi^3 + (51051/8192)*xi^5 - (138567/4096)*xi^7 + (1616615/16384)*xi^9 - (676039/4096)*xi^11 + (1300075/8192)*xi^13 - (334305/4096)*xi^15 + (570285/32768)*xi^17;
    f(16) = -(715/65536)*xi + (36465/65536)*xi^3 - (138567/16384)*xi^5 + (969969/16384)*xi^7 - (7436429/32768)*xi^9 + (16900975/32768)*xi^11 - (11700675/16384)*xi^13 + (9694845/16384)*xi^15 - (17678835/65536)*xi^17 + (3411705/65536)*xi^19;
    f(18) = (2431/262144)*xi - (230945/393216)*xi^3 + (2909907/262144)*xi^5 - (3187041/32768)*xi^7 + (185910725/393216)*xi^9 - (91265265/65536)*xi^11 + (339319575/131072)*xi^13 - (100180065/32768)*xi^15 + (583401555/262144)*xi^17 - (119409675/131072)*xi^19 + (42077695/262144)*xi^21;
    f(20) = -(4199/524288)*xi + (323323/524288)*xi^3 - (7436429/524288)*xi^5 + (79676025/524288)*xi^7 - (239028075/262144)*xi^9 + (882230895/262144)*xi^11 - (2103781365/262144)*xi^13 + (3305942145/262144)*xi^15 - (6806351475/524288)*xi^17 + (4418157975/524288)*xi^19 - (1641030105/524288)*xi^21 + (265937685/524288)*xi^23;
    f(22) = (29393/4194304)*xi - (676039/1048576)*xi^3 + (37182145/2097152)*xi^5 - (239028075/1048576)*xi^7 + (6931814175/4194304)*xi^9 - (3907022535/524288)*xi^11 + (23141595015/1048576)*xi^13 - (23141595015/524288)*xi^15 + (251835004575/4194304)*xi^17 - (57436053675/1048576)*xi^19 + (67282234305/2097152)*xi^21 - (11435320455/1048576)*xi^23 + (6861192273/4194304)*xi^25;
    f(24) = -(52003/8388608)*xi + (16900975/25165824)*xi^3 - (91265265/4194304)*xi^5 + (1386362835/4194304)*xi^7 - (23876248825/8388608)*xi^9 + (128931743655/8388608)*xi^11 - (115707975075/2097152)*xi^13 + (285413005185/2097152)*xi^15 - (1964313035685/8388608)*xi^17 + (2354878200675/8388608)*xi^19 - (964378691705/4194304)*xi^21 + (514589420475/4194304)*xi^23 - (322476036831/8388608)*xi^25 + (135054066707/25165824)*xi^27;

    if po > 25
        warning('Requested number of functions (%d) exceeds 25 defined functions. Using first 25.', po);
        po = 25;
        po2 = po * po;
    end
    f = f(1:po);
end

% 4.1 Generate 2D tensor-product basis functions
f2 = subs(f, xi, eta);
FI = reshape(f * transpose(f2), [], 1);

%% 5. Boundary Condition Verification
tol = 1e-10;
satisfied_count = 0;

if boundarycase == 1
    for i = 1:po2
        vals = double([subs(FI(i), xi, 1), subs(diff(FI(i), xi, 2), xi, 1), ...
                       subs(FI(i), xi, -1), subs(diff(FI(i), xi, 2), xi, -1), ...
                       subs(FI(i), eta, 1), subs(diff(FI(i), eta, 2), eta, 1), ...
                       subs(FI(i), eta, -1), subs(diff(FI(i), eta, 2), eta, -1)]);
        if all(abs(vals) < tol), satisfied_count = satisfied_count + 1; end
    end
elseif boundarycase == 2
    for i = 1:po2
        vals = double([subs(FI(i), xi, 1), subs(diff(FI(i), xi), xi, 1), ...
                       subs(FI(i), xi, -1), subs(diff(FI(i), xi), xi, -1), ...
                       subs(FI(i), eta, 1), subs(diff(FI(i), eta), eta, 1), ...
                       subs(FI(i), eta, -1), subs(diff(FI(i), eta), eta, -1)]);
        if all(abs(vals) < tol), satisfied_count = satisfied_count + 1; end
    end
end

if satisfied_count == po2
    disp('All basis functions FI[i] satisfy the boundary conditions.');
else
    warning('Not all basis functions satisfy the boundary conditions.');
end

%% 6. Isoparametric Coordinate Mapping (Natural <-> Global)
inter = 4;
X = [0; 0; a; 0; c; b; 0; b];

N = [(1 - xi)*(1 - eta)/4, (1 + xi)*(1 - eta)/4, (1 + xi)*(1 + eta)/4, (1 - xi)*(1 + eta)/4];
N_matrix = sym(zeros(2, 2 * inter));
N_matrix(1, 1:2:end) = N;
N_matrix(2, 2:2:end) = N;

coords = N_matrix * X;
syms x1 x2;

sol = solve([x1 == coords(1), x2 == coords(2)], [xi, eta]);
FI_f = subs(FI, {xi, eta}, {sol.xi, sol.eta});

%% 7. Numeric Assembly of Stiffness Matrix K_num and Load Vector p_num via integral2
K_num = zeros(po2, po2);
p_num = zeros(po2, 1);
x1_upper = @(x2) (c - a)/b * x2 + a;

for i = 1:po2
    d4phid4x1 = diff(FI_f(i), x1, 4);
    d4phid2x1d2x2 = diff(diff(FI_f(i), x1, 2), x2, 2);
    d4phid4x2 = diff(FI_f(i), x2, 4);
    biharmonic_i = D * (d4phid4x1 + 2 * d4phid2x1d2x2 + d4phid4x2);

    for j = 1:po2
        integrand = biharmonic_i * FI_f(j);
        if isequal(integrand, sym(0))
            K_num(i, j) = 0;
        else
            % Note: integral2 integrates outer variable (x2) first, inner (x1) second
            integrand_fn = matlabFunction(integrand + 0*x2, 'Vars', {x2, x1});
            K_num(i, j) = integral2(integrand_fn, 0, b, 0, x1_upper, 'RelTol', 1e-8, 'AbsTol', 1e-12);
        end
    end

    % Generalized load vector P_i
    if loadcase == 1
        load_fn = matlabFunction(p * FI_f(i) + 0*x2, 'Vars', {x2, x1});
        p_num(i) = integral2(load_fn, 0, b, 0, x1_upper, 'RelTol', 1e-8, 'AbsTol', 1e-12);
    elseif loadcase == 2
        load_fn = matlabFunction(p * FI_f(i) + 0*x2, 'Vars', {x2, x1});
        p_num(i) = integral2(load_fn, x2_inf, x2_sup, x1_inf, x1_sup, 'RelTol', 1e-8, 'AbsTol', 1e-12);
    elseif loadcase == 3
        if dir == 0
            line_fn = matlabFunction(L * subs(FI_f(i), x2, yl) + 0*x1, 'Vars', {x1});
            p_num(i) = integral(line_fn, 0, x1_upper(yl), 'RelTol', 1e-8);
        elseif dir == 1
            line_fn = matlabFunction(L * subs(FI_f(i), x1, xl) + 0*x2, 'Vars', {x2});
            p_num(i) = integral(line_fn, 0, b, 'RelTol', 1e-8);
        end
    elseif loadcase == 4
        p_num(i) = F * double(subs(FI_f(i), {x1, x2}, {xp, yp}));
    end
end

%% 8. Solve Linear System (K_num * q_num = p_num)
if po >= 5
    disp('Solving system via SVD (po >= 5)...');
    [U, S, V] = svd(K_num);
    tol_svd = max(size(K_num)) * eps(max(diag(S)));
    S_inv = zeros(size(S'));
    for i = 1:min(size(S))
        if S(i,i) > tol_svd
            S_inv(i,i) = 1/S(i,i);
        end
    end
    q_num = V * S_inv * U' * p_num;
else
    q_num = K_num \ p_num;
end

disp('Generalized coordinate vector q:');
disp(q_num);

%% 9. Transverse Deflection Field w(x1, x2)
w = sum(FI_f .* q_num);

%% 10. Vectorized Deflection & Stress Post-Processing (Top Surface z = h/2)
[x1_grid, x2_grid] = meshgrid(linspace(0, a, 50), linspace(0, b, 50));
outside_domain = x1_grid > ((c - a)/b * x2_grid + a);

w_fn = matlabFunction(w + 0*x1, 'Vars', {x1, x2});

z = h / 2;
epsilon_x1x1 = -z * diff(w, x1, 2);
epsilon_x2x2 = -z * diff(w, x2, 2);
gamma_x1x2   = -2 * z * diff(diff(w, x1), x2);

sigma_x1x1 = (E / (1 - poiss^2)) * (epsilon_x1x1 + poiss * epsilon_x2x2);
sigma_x2x2 = (E / (1 - poiss^2)) * (epsilon_x2x2 + poiss * epsilon_x1x1);
tau_x1x2   = (E / (2 * (1 + poiss))) * gamma_x1x2;
sigma_vm   = sqrt(sigma_x1x1^2 - sigma_x1x1*sigma_x2x2 + sigma_x2x2^2 + 3*tau_x1x2^2);

sigma_x1x1_fn = matlabFunction(sigma_x1x1 + 0*x1, 'Vars', {x1, x2});
sigma_x2x2_fn = matlabFunction(sigma_x2x2 + 0*x1, 'Vars', {x1, x2});
tau_x1x2_fn   = matlabFunction(tau_x1x2   + 0*x1, 'Vars', {x1, x2});
sigma_vm_fn   = matlabFunction(sigma_vm   + 0*x1, 'Vars', {x1, x2});

w_num          = w_fn(x1_grid, x2_grid);
sigma_x1x1_num = sigma_x1x1_fn(x1_grid, x2_grid);
sigma_x2x2_num = sigma_x2x2_fn(x1_grid, x2_grid);
tau_x1x2_num   = tau_x1x2_fn(x1_grid, x2_grid);
sigma_vm_num   = sigma_vm_fn(x1_grid, x2_grid);

w_num(outside_domain)          = NaN;
sigma_x1x1_num(outside_domain) = NaN;
sigma_x2x2_num(outside_domain) = NaN;
tau_x1x2_num(outside_domain)   = NaN;
sigma_vm_num(outside_domain)   = NaN;

w_max = max(w_num(:), [], 'omitnan');
sigma_vm_max = max(sigma_vm_num(:), [], 'omitnan');

fprintf('Maximum deflection w_max: %.6f m\n', w_max);
if sigma_vm_max > sigma_y
    fprintf('WARNING: Yielding detected (sigma_vm_max = %.2f MPa > sigma_y = %.2f MPa)\n', ...
            sigma_vm_max/1e6, sigma_y/1e6);
else
    fprintf('No yielding (sigma_vm_max = %.2f MPa <= sigma_y = %.2f MPa)\n', ...
            sigma_vm_max/1e6, sigma_y/1e6);
end
fprintf('Total execution time: %.3f s\n', toc);

%% 11. Visualization
figure;
surf(x1_grid, x2_grid, w_num);
xlabel('Coordinate x_1 [m]'); ylabel('Coordinate x_2 [m]'); zlabel('Deflection w [m]');
title('Trapezoidal Plate Transverse Deflection');
colorbar; view(3);

figure;
surf(x1_grid, x2_grid, sigma_x1x1_num);
xlabel('Coordinate x_1 [m]'); ylabel('Coordinate x_2 [m]'); zlabel('\sigma_{x1x1} [Pa]');
title(['Distribution of \sigma_{x1x1} at z = ', num2str(z), ' m']);
colorbar; view(3); shading interp; alpha 0.75;

figure;
surf(x1_grid, x2_grid, sigma_x2x2_num);
xlabel('Coordinate x_1 [m]'); ylabel('Coordinate x_2 [m]'); zlabel('\sigma_{x2x2} [Pa]');
title(['Distribution of \sigma_{x2x2} at z = ', num2str(z), ' m']);
colorbar; view(3); shading interp; alpha 0.75;

figure;
surf(x1_grid, x2_grid, tau_x1x2_num);
xlabel('Coordinate x_1 [m]'); ylabel('Coordinate x_2 [m]'); zlabel('\tau_{x1x2} [Pa]');
title(['Distribution of \tau_{x1x2} at z = ', num2str(z), ' m']);
colorbar; view(3); shading interp; alpha 0.75;