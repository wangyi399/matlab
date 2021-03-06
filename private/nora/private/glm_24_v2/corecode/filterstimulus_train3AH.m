function [kx kxsq] = filterstimulus_train3AH(p,Paramind,string_filtermode,Movie,LinearFilter)
% Commented 2012-12-06  AK Heitman
% filter3 just cleans out all the unused options and caveats of previous versions
% Basically just a wrapper for fastconv


%INPUTS:
%   string_filtermode: either 'fixed_filter' ,'rk2'
%   LinearFilter .. only for fixed filter mode
%
% This could be improved to just grab the Linear Filter and run it 
% through the sum(fastconv(..))

%OUTPUT:
% kx scalar filtered stimulus as a function of stimFrames





[spacePixels stimFrames] = size(Movie);
            
switch(string_filtermode)
	case 'fixed_filter'        
        kx = sum(fastconv(Movie,LinearFilter,spacePixels,stimFrames,0),1); % edoi
    case {'rk2'}              
        s1_idx = Paramind.SPACE1 ;
        t1_idx = Paramind.TIME1 ;
        s2_idx = Paramind.SPACE2 ;
        t2_idx = Paramind.TIME2 ;
        
        kx1 = fastconv( (p(s1_idx)')*Movie , (p(t1_idx)'), 1, stimFrames, 0);
        kx2 = fastconv( (p(s2_idx)')*Movie , (p(t2_idx)'), 1, stimFrames, 0);
        kx  = kx1 + kx2;      
end

    