classdef bot 
    %BOT player class
    %   Detailed explanation goes here
    
    properties
        bias_detectors        
        bias_detectors_same_diff        
        pattern_detectors        
        pattern_detectors_same_diff
        reactive_user_detectors
        
        N
        
    end
    
    
    methods (Access = public)
        function bot = bot(expert_params)
            for i = 1 : length(expert_params.bias_memories)
                bias_detectors(i) = bias_detector(expert_params.bias_memories(i), 0);
            end 
            bot.bias_detectors = bias_detectors;
            
            for i = 1 : length(expert_params.bias_memories_same_diff)
                bias_detectors_same_diff(i) = bias_detector(expert_params.bias_memories_same_diff(i), 1);
            end 
            bot.bias_detectors_same_diff = bias_detectors_same_diff;
            
            for i = 1 : length(expert_params.pattern_length)
                pattern_detectors(i) = pattern_detector(expert_params.pattern_length(i), 0);
            end 
            bot.pattern_detectors = pattern_detectors;
            
            for i = 1 : length(expert_params.pattern_length_same_diff)
                pattern_detectors_same_diff(i) = pattern_detector(expert_params.pattern_length_same_diff(i), 1);
            end 
            bot.pattern_detectors_same_diff = pattern_detectors_same_diff;            

            for i = 1 : length(expert_params.reactive_user_length)
                reactive_user_detectors(i) = reactive_user_detector(expert_params.reactive_user_length(i));
            end 
            bot.reactive_user_detectors = reactive_user_detectors;    
            
            bot.N = length(expert_params.bias_memories) + length(expert_params.bias_memories_same_diff) + length(expert_params.pattern_length) + ...
                length(expert_params.pattern_length_same_diff) + length(expert_params.reactive_user_length);
        end
        
        
        function [bot, bot_move] = bot_play(bot, game)
            X = []; %the experts decisions (in +-1)
            for i = 1 : length(bot.bias_detectors)
                [bot.bias_detectors(i), p] = bot.bias_detectors(i).predict(game.user_strokes, game.user_strokes_same_diff, game.turn_number);
                X = [X, p];
            end
            for i = 1 : length(bot.bias_detectors_same_diff)
                [bot.bias_detectors_same_diff(i), p] = bot.bias_detectors_same_diff(i).predict(game.user_strokes, game.user_strokes_same_diff, game.turn_number);
                X = [X, p];
            end
            for i = 1 : length(bot.pattern_detectors)
                [bot.pattern_detectors(i), p] = bot.pattern_detectors(i).predict(game.user_strokes, game.user_strokes_same_diff, game.turn_number);
                X = [X, p];
            end
            for i = 1 : length(bot.pattern_detectors_same_diff)
                [bot.pattern_detectors_same_diff(i), p] = bot.pattern_detectors_same_diff(i).predict(game.user_strokes, game.user_strokes_same_diff, game.turn_number);
                X = [X, p];
            end
            for i = 1 : length(bot.reactive_user_detectors)    
                [bot.reactive_user_detectors(i), p] = bot.reactive_user_detectors(i).predict(game.user_strokes, game.user_win_loss, game.user_strokes_same_diff, game.turn_number);
                X = [X, p];
            end
            
            if game.turn_number > 1
                eta = sqrt(log(bot.N)/(2*game.turn_number));
                qt = AggregateExperts(bot, X, game.user_strokes, eta); 
            else
                qt = 0;
            end
            
            bot_move = 2*binornd(1, (qt+1)/2)-1; %translate to 0,1  and back to -1,1
        end
        
        function qt = AggregateExperts(bot, X, user_strokes, eta)
            yt = []; %the experts decisions (in +-1)
            for i = 1 : length(bot.bias_detectors)
                p = exp(-eta * sum(abs(bot.bias_detectors(i).predictions(1:(end-1)) - user_strokes')));
                yt = [yt, p];
            end
            for i = 1 : length(bot.bias_detectors_same_diff)
                p = exp(-eta * sum(abs(bot.bias_detectors_same_diff(i).predictions(1:(end-1)) - user_strokes')));
                yt = [yt, p];
            end
            for i = 1 : length(bot.pattern_detectors)
                p = exp(-eta * sum(abs(bot.pattern_detectors(i).predictions(1:(end-1)) - user_strokes')));
                yt = [yt, p];
            end
            for i = 1 : length(bot.pattern_detectors_same_diff)
                p = exp(-eta * sum(abs(bot.pattern_detectors_same_diff(i).predictions(1:(end-1)) - user_strokes')));
                yt = [yt, p];
            end
            for i = 1 : length(bot.reactive_user_detectors)    
                p = exp(-eta * sum(abs(bot.reactive_user_detectors(i).predictions(1:(end-1)) - user_strokes')));
                yt = [yt, p];
            end            
            
            yt = yt / sum(yt);
            
            qt = yt * X';
            %qt = mean(yt);
        end
        
        

  

        
    end
    
end



