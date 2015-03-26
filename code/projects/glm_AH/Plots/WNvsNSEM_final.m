

BD = NSEM_BaseDirectories;
runoverexisting  = true;
shortlist = false;


reverseorder = false;


if exist('changes_cell', 'var')
    GLMType = GLM_settings('default',changes_cell);
else
    GLMType = GLM_settings('default');
end

GLMType.fitname    = GLM_fitname(GLMType); 
GLMType.func_sname = 'glmwrap';
GLMType.fullmfilename =mfilename('fullpath'); 
eval(sprintf('load %s/allcells.mat', BD.Cell_Selection)); 
i_exp = 1; i_cell = 1;
troubleshoot.doit    = true;


%%
for i_exp = exps
    for i_stimtype = stimtypes 
        for i_celltype = celltypes
            %% Cells / Directories / Parameters
            
            % DEFINE GLMTYPE 
            if i_stimtype == 1, stimtype = 'WN';   end
            if i_stimtype == 2, stimtype = 'NSEM'; end
            GLMType.fit_type = stimtype;
             
            
            % LOAD CELLS AND EXP DEPENDENT VARIABLES
            if i_celltype == 1; cellgroup = allcells{i_exp}.ONP;  celltype = 'ONPar'; end
            if i_celltype == 2; cellgroup = allcells{i_exp}.OFFP; celltype = 'OFFPar'; end
            exp_nm  = allcells{i_exp}.exp_nm;
            expname = allcells{i_exp}.expname;
            [StimulusPars Dirs datarun_slv datarun_mas] = Directories_Params_v23(exp_nm, GLMType.fit_type, GLMType.map_type);
            if GLMType.debug
                StimulusPars.slv.FitBlocks = StimulusPars.slv.FitBlocks(1:2);
            end

    