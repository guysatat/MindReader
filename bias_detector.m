classdef bias_detector
    %UNTITLED6 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        bias_memory
        
        predictions
    end
    
    methods
        function obj = bias_detector(bias_memory)
            obj.bias_memory = bias_memory;
            obj.predictions = [];            
        end
        
        function [obj, bot_play] = predict(obj, user_strokes, turn_number)
            if turn_number == 1
                bot_play = 0;
            else
                if turn_number > obj.bias_memory
                    user_strokes = user_strokes(turn_number - obj.bias_memory : end);
                end
                bot_play = mean(user_strokes);
            end
            obj.predictions = [obj.predictions; bot_play];
        end
        
        
    end
    
end

