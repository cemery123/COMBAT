function ret = check_SLforge(~, ~, ret)

if ~ ret.compiles || ret.exception
    return;
end

ret.peprocess_skipped = false;

X=string;
NUM_CONS=0;
%global NUM_CONS;
function x = get_nonempty(x)
                x = x(rowfun(@(p) ~isempty(p) , x,...
                    'InputVariables', {'percentcov'}, 'ExtractCellContents', true,...
                'OutputFormat', 'uniform'), :);
            end
            
            function x = remove_model_names(x)
                % remove model name from the blocks
                x(:, 'fullname') = cellfun(@(p) utility.strip_first_split(...
                    p, '/', '/') ,x{:, 'fullname'}, 'UniformOutput', false);
            end

model_data = struct2table(ret, 'AsArray', true);
 blocks = struct2table(model_data.blocks);
 blocks = get_nonempty(blocks);
 blocks = remove_model_names(blocks);
 A = blocks{:,'percentcov'};
 tf = iscell(A);
 if tf == false
%     NUM_CONS=length(X);
     B = cell2mat(model_data.sys); 
     filename="E:\slemi\slemi-master\reproduce\samplecorpus\"+B+".slx";
     delete (filename);
%     NUM_CONS=NUM_CONS+1;
%     X(NUM_CONS)=B;
   
%     save('test.mat','X');
%     save('test1.mat','NUM_CONS');
     disp("warning");
 else
     disp('right');
 end
end