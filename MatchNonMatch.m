%%timing file for the test the probabilistic reasoning by neurons
%% write by ly 20150109
%% 20150813 by ty
%%      now targets appear after the 2nd image is presented for 500ms (shape_presentation time).
%%      the monkey has to maintain its fixation for an additional 500ms (delay_time_2) 
%%      after the targets appear.

% trialerror 0-correct 3-break fixation 4-no fixation 6-error choice
%% in the timeing file ,there are only two shapes and two targets
%%%%%%%%
% give names to the TaskObjects defined in the conditions file:
VERSION = 1;
EVE_DEF = eventmarker_define_match_non_match();
% eventmarker(EVE_DEF.E_VERSION);
% eventmarker(VERSION);
% eventmarker(EVE_DEF.E_VERSION);
fprintf('current version: %d',VERSION);

%% define the global valuable %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global TrialRecord;
if(getCurTrialNumber() == 1)
%     rand('twister',mod(floor(now*8640000),2^31-1)) 
     if ~isfield(TrialRecord,'correctRun')
         TrialRecord.correctRun = 1;
     end
    TrialRecord.isBreak = 0;
    TrialRecord.preShapeGroup = [];
    TrialRecord.preWeightGroup = [];
    TrialRecord.correct = 0;
    TrialRecord.wrong = 0;
    TrialRecord.wrongseries = 0;
end

%% define the fixation point , target_points and the picture
% % % % a= TrialRecord.isBreak
% % % % b=TrialRecord.preShapeGroup
num_shapes = 2; %% the num of the showned graphics ,the value is 2

%% stimulus index
%%% point1 is red ,and the point2 is green
fixation_point = 1;%% the fixation point
target_correct = 2;%%red point
target_wrong = 3;%%green point
saccade_point = 9;

%% trial timing definitions  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
acq_fix_time = 5000; %%acquire the fixation point time
hold_fix_time = 500;%% initial holding of the fixation point time. eventually should be 500
saccade_time = 1000; %%time out before leaving the fixation point time
after_target_show_cue1 = 500; %msec
shape_presentation_time = 300; %% eventually 500
shape2_present_time = 200;
delay_time = 0;
% delay_time_2 = 500; %%
delay_time_2 = rand(1)*400;
acq_target_time = 50;%%acquire the target point time
hold_target_time =500;%% hold the target point time

%% fixation window size
fix_radius = 2.5;
tar_radius = 3;
%% difine sound
% correct_sound = 5;
wrong_sound = 4;
wrong_choice = 8;

%% reward;
first_reward = 50;
reward_stairs = 220;%% reward size for each drop
if TrialRecord.correctRun >4
    reward_num = 4;
else
reward_num=TrialRecord.correctRun;  
end                                         %% the nums of the drops of water(staircase)
%% penalty%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
break_fixation_penalty = 7000;

%% set the target and the shape locations
shape_position =1;%% the distance from the center of the grapic to the fixation point
target_position=[-8 8];%% the distance from the target position to the fixation point

%%
shape_group = [5 6];


%% define the figure onset order

first_image = 5;
second_image = 6;


% weight_group = [1000 0.9 0.7 0.5 0.3 -0.3 -0.5 -0.7 -0.9 -1000];
%% checking the validility of the parameters
if(num_shapes ~= 2)
    user_text('num_shapes ~= 2!!');
    return;
end

group_length = length(shape_group);
if(group_length ~= 2)
    user_text('group_length ~= 2!!');
    return;
end

%% set the locations of the targets
if rand()<0.5
tar_correct_xpath=target_position(1);
else tar_correct_xpath=target_position(2);
end

tar_correct_ypath=0;

tar_wrong_xpath=-tar_correct_xpath;
tar_wrong_ypath=0;

if tar_correct_xpath>tar_wrong_xpath
    eventmarker(EVE_DEF.E_CORRECT_RIGHT);
else if tar_correct_xpath<tar_wrong_xpath
        eventmarker(EVE_DEF.E_CORRECT_LEFT);
    end
end

%% set the locations of the shapes
% if rand()<0.2
%     if rand()<0.5
%     shape_xpath_real_group = [tar_correct_xpath/8*0.3,tar_correct_xpath/8*0.3];
%     shape_ypath_real_group = [1.7,1.7];
%     eventmarker(EVE_DEF.SKEWED_LOC_CUE);
%     else
%     shape_xpath_real_group = [tar_correct_xpath/8*0.2,tar_correct_xpath/8*0.2];
%     shape_ypath_real_group = [1.7,1.7];
%     eventmarker(EVE_DEF.SKEWED_LESS_LOC_CUE);
%     end
% else 
    shape_xpath_real_group = [tar_correct_xpath/8*0,tar_correct_xpath/8*0];
