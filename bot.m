classdef bot 
    %BOT player class
    %   Detailed explanation goes here
    
    properties
        game
        
        user_strokes
        user_strokes_sd
        user_win_loss
        
        bot_strokes
        bot_strokes_sd
        bot_win_loss
        
        turn_number
        
        bias_detectors
        bias_memories
        
        bias_detectors_sd
        bias_memories_sd
    end
    
    
    methods (Access = public)
        function obj = bot(game)
            obj.game = game;
            
            obj.bias_memories = [5,10,15,20];
            for i = 1 : length(obj.bias_memories)
                bias_detectors(i) = bias_detector(obj.bias_memories(i));
            end 
            obj.bias_detectors = bias_detectors;
            
            obj.bias_memories_sd = [5,10,15,20]-1;
            for i = 1 : length(obj.bias_memories_sd)
                bias_detectors_sd(i) = bias_detector(obj.bias_memories_sd(i));
            end 
            obj.bias_detectors_sd = bias_detectors_sd;
            
            obj.turn_number = 0';          
            
        end
        
        
        function [obj, bot_move_01] = bot_play(obj, last_user_play)
            obj.turn_number = obj.turn_number + 1;
%             last_user_play = last_user_play*2-1;
            obj = update_game(obj, last_user_play);
            
            X = []; %the experts decisions (in +-1, not same/diff)
            for i = 1 : length(obj.bias_memories)
                [obj.bias_detectors(i), p] = obj.bias_detectors(i).predict(obj.user_strokes, obj.turn_number);
                X = [X, p];
            end
            for i = 1 : length(obj.bias_memories_sd)
                [obj.bias_detectors_sd(i), p] = obj.bias_detectors_sd(i).predict(obj.user_strokes_sd, obj.turn_number);
                if obj.turn_number>1
                    p = p*obj.bot_strokes(obj.turn_number-1);
                end
                X = [X, p];
            end

            qt = (AggregateExperts(obj, X)+1)/2; %translate to 0,1 
            bot_move_01 = binornd(1, qt);
            bot_move = bot_move_01*2 - 1; 
            
            obj.bot_strokes(obj.turn_number) = bot_move;
            if obj.turn_number >= 2
                obj.bot_strokes_sd(obj.turn_number) = obj.bot_strokes_sd(obj.turn_number-1) * bot_move;
            else
                obj.bot_strokes_sd(obj.turn_number) = 1;
            end
        end
        
        function obj = update_game(obj, last_user_play)
            prev_turn_number = obj.turn_number - 1;
            
            if prev_turn_number>0
                obj.user_strokes(prev_turn_number) = last_user_play;
                obj.user_win_loss(prev_turn_number) = - last_user_play * obj.bot_strokes(prev_turn_number);
                obj.bot_win_loss(prev_turn_number) = last_user_play * obj.bot_strokes(prev_turn_number);
                
                if prev_turn_number == 1
                    obj.user_strokes_sd(prev_turn_number) = 1;
                else
                    obj.user_strokes_sd(prev_turn_number) = obj.user_strokes(prev_turn_number-1) *  last_user_play;
                end
            end
        end
        
        function qt = AggregateExperts(obj, X)
            qt = mean(X);
        end
        
        
        function [pat_grade, pat_next] = pattern_detector(obj, pat_l)
            pat_grade=0;
            pat_next = 2;
            if obj.i>(pat_l+1)
                pat = obj.user_strokes((obj.i-pat_l):(obj.i-1));
                pat_next = pat(1);
                c=obj.i-pat_l-1;                
                while c>0
                    pat = [pat(end), pat(1:(end-1))];
                    if sum(abs(obj.user_strokes(c:(c+pat_l-1)) - pat)) == 0
                        pat_grade = pat_grade+1;
                    else
                        break;
                    end
                    c=c-1;
                end
            end
        end
        
        function obj = temp(obj)
        
