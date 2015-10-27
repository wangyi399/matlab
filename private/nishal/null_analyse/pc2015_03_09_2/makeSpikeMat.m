
function spkMat = makeSpikeMat(cell_spk,binsz,len)
nTrials=length(cell_spk);
spkMat=zeros(nTrials,len);
bintime=[0:len]*binsz;
for itrial=1:nTrials

    for itime=1:len
        if(sum(cell_spk{itrial}>=bintime(itime)*20000 & cell_spk{itrial}<bintime(itime+1)*20000)>0)
            spkMat(itrial,itime)=1;
        end
    end
end

end