close all
load area.mat
[match] = get_cell_type_index(22)


[~, txt,array_size] = xlsread('/Volumes/Lab/Users/crhoades/Large Cell Data ARVO.xlsx');
array_size = cell2mat(array_size(:,4));
% txt = {'
% };

%     [rf, t_zc, t_p, t_t, bi_ind, fr, amp] = get_timecourse_prop(datarun, cell_id, run_opts)

%% ON smooth
% 
% pieces = [1, 4 5 6 7 15 16 19 20 21]
% 
% for j= 1:length(pieces)
%     % piece = txt(j,1:3);
%     run_opts.date=strtrim(txt{pieces(j),1}); % one slash at the end
%     temp1 = strtrim(txt{pieces(j),2});
%     temp2 =  strtrim(txt{pieces(j),3});
%     run_opts.concatname=temp1; % Name (or modified name) of run, no slashes\
%     run_opts.dataname = temp2;
%     run_opts.file_name = [run_opts.date, '/', run_opts.concatname, '/',run_opts.dataname, '/',run_opts.dataname];
%    
%     run_opts.save_location_root = '/Volumes/Lab/Users/crhoades/Cell Properties/';
%     run_opts.filepath= [run_opts.save_location_root, run_opts.date, '/', run_opts.concatname, '/', run_opts.dataname];
%     
%     output_large= load([run_opts.filepath, '/' 'ON large 1','/output.mat']);
%         output_parasol= load([run_opts.filepath, '/' 'ON parasol','/output.mat']);
%         output_midget= load([run_opts.filepath, '/' 'ON midget','/output.mat']);
% 
%     parameters_large{pieces(j)}  =output_large.output.parameters;
%         parameters_parasol{pieces(j)}  =output_parasol.output.parameters
%         parameters_midget{pieces(j)}  =output_midget.output.parameters
% 
%         tc_nan_large = ~isnan(parameters_large{pieces(j)}.t_zc);
%                 tc_nan_parasol = ~isnan(parameters_parasol{pieces(j)}.t_zc);
%                                 tc_nan_midget = ~isnan(parameters_midget{pieces(j)}.t_zc);
% 
%                     bi_ind_nan_large = ~isnan(parameters_large{pieces(j)}.bi_ind);
%                 bi_ind_nan_parasol = ~isnan(parameters_parasol{pieces(j)}.bi_ind);
%                                 bi_ind_nan_midget = ~isnan(parameters_midget{pieces(j)}.bi_ind);
% 
%     t_zc_large(j) = mean(parameters_large{pieces(j)}.t_zc(tc_nan_large));
%     bi_ind_large(j) = mean(parameters_large{pieces(j)}.bi_ind(bi_ind_nan_large));
%     bi_ind_midget(j) = mean(parameters_midget{pieces(j)}.bi_ind(bi_ind_nan_midget));
% 
%         t_zc_midget(j) = mean(parameters_midget{pieces(j)}.t_zc(tc_nan_midget));
% 
%         
%     t_zc_parasol(j) = mean(parameters_parasol{pieces(j)}.t_zc(tc_nan_parasol));
%     bi_ind_parasol(j) = mean(parameters_parasol{pieces(j)}.bi_ind(bi_ind_nan_parasol));
% 
%     
%     on_parasol_rf(j) = mean(area{pieces(j)}{match(pieces(j),1)});
%     
%     large_on_rf(j) = mean(area{pieces(j)}{match(pieces(j),5)});
%         midget_on_rf(j) = mean(area{pieces(j)}{match(pieces(j),3)});
% 
% end
% 
% rf_on_ratio = large_on_rf./on_parasol_rf;
% rf_on_ratio2 = midget_on_rf./on_parasol_rf;
% 
% b= figure; 
% [nb,xb] = hist(t_zc_parasol);
% bh= bar(xb,nb);
% set(bh, 'facecolor', [1 0 1])
% 
% f = figure; 
% [nb,xb] = hist(rf_on_ratio);
% bh= bar(xb,nb);
% set(bh, 'facecolor', [1 1 0])
% [nb,xb] = hist(rf_on_ratio2);
% hold on
% bh2= bar(xb,nb);
% set(bh2, 'facecolor', [1 0 0])
% 
% g = figure;
% [nb,xb] =hist(t_zc_large./t_zc_parasol);
% bh= bar(xb,nb);
% set(bh, 'facecolor', [1 1 0])
% [nb,xb] = hist(t_zc_midget./t_zc_parasol);
% hold on
% bh2= bar(xb,nb);
% set(bh2, 'facecolor', [1 0 0])
% 
% a = figure;
% [nb,xb] = hist(bi_ind_large./bi_ind_parasol);
% bh= bar(xb,nb);
% set(bh, 'facecolor', [1 1 0])
% [nb,xb] = hist(bi_ind_midget./bi_ind_parasol);
% hold on
% bh2= bar(xb,nb);
% set(bh2, 'facecolor', [1 0 0])
% 
% 
% clear on_parasol_rf
% clear parameters
% clear t_zc_large
% clear t_zc_parasol
% clear t_zc_midget
% 
% clear bi_ind_large
% clear bi_ind_parasol
% clear bi_ind_midget
% %% OFF smooth
% pieces = [4 10 13 15 17 19 ];
% % pieces = [9];
% 
% for j= 1:length(pieces)
%     % piece = txt(j,1:3);
%     run_opts.date=strtrim(txt{pieces(j),1}); % one slash at the end
%     temp1 = strtrim(txt{pieces(j),2});
%     temp2 =  strtrim(txt{pieces(j),3});
%     run_opts.concatname=temp1; % Name (or modified name) of run, no slashes\
%     run_opts.dataname = temp2;
%     run_opts.file_name = [run_opts.date, '/', run_opts.concatname, '/',run_opts.dataname, '/',run_opts.dataname];
%    
%     run_opts.save_location_root = '/Volumes/Lab/Users/crhoades/Cell Properties/';
%     run_opts.filepath= [run_opts.save_location_root, run_opts.date, '/', run_opts.concatname, '/', run_opts.dataname];
%     
%     output_large = load([run_opts.filepath, '/' 'OFF large 1','/output.mat'])
% 
%             output_parasol= load([run_opts.filepath, '/' 'OFF parasol','/output.mat']);
%             output_midget= load([run_opts.filepath, '/' 'OFF midget','/output.mat']);
% 
%     parameters_large{pieces(j)}  =output_large.output.parameters;
%         parameters_parasol{pieces(j)}  =output_parasol.output.parameters;
%         parameters_midget{pieces(j)}  =output_midget.output.parameters;
% 
%         tc_nan_large = ~isnan(parameters_large{pieces(j)}.t_zc);
%                 tc_nan_parasol = ~isnan(parameters_parasol{pieces(j)}.t_zc);
%                 tc_nan_midget = ~isnan(parameters_midget{pieces(j)}.t_zc);
% 
%                     bi_ind_nan_large = ~isnan(parameters_large{pieces(j)}.bi_ind);
%                 bi_ind_nan_parasol = ~isnan(parameters_parasol{pieces(j)}.bi_ind);
%                                 bi_ind_nan_midget = ~isnan(parameters_midget{pieces(j)}.bi_ind);
% 
%     t_zc_large(j) = mean(parameters_large{pieces(j)}.t_zc(tc_nan_large));
%     bi_ind_large(j) = mean(parameters_large{pieces(j)}.bi_ind(bi_ind_nan_large));
% 
%         t_zc_midget(j) = mean(parameters_midget{pieces(j)}.t_zc(tc_nan_midget));
%     bi_ind_midget(j) = mean(parameters_midget{pieces(j)}.bi_ind(bi_ind_nan_midget));
% 
%     
%     t_zc_parasol(j) = mean(parameters_parasol{pieces(j)}.t_zc(tc_nan_parasol));
%     bi_ind_parasol(j) = mean(parameters_parasol{pieces(j)}.bi_ind(bi_ind_nan_parasol));
%     
%     off_parasol_rf(j) = mean(area{pieces(j)}{match(pieces(j),2)});
%     
%     large_off_rf(j) = mean(area{pieces(j)}{match(pieces(j),7)});
%     midget_off_rf(j) = mean(area{pieces(j)}{match(pieces(j),4)});
% 
% 
% end
% 
% rf_off_ratio = large_off_rf./off_parasol_rf;
% rf_off_ratio2 = midget_off_rf./off_parasol_rf;
% 
% figure(b);
% hold on
% [nb,xb] = hist(t_zc_parasol);
% bh= bar(xb,nb);
% set(bh, 'facecolor', [0 1 1])
% 
% title('zc parasol')
% legend('ON parasol','OFF parasol')
% 
% figure(f);
% hold on
% [nb,xb] = hist(rf_off_ratio);
% bh= bar(xb,nb);
% set(bh, 'facecolor', [0 1 0])
% 
% [nb,xb] = hist(rf_off_ratio2);
% hold on
% bh2= bar(xb,nb);
% set(bh2, 'facecolor', [0 0 1])
% 
% 
% title('rf')
% legend('ON large','ON midget', 'OFF large', 'OFF midget')
% 
% figure(g);
% hold on
% [nb,xb] =hist(t_zc_large./t_zc_parasol);
% bh= bar(xb,nb);
% set(bh, 'facecolor', [0 1 0])
% 
% [nb,xb] = hist(t_zc_midget./t_zc_parasol);
% hold on
% bh2= bar(xb,nb);
% set(bh2, 'facecolor', [0 0 1])
% title('tzc')
% legend('ON large','ON midget', 'OFF large', 'OFF midget')
% 
% figure(a);
% hold on
% [nb,xb] =  hist(bi_ind_large./bi_ind_parasol);
% bh= bar(xb,nb);
% set(bh, 'facecolor', [0 1 0])
% 
% [nb,xb] =  hist(bi_ind_midget./bi_ind_parasol);
% hold on
% bh2= bar(xb,nb);
% set(bh2, 'facecolor', [0 0 1])
% title('bi_ind')
% 
% legend('ON large','ON midget', 'OFF large', 'OFF midget')
% 
% 
% clear on_parasol_rf
% clear parameters
% clear t_zc_large
% clear t_zc_parasol
% clear t_zc_midget
% 
% clear bi_ind_large
% clear bi_ind_parasol
% clear bi_ind_midget
%% compare pieces directly

