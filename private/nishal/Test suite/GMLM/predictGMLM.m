
function predictedResponse = predictGMLM(fitGMLM,maskedMov,nTrials)
filters = fitGMLM.Linear.filter;
nFrontEnds = length(filters);
mu=fitGMLM.mu;

mov_filtered=maskedMov;

kx=cell(nFrontEnds,1);

for ifilter=1:nFrontEnds
    kx{ifilter} = exp(filters{ifilter}'*mov_filtered);
end



lam=kx{1};
for ik=2:length(kx)
lam=lam+kx{ik};
end
lam=lam+mu;
l2=repmat(lam,[10,1]);
lam=l2(:);
lam=lam*(1/1200);
predictedResponse = zeros(nTrials,length(lam));

for itrial=1:nTrials
predictedResponse(itrial,:)=poissrnd(lam);    
end

predictedResponse= predictedResponse';
end