%     shape_xpath_real_group = [-2, +2];
    shape_ypath_real_group = [0,0];
%     eventmarker(EVE_DEF.CENTERED_LOC_CUE);
% end
%%  caculate and shown the correct rate for every shape
% if ~isfield(TrialRecord, 'cur_continue_correctNum')
%      TrialRecord.cur_continue_correctNum = 0;
% end
%% show fixation point
[tflip, framenumber]=toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_ON,'Status','on');
% [tflip, framenumber]=toggleobject(fixation_point,'Status','on');
% eventmarker(EVE_DEF.E_FIX_ON);
%% monkey should look at the fixation point
success_hold = 0;

while success_hold == 0 && acq_fix_time >0

[ontarget rt] = eyejoytrack('acquirefix', fixation_point, fix_radius, acq_fix_time);

if ontarget
eventmarker(EVE_DEF.E_ACQUIRE_FIX);
end

if ~ontarget
    toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_FIX_OFF);
    trialerror(4); % no fixation
    eventmarker(EVE_DEF.E_NO_FIX);
    user_text('No fixation');
    
    
    toggleobject(wrong_sound,'Status','on');
    acq_fix_time = 0;
    
  idle(break_fixation_penalty);  % a  long timeout for failing to acquire fixation
%      TrialRecord.cur_continue_correctNum = 0;
     TrialRecord.correctRun = 1;
%      TrialRecord.isBreak = 1;
    return;
end

idle(30); % to allow the noisy signal settling wholly within the target


% %% the monkey should hold fixation for 500ms

[ontarget cur_rt] = eyejoytrack('holdfix', fixation_point, fix_radius, hold_fix_time);
% %% if the monkey break fixation whithin the 500ms ,end the trial
if ontarget
    success_hold = 1;
    eventmarker(EVE_DEF.E_HOLD_FIX);
end

if ~ontarget
    
    toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'Status','off');
    toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_ON,'Status','on');
    acq_fix_time = acq_fix_time - 30 - cur_rt - rt;
    
% % % %     eventmarker(EVE_DEF.E_FIX_OFF); 
% % % %     eventmarker(EVE_DEF.E_BREAK_FIX);
% % %     trialerror(3);%%%%break fixation
% % %    
% % % %     TrialRecord.correctRun = 0;
% % %     toggleobject(wrong_sound,'Status','on');
% % %    
% % %         idle(break_fixation_penalty);
% % % %      TrialRecord.cur_continue_correctNum = 0;
% % %      TrialRecord.correctRun = 1;
% % % %      TrialRecord.isBreak = 1;
% % %     return;
end
end

if acq_fix_time<=0
     toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'Status','off');
     trialerror(4); % no fixation
    eventmarker(EVE_DEF.E_NO_FIX);
    user_text('No fixation');
    
    
    toggleobject(wrong_sound,'Status','on');
    acq_fix_time = 0;
    
  idle(break_fixation_penalty);  % a  long timeout for failing to acquire fixation
%      TrialRecord.cur_continue_correctNum = 0;
     TrialRecord.correctRun = 1;
%      TrialRecord.isBreak = 1;
    return;
end
%% show the first figure %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% and the targets
set_object_path(target_correct, tar_correct_xpath, tar_correct_ypath);
set_object_path(target_wrong, tar_wrong_xpath, tar_wrong_ypath);
toggleobject([target_correct target_wrong],'eventmarker',EVE_DEF.E_TAR_CORRECT_ON,'eventmarker',EVE_DEF.E_TAR_WRONG_ON,'Status','on');

[ontarget cur_rt] = eyejoytrack('holdfix',fixation_point, fix_radius, after_target_show_cue1);
if ~ontarget
    toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'eventmarker',EVE_DEF.E_BREAK_FIX,'Status','off');
    toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'Status','off');
    toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
    toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
    trialerror(3); %break fixation
    toggleobject(wrong_sound,'Status','on');
       
%      TrialRecord.cur_continue_correctNum = 0;
idle(break_fixation_penalty);
     TrialRecord.correctRun = 1;
%      TrialRecord.isBreak = 1;
    return
end


set_object_path(first_image,shape_xpath_real_group(1),shape_ypath_real_group(1));
toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_ON,'Status','on');
[ontarget cur_rt] = eyejoytrack('holdfix',fixation_point, fix_radius, shape_presentation_time);

if ~ontarget
    toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'eventmarker',EVE_DEF.E_BREAK_FIX,'Status','off');
    toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'Status','off');
    toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
    toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
    trialerror(3); %break fixation
    toggleobject(wrong_sound,'Status','on');
       
