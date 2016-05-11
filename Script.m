clear
clc

game_target = 50; %game length
random_player = 0; %let a random computer player play against the algorithm

%Initialize and run the game
game_parameters;
game = game(game_target, expert_params, random_player, figure_ind);
game = game.play_game();