%              fprintf('\n');            
%              fprintf('\n');
%              fprintf('%d ', obj.user_likelihood_table);
             
             if obj.i > 3   %update grades
                state = [0,0,0];  % 0(1) -> won(lost),  same(diff),  won(lost)
                ind_map = [4,2,1];
                if obj.user_strokes(obj.i-3) ~= obj.bot_strokes(obj.i-3) %won
                    state(1) = 0;
                else
                    state(1) = 1;
                end
                
                if obj.user_strokes(obj.i-3) == obj.user_strokes(obj.i-2) %same
                   state(2) = 0;
                else
                   state(2) = 1;
                end
                
                if obj.user_strokes(obj.i-2) ~= obj.bot_strokes(obj.i-2) %won
                    state(3) = 0;
                else
                    state(3) = 1;
                end
                state_ind = sum(state.*ind_map)+1;
                
                if obj.user_strokes(obj.i-2) == obj.user_strokes(obj.i-1) %same
                    obj.user_likelihood_table(state_ind) = obj.user_likelihood_table(state_ind) + 1;
                else %diff
                    obj.user_likelihood_table(state_ind) = obj.user_likelihood_table(state_ind) - 1;
                end
             end
            
%              fprintf('\n');
             fprintf('%d ', obj.user_likelihood_table);
             
             likelihood = 0;
             likelihood_grade = 0;
            if obj.i > 2 %estimate for now
                state = [0,0,0];  % 0(1) -> won(lost),  same(diff),  won(lost)
                ind_map = [4,2,1];
                if obj.user_strokes(obj.i-2) ~= obj.bot_strokes(obj.i-2) %won
                    state(1) = 0;
                else
                    state(1) = 1;
                end
                
                if obj.user_strokes(obj.i-2) == obj.user_strokes(obj.i-1) %same
                   state(2) = 0;
                else
                   state(2) = 1;
                end
                
                if obj.user_strokes(obj.i-1) ~= obj.bot_strokes(obj.i-1) %won
                    state(3) = 0;
                else
                    state(3) = 1;
                end
                state_ind = sum(state.*ind_map)+1;
                
                if obj.user_likelihood_table(state_ind) >= 0  %same
                    likelihood = obj.user_strokes(obj.i-1);
                else
                    likelihood = ~obj.user_strokes(obj.i-1);
                end
                
                likelihood_grade = sum(abs(obj.user_likelihood_table)) / obj.i;
            end
            
            fprintf('  l: %d, l_G: %.1f    ', likelihood, likelihood_grade);

            
            
            [pat2_grade, pat2_next] = pattern_detector(obj, 2);
            [pat3_grade, pat3_next] = pattern_detector(obj, 3);
            [pat4_grade, pat4_next] = pattern_detector(obj, 4);
            
%            
            fprintf('  P2 g: %.1f n: %d  ', pat2_grade, pat2_next);
            fprintf('  P3 g: %.1f n: %d  ', pat3_grade, pat3_next);
            fprintf('  P4 g: %.1f n: %d  ', pat4_grade, pat4_next);
            
            
            if obj.i > 20
                t = obj.user_strokes(obj.i-20 : end);
            else
                t= obj.user_strokes;
            end
            u_m = mean(t);
            u_s = std(t);
            
            if isnan(u_s)
                u_s=1;
            end
            
            fprintf('std=%.1f ',u_s)
            if likelihood_grade > 0.1
                t = likelihood;
                fprintf('li %d ', state_ind);
            elseif pat4_grade > 2
                t = pat4_next;
                fprintf('pat4 ');
            elseif pat3_grade > 2
                t = pat3_next;
                fprintf('pat3 ');
            elseif pat2_grade > 3
                t = pat2_next;
                fprintf('pat2 ');                
            elseif u_s < 0.5
                t = u_m>0.5;
                fprintf('bias ');
            else
                t = randn(1)>0;
                fprintf('rand ');
            end
            obj.bot_strokes(obj.i) = t;
            
            %cheatting
            fprintf(' B: %d        ', t);
            
            
            
            
            
            
            
        end
        
    end
    
end