pieces = [4 5 6 16 20]

for j= 1:length(pieces)
    % piece = txt(j,1:3);
    run_opts.date=strtrim(txt{pieces(j),1}); % one slash at the end
    temp1 = strtrim(txt{pieces(j),2});
    temp2 =  strtrim(txt{pieces(j),3});
    run_opts.concatname=temp1; % Name (or modified name) of run, no slashes\
    run_opts.dataname = temp2;
    run_opts.file_name = [run_opts.date, '/', run_opts.concatname, '/',run_opts.dataname, '/',run_opts.dataname];
   
    run_opts.save_location_root = '/Volumes/Lab/Users/crhoades/Cell Properties/';
    run_opts.filepath= [run_opts.save_location_root, run_opts.date, '/', run_opts.concatname, '/', run_opts.dataname];
    
    output_large= load([run_opts.filepath, '/' 'ON large 1','/output.mat']);
        output_parasol= load([run_opts.filepath, '/' 'ON parasol','/output.mat']);
        output_midget= load([run_opts.filepath, '/' 'ON midget','/output.mat']);

    parameters_large{pieces(j)}  =output_large.output.parameters;
        parameters_parasol{pieces(j)}  =output_parasol.output.parameters
        parameters_midget{pieces(j)}  =output_midget.output.parameters

        tc_nan_large = ~isnan(parameters_large{pieces(j)}.t_zc);
                tc_nan_parasol = ~isnan(parameters_parasol{pieces(j)}.t_zc);
                                tc_nan_midget = ~isnan(parameters_midget{pieces(j)}.t_zc);

                    bi_ind_nan_large = ~isnan(parameters_large{pieces(j)}.bi_ind);
                bi_ind_nan_parasol = ~isnan(parameters_parasol{pieces(j)}.bi_ind);
                                bi_ind_nan_midget = ~isnan(parameters_midget{pieces(j)}.bi_ind);

    t_zc_large(j) = mean(parameters_large{pieces(j)}.t_zc(tc_nan_large));
    bi_ind_large(j) = mean(parameters_large{pieces(j)}.bi_ind(bi_ind_nan_large));
    bi_ind_midget(j) = mean(parameters_midget{pieces(j)}.bi_ind(bi_ind_nan_midget));

        t_zc_midget(j) = mean(parameters_midget{pieces(j)}.t_zc(tc_nan_midget));

        
    t_zc_parasol(j) = mean(parameters_parasol{pieces(j)}.t_zc(tc_nan_parasol));
    bi_ind_parasol(j) = mean(parameters_parasol{pieces(j)}.bi_ind(bi_ind_nan_parasol));

    
    parasol_rf(j) = mean(area{pieces(j)}{match(pieces(j),1)});
    
    large_rf(j) = mean(area{pieces(j)}{match(pieces(j),5)});
        midget_rf(j) = mean(area{pieces(j)}{match(pieces(j),3)});

