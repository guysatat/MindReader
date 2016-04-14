classdef reactive_user_detector
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        memory_length
        
        predictions     
        
        state_machine
    end
    
    methods
        function obj = reactive_user_detector(memory_length)
            obj.memory_length = memory_length;
            obj.predictions = []; 
            obj.state_machine = zeros(1, (2.^(2*memory_length+1)));
        end
        
        function [obj, bot_play] = predict(obj, user_strokes, user_win_loss, user_strokes_same_diff, turn_number)
            if turn_number <= (obj.memory_length+2)
                bot_play = 0;
            else
                [obj, bot_play] = reactive_det(obj, user_strokes_same_diff, user_win_loss);
                bot_play = bot_play * user_strokes(end);                
            end
            obj.predictions = [obj.predictions; bot_play];
        end
        
        function [obj, bot_play] = reactive_det(obj, target, target_win_loss)
            ind_map = 2.^((2*obj.memory_length):-1:0);
            
            %update for last turn
            last_state = [target_win_loss((end-obj.memory_length-1) : (end-1)), target((end-obj.memory_length) : (end-1))];
            last_state_ind = sum(((last_state+1)/2).*ind_map) + 1;
            last_state_result = target(end);
            
            if obj.state_machine(last_state_ind) == 0             %no info so assume prev state with low prob
                obj.state_machine(last_state_ind) = last_state_result * 0.3;
            elseif obj.state_machine(last_state_ind)*last_state_result == 0.3  %(same state so stregthen it
                obj.state_machine(last_state_ind) = last_state_result * 0.8;
            elseif obj.state_machine(last_state_ind)*last_state_result == 0.8  %(same state so stregthen it
                obj.state_machine(last_state_ind) = last_state_result * 1;
            else
                obj.state_machine(last_state_ind) = 0;     %mistake - so clean slate
            end
            
            %decide for current state
            current_state = [target_win_loss((end-obj.memory_length) : (end)), target((end-obj.memory_length+1) : (end))];
            current_state_ind = sum(((current_state+1)/2).*ind_map) + 1;
            
            bot_play = obj.state_machine(current_state_ind);

               
            
        end
    end
    
end

