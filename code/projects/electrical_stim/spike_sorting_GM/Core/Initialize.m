function initial=Initialize(input)



data           = input.tracesInfo.data;
templates      = input.neuronInfo.templates;
TfindRange     = input.params.TfindRange;  
TfindRangeRel  = input.params.TfindRangeRel;
TfindRel       = [TfindRangeRel(1):TfindRangeRel(2)];
Tdivide        = input.params.Tdivide;

E = input.tracesInfo.E;
T = input.tracesInfo.T;
I = input.tracesInfo.I;
J = input.tracesInfo.J;
nNeurons = input.neuronInfo.nNeurons;


      
lengthFindRange = length(TfindRel);
lengthSpikes    = sum(I)*nNeurons*lengthFindRange;
lengthDataVec   = sum(I)*E*T;
for e=1:E
    breakRanges{e}  = [0 input.tracesInfo.breakRecElecs{e} J];
    
    for m=1:length(breakRanges{e})-1
        lengthRange    = breakRanges{e}(m+1)-breakRanges{e}(m);
        aux            = find(lengthRange<=input.params.degPolRule)-1;
        degPols{e}(m)  = aux(1);
    end
end



dataVec=[];

for j=1:J
    for i=1:I(j)
        for e=1:E
            dataVec=[dataVec;data{j,e}(i,:)'];
        end
    end
end



for e = 1:E
    sizeAe(e)       = T*sum(degPols{e}+1);
    sizeAeDegCum{e} = [0 T*cumsum(degPols{e}+1)];
end
sizeAeCum = [0 cumsum(sizeAe)];
sizeA     = sum(sizeAe);


Xpol=sparse(0,0);
for j = 1:J

    Xji=sparse(T*E,sizeA);
    
    for e = 1:E

    Xjei=sparse(T,sizeAe(e));
    rangeIndex=find(breakRanges{e}<j);
    rangeIndex=rangeIndex(end);
    covPol=(j-breakRanges{e}(rangeIndex));
    covsPol=[];

        for p = 1:degPols{e}(rangeIndex)+1
            covsPol=[covsPol covPol^(p-1)];
        end

    XjeiAux=sparse(0,0);
    
        for t=1:T
            indt     = sparse(1,T);
            indt(t)  = 1;
            indtcovs = sparse(kron(indt,covsPol));
            XjeiAux  = sparse([XjeiAux;indtcovs]);
        end

        Xjei(:,1+sizeAeDegCum{e}(rangeIndex):sizeAeDegCum{e}(rangeIndex+1)) = XjeiAux;
        Xji(T*(e-1)+1:T*e,1+sizeAeCum(e):sizeAeCum(e+1)) = Xjei;
        Xjis{j} = Xji;
    end
    
        Xjpol = sparse(repmat(Xji,I(j),1));
        Xpol  = sparse([Xpol;Xjpol]);

end
    




K  = sparse(0,0);
K0 = makeToeplitz(templates,TfindRel,T);

cumsumSpikes = [0 cumsum(I*nNeurons*lengthFindRange)];

for j = 1:J
    Kj    = sparse(E*T*I(j),lengthSpikes);
    Kjaux = sparse(kron(speye(I(j)),K0));
    Kj(:,cumsumSpikes(j)+1:cumsumSpikes(j+1)) = Kjaux;
    K = sparse([K;Kj]);
end



indt = ones(1,lengthFindRange);
%at most one spike per neuron per trial
Asp = sparse(0,0);

for j=1:J
    
    for i=1:I(j)
    
        for n=1:nNeurons
            
            indn    = zeros(1,nNeurons);
            indn(n) = 1;
            indtn   = kron(indn,indt);
            indi    = zeros(1,I(j));
            indi(i) = 1 ;
            indtni  = sparse(kron(indi,indtn));
            ind     = zeros(1,lengthSpikes);
            ind(1,1+cumsumSpikes(j):cumsumSpikes(j+1)) = indtni;
            Asp     = sparse([Asp;ind]);
        end
      
    end
end


cumsumI = [0 cumsum(I*nNeurons*lengthFindRange)];

Ai = sparse(0,0);
%increasing spike probabilities
for n = 1:nNeurons

    for j = 1:J-1
         indi1      = ones(1,I(j))/I(j);
         indi2      = -ones(1,I(j+1))/I(j+1);
         indn       = zeros(1,nNeurons);
         indn(n)    = 1;
         indtn      = kron(indn,indt);
         indtni1    = sparse(kron(indi1,indtn));
         indtni2    = sparse(kron(indi2,indtn));
         ind        = zeros(1,lengthSpikes);
         ind(1,1+cumsumI(j):cumsumI(j+1)) = indtni1;
         ind(1,1+cumsumI(j+1):cumsumI(j+2))=indtni2;
         Ai = sparse([Ai;ind]);
    end
    
end

%
Ag = sparse([speye(lengthSpikes);-speye(lengthSpikes);Asp;Ai]);
b  = sparse([ones(lengthSpikes,1);zeros(lengthSpikes,1);ones(size(Asp,1),1);zeros(size(Ai,1),1)]);

rho1 = lengthSpikes;
rho2 = norm(dataVec,2)^2;


c = ones(lengthSpikes,1);
cvx_begin
variable BetaPol(sizeA)
variable s(lengthSpikes) 
minimize (quad_form((dataVec-Xpol*BetaPol-K*s),speye(length(dataVec))));
Ag*s <= b;
cvx_end



for n = 1:nNeurons
    for j = 1:J
        for i = 1:I(j)
            ind                         = cumsumI(j)+lengthFindRange*nNeurons*(i-1)+lengthFindRange*(n-1);
            GeneralizedSpikes{n,j}(:,i) = s(ind+1:ind+lengthFindRange);
        end
    end
end

for j = 1:J
    for n = 1:nNeurons
            Probs(n,j) = nanmean(nansum(GeneralizedSpikes{n,j})); 
    end
end



for j = 1:J
    A(j,:) = Xjis{j}*BetaPol;
    
end

for e = 1:E
    AE{e} = A(:,1+(e-1)*T:e*T);
end


for j=1:J
    for n=1:nNeurons
        indn    = zeros(1,nNeurons);
        indn(n) = 1;
        ActionPotentials{n,j} = (K0*kron(indn',GeneralizedSpikes{n,j}))';
    end
end    

for j = 1:J
    sumActionPotentials = 0;
    
    for n = 1:nNeurons
        sumActionPotentials = sumActionPotentials+ActionPotentials{n,j};
        
        for e=1:E
           
            Residuals{j,e}  = data{j,e} - repmat(AE{e}(j,:),I(j),1) - sumActionPotentials(:,T*(e-1)+1:T*e);
            sigma(e,j)      = sqrt(nansum(nansum((Residuals{j,e}.^2)))/(I(j)*T));
        
        end
    end
end

 

[X Xj]        = makeArtifactCovariates(T,J,I);
[matricesReg] = makeRegularizationMatrices(breakRanges,Tdivide);


for e=1:E
    clear quad  
    Beta(:,e)  = reshape(AE{e}',T*J,1);
    for l = 1:length(matricesReg(e).Prods)
       quad(l) = trace(Beta(:,e)'*matricesReg(e).Prods{l}*Beta(:,e));
    end

    lambda0    = ones(length(matricesReg(e).Prods),1);
    lambda     = NewtonMaxLogDet(lambda0,matricesReg(e).Prods,quad);
    lambda     = exp(lambda);
    lambdas{e} = lambda;

Lambdas{e} = 0;


for r = 1:length(matricesReg(e).Prods)
    
    Lambdas{e} = Lambdas{e}+lambdas{e}(r)*matricesReg(e).Prods{r};

end

Lambdas{e} = sparse(Lambdas{e});
LambdasInv{e} = sparse(inv(Lambdas{e}));
end



initial.ArtifactVariables = Beta;
initial.Artifact          = A;
initial.ArtifactE         = AE;
initial.Residual          = Residuals;
initial.sigma             = sigma;
initial.Probs             = Probs;
initial.GeneralizedSpikes = GeneralizedSpikes;
initial.ActionPotentials  = ActionPotentials;

initial.params.Xj                 = Xj;
initial.params.X                  = X;
initial.params.matricesReg        = matricesReg;
initial.params.lambdas            = lambdas;
initial.params.Lambdas            = Lambdas;
initial.params.LambdasInv         = LambdasInv;
initial.params.a0                 = -0.5*ones(1,J);
initial.params.b0                 =  zeros(1,J);
initial.params.lambdaLogReg       = 0.0001;
initial.params.alphaLogReg        = 0.0001;