end


% rf_on_ratio = large_on_rf./on_parasol_rf;
% rf_on_ratio2 = midget_on_rf./on_parasol_rf;


% 
% % clear on_parasol_rf
% clear parameters
% clear t_zc_large
% clear t_zc_parasol
% clear t_zc_midget
% 
% clear bi_ind_large
% clear bi_ind_parasol
% clear bi_ind_midget

% Compare directly with OFF smooth
pieces = [4 5 6 16 20]
% pieces = [9];

for j= 1:length(pieces)
    % piece = txt(j,1:3);
    run_opts.date=strtrim(txt{pieces(j),1}); % one slash at the end
    temp1 = strtrim(txt{pieces(j),2});
    temp2 =  strtrim(txt{pieces(j),3});
    run_opts.concatname=temp1; % Name (or modified name) of run, no slashes\
    run_opts.dataname = temp2;
    run_opts.file_name = [run_opts.date, '/', run_opts.concatname, '/',run_opts.dataname, '/',run_opts.dataname];
   
    run_opts.save_location_root = '/Volumes/Lab/Users/crhoades/Cell Properties/';
    run_opts.filepath= [run_opts.save_location_root, run_opts.date, '/', run_opts.concatname, '/', run_opts.dataname];
    
    output_large = load([run_opts.filepath, '/' 'OFF large 1','/output.mat'])

            output_parasol= load([run_opts.filepath, '/' 'OFF parasol','/output.mat']);
            output_midget= load([run_opts.filepath, '/' 'OFF midget','/output.mat']);

    parameters_large{pieces(j)}  =output_large.output.parameters;
        parameters_parasol{pieces(j)}  =output_parasol.output.parameters;
        parameters_midget{pieces(j)}  =output_midget.output.parameters;

        tc_nan_large = ~isnan(parameters_large{pieces(j)}.t_zc);
                tc_nan_parasol = ~isnan(parameters_parasol{pieces(j)}.t_zc);
                tc_nan_midget = ~isnan(parameters_midget{pieces(j)}.t_zc);

                    bi_ind_nan_large = ~isnan(parameters_large{pieces(j)}.bi_ind);
                bi_ind_nan_parasol = ~isnan(parameters_parasol{pieces(j)}.bi_ind);
                                bi_ind_nan_midget = ~isnan(parameters_midget{pieces(j)}.bi_ind);

    t_zc_large(2,j) = mean(parameters_large{pieces(j)}.t_zc(tc_nan_large));
    bi_ind_large(2,j) = mean(parameters_large{pieces(j)}.bi_ind(bi_ind_nan_large));

        t_zc_midget(2,j) = mean(parameters_midget{pieces(j)}.t_zc(tc_nan_midget));
    bi_ind_midget(2,j) = mean(parameters_midget{pieces(j)}.bi_ind(bi_ind_nan_midget));

    
    t_zc_parasol(2,j) = mean(parameters_parasol{pieces(j)}.t_zc(tc_nan_parasol));
    bi_ind_parasol(2,j) = mean(parameters_parasol{pieces(j)}.bi_ind(bi_ind_nan_parasol));
    
    parasol_rf(2,j) = mean(area{pieces(j)}{match(pieces(j),2)});
    
    large_rf(2,j) = mean(area{pieces(j)}{match(pieces(j),7)});
    midget_rf(2,j) = mean(area{pieces(j)}{match(pieces(j),4)});


