:- use_module(library(filesex)).
:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(listing)).

:- prolog_load_context(directory, AnnDir),
   directory_file_path(AnnDir, '../../Philosophy/s2a/spec_to_algorithm.pl', S2AFile),
   ( exists_file(S2AFile) -> load_files(S2AFile, [if(not_loaded)]) ; true ).

:- include('ann_driver.pl').
:- include('ann_mnn.pl').
:- include('ann_t_state.pl').
:- include('ann_t_exec.pl').
:- include('ann_traverse.pl').
:- include('ann_g_state.pl').
:- include('ann_g_exec.pl').
:- include('ann_find_lists.pl').
:- include('ann_spec_to_algorithm.pl').
:- include('ann_algorithm.pl').
:- include('ann_rules.pl').
:- include('ann_explain.pl').
:- include('ann_train.pl').

:- prolog_load_context(directory, AnnDir),
   directory_file_path(AnnDir, 'mnn_g_weights.pl', GWeights),
   ( exists_file(GWeights) -> consult(GWeights) ; true ).
:- prolog_load_context(directory, AnnDir),
   directory_file_path(AnnDir, 'mnn_t_weights.pl', TWeights),
   ( exists_file(TWeights) -> consult(TWeights) ; true ).
:- prolog_load_context(directory, AnnDir),
   directory_file_path(AnnDir, 'ann_g_rules_out.pl', GRules),
   ( exists_file(GRules) -> consult(GRules) ; true ).
:- prolog_load_context(directory, AnnDir),
   directory_file_path(AnnDir, 'ann_t_rules_out.pl', TRules),
   ( exists_file(TRules) -> consult(TRules) ; true ).

:- ( current_predicate(find_lists3b/2) ->
         ( dynamic(s2a_orig_find_lists3b/2),
           catch(install_find_lists_dispatcher, _, true) )
   ; true
   ).
:- ( current_predicate(rs_and_data_to_term/7) ->
         ( dynamic(s2a_orig_rs_and_data_to_term/7),
           catch(install_rs_dispatcher, _, true) )
   ; true
   ).