%      TrialRecord.cur_continue_correctNum = 0;
idle(break_fixation_penalty);
     TrialRecord.correctRun = 1;
%      TrialRecord.isBreak = 1;
    return
end

toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'Status','off');

%% if the monkey hold fixation for another 500ms delay, then show the second image 
%user_text(sprintf('current condition: %d',getCurCondNumber));
% if mod(getCurCondNumber-1,4)<2
%     [ontarget cur_rt] = eyejoytrack('holdfix', fixation_point, fix_radius, 200 );
% else
%     [ontarget cur_rt] = eyejoytrack('holdfix', fixation_point, fix_radius, 200 );
% end
[ontarget cur_rt] = eyejoytrack('holdfix', fixation_point, fix_radius, delay_time);

set_object_path(second_image,shape_xpath_real_group(2),shape_ypath_real_group(2));

if ~ontarget
%     toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_OFF,'eventmarker',EVE_DEF.E_BREAK_FIX,'Status','off');
    toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'eventmarker',EVE_DEF.E_BREAK_FIX,'Status','off');
    toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
    toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
    trialerror(3); %break fixation
    toggleobject(wrong_sound,'Status','on');
    idle(break_fixation_penalty);
%          TrialRecord.cur_continue_correctNum = 0;
     TrialRecord.correctRun = 1;
%      TrialRecord.isBreak = 1;
    return
end

if ontarget
    toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_ON,'Status','on');
%     idle(10)
%     toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'Status','off');%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end


%% the monkey should hold fixation for another 200ms 

[ontarget cur_rt] = eyejoytrack('holdfix', fixation_point, fix_radius, shape2_present_time);


if ~ontarget
    toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_OFF,'eventmarker',EVE_DEF.E_BREAK_FIX,'Status','off');
    
%     toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'eventmarker',EVE_DEF.E_BREAK_FIX,'Status','off');
    toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'Status','off');
    toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
    toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
    trialerror(3); %break fixation
    toggleobject(wrong_sound,'Status','on');
    idle(break_fixation_penalty);
% 
%          TrialRecord.cur_continue_correctNum = 0;
     TrialRecord.correctRun = 1;
%      TrialRecord.isBreak = 1;
    return
end


%% if the monkey hold the fixation point for another 500ms,then show the two target
%% points at the same time,one is red and the other is green

%%%%turn on both target points
% set_object_path(target_correct, tar_correct_xpath, tar_correct_ypath);
% set_object_path(target_wrong, tar_wrong_xpath, tar_wrong_ypath);
% toggleobject([target_correct target_wrong],'eventmarker',EVE_DEF.E_TAR_CORRECT_ON,'eventmarker',EVE_DEF.E_TAR_WRONG_ON,'Status','on');
toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_OFF,'Status','off');
% toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'Status','off');

%% the monkey should hold the fixation point for 500ms
[ontarget cur_rt] = eyejoytrack('holdfix', fixation_point, fix_radius, delay_time_2);
if ~ontarget
    toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'Status','off');
    toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
    toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
    
    trialerror(3); %break fixation
    toggleobject(wrong_sound,'Status','on');
    idle(break_fixation_penalty);
% 
%          TrialRecord.cur_continue_correctNum = 0;
     TrialRecord.correctRun = 1;
%      TrialRecord.isBreak = 1;
    return
end

%% _____________________fixation off ____________________
% toggleobject(fixation_point,'Status','off');
% eventmarker(EVE_DEF.E_FIX_OFF);
toggleobject(saccade_point,'eventmarker',EVE_DEF.E_SAC_ON,'Status','on');
toggleobject(fixation_point,'eventmarker',EVE_DEF.E_FIX_OFF,'Status','off');

[ontarget rt] = eyejoytrack('holdfix', fixation_point, fix_radius, saccade_time);

if ontarget                                                 %% stay holding fixation on the invisible fixation point
    toggleobject(saccade_point,'eventmarker',EVE_DEF.E_SAC_OFF,'Status','off');
    toggleobject(target_correct ,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_CORRECT_OFF);
    toggleobject(target_wrong ,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_WRONG_OFF);
    
    trialerror(4);    %%%%%%%%%%%%%%%%%%%% no saccade
    eventmarker(EVE_DEF.E_NO_FIX);
    
    toggleobject(wrong_sound,'Status','on');

    idle(break_fixation_penalty);
%      TrialRecord.cur_continue_correctNum = 0;
     TrialRecord.correctRun = 1;
%      TrialRecord.isBreak = 1;
    return;
end


if ~ontarget
    
    eventmarker(EVE_DEF.EC_LEAVE_FIXPOINT);
    toggleobject(saccade_point,'eventmarker',EVE_DEF.E_SAC_OFF,'Status','off');
