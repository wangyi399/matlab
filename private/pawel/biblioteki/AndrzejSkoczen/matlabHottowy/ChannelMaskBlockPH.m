function bitstr = ChannelMaskBlockPH(DL,Masks)
%nrch - liczba kanalow w modelu, ktorzy zamierzamy symulowac
%dla pelnego modelu nrch=64 i mozna stowac wszystki inizesz wartosci
nrch=length(Masks);    
cmd = '011_';
    CM = '';
    nrActive = DL/14;
    maxDL = nrch*14;
    if(nrActive > floor(nrActive)) 
        error('error in ChannelMask: DL must be multiple of 14');
    end
    if(DL <= maxDL)
        DLstr = dec2bin(DL,12);
    else
        error('error in ChannelMask: DL is too big,  should be <= %i',maxDL);
    end            
    for i = 1:nrch
        if(Masks(i)==1)
            s = '1';
        else
            s = '0';
        end
        CM = [CM,s];
    end
    bitstr = ['1010_',cmd,DLstr,'_',CM];
end
