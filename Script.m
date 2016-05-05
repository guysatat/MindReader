clear

game_target = 50; %game length
random_player = 0; %let a random computer player play against the algorithm

%Experts parameters:
%Direct strokes are the actual keys pressed, "same-different" is the set of
%decisions (play the same key as last time or switch to the different key).

%Bias detector (Operates on direct strokes), number define the memory of
%the expert. Operates on direct strokes.
expert_params.bias_memories = [5,10,15,20];

%Bias detector (Operates on "same-different"), same different, number
%define the memory of the expert.
expert_params.bias_memories_same_diff = [5,10,15,20];

%Pattern detector (Operates on direct strokes), number define the pattern
%lengths to search for.
expert_params.pattern_length = [2,3,4,5,6];

%Pattern detector (Operates on "same-different"), number define the pattern
%lengths to search.
expert_params.pattern_length_same_diff = [2,3,4,5,6];

%Shannon like detector (Operates on "same-different"), number defines the
%memory (original Shannon paper suggested length of 1.
expert_params.reactive_user_length = [0,1,2,3];

%Hagelbarger like detectorm (Operates on "same-different"),number defines
%memory (original paper suggested length of 1.
expert_params.reactive_bot_length = [0,1,2,3];

%figure to plot
figure_ind = 1;

%Initialize the game
game = game(game_target, expert_params, random_player, figure_ind);

%Run the game
game = game.play_game();

