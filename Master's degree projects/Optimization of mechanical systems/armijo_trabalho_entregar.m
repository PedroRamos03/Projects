function alpha = armijo_trabalho_entregar(x,d,epsilon,lambda,f,g,gradf,gradg)
% Initialisation parameters
    delta = 0.5;
    gamma = 0.5;
    c = 0.5;
    % max nr of iterations
    miter = 1000;

    %definir dk e inicializar alpha
    dk=3*c.*abs(dot(GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg),d))/(norm(d).^2);
    alpha=dk;

    %inicializar fx no ponto inicial
    f_x=LagrangeComparar(x,epsilon,lambda,g,f);

    for k=1:miter
        xnew=x+alpha*d;
        f_xnew=LagrangeComparar(xnew,epsilon,lambda,g,f);

        %condicao de armijo
        if f_xnew <= f_x+gamma*alpha*dot(GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg),d) && 0.125-xnew(1)<=0 && xnew(1)-2<=0 && 0.1-xnew(4)<=0 && xnew(4)-2<=0 && 0.1-xnew(2)<=0 && xnew(2)-10<=0 && 0.1-xnew(3)<=0 && xnew(3)-10<=0
            break
        else
            alpha=alpha*delta;
        end
    end  

end