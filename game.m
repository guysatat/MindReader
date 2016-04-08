classdef game
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (SetAccess = private)
        user_strokes
        bot_strokes
        
        user_likelihood_table
        
        user_grade
        bot_grade
        i
        
       
    end
    
    methods (Access = public)
        function obj = game()
            obj.user_strokes = [];
            obj.bot_strokes = [];

            obj.user_grade = 0;
            obj.bot_grade = 0;
            obj.i = 1;
            
            obj.user_likelihood_table = zeros(8,1);
                       
        end
        
        function obj = bot_play(obj)
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
        
        function obj = user_play(obj)
            obj.user_strokes(obj.i) = r;
        end
        
        function obj = play_turn(obj)
            obj = obj.bot_play();
            
            stroke=getkey();
            switch stroke
                case 29
                    obj.user_strokes(obj.i) = 1;
                case 28
                    obj.user_strokes(obj.i) = 0;
                case 113
                    obj.i = -100;
                    return
            end 
            
                fprintf(',  U: %d B: %d,  ', obj.user_strokes(obj.i), obj.bot_strokes(obj.i));
            
            if obj.bot_strokes(obj.i) == obj.user_strokes(obj.i)
                obj.bot_grade = obj.bot_grade + 1;
                fprintf(' B wins ');
            else
                obj.user_grade = obj.user_grade+1;
                fprintf(' U wins ');
            end
            
            fprintf(',  Grade: %d, %d', obj.user_grade, obj.bot_grade);
            
            obj.i = obj.i+1;
            
            fprintf('\n');
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
        
        function draw_figure(obj, n)
            figure(1); 
            bar([0,1], [obj.user_grade, 0], 'b'); hold on;
            bar([0,1], [0, obj.bot_grade], 'r'); hold off;
            ylim([0,n]);
            ax = gca;
            ax.XTickLabel = {['User: ', num2str(obj.user_grade)], ['Bot: ', num2str(obj.bot_grade)]};
        end

        
    end
    
end

