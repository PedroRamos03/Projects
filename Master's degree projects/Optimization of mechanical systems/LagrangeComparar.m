function Lagrange= LagrangeComparar(x,epsilon,lambda,g,f)

fx=f(x(1),x(2),x(3),x(4));
gx=g(x);

max1 = zeros(length(gx),1);

for i=1:length(max1)
    max1(i) = max(gx(i), (-epsilon/2)*lambda(i));
end

Lagrange= fx + transpose(lambda)*max1 + (1/epsilon)*norm(max1)^2;
end