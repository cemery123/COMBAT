classdef AddActionSubSystemAssertError < emi.livedecs.AddActionSubSystem
    %ADDACTIONSUBSYSTEM An Action Subsystem which will always trigger error
    %   Useful if this subsystem would never be selected, e.g. can be
    %   connected to always-false outcome
    
    properties
        
    end
    
    methods
        function obj = AddActionSubSystemAssertError(varargin)
            %ADDACTIONSUBSYSTEM Construct an instance of this class
            %   Detailed explanation goes here
            obj = obj@emi.livedecs.AddActionSubSystem(varargin{:});
            
        end
        
        function configure(obj, varargin)
            obj.empty_me(varargin{:});
            obj.add_in_registry();
            
            % Add Error assertion 
           %[new_blk1,new_blk1_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], 'simulink/Commonly Used Blocks/Integrator');
           [new_Asserion,new_Asserion_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], 'simulink/Model Verification/Assertion');
           %[new_blk,new_blk_h]=obj.mutant.add_new_block_in_model([obj.hobj.parent '/' obj.hobj.new_ss], 'simulink/Model Verification/Check Discrete Gradient');
            %add_line(obj.hobj.parent,'simulink/Commonly Used Blocks/Integrator', 'simulink/Model Verification/Assertion');
            obj.mutant.add_conn([obj.hobj.parent '/' obj.hobj.new_ss], new_blk1, 1, new_Asserion, 1);
        end
        

    end
end

