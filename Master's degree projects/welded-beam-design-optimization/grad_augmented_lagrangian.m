function GradLagrange = grad_augmented_lagrangian(x, epsilon, lambda, g, gradf, gradg)
% Computes the analytical gradient of the Augmented Lagrangian function.

gx = g(x);                              % Column vector (6x1)
grad_f = gradf(x(1), x(2), x(3), x(4)); % Column vector (4x1)
grad_g = gradg(x);                      % Jacobian matrix (4x6)

max_ = zeros(length(gx), 1);
grad_max = zeros(length(x), length(gx));

flag = zeros(length(gx), 1);
for i = 1:length(flag)
    if gx(i) >= (-epsilon/2)*lambda(i)
        flag(i) = 1;
    else
        flag(i) = 0;
    end
end

for i = 1:length(max_)
    max_(i) = max(gx(i), (-epsilon/2)*lambda(i));
end

for j = 1:length(gx)
    for i = 1:length(x)
        if flag(j) == 1
            grad_max(i,j) = grad_g(i,j);
        else
            grad_max(i,j) = 0;
        end
    end
end

GradLagrange = grad_f;
for i = 1:length(grad_f)
    for j = 1:length(gx)
        GradLagrange(i) = GradLagrange(i) + (lambda(j) + (2/epsilon)*max_(j))*grad_max(i,j);
    end    
end

end