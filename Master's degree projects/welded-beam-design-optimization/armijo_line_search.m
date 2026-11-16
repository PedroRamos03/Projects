function alpha = armijo_line_search(x, d, epsilon, lambda, f, g, gradf, gradg)
% Backtracking Armijo line search enforcing geometric side bounds.

delta = 0.5;
gamma = 0.5;
c = 0.5;
miter = 1000;

% Initial step size estimate
dk = 3*c .* abs(dot(grad_augmented_lagrangian(x, epsilon, lambda, g, gradf, gradg), d)) / (norm(d).^2);
alpha = dk;

f_x = augmented_lagrangian(x, epsilon, lambda, g, f);

for k = 1:miter
    xnew = x + alpha*d;
    f_xnew = augmented_lagrangian(xnew, epsilon, lambda, g, f);

    % Armijo sufficient decrease condition + geometric box bounds
    if f_xnew <= f_x + gamma*alpha*dot(grad_augmented_lagrangian(x, epsilon, lambda, g, gradf, gradg), d) && ...
       0.125 - xnew(1) <= 0 && xnew(1) - 2 <= 0 && ...
       0.1 - xnew(4) <= 0   && xnew(4) - 2 <= 0 && ...
       0.1 - xnew(2) <= 0   && xnew(2) - 10 <= 0 && ...
       0.1 - xnew(3) <= 0   && xnew(3) - 10 <= 0
        break
    else
        alpha = alpha * delta;
    end
end

end