end

t_zc_large = [t_zc_large(:, 1:2) t_zc_large(:, 4:5)];
t_zc_parasol = [t_zc_parasol(:, 1), t_zc_parasol(:, 3:5)];
t_zc_midget = [t_zc_midget(:, 1), t_zc_midget(:, 3:5)];

bi_ind_midget = [bi_ind_midget(:,1), bi_ind_midget(:,3:5)];
bi_ind_parasol = [bi_ind_parasol(:,1), bi_ind_parasol(:,3:5)];
bi_ind_large = [bi_ind_large(:,2), bi_ind_large(:,4:5)];



large_rf = [large_rf(:,1:2), large_rf(:,4:end)];
parasol_rf = [parasol_rf(:,1), parasol_rf(:,3:end)];
midget_rf = [midget_rf(:,1), midget_rf(:,3:end)];


figure;
subplot(1,3,1)
plot(large_rf, 'o-')
set(gca, 'xtick', [0 1,2 3])
set(gca, 'xticklabel', {'','ON smooth', 'OFF smooth',''})
set(gca, 'xlim', [0.5 2.5])
title('RF Size')

subplot(1,3,2)
plot(parasol_rf, 'o-')
set(gca, 'xtick', [0 1,2 3])
set(gca, 'xticklabel', {'','ON parasol', 'OFF parasol',''})
set(gca, 'xlim', [0.5 2.5])
title('RF Size')

