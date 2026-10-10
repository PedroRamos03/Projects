function d = conjugado_trabalho_entregar(x,xprev,dprev,epsilon,lambda,g,gradf,gradg,i,mode)
gradf0=GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg);

    if mode==1
    %fletcher-reeves
    beta=(norm(GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg))^2)/norm(GradLagrangeComparar(xprev,epsilon,lambda,g,gradf,gradg))^2;
    d=-GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg)+beta*dprev;

    elseif mode==2

    %Polak-ribiere
    dif=GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg)-GradLagrangeComparar(xprev,epsilon,lambda,g,gradf,gradg);
    beta=(dot(GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg),dif))/norm(GradLagrangeComparar(xprev,epsilon,lambda,g,gradf,gradg))^2;
    d=-GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg)+beta*dprev;
    end

%fazer o reset
if mod(i,10)==0 || dot(GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg),GradLagrangeComparar(xprev,epsilon,lambda,g,gradf,gradg))/(norm(GradLagrangeComparar(xprev,epsilon,lambda,g,gradf,gradg))^2) > 0.999
    d=-gradf0;
end
end