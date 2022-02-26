modelsPath = 'E:\slemi\slemi-master\reproduce\samplecorpus';
fileFolder=fullfile(modelsPath);
dirOutput=dir(fullfile(fileFolder,'*.slx'));
fileNames={dirOutput.name};

for i =1: numel(fileNames)
    res  = load('compare.mat');
    compare_info = res.compare_info;
    fprintf('start to compare %d files in%d\n',i,numel(fileNames));
    newmodelsPath = 'E:\slemi\slemi-master\emi_results';
    newfileFolder=fullfile(newmodelsPath);
    file = split(fileNames{i},'.');
    file = ['**/' file{1} '_pp*difftest.slx'];
    newdirOutput=dir(fullfile(newfileFolder,file));
    newfileNames={newdirOutput.name};
    global c;
    c= 0;
    for j = 1:numel(newfileNames)
        fprintf('file is %d name is %s,rate of process is %d \n',j,newfileNames{j},i/numel(fileNames))
        fprintf('start compare /n')
        for k = j:numel(newfileNames)-1
            c=c+1;
            data = ch_model_ifsame(newfileNames{j},newfileNames{k+1});
            compare_info{i,c} = data;
        end
    end
    save('compare.mat','compare_info')
end