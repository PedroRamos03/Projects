function GradLagrange = GradLagrangeComparar(x,epsilon,lambda,g,gradf,gradg)
gx=g(x); %vetor coluna
grad_f=gradf(x(1),x(2),x(3),x(4)); %vetor coluna
grad_g=gradg(x); %matrix 4x6

max_= zeros(length(gx),1);
grad_max = zeros(length(x),length(gx));

flag=zeros(length(gx),1);
for i=1:length(flag) % verificar se no max fica gx ou o resto
    if gx(i) >= (-epsilon/2)*lambda(i)
        flag(i)=1;
    else
        flag(i)=0;
    end
end

for i=1:length(max_) % atribuir os valores ao vetor max
    max_(i) = max(gx(i), (-epsilon/2)*lambda(i));
end

for j=1:length(gx)
    for i=1: length(x)
        if flag(i)==1
            grad_max(i,j)=grad_g(i,j);
        else
            grad_max(i,j)=0;
        end
    end
end

GradLagrange=zeros(length(x),1); 
for i=1:length(grad_f)
    for j=1:length(gx)
        for k=1:length(x)
            GradLagrange(i)=grad_f(i)+lambda(j)*grad_max(k,i)+ (2/epsilon)*max_(j)*grad_max(k,i);
        end
                
    end    
end

end