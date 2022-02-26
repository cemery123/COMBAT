classdef mcmc < emi.livedecs.AddActionSubSystem
    %ADDACTIONSUBSYSTEM An Action Subsystem which will always trigger error
    %   Useful if this subsystem would never be selected, e.g. can be
    %   connected to always-false outcome
    
    properties
        
    end
    
    methods
        function obj = mcmc(varargin)
            %ADDACTIONSUBSYSTEM Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@emi.livedecs.AddActionSubSystem(varargin{:});
            
        end
        
        function configure(obj, varargin)
            obj.empty_me(varargin{:});
            obj.add_in_registry();
            typeList = obj.r.sample_live_blocks_TypeList();
            List_mcmc = typeList.blocktype;

            for i = 1:size(List_mcmc)
                 if strcmp(List_mcmc(i),'SubSystem')||strcmp(List_mcmc(i),'Delay')||strcmp(List_mcmc(i),'If')
                     List_mcmc(i)={1};
                 end
            end
            List_mcmc = List_mcmc(cellfun(@(p)~isequal(p,1),List_mcmc));
            if size(List_mcmc) == 0
                obj.l.warn('No mcmc module is available. Consider using a predetermined value')
                string=["simulink/Commonly Used Blocks/Gain",....
                "simulink/Math Operations/Math Function","simulink/Math Operations/Trigonometric Function","simulink/Math Operations/Abs",....
                 "simulink/Math Operations/MinMax"];
                  i = ceil(10*rand()/2);
                  p = ceil(10*rand()/2);
                  m = ceil(10*rand()/2);
                  A = string(i);
                  B = string(p);
                  C = string(m);
            else
                obj.l.info('--------------------------------MCMC--------------------------------')
                %% Define probability use acceptance probability judgment
                List_mcmc_new = List_mcmc;
                for i = 1:size(List_mcmc_new)
                    for j = i+1:size(List_mcmc_new)
                         if ~strcmp(List_mcmc_new(i),List_mcmc_new(j))
                         else
                             List_mcmc_new(i) = {1};
                         end
                    end
                end
                List_mcmc_new = List_mcmc_new(cellfun(@(p)~isequal(p,1),List_mcmc_new));
                m = size(List_mcmc_new,1);
                P = ones(m);%Create probability matrix
                p = 0;
                for i = 1:size(List_mcmc)
                    for j = i+1:size(List_mcmc)-1
                        if strcmp(List_mcmc(i),List_mcmc(j))
                            p=p+1;
                            P(i,j) = p/m; 
                        end
                    end
                end
                %An acceptance probability
                k = 0;
                for i = 1:m
                    a = P(:,1)./P(1,:);
                    for j = size(a)
                        if a(j)>=1
                            k=k+1;
                        end
                    end
                end
                List_mcmc_accepted = {};
                for i = 1:m
                    a = P(:,1)./P(1,:);
                    for j = size(a)
                        if a(j)>=1
                            obj.l.info('-----Accept one as MCMC subsysterm----');
                            List_mcmc_accepted{i} = List_mcmc_new{i};
                        end
                    end
                end
                if size(List_mcmc_accepted)<3
                    obj.l.info('-----The number of MCMC systems is insufficient to take the predetermined value----')
                    string=["simulink/Commonly Used Blocks/Gain",....
                "simulink/Math Operations/Math Function","simulink/Math Operations/Trigonometric Function","simulink/Math Operations/Abs",....
                 "simulink/Math Operations/MinMax"];
                  i = ceil(10*rand()/2);
                  p = ceil(10*rand()/2);
                  m = ceil(10*rand()/2);
                  A = string(i);
                  B = string(p);
                  C = string(m); 
                else
                    obj.l.info('----insert MCMC subsystrem begining----');
                    model = load('model.mat');
                    for i=1:size(List_mcmc_accepted,2)
                       Index = ismember(model.model1(:,2),List_mcmc_accepted{i});
                       Index = bin2dec(num2str(Index));
                       a=0;
                       for j =1:size(Index)
                         if Index(j) == 1
                           obj.l.info('right')
                           a = j;
                         end
                        List_mcmc_accepted{i} = model.model1{j};
                        break
                       end
                    end
                  A = convertCharsToStrings(List_mcmc_accepted{1});
                  B = convertCharsToStrings(List_mcmc_accepted{2});
                  C = convertCharsToStrings(List_mcmc_accepted{3});
                end
           %[new_blksink,new_blk1_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], 'simulink/Sources/Ground');
           %[new_blksource,new_Asserion_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], 'simulink/Sinks/Terminator');
           %[new_blk3,new_blk_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], C);
           [new_blk1,new_blk1_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], A);
           [new_blk2,~]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], B);
           [new_blk3,new_blk_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], C);
           sample_time = cell2mat(obj.hobj.if_cond_gen_blk(2));
           %set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blksink],'SampleTime',sample_time);
           %set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blksource],'SampleTime',sample_time);
           %set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk3],'SampleTime',sample_time);
           try
               set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk1],'SampleTime',sample_time);
           catch
               obj.l.info('----warning:block does not have a parameter named SampleTime,Adopt a predetermined value strategy----');
               delete_block([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk1]);
               string=["simulink/Commonly Used Blocks/Gain",....
                "simulink/Math Operations/Math Function","simulink/Math Operations/Trigonometric Function","simulink/Math Operations/Abs",....
                 "simulink/Math Operations/MinMax"];
                i = ceil(10*rand()/2);
                A = string(i);
                obj.l.info('-----------------------Re-add block--------------------');
               [new_blk1,new_blk1_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], A);
               set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk1],'SampleTime',sample_time);
           end
           try
               set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk2],'SampleTime',sample_time);
           catch
               obj.l.info('----warning:block does not have a parameter named SampleTime,Adopt a predetermined value strategy----');
               delete_block([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk2]);
               string=["simulink/Commonly Used Blocks/Gain",....
                "simulink/Math Operations/Math Function","simulink/Math Operations/Trigonometric Function","simulink/Math Operations/Abs",....
                 "simulink/Math Operations/MinMax"];
                i = ceil(10*rand()/2);
                A = string(i);
                obj.l.info('-----------------------Re-add block--------------------');
               [new_blk2,new_blk2_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], A);
               set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk2],'SampleTime',sample_time);
           end
           try
               set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk3],'SampleTime',sample_time); 
           catch
               obj.l.info('----warning:block does not have a parameter named SampleTime,Adopt a predetermined value strategy----');
                delete_block([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk3]);
               string=["simulink/Commonly Used Blocks/Gain",....
                "simulink/Math Operations/Math Function","simulink/Math Operations/Trigonometric Function","simulink/Math Operations/Abs",....
                 "simulink/Math Operations/MinMax"];
                i = ceil(10*rand()/2);
                A = string(i);
                obj.l.info('-----------------------Re-add block--------------------');
               [new_blk3,new_blk3_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], A); 
               set_param([obj.hobj.parent '/' obj.hobj.new_ss '/' new_blk3],'SampleTime',sample_time);
           end
           [suorce,suorce_h] = obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], "simulink/Sources/In1");