subplot(1,3,3)
plot(midget_rf, 'o-')
set(gca, 'xtick', [0 1,2 3])
set(gca, 'xticklabel', {'','ON midget', 'OFF midget',''})
set(gca, 'xlim', [0.5 2.5])
title('RF Size')


figure;
subplot(1,3,1)
plot(t_zc_large, 'o-')
set(gca, 'xtick', [0 1,2 3])
set(gca, 'xticklabel', {'','ON smooth', 'OFF smooth',''})
set(gca, 'xlim', [0.5 2.5])
title('ZC')

subplot(1,3,2)
plot(t_zc_parasol, 'o-')
set(gca, 'xtick', [0 1,2 3])
set(gca, 'xticklabel', {'','ON parasol', 'OFF parasol',''})
set(gca, 'xlim', [0.5 2.5])
title('ZC')

subplot(1,3,3)
plot(t_zc_midget, 'o-')
set(gca, 'xtick', [0 1,2 3])
set(gca, 'xticklabel', {'','ON midget', 'OFF midget',''})
set(gca, 'xlim', [0.5 2.5])
title('ZC')



% rf_off_ratio = large_off_rf./off_parasol_rf;
% rf_off_ratio2 = midget_off_rf./off_parasol_rf;

figure(b);
hold on
[nb,xb] = hist(t_zc_parasol);
bh= bar(xb,nb);
set(bh, 'facecolor', [0 1 1])

title('zc parasol')
legend('ON parasol','OFF parasol')

figure(f);
hold on
[nb,xb] = hist(rf_off_ratio);
bh= bar(xb,nb);
set(bh, 'facecolor', [0 1 0])

[nb,xb] = hist(rf_off_ratio2);
hold on
bh2= bar(xb,nb);
set(bh2, 'facecolor', [0 0 1])


title('rf')
legend('ON large','ON midget', 'OFF large', 'OFF midget')

figure(g);
hold on
[nb,xb] =hist(t_zc_large./t_zc_parasol);
bh= bar(xb,nb);
set(bh, 'facecolor', [0 1 0])

[nb,xb] = hist(t_zc_midget./t_zc_parasol);
hold on
bh2= bar(xb,nb);
set(bh2, 'facecolor', [0 0 1])
title('tzc')
legend('ON large','ON midget', 'OFF large', 'OFF midget')

figure(a);
hold on
[nb,xb] =  hist(bi_ind_large./bi_ind_parasol);
bh= bar(xb,nb);
set(bh, 'facecolor', [0 1 0])

[nb,xb] =  hist(bi_ind_midget./bi_ind_parasol);
hold on
bh2= bar(xb,nb);
set(bh2, 'facecolor', [0 0 1])
title('bi_ind')

legend('ON large','ON midget', 'OFF large', 'OFF midget')
