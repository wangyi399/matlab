% Quick access to final BPS scores of the GLM for all cells
% Super Hack!! grabbed data from convergence structre..
% AKHeitman 2014-11-17 

clear; close all; clc
BD = NSEM_BaseDirectories;
eval(sprintf('load %s/allcells.mat', BD.Cell_Selection));
eval(sprintf('load %s/glm_convergence/glm_conv.mat', BD.Cell_Selection));


glmscores = allcells;



for i_exp = 1:4
    
    glmscores{i_exp}.WNBPS_ONP = (glm_conv{i_exp}.scores.stim_type{1}.celltype{1}.normedbps(:,end))';
    glmscores{i_exp}.NSEMBPS_ONP = (glm_conv{i_exp}.scores.stim_type{2}.celltype{1}.normedbps(:,end))';
    glmscores{i_exp}.WNBPS_OFFP = (glm_conv{i_exp}.scores.stim_type{1}.celltype{2}.normedbps(:,end))';
    glmscores{i_exp}.NSEMBPS_OFFP = (glm_conv{i_exp}.scores.stim_type{2}.celltype{2}.normedbps(:,end))';

end

eval(sprintf('save %s/allglmscores.mat glmscores', BD.Cell_Selection))

%% DO NOT NEED THIS
%{
figure;
clf;
subplot(5,1,1);
MS = 10;
axis off
c = 0;
text(-.1, 1,sprintf('Xaxis: WN Normed BPS values,  Yaxis: NSEM Normed BPS,   ALL CELLS   NO SMOOTHING' ));
%c=c+1; text(-.1, 1-0.1*c,sprintf('Fit Type: %s', GLMType_Base.fitname),'interpreter','none');
c=c+1; text(-.1, 1-0.1*c,'Color are experiments, dots ONP, asterisk OFFP');
c=c+1; text(-.1, 1-0.1*c,'0 value means worse than steady firing rate,1 means unconditioned optimum');
for i_exp = 1:4
    
    if i_exp == 1; basecolor = 'r'; end
    if i_exp == 2; basecolor = 'g'; end
    if i_exp == 3; basecolor = 'b'; end
    if i_exp == 4; basecolor = 'c'; end
    
    for i_type = 1:2
        if i_type == 1, WNvals = glmscores{i_exp}.WNBPS_ONP;  NSEMvals = glmscores{i_exp}.NSEMBPS_ONP; marktype  = '.'; end
        if i_type == 2, WNvals = glmscores{i_exp}.WNBPS_OFFP;  NSEMvals = glmscores{i_exp}.NSEMBPS_OFFP;marktype = '*'; end
        
        subplot(5,2, (i_exp*2 + i_type))
        hold on;
        WNvals( WNvals <=0) = 0;
        NSEMvals( NSEMvals <=0) = 0;
        
        max_x = max(1, max(WNvals));
        max_y = max(1, max(NSEMvals));
        max_val = max(max_x,max_y);
        
        set(gca,'xlim',[0 max_x]); set(gca,'ylim',[0 max_y]);
        
        
        plotstring = sprintf('%s%s',basecolor,marktype);
        plot(WNvals, NSEMvals, plotstring,'markersize',MS);
        plot(linspace(0,1,100), linspace(0,1,100), 'k')
    end
end

orient tall
eval(sprintf('print -dpdf %s/WN_V_NSEM_ALLCELLS.pdf', BD.Cell_Selection))
%}