%            source = add_block('simulink/Ports & Subsystems/Inport',[obj.hobj.parent '/' obj.hobj.new_ss '/In1']);
%            out = add_block('simulink/Ports & Subsystems/If Action Subsystem',[obj.hobj.parent '/' obj.hobj.new_ss '/out1']);
           [out,out_h] = obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], "simulink/Sinks/Out1");
           %add_line(obj.hobj.parent,'simulink/Commonly Used Blocks/Integrator', 'simulink/Model Verification/Assertion');
           %obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss], new_blksource, 1, new_blk1_h, 1);
           obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss],suorce, 1, new_blk1, 1);
           obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss], new_blk1, 1, new_blk2, 1);
           obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss], new_blk2, 1, new_blk3, 1);
%            obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss], new_blk3, 1, out, 1);
           %obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss], new_blk3, 1, new_blksink, 1);
           %% mcmcrand
%            model1 = load('model_math.mat');
%            model_mcmc = model1.modelmath;
%            model_mcmc_add = {};
%            mcmcsize = ceil(40*rand());
%            for i = 1:mcmcsize
%                model_mcmc_add{i,1} = obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], convertCharsToStrings(model_mcmc{ceil(11*rand())}));
%            end
%            for j = 1:mcmcsize-1
%                obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss], model_mcmc_add{j}, 1, model_mcmc_add{j+1}, 1);
%            end
%            mcmc_suorce = obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], "simulink/Sources/Ground");
%            obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss],mcmc_suorce, 1, model_mcmc_add{1}, 1);
%            obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss], model_mcmc_add{mcmcsize}, 1, out, 1);
            end
            %% mcmc conn
            rec = emi.livedecs.mcmc_conn(obj);
            if rec
                obj.l.info('right');
            else
                obj.l.info('error');
            end
            %% mutant
            if size(obj.r.live_blocks, 1) == 0
                    obj.l.warn('No live blocks in the original model! Returning from Decorator.');
            
            end

        end
        

    end
end