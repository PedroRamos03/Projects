function d = conjugate_gradient_dir(x, xprev, dprev, epsilon, lambda, g, gradf, gradg, i, mode)
% Computes the nonlinear conjugate gradient search direction with periodic restarts.

gradf0 = grad_augmented_lagrangian(x, epsilon, lambda, g, gradf, gradg);
gradf_prev = grad_augmented_lagrangian(xprev, epsilon, lambda, g, gradf, gradg);

if mode == 1
    % Fletcher-Reeves
    beta = (norm(gradf0)^2) / (norm(gradf_prev)^2);
    d = -gradf0 + beta * dprev;
elseif mode == 2
    % Polak-Ribiere
    dif = gradf0 - gradf_prev;
    beta = dot(gradf0, dif) / (norm(gradf_prev)^2);
    d = -gradf0 + beta * dprev;
end

% Direction reset every 10 iterations or upon loss of conjugacy
if mod(i, 10) == 0 || dot(gradf0, gradf_prev) / (norm(gradf_prev)^2) > 0.999
    d = -gradf0;
end

end