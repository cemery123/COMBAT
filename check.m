modelsPath = 'E:\slemi\slemi-master\emi_results';
fileFolder=fullfile(modelsPath);
dirOutput=dir(fullfile(fileFolder,'**/*difftest.slx'));
fileNames={dirOutput.name};
for i = 1:numel(fileNames)
    %numel(fileNames)
    disp('start')
   res3 = load('xinxi.mat');
    xinxi = res3.xinxi;
    %% 开始编译执行
    model =  fileNames{i};
    fprintf('start to compile %s\n',fileNames{i});
    p = i/numel(fileNames);
    fprintf('process is %d in %d files\n',i,numel(fileNames))
    fprintf('compile in %d\n',p*100)
    %% 标注信号
    load_system(model);
    sys_pr = strsplit(model,'.');
    sys = sys_pr{1};
    BlockPaths = find_system(sys,'Type','Block');
    BlockTypes = get_param(BlockPaths,'BlockType');
    %得到连线信息
    L = find_system(sys,'FindAll','on','type','line');
    line_value = numel(L);
    block_num = numel(BlockTypes);
    xinxi{i,1} = block_num;
    xinxi{i,2} = line_value;
    if_blk = find_system(sys,'BlockType','If');
    if_num = numel(if_blk);
    xinxi{i,5} = if_num;
%     for j = 1:numel(BlockPaths)
%         BlockPaths{j} = tmp;
%         temp = split(BlockPaths,'/');
% 
%     end
    close_system(sys)
   model_orpath  = 'E:\slemi\slemi-master\reproduce\samplecorpus';
   name =  split(fileNames{i},'_');
   model_name = name{1};
   model_orpath_final = [model_orpath '\' model_name '.slx'];
    model_sys = model_name;
    load_system(model_orpath_final)
    orBlockpaths = find_system(model_sys,'Type','Block');
    original_line = find_system(model_sys,'FindAll','on','type','line');
    original_line_value = numel(original_line);
    close_system(model_sys)
   add_bloks = block_num-numel(orBlockpaths);
   add_line = line_value-original_line_value;
   xinxi{i,3} = add_bloks;
   xinxi{i,4} = add_line;
    fprintf('close system success\n')
    save('xinxi.mat','xinxi');
    fprintf('SLBUG save success in %s',model_name)
end