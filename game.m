classdef game
    %This class manages the game
    %   It tracks the game and predicts next moves
    
    properties (SetAccess = private)
        user_strokes
        bot_strokes
        
        user_grade
        bot_grade
        
        turn_number
        game_target      
        
        stop_game_flag
        
        cheating_flag
        figure_ind
        
        bot
    end
    
    methods (Access = public)
        function obj = game(game_target)   %constractor
            obj.user_strokes = [];
            obj.bot_strokes = [];

            obj.user_grade = 0;
            obj.bot_grade = 0;
            
            obj.turn_number = 1;
            obj.game_target = game_target;   
            
            obj.stop_game_flag = 0;
            
            obj.cheating_flag = 0;
            obj.figure_ind = 1;
            
            obj.bot = bot(obj);
            
        end
        
        function obj = play_game(obj)
            fprintf('\n\n\n\nStart!\n');
            obj.draw_status();
            
            while obj.user_grade < obj.game_target && obj.bot_grade < obj.game_target   %main game loop
                
                if obj.turn_number == 1
                    [obj.bot, bot_move] = obj.bot.bot_play([]);
                else
                    [obj.bot, bot_move] = obj.bot.bot_play( obj.user_strokes(obj.turn_number-1));
                end
                obj.bot_strokes(obj.turn_number) = bot_move;
                
                if obj.cheating_flag
                    fprintf('Bot: %d', obj.bot_strokes(obj.turn_number));
                end
                
                obj = obj.user_play();
                
                if obj.stop_game_flag
                    break;
                end
                
                if ~obj.cheating_flag
                    fprintf('Bot: %d', obj.bot_strokes(obj.turn_number));
                end                                
                fprintf(' User: %d,  ', obj.user_strokes(obj.turn_number));
            
                if obj.bot_strokes(obj.turn_number) == obj.user_strokes(obj.turn_number)
                    obj.bot_grade = obj.bot_grade + 1;
                    fprintf(' B wins ');
                else
                    obj.user_grade = obj.user_grade+1;
                    fprintf(' U wins ');
                end
            
                fprintf(',  Grade: %d, %d', obj.bot_grade, obj.user_grade);
            
                obj.draw_status();
                
                obj.turn_number = obj.turn_number+1;
            
                fprintf('\n');
            end
            
            if obj.user_grade > obj.bot_grade
                fprintf('\nDone, You win\n\n\n');
                figure(obj.figure_ind); title('User Won');
            else
                fprintf('\nDone, Bot wins\n\n\n');
                figure(obj.figure_ind); title('Bot Won');
            end
        end
        
        function draw_status(obj)
            figure(1); 
            bar([0,1], [obj.user_grade, 0], 'b'); hold on;
            bar([0,1], [0, obj.bot_grade], 'r'); hold off;
            ylim([0,obj.game_target]);
            ax = gca;
            ax.XTickLabel = {['User: ', num2str(obj.user_grade)], ['Bot: ', num2str(obj.bot_grade)]};
        end
        
        function obj = user_play(obj)
            while 1
                stroke=getkey();
                switch stroke
                    case 29
                        obj.user_strokes(obj.turn_number) = 1;
                        break;
                    case 28
                        obj.user_strokes(obj.turn_number) = 0;
                        break;
                    case 99
                        obj.cheating_flag = ~obj.cheating_flag;
                        if obj.cheating_flag
                            fprintf('\nOk, here is a little help for you\n')
                            fprintf('Bot will play %d\n', obj.bot_strokes(obj.turn_number));
                        else
                            fprintf('\nOk, lets make it harder\n');
                        end
                    case 113
                        obj.stop_game_flag = 1;                    
                        break;
                end 
            end
        end 
        
    end
    
end