end
%% choose one from the two targets

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ontarget cur_rt] = eyejoytrack('acquirefix', target_correct, tar_radius, acq_target_time);

% acquire fixation on target_correct or not?
 
if ontarget                             % if yes
    idle(30);
    ontarget = eyejoytrack('holdfix', target_correct, tar_radius, hold_target_time);    % then see whether it holds fixation

    if ontarget    % if yes again


    toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_OFF,'Status','off');
%     toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'Status','off');
    toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_CORRECT_OFF);
    toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
    
    
%     eventmarker(EVE_DEF.E_TAR_WRONG_OFF);
%         TrialRecord.isBreak = 0;
                trialerror(0);
        eventmarker(EVE_DEF.E_CORRECT);

        goodmonkey(first_reward);       % then pay it, withdraw the images, end the trial 
        eventmarker(EVE_DEF.E_REWARD);
            idle(300);
       if reward_num>1
            for i=1:(reward_num-1)                                  
            eventmarker(EVE_DEF.E_REWARD);
            goodmonkey(reward_stairs);
            idle(300);
            end
       end
       if TrialRecord.wrongseries == 0
    TrialRecord.correct = TrialRecord.correct+1;
       end
    correct_rate_com = TrialRecord.correct/(TrialRecord.correct+TrialRecord.wrong);
    TrialRecord.correctRun = TrialRecord.correctRun+1;
    user_text(mat2str(correct_rate_com));
    user_text('reward');
    
    TrialRecord.wrongseries = 0;

    else                                                    % if not
        trialerror(3);%%%break fixation
        eventmarker(EVE_DEF.E_BREAK_FIX);                    % then break, and shut down all the images
        toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_OFF,'Status','off');
%         toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'Status','off');
        toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_CORRECT_OFF);
        toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_WRONG_OFF);
        toggleobject(wrong_sound,'Status','on');
        idle(break_fixation_penalty);
        TrialRecord.correctRun = 1;
%         TrialRecord.isBreak = 1;
        return;
    end
    


% if not on the correct target, then see whether it's on the wrong target
    else [ontarget cur_rt] = eyejoytrack('acquirefix', target_wrong, tar_radius, acq_target_time);
        
    if ontarget             % if it is indeed on the error target
    idle(30);
    ontarget = eyejoytrack('holdfix', target_wrong, tar_radius, hold_target_time); % see whether it holds or not    

    if ontarget         % if yes, it hold the wrong choice
    toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_OFF,'Status','off');       % then close the images, end the trial
%     toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'Status','off');
    toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
    toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');

        TrialRecord.isBreak = 0;
                trialerror(6);
                
        eventmarker(EVE_DEF.EC_ERROR); % and mark it, with no feedback
        toggleobject(wrong_choice,'Status','on')
        if TrialRecord.wrongseries == 0
        TrialRecord.wrong = TrialRecord.wrong+1;
        end
        correct_rate_com = TrialRecord.correct/(TrialRecord.correct+TrialRecord.wrong);
        user_text(mat2str(correct_rate_com));
        user_text('wrong choice');
                TrialRecord.correctRun = 1;
        % TrialRecord.wrongseries = 1; % this should be only used in force-repeat condition
                idle(1500); 

    else   % if it doesn't hold it
        trialerror(3);%%%break fixation
        eventmarker(EVE_DEF.E_BREAK_FIX);                    % then break, and shut down all the images
        toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_OFF,'Status','off');
%         toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'Status','off');
        toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_CORRECT_OFF);
        toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_WRONG_OFF);
        toggleobject(wrong_sound,'Status','on');
        idle(break_fixation_penalty);
        TrialRecord.correctRun = 1;
%         TrialRecord.isBreak = 1;
        return;
    end
    
    
    else   % if it neither hold the correct nor the wrong choice, as it has already leave the fixation point, it breaks 
        trialerror(3);%%%break fixation
        eventmarker(EVE_DEF.E_BREAK_FIX);
        toggleobject(second_image,'eventmarker',EVE_DEF.E_IMAGE2_OFF,'Status','off');
%         toggleobject(first_image,'eventmarker',EVE_DEF.E_IMAGE1_OFF,'Status','off');
        toggleobject(target_correct,'eventmarker',EVE_DEF.E_TAR_CORRECT_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_CORRECT_OFF);
        toggleobject(target_wrong,'eventmarker',EVE_DEF.E_TAR_WRONG_OFF,'Status','off');
%     eventmarker(EVE_DEF.E_TAR_WRONG_OFF);
        toggleobject(wrong_sound,'Status','on');
        idle(break_fixation_penalty);
        TrialRecord.correctRun = 1;
%         TrialRecord.isBreak = 1;
        return;
    end
    end
%         idle(2000);