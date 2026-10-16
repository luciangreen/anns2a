% ann_s2a_pairs.pl - 200 input/output pairs for ANN-S2A
%
% ann_pair(Id, Kind, Input, Expected)
%   Kind = find_lists | traverse | s2a
% ann_known_gap(Id, AnnOutput)
%   What the ANN path returned instead of Expected when these pairs were
%   generated (SWI-Prolog 9.2.9, repo weights as committed). Absent = ANN
%   already returns Expected.
%
% Every Expected value was produced by running the code, not written by hand.
%
% Run from ann_s2a/ (Philosophy and listprologinterpreter checked out as
% siblings of anns2a, as the README describes):
%
%   swipl -g "['tests/ann_s2a_pairs.pl'], run_ann_s2a_pairs(ann), halt."
%   swipl -g "['tests/ann_s2a_pairs.pl'], run_ann_s2a_pairs(reference), halt."
%
% run_ann_s2a_pairs(reference) checks the pairs against the recursive S2A
% path (should be 200/200). run_ann_s2a_pairs(ann) checks the ANN path.
% s2a pairs are skipped if spec_to_algorithm/4 is not loaded.

:- use_module(library(filesex)).
:- prolog_load_context(directory, TestDir),
   directory_file_path(TestDir, '../ann_s2a.pl', Loader),
   load_files(Loader, [if(not_loaded)]).

:- discontiguous ann_pair/4, ann_known_gap/2.
:- dynamic ann_known_gap/2.

% ---------------------------------------------------------------------
% Phase 1 (MNN-G): ann_find_lists(Tokens, Pattern)
% Expected = recursive S2A find_lists3b/2. Pairs 51-60 use the [split,_]
% labelled shape that spec_to_algorithm/4 actually passes in.
% ---------------------------------------------------------------------

ann_pair('P-001', find_lists, [], []).
ann_pair('P-002', find_lists, [1], [1]).
ann_pair('P-003', find_lists, [a], [a]).
ann_pair('P-004', find_lists, [1,1], [['&r',[1]]]).
ann_pair('P-005', find_lists, [a,a], [['&r',[a]]]).
ann_pair('P-006', find_lists, [1,1,1,1], [['&r',[1]]]).
ann_pair('P-007', find_lists, [1,2,1,2,1,2], [['&r',[1,2]]]).
ann_pair('P-008', find_lists, [a,b,a,b,a,b,a,b], [['&r',[a,b]]]).
ann_pair('P-009', find_lists, [1,2,3,1,2,3], [['&r',[1,2,3]]]).
ann_pair('P-010', find_lists, [p,q,r,p,q,r,p,q,r], [['&r',[p,q,r]]]).
ann_pair('P-011', find_lists, [a,a,b,b,c,c], [['&r',[a]],['&r',[b]],['&r',[c]]]).
ann_pair('P-012', find_lists, [1,1,1,2,2,2], [['&r',[1]],['&r',[2]]]).
ann_pair('P-013', find_lists, [0,1,0,1,2], [['&r',[0,1]],2]).
ann_pair('P-014', find_lists, [1,2,1,2,3,4,3,4], [['&r',[1,2]],['&r',[3,4]]]).
ann_pair('P-015', find_lists, [a,b,c,d,a,b,c,d], [['&r',[a,b,c,d]]]).
ann_pair('P-016', find_lists, [3,4,3,4,3,4,9], [['&r',[3,4]],9]).
ann_pair('P-017', find_lists, [9,1,1,1,8], [9,['&r',[1]],8]).
ann_pair('P-018', find_lists, [1,2,3,2,3], [1,['&r',[2,3]]]).
ann_pair('P-019', find_lists, [1,2,3,2,3,1,2,3,2,3], [['&r',[1,['&r',[2,3]]]]]).
ann_known_gap('P-019', [['&r',[1,2,3,2,3]]]).
ann_pair('P-020', find_lists, [1,2,4,2,4,1,2,4,2,4], [['&r',[1,['&r',[2,4]]]]]).
ann_known_gap('P-020', [['&r',[1,2,4,2,4]]]).
ann_pair('P-021', find_lists, [x,x,y,x,x,y], [['&r',[['&r',[x]],y]]]).
ann_known_gap('P-021', [['&r',[x]],y,['&r',[x]],y]).
ann_pair('P-022', find_lists, [a,b,b,a,b,b], [['&r',[a,['&r',[b]]]]]).
ann_known_gap('P-022', [['&r',[a,b,b]]]).
ann_pair('P-023', find_lists, [1,0,0,1,0,0,1,0,0], [['&r',[1,['&r',[0]]]]]).
ann_known_gap('P-023', [['&r',[1,0,0]]]).
ann_pair('P-024', find_lists, ["a","a"], [['&r',["a"]]]).
ann_pair('P-025', find_lists, ["a","b","a","b"], [['&r',["a","b"]]]).
ann_pair('P-026', find_lists, [1,"a",1,"a"], [['&r',[1,"a"]]]).
ann_pair('P-027', find_lists, [a,1,a,1,a,1], [['&r',[a,1]]]).
ann_pair('P-028', find_lists, [2,2,2,3,3,3,4], [['&r',[2]],['&r',[3]],4]).
ann_pair('P-029', find_lists, ['[',1,1,']'], ['[',['&r',[1]],']']).
ann_pair('P-030', find_lists, ['[',1,2,1,2,']'], ['[',['&r',[1,2]],']']).
ann_pair('P-031', find_lists, ['[',a,b,a,b,a,b,']'], ['[',['&r',[a,b]],']']).
ann_pair('P-032', find_lists, ['[',1,2,']','[',1,2,']'], [['&r',['[',1,2,']']]]).
ann_known_gap('P-032', ['[',1,2,']','[',1,2,']']).
ann_pair('P-033', find_lists, [0,'[',1,1,']',0], [0,'[',['&r',[1]],']',0]).
ann_pair('P-034', find_lists, ['[','[',1,']',']'], [['&r',['[']],1,['&r',[']']]]).
ann_known_gap('P-034', ['[','[',1,']',']']).
ann_pair('P-035', find_lists, ['[',1,2,']',3,3], ['[',1,2,']',['&r',[3]]]).
ann_pair('P-036', find_lists, [x,'[',y,y,y,']'], [x,'[',['&r',[y]],']']).
ann_pair('P-037', find_lists, ['[',1,']','[',2,']'], ['[',1,']','[',2,']']).
ann_pair('P-038', find_lists, ["[",1,2,"]"], ["[",1,2,"]"]).
ann_pair('P-039', find_lists, ["[",1,1,1,"]"], ["[",['&r',[1]],"]"]).
ann_pair('P-040', find_lists, ["[",a,b,a,b,"]"], ["[",['&r',[a,b]],"]"]).
ann_pair('P-041', find_lists, ["[",1,"]","[",1,"]"], [['&r',["[",1,"]"]]]).
ann_known_gap('P-041', ["[",1,"]","[",1,"]"]).
ann_pair('P-042', find_lists, ["[","[",1,"]","]"], [['&r',["["]],1,['&r',["]"]]]).
ann_known_gap('P-042', ["[","[",1,"]","]"]).
ann_pair('P-043', find_lists, [7,"[",8,8,"]"], [7,"[",['&r',[8]],"]"]).
ann_pair('P-044', find_lists, [1,2,3,4,1,2,3,4,5,6,5,6], [['&r',[1,2,3,4]],['&r',[5,6]]]).
ann_pair('P-045', find_lists, [a,a,a,b,a,a,a,b], [['&r',[['&r',[a]],b]]]).
ann_known_gap('P-045', [['&r',[a]],b,['&r',[a]],b]).
ann_pair('P-046', find_lists, [1,2,1,3,1,2,1,3], [['&r',[1,2,1,3]]]).
ann_pair('P-047', find_lists, [m,n,m,n,o,p,o,p,o,p], [['&r',[m,n]],['&r',[o,p]]]).
ann_pair('P-048', find_lists, [1,1,2,1,1,2,1,1,2], [['&r',[['&r',[1]],2]]]).
ann_known_gap('P-048', [['&r',[1]],['&r',[2,1,1]],2]).
ann_pair('P-049', find_lists, [4,4,4,4,4,4,4,4], [['&r',[4]]]).
ann_pair('P-050', find_lists, [1,2,3,3,2,1], [1,2,['&r',[3]],2,1]).
ann_pair('P-051', find_lists, [[split,["[",1,2,"]"]]], ["[",1,2,"]"]).
ann_known_gap('P-051', [[split,["[",1,2,"]"]]]).
ann_pair('P-052', find_lists, [[split,["[",a,b,c,"]"]]], ["[",a,b,c,"]"]).
ann_known_gap('P-052', [[split,["[",a,b,c,"]"]]]).
ann_pair('P-053', find_lists, [[split,[1,2,1,2]]], [['&r',[1,2]]]).
ann_known_gap('P-053', [[split,[1,2,1,2]]]).
ann_pair('P-054', find_lists, [[split,[x,x,x]]], [['&r',[x]]]).
ann_known_gap('P-054', [[split,[x,x,x]]]).
ann_pair('P-055', find_lists, [[split,["[",1,2,1,2,"]"]]], ["[",['&r',[1,2]],"]"]).
ann_known_gap('P-055', [[split,["[",1,2,1,2,"]"]]]).
ann_pair('P-056', find_lists, [[split,["[",7,"]"]]], ["[",7,"]"]).
ann_known_gap('P-056', [[split,["[",7,"]"]]]).
ann_pair('P-057', find_lists, [[split,["[",1,2,3,2,3,1,2,3,2,3,"]"]]], ["[",['&r',[1,['&r',[2,3]]]],"]"]).
ann_known_gap('P-057', [[split,["[",1,2,3,2,3,1,2,3,2,3,"]"]]]).
ann_pair('P-058', find_lists, [[split,["[",1,"]"]],[split,["[",2,"]"]]], ["[",1,"]","[",2,"]"]).
ann_known_gap('P-058', [[split,["[",1,"]"]],[split,["[",2,"]"]]]).
ann_pair('P-059', find_lists, [[split,[5,6,5,6,9]]], [['&r',[5,6]],9]).
ann_known_gap('P-059', [[split,[5,6,5,6,9]]]).
ann_pair('P-060', find_lists, [[split,["[",a,a,b,b,"]"]]], ["[",['&r',[a]],['&r',[b]],"]"]).
ann_known_gap('P-060', [[split,["[",a,a,b,b,"]"]]]).

% ---------------------------------------------------------------------
% Phase 2 (MNN-T): ann_traverse(Pattern, Data, Opts, Matched)
% Input is Pattern-Data. Expected = first solution with order(reference);
% `fail` means no match.
% ---------------------------------------------------------------------

ann_pair('P-061', traverse, [a]-[a], [a]).
ann_pair('P-062', traverse, [1,2,3]-[1,2,3], [1,2,3]).
ann_pair('P-063', traverse, ["s"]-["s"], ["s"]).
ann_pair('P-064', traverse, [a]-[b], fail).
ann_pair('P-065', traverse, [1,2]-[1,3], fail).
ann_pair('P-066', traverse, [a,b]-[a], fail).
ann_pair('P-067', traverse, [a]-[], fail).
ann_pair('P-068', traverse, []-[], []).
ann_pair('P-069', traverse, ['C1']-[a], [a]).
ann_pair('P-070', traverse, ['C1']-["x"], ["x"]).
ann_pair('P-071', traverse, ['C1','C2']-[a,b], [a,b]).
ann_pair('P-072', traverse, ['C1','C2']-[3,3], [3,3]).
ann_pair('P-073', traverse, ['C1','C1']-[a,a], [a,a]).
ann_pair('P-074', traverse, ['C1','C1']-[5,5], [5,5]).
ann_pair('P-075', traverse, ['C1','C1']-[a,b], fail).
ann_pair('P-076', traverse, ['C1','C2','C1']-[x,y,x], [x,y,x]).
ann_pair('P-077', traverse, ['C1','C2','C1']-[x,y,z], fail).
ann_pair('P-078', traverse, [1,'C1']-[1,9], [1,9]).
ann_pair('P-079', traverse, [1,'C1']-[2,9], fail).
ann_pair('P-080', traverse, ['C1',3]-[4,3], [4,3]).
ann_pair('P-081', traverse, ['C1','C2','C3']-[p,q,r], [p,q,r]).
ann_pair('P-082', traverse, ['C1']-[[1,2]], [[1,2]]).
ann_pair('P-083', traverse, [['C1']]-[[a]], [[a]]).
ann_pair('P-084', traverse, [['C1','C2']]-[[1,2]], [[1,2]]).
ann_pair('P-085', traverse, [[a,'C1']]-[[a,b]], [[a,b]]).
ann_pair('P-086', traverse, [[a,'C1']]-[[b,b]], fail).
ann_pair('P-087', traverse, [['C1'],['C1']]-[[x],[x]], [[x],[x]]).
ann_pair('P-088', traverse, [['C1'],['C1']]-[[x],[y]], fail).
ann_pair('P-089', traverse, [[['C1']]]-[[[z]]], [[[z]]]).
ann_pair('P-090', traverse, [['C1',1]]-[[4,1]], [[4,1]]).
ann_pair('P-091', traverse, [[1,'C1'],'C1']-[[1,8],8], [[1,8],8]).
ann_pair('P-092', traverse, [[]]-[[]], [[]]).
ann_pair('P-093', traverse, [['&r',['C1']]]-[a,a], [['&r',[[a],[a]]]]).
ann_known_gap('P-093', [['&r',[]]]).
ann_pair('P-094', traverse, [['&r',['C1']]]-[a,a,a], [['&r',[[a],[a],[a]]]]).
ann_known_gap('P-094', [['&r',[]]]).
ann_pair('P-095', traverse, [['&r',['C1']]]-[a,b], [['&r',[[a]]]]).
ann_known_gap('P-095', [['&r',[]]]).
ann_pair('P-096', traverse, [['&r',[a]]]-[a,a,a,a], [['&r',[[a],[a],[a],[a]]]]).
ann_known_gap('P-096', [['&r',[]]]).
ann_pair('P-097', traverse, [['&r',[1,2]]]-[1,2,1,2], [['&r',[[1,2],[1,2]]]]).
ann_known_gap('P-097', [['&r',[]]]).
ann_pair('P-098', traverse, [['&r',[1,2]]]-[1,2,1,2,1,2], [['&r',[[1,2],[1,2],[1,2]]]]).
ann_known_gap('P-098', [['&r',[]]]).
ann_pair('P-099', traverse, [['&r',[1,2]]]-[1,2,1], [['&r',[[1,2]]]]).
ann_known_gap('P-099', [['&r',[]]]).
ann_pair('P-100', traverse, [['&r',['C1','C2']]]-[3,4,3,4], [['&r',[[3,4],[3,4]]]]).
ann_known_gap('P-100', [['&r',[]]]).
ann_pair('P-101', traverse, [['&r',[x]],y]-[x,x,y], [['&r',[[x],[x]]],y]).
ann_pair('P-102', traverse, [0,['&r',[1]],0]-[0,1,1,1,0], [0,['&r',[[1],[1],[1]]],0]).
ann_pair('P-103', traverse, [['&r',['C1']],'C1']-[k,k,k], [['&r',[[k],[k]]],k]).
ann_known_gap('P-103', [['&r',[]],k]).
ann_pair('P-104', traverse, [[string,'C1']]-[[string,"a"]], [[string,"a"]]).
ann_pair('P-105', traverse, [[atom,'C1']]-[[atom,q]], [[atom,q]]).
ann_pair('P-106', traverse, [[string,'C1'],[string,'C1']]-[[string,"a"],[string,"a"]], [[string,"a"],[string,"a"]]).
ann_pair('P-107', traverse, [[string,'C1'],[string,'C1']]-[[string,"a"],[string,"b"]], fail).
ann_pair('P-108', traverse, [[number,'C1'],[number,'C2']]-[[number,1],[number,2]], [[number,1],[number,2]]).
ann_pair('P-109', traverse, [[string,"z"]]-[[string,"z"]], [[string,"z"]]).
ann_pair('P-110', traverse, [[string,"z"]]-[[string,"y"]], fail).
ann_pair('P-111', traverse, [[nd,[[a],[b]]]]-[a], [a]).
ann_pair('P-112', traverse, [[nd,[[a],[b]]]]-[c], fail).
ann_pair('P-113', traverse, [[nd,[[1,2],[3]]]]-[3], [3]).
ann_pair('P-114', traverse, [[nd,[[1,2],[3]]]]-[1,2], [1,2]).
ann_pair('P-115', traverse, [[nd,[['C1'],[x]]]]-[q], [q]).
ann_pair('P-116', traverse, [[nd,[[a],['C1']]]]-[a], [a]).
ann_pair('P-117', traverse, [x,[nd,[[1],[2]]]]-[x,2], [x,2]).
ann_pair('P-118', traverse, [['&r',['C1']],[nd,[[a],[b]]]]-[z,z,b], [['&r',[[z],[z]]],b]).
ann_pair('P-119', traverse, [['C1',['&r',[2]]]]-[[7,2,2]], [[7,['&r',[[2],[2]]]]]).
ann_pair('P-120', traverse, [[string,'C1'],'C2']-[[string,"h"],5], [[string,"h"],5]).

% ---------------------------------------------------------------------
% End to end: spec(Specs, HeldOutInput) -> output of the generated
% algorithm on an input that is not in the spec. Expected = output of the
% algorithm recursive S2A generates (all 80 also match the intended
% function: swap, reverse3, rotate3, identity, first_var, second_var,
% concat, duplicate, drop_const, head2). character_breakdown_mode=off.
% ---------------------------------------------------------------------

% swap_1
ann_pair('P-121', s2a, spec([[[input,[['A',[1,2]]]],[output,[['B',[2,1]]]]],[[input,[['A',[3,4]]]],[output,[['B',[4,3]]]]]], [[7,9]]), [[9,7]]).
ann_known_gap('P-121', fail).
% swap_2
ann_pair('P-122', s2a, spec([[[input,[['A',[5,6]]]],[output,[['B',[6,5]]]]],[[input,[['A',[8,1]]]],[output,[['B',[1,8]]]]]], [[2,7]]), [[7,2]]).
ann_known_gap('P-122', fail).
% swap_3
ann_pair('P-123', s2a, spec([[[input,[['A',[a,b]]]],[output,[['B',[b,a]]]]],[[input,[['A',[c,d]]]],[output,[['B',[d,c]]]]]], [[e,f]]), [[f,e]]).
ann_known_gap('P-123', fail).
% swap_4
ann_pair('P-124', s2a, spec([[[input,[['A',[10,20]]]],[output,[['B',[20,10]]]]],[[input,[['A',[30,40]]]],[output,[['B',[40,30]]]]]], [[50,60]]), [[60,50]]).
ann_known_gap('P-124', fail).
% swap_5
ann_pair('P-125', s2a, spec([[[input,[['A',[p,q]]]],[output,[['B',[q,p]]]]],[[input,[['A',[r,s]]]],[output,[['B',[s,r]]]]]], [[m,n]]), [[n,m]]).
ann_known_gap('P-125', fail).
% swap_6
ann_pair('P-126', s2a, spec([[[input,[['A',[1,2]]]],[output,[['B',[2,1]]]]],[[input,[['A',[3,4]]]],[output,[['B',[4,3]]]]]], [[a,b]]), [[b,a]]).
ann_known_gap('P-126', fail).
% swap_7
ann_pair('P-127', s2a, spec([[[input,[['A',[x,y]]]],[output,[['B',[y,x]]]]],[[input,[['A',[u,v]]]],[output,[['B',[v,u]]]]]], [[11,12]]), [[12,11]]).
ann_known_gap('P-127', fail).
% swap_8
ann_pair('P-128', s2a, spec([[[input,[['A',[4,7]]]],[output,[['B',[7,4]]]]],[[input,[['A',[9,2]]]],[output,[['B',[2,9]]]]]], [[6,5]]), [[5,6]]).
ann_known_gap('P-128', fail).
% reverse3_1
ann_pair('P-129', s2a, spec([[[input,[['A',[1,2,3]]]],[output,[['B',[3,2,1]]]]],[[input,[['A',[4,5,6]]]],[output,[['B',[6,5,4]]]]]], [[7,8,9]]), [[9,8,7]]).
ann_known_gap('P-129', fail).
% reverse3_2
ann_pair('P-130', s2a, spec([[[input,[['A',[a,b,c]]]],[output,[['B',[c,b,a]]]]],[[input,[['A',[d,e,f]]]],[output,[['B',[f,e,d]]]]]], [[g,h,i]]), [[i,h,g]]).
ann_known_gap('P-130', fail).
% reverse3_3
ann_pair('P-131', s2a, spec([[[input,[['A',[9,8,7]]]],[output,[['B',[7,8,9]]]]],[[input,[['A',[6,5,4]]]],[output,[['B',[4,5,6]]]]]], [[1,2,3]]), [[3,2,1]]).
ann_known_gap('P-131', fail).
% reverse3_4
ann_pair('P-132', s2a, spec([[[input,[['A',[10,20,30]]]],[output,[['B',[30,20,10]]]]],[[input,[['A',[40,50,60]]]],[output,[['B',[60,50,40]]]]]], [[70,80,90]]), [[90,80,70]]).
ann_known_gap('P-132', fail).
% reverse3_5
ann_pair('P-133', s2a, spec([[[input,[['A',[p,q,r]]]],[output,[['B',[r,q,p]]]]],[[input,[['A',[s,t,u]]]],[output,[['B',[u,t,s]]]]]], [[x,y,z]]), [[z,y,x]]).
ann_known_gap('P-133', fail).
% reverse3_6
ann_pair('P-134', s2a, spec([[[input,[['A',[1,2,3]]]],[output,[['B',[3,2,1]]]]],[[input,[['A',[4,5,6]]]],[output,[['B',[6,5,4]]]]]], [[a,b,c]]), [[c,b,a]]).
ann_known_gap('P-134', fail).
% reverse3_7
ann_pair('P-135', s2a, spec([[[input,[['A',[2,4,6]]]],[output,[['B',[6,4,2]]]]],[[input,[['A',[1,3,5]]]],[output,[['B',[5,3,1]]]]]], [[7,9,11]]), [[11,9,7]]).
ann_known_gap('P-135', fail).
% reverse3_8
ann_pair('P-136', s2a, spec([[[input,[['A',[k,l,m]]]],[output,[['B',[m,l,k]]]]],[[input,[['A',[n,o,q]]]],[output,[['B',[q,o,n]]]]]], [[4,5,6]]), [[6,5,4]]).
ann_known_gap('P-136', fail).
% rotate3_1
ann_pair('P-137', s2a, spec([[[input,[['A',[1,2,3]]]],[output,[['B',[2,3,1]]]]],[[input,[['A',[4,5,6]]]],[output,[['B',[5,6,4]]]]]], [[7,8,9]]), [[8,9,7]]).
ann_known_gap('P-137', fail).
% rotate3_2
ann_pair('P-138', s2a, spec([[[input,[['A',[a,b,c]]]],[output,[['B',[b,c,a]]]]],[[input,[['A',[d,e,f]]]],[output,[['B',[e,f,d]]]]]], [[g,h,i]]), [[h,i,g]]).
ann_known_gap('P-138', fail).
% rotate3_3
ann_pair('P-139', s2a, spec([[[input,[['A',[9,8,7]]]],[output,[['B',[8,7,9]]]]],[[input,[['A',[6,5,4]]]],[output,[['B',[5,4,6]]]]]], [[1,2,3]]), [[2,3,1]]).
ann_known_gap('P-139', fail).
% rotate3_4
ann_pair('P-140', s2a, spec([[[input,[['A',[10,20,30]]]],[output,[['B',[20,30,10]]]]],[[input,[['A',[40,50,60]]]],[output,[['B',[50,60,40]]]]]], [[70,80,90]]), [[80,90,70]]).
ann_known_gap('P-140', fail).
% rotate3_5
ann_pair('P-141', s2a, spec([[[input,[['A',[p,q,r]]]],[output,[['B',[q,r,p]]]]],[[input,[['A',[s,t,u]]]],[output,[['B',[t,u,s]]]]]], [[x,y,z]]), [[y,z,x]]).
ann_known_gap('P-141', fail).
% rotate3_6
ann_pair('P-142', s2a, spec([[[input,[['A',[1,2,3]]]],[output,[['B',[2,3,1]]]]],[[input,[['A',[4,5,6]]]],[output,[['B',[5,6,4]]]]]], [[a,b,c]]), [[b,c,a]]).
ann_known_gap('P-142', fail).
% rotate3_7
ann_pair('P-143', s2a, spec([[[input,[['A',[2,4,6]]]],[output,[['B',[4,6,2]]]]],[[input,[['A',[1,3,5]]]],[output,[['B',[3,5,1]]]]]], [[7,9,11]]), [[9,11,7]]).
ann_known_gap('P-143', fail).
% rotate3_8
ann_pair('P-144', s2a, spec([[[input,[['A',[k,l,m]]]],[output,[['B',[l,m,k]]]]],[[input,[['A',[n,o,q]]]],[output,[['B',[o,q,n]]]]]], [[4,5,6]]), [[5,6,4]]).
ann_known_gap('P-144', fail).
% identity_1
ann_pair('P-145', s2a, spec([[[input,[['A',[1,2]]]],[output,[['B',[1,2]]]]],[[input,[['A',[3,4]]]],[output,[['B',[3,4]]]]]], [[7,9]]), [[7,9]]).
ann_known_gap('P-145', fail).
% identity_2
ann_pair('P-146', s2a, spec([[[input,[['A',[5,6]]]],[output,[['B',[5,6]]]]],[[input,[['A',[8,1]]]],[output,[['B',[8,1]]]]]], [[2,7]]), [[2,7]]).
ann_known_gap('P-146', fail).
% identity_3
ann_pair('P-147', s2a, spec([[[input,[['A',[a,b]]]],[output,[['B',[a,b]]]]],[[input,[['A',[c,d]]]],[output,[['B',[c,d]]]]]], [[e,f]]), [[e,f]]).
ann_known_gap('P-147', fail).
% identity_4
ann_pair('P-148', s2a, spec([[[input,[['A',[10,20]]]],[output,[['B',[10,20]]]]],[[input,[['A',[30,40]]]],[output,[['B',[30,40]]]]]], [[50,60]]), [[50,60]]).
ann_known_gap('P-148', fail).
% identity_5
ann_pair('P-149', s2a, spec([[[input,[['A',[p,q]]]],[output,[['B',[p,q]]]]],[[input,[['A',[r,s]]]],[output,[['B',[r,s]]]]]], [[m,n]]), [[m,n]]).
ann_known_gap('P-149', fail).
% identity_6
ann_pair('P-150', s2a, spec([[[input,[['A',[1,2]]]],[output,[['B',[1,2]]]]],[[input,[['A',[3,4]]]],[output,[['B',[3,4]]]]]], [[a,b]]), [[a,b]]).
ann_known_gap('P-150', fail).
% identity_7
ann_pair('P-151', s2a, spec([[[input,[['A',[x,y]]]],[output,[['B',[x,y]]]]],[[input,[['A',[u,v]]]],[output,[['B',[u,v]]]]]], [[11,12]]), [[11,12]]).
ann_known_gap('P-151', fail).
% identity_8
ann_pair('P-152', s2a, spec([[[input,[['A',[4,7]]]],[output,[['B',[4,7]]]]],[[input,[['A',[9,2]]]],[output,[['B',[9,2]]]]]], [[6,5]]), [[6,5]]).
ann_known_gap('P-152', fail).
% first_var_1
ann_pair('P-153', s2a, spec([[[input,[['A',[1]],['B',[2]]]],[output,[['C',[1]]]]],[[input,[['A',[3]],['B',[4]]]],[output,[['C',[3]]]]]], [[7],[9]]), [[7]]).
ann_known_gap('P-153', fail).
% first_var_2
ann_pair('P-154', s2a, spec([[[input,[['A',[5]],['B',[6]]]],[output,[['C',[5]]]]],[[input,[['A',[8]],['B',[1]]]],[output,[['C',[8]]]]]], [[2],[7]]), [[2]]).
ann_known_gap('P-154', fail).
% first_var_3
ann_pair('P-155', s2a, spec([[[input,[['A',[a]],['B',[b]]]],[output,[['C',[a]]]]],[[input,[['A',[c]],['B',[d]]]],[output,[['C',[c]]]]]], [[e],[f]]), [[e]]).
ann_known_gap('P-155', fail).
% first_var_4
ann_pair('P-156', s2a, spec([[[input,[['A',[10]],['B',[20]]]],[output,[['C',[10]]]]],[[input,[['A',[30]],['B',[40]]]],[output,[['C',[30]]]]]], [[50],[60]]), [[50]]).
ann_known_gap('P-156', fail).
% first_var_5
ann_pair('P-157', s2a, spec([[[input,[['A',[p]],['B',[q]]]],[output,[['C',[p]]]]],[[input,[['A',[r]],['B',[s]]]],[output,[['C',[r]]]]]], [[m],[n]]), [[m]]).
ann_known_gap('P-157', fail).
% first_var_6
ann_pair('P-158', s2a, spec([[[input,[['A',[1]],['B',[2]]]],[output,[['C',[1]]]]],[[input,[['A',[3]],['B',[4]]]],[output,[['C',[3]]]]]], [[a],[b]]), [[a]]).
ann_known_gap('P-158', fail).
% first_var_7
ann_pair('P-159', s2a, spec([[[input,[['A',[x]],['B',[y]]]],[output,[['C',[x]]]]],[[input,[['A',[u]],['B',[v]]]],[output,[['C',[u]]]]]], [[11],[12]]), [[11]]).
ann_known_gap('P-159', fail).
% first_var_8
ann_pair('P-160', s2a, spec([[[input,[['A',[4]],['B',[7]]]],[output,[['C',[4]]]]],[[input,[['A',[9]],['B',[2]]]],[output,[['C',[9]]]]]], [[6],[5]]), [[6]]).
ann_known_gap('P-160', fail).
% second_var_1
ann_pair('P-161', s2a, spec([[[input,[['A',[1]],['B',[2]]]],[output,[['C',[2]]]]],[[input,[['A',[3]],['B',[4]]]],[output,[['C',[4]]]]]], [[7],[9]]), [[9]]).
ann_known_gap('P-161', fail).
% second_var_2
ann_pair('P-162', s2a, spec([[[input,[['A',[5]],['B',[6]]]],[output,[['C',[6]]]]],[[input,[['A',[8]],['B',[1]]]],[output,[['C',[1]]]]]], [[2],[7]]), [[7]]).
ann_known_gap('P-162', fail).
% second_var_3
ann_pair('P-163', s2a, spec([[[input,[['A',[a]],['B',[b]]]],[output,[['C',[b]]]]],[[input,[['A',[c]],['B',[d]]]],[output,[['C',[d]]]]]], [[e],[f]]), [[f]]).
ann_known_gap('P-163', fail).
% second_var_4
ann_pair('P-164', s2a, spec([[[input,[['A',[10]],['B',[20]]]],[output,[['C',[20]]]]],[[input,[['A',[30]],['B',[40]]]],[output,[['C',[40]]]]]], [[50],[60]]), [[60]]).
ann_known_gap('P-164', fail).
% second_var_5
ann_pair('P-165', s2a, spec([[[input,[['A',[p]],['B',[q]]]],[output,[['C',[q]]]]],[[input,[['A',[r]],['B',[s]]]],[output,[['C',[s]]]]]], [[m],[n]]), [[n]]).
ann_known_gap('P-165', fail).
% second_var_6
ann_pair('P-166', s2a, spec([[[input,[['A',[1]],['B',[2]]]],[output,[['C',[2]]]]],[[input,[['A',[3]],['B',[4]]]],[output,[['C',[4]]]]]], [[a],[b]]), [[b]]).
ann_known_gap('P-166', fail).
% second_var_7
ann_pair('P-167', s2a, spec([[[input,[['A',[x]],['B',[y]]]],[output,[['C',[y]]]]],[[input,[['A',[u]],['B',[v]]]],[output,[['C',[v]]]]]], [[11],[12]]), [[12]]).
ann_known_gap('P-167', fail).
% second_var_8
ann_pair('P-168', s2a, spec([[[input,[['A',[4]],['B',[7]]]],[output,[['C',[7]]]]],[[input,[['A',[9]],['B',[2]]]],[output,[['C',[2]]]]]], [[6],[5]]), [[5]]).
ann_known_gap('P-168', fail).
% concat_1
ann_pair('P-169', s2a, spec([[[input,[['A',[1]],['B',[2]]]],[output,[['C',[1,2]]]]],[[input,[['A',[3]],['B',[4]]]],[output,[['C',[3,4]]]]]], [[7],[9]]), [[7,9]]).
ann_known_gap('P-169', fail).
% concat_2
ann_pair('P-170', s2a, spec([[[input,[['A',[5]],['B',[6]]]],[output,[['C',[5,6]]]]],[[input,[['A',[8]],['B',[1]]]],[output,[['C',[8,1]]]]]], [[2],[7]]), [[2,7]]).
ann_known_gap('P-170', fail).
% concat_3
ann_pair('P-171', s2a, spec([[[input,[['A',[a]],['B',[b]]]],[output,[['C',[a,b]]]]],[[input,[['A',[c]],['B',[d]]]],[output,[['C',[c,d]]]]]], [[e],[f]]), [[e,f]]).
ann_known_gap('P-171', fail).
% concat_4
ann_pair('P-172', s2a, spec([[[input,[['A',[10]],['B',[20]]]],[output,[['C',[10,20]]]]],[[input,[['A',[30]],['B',[40]]]],[output,[['C',[30,40]]]]]], [[50],[60]]), [[50,60]]).
ann_known_gap('P-172', fail).
% concat_5
ann_pair('P-173', s2a, spec([[[input,[['A',[p]],['B',[q]]]],[output,[['C',[p,q]]]]],[[input,[['A',[r]],['B',[s]]]],[output,[['C',[r,s]]]]]], [[m],[n]]), [[m,n]]).
ann_known_gap('P-173', fail).
% concat_6
ann_pair('P-174', s2a, spec([[[input,[['A',[1]],['B',[2]]]],[output,[['C',[1,2]]]]],[[input,[['A',[3]],['B',[4]]]],[output,[['C',[3,4]]]]]], [[a],[b]]), [[a,b]]).
ann_known_gap('P-174', fail).
% concat_7
ann_pair('P-175', s2a, spec([[[input,[['A',[x]],['B',[y]]]],[output,[['C',[x,y]]]]],[[input,[['A',[u]],['B',[v]]]],[output,[['C',[u,v]]]]]], [[11],[12]]), [[11,12]]).
ann_known_gap('P-175', fail).
% concat_8
ann_pair('P-176', s2a, spec([[[input,[['A',[4]],['B',[7]]]],[output,[['C',[4,7]]]]],[[input,[['A',[9]],['B',[2]]]],[output,[['C',[9,2]]]]]], [[6],[5]]), [[6,5]]).
ann_known_gap('P-176', fail).
% duplicate_1
ann_pair('P-177', s2a, spec([[[input,[['A',[1]]]],[output,[['B',[1,1]]]]],[[input,[['A',[2]]]],[output,[['B',[2,2]]]]]], [[7]]), [[7,7]]).
ann_known_gap('P-177', fail).
% duplicate_2
ann_pair('P-178', s2a, spec([[[input,[['A',[a]]]],[output,[['B',[a,a]]]]],[[input,[['A',[b]]]],[output,[['B',[b,b]]]]]], [[c]]), [[c,c]]).
ann_known_gap('P-178', fail).
% duplicate_3
ann_pair('P-179', s2a, spec([[[input,[['A',[5]]]],[output,[['B',[5,5]]]]],[[input,[['A',[9]]]],[output,[['B',[9,9]]]]]], [[4]]), [[4,4]]).
ann_known_gap('P-179', fail).
% duplicate_4
ann_pair('P-180', s2a, spec([[[input,[['A',[10]]]],[output,[['B',[10,10]]]]],[[input,[['A',[20]]]],[output,[['B',[20,20]]]]]], [[30]]), [[30,30]]).
ann_known_gap('P-180', fail).
% duplicate_5
ann_pair('P-181', s2a, spec([[[input,[['A',[x]]]],[output,[['B',[x,x]]]]],[[input,[['A',[y]]]],[output,[['B',[y,y]]]]]], [[z]]), [[z,z]]).
ann_known_gap('P-181', fail).
% duplicate_6
ann_pair('P-182', s2a, spec([[[input,[['A',[1]]]],[output,[['B',[1,1]]]]],[[input,[['A',[2]]]],[output,[['B',[2,2]]]]]], [[q]]), [[q,q]]).
ann_known_gap('P-182', fail).
% duplicate_7
ann_pair('P-183', s2a, spec([[[input,[['A',[6]]]],[output,[['B',[6,6]]]]],[[input,[['A',[8]]]],[output,[['B',[8,8]]]]]], [[11]]), [[11,11]]).
ann_known_gap('P-183', fail).
% duplicate_8
ann_pair('P-184', s2a, spec([[[input,[['A',[m]]]],[output,[['B',[m,m]]]]],[[input,[['A',[n]]]],[output,[['B',[n,n]]]]]], [[o]]), [[o,o]]).
ann_known_gap('P-184', fail).
% drop_const_1
ann_pair('P-185', s2a, spec([[[input,[['A',[1,3]]]],[output,[['B',[1]]]]],[[input,[['A',[2,3]]]],[output,[['B',[2]]]]]], [[7,3]]), [[7]]).
ann_known_gap('P-185', fail).
% drop_const_2
ann_pair('P-186', s2a, spec([[[input,[['A',[a,3]]]],[output,[['B',[a]]]]],[[input,[['A',[b,3]]]],[output,[['B',[b]]]]]], [[c,3]]), [[c]]).
ann_known_gap('P-186', fail).
% drop_const_3
ann_pair('P-187', s2a, spec([[[input,[['A',[5,3]]]],[output,[['B',[5]]]]],[[input,[['A',[9,3]]]],[output,[['B',[9]]]]]], [[4,3]]), [[4]]).
ann_known_gap('P-187', fail).
% drop_const_4
ann_pair('P-188', s2a, spec([[[input,[['A',[10,3]]]],[output,[['B',[10]]]]],[[input,[['A',[20,3]]]],[output,[['B',[20]]]]]], [[30,3]]), [[30]]).
ann_known_gap('P-188', fail).
% drop_const_5
ann_pair('P-189', s2a, spec([[[input,[['A',[x,3]]]],[output,[['B',[x]]]]],[[input,[['A',[y,3]]]],[output,[['B',[y]]]]]], [[z,3]]), [[z]]).
ann_known_gap('P-189', fail).
% drop_const_6
ann_pair('P-190', s2a, spec([[[input,[['A',[1,3]]]],[output,[['B',[1]]]]],[[input,[['A',[2,3]]]],[output,[['B',[2]]]]]], [[q,3]]), [[q]]).
ann_known_gap('P-190', fail).
% drop_const_7
ann_pair('P-191', s2a, spec([[[input,[['A',[6,3]]]],[output,[['B',[6]]]]],[[input,[['A',[8,3]]]],[output,[['B',[8]]]]]], [[11,3]]), [[11]]).
ann_known_gap('P-191', fail).
% drop_const_8
ann_pair('P-192', s2a, spec([[[input,[['A',[m,3]]]],[output,[['B',[m]]]]],[[input,[['A',[n,3]]]],[output,[['B',[n]]]]]], [[o,3]]), [[o]]).
ann_known_gap('P-192', fail).
% head2_1
ann_pair('P-193', s2a, spec([[[input,[['A',[1,2]]]],[output,[['B',[1]]]]],[[input,[['A',[3,4]]]],[output,[['B',[3]]]]]], [[7,9]]), [[7]]).
ann_known_gap('P-193', fail).
% head2_2
ann_pair('P-194', s2a, spec([[[input,[['A',[5,6]]]],[output,[['B',[5]]]]],[[input,[['A',[8,1]]]],[output,[['B',[8]]]]]], [[2,7]]), [[2]]).
ann_known_gap('P-194', fail).
% head2_3
ann_pair('P-195', s2a, spec([[[input,[['A',[a,b]]]],[output,[['B',[a]]]]],[[input,[['A',[c,d]]]],[output,[['B',[c]]]]]], [[e,f]]), [[e]]).
ann_known_gap('P-195', fail).
% head2_4
ann_pair('P-196', s2a, spec([[[input,[['A',[10,20]]]],[output,[['B',[10]]]]],[[input,[['A',[30,40]]]],[output,[['B',[30]]]]]], [[50,60]]), [[50]]).
ann_known_gap('P-196', fail).
% head2_5
ann_pair('P-197', s2a, spec([[[input,[['A',[p,q]]]],[output,[['B',[p]]]]],[[input,[['A',[r,s]]]],[output,[['B',[r]]]]]], [[m,n]]), [[m]]).
ann_known_gap('P-197', fail).
% head2_6
ann_pair('P-198', s2a, spec([[[input,[['A',[1,2]]]],[output,[['B',[1]]]]],[[input,[['A',[3,4]]]],[output,[['B',[3]]]]]], [[a,b]]), [[a]]).
ann_known_gap('P-198', fail).
% head2_7
ann_pair('P-199', s2a, spec([[[input,[['A',[x,y]]]],[output,[['B',[x]]]]],[[input,[['A',[u,v]]]],[output,[['B',[u]]]]]], [[11,12]]), [[11]]).
ann_known_gap('P-199', fail).
% head2_8
ann_pair('P-200', s2a, spec([[[input,[['A',[4,7]]]],[output,[['B',[4]]]]],[[input,[['A',[9,2]]]],[output,[['B',[9]]]]]], [[6,5]]), [[6]]).
ann_known_gap('P-200', fail).

% ---------------------------------------------------------------------
% Runner
% ---------------------------------------------------------------------

% ann_s2a.pl pre-declares s2a_orig_find_lists3b/2 and
% s2a_orig_rs_and_data_to_term/7 as dynamic before calling install_*, so the
% installers' \+ current_predicate(...) guard fails and the engine switches
% never reach S2A. This installs them as intended.
pairs_install_dispatchers :-
    ( current_predicate(find_lists3b/2),
      predicate_property(s2a_orig_find_lists3b(_,_), number_of_clauses(0)) ->
        abolish(s2a_orig_find_lists3b/2), install_find_lists_dispatcher
    ; true ),
    ( current_predicate(rs_and_data_to_term/7),
      predicate_property(s2a_orig_rs_and_data_to_term(_,_,_,_,_,_,_), number_of_clauses(0)) ->
        abolish(s2a_orig_rs_and_data_to_term/7), install_rs_dispatcher
    ; true ).

run_ann_s2a_pairs(Mode) :-
    memberchk(Mode, [ann, reference]),
    pairs_install_dispatchers,
    findall(R, ( ann_pair(Id, Kind, In, Exp),
                 pair_result(Mode, Id, Kind, In, Exp, R),
                 format('[~w, ~w, ~w]~n', [R, Id, Kind]) ), Rs),
    aggregate_all(count, member(success, Rs), P),
    aggregate_all(count, member(fail, Rs), F),
    aggregate_all(count, member(skip, Rs), K),
    format('ANN-S2A pairs (~w): ~w passed, ~w failed, ~w skipped.~n', [Mode, P, F, K]).

pair_result(_, _, s2a, _, _, skip) :-
    \+ current_predicate(spec_to_algorithm/4), !.
pair_result(_, _, find_lists, Tokens, _, skip) :-
    Tokens = [[split,_]|_], \+ current_predicate(find_lists3b/2), !.
pair_result(Mode, Id, Kind, In, Exp, R) :-
    ( catch(call_with_time_limit(60, pair_output(Mode, Id, Kind, In, Out)), _, fail) -> true
    ; Out = fail ),
    ( Out =@= Exp -> R = success ; R = fail ).

pair_output(ann, _, find_lists, Tokens, Out) :-
    ( ann_find_lists(Tokens, Out) -> true ; Out = fail ).
pair_output(reference, _, find_lists, Tokens, Out) :-
    ( s2a_orig_find_lists3b(Tokens, Out) -> true ; Out = fail ).
pair_output(ann, _, traverse, Pattern-Data, Out) :-
    ( ann_traverse(Pattern, Data, [], Out) -> true ; Out = fail ).
pair_output(reference, _, traverse, Pattern-Data, Out) :-
    ( ann_traverse(Pattern, Data, [order(reference)], Out) -> true ; Out = fail ).
pair_output(Mode, Id, s2a, spec(Specs, Input), Out) :-
    atom_codes(Id, Cs), exclude(==(0'-), Cs, Cs1), atom_codes(Base, Cs1),
    atomic_list_concat([pair_, Mode, '_', Base], Name),
    ( Mode == ann -> Engine = ann ; Engine = recursive ),
    with_output_to(string(_),
        ( Engine == ann -> with_s2a_matcher(ann, ann_spec_to_algorithm(Name, Specs, off, _))
        ; reset_s2a_algs, spec_to_algorithm(Name, Specs, off, _) )),
    retractall(vars_table_s2a(_)), assertz(vars_table_s2a([])),
    Goal =.. [Name, Input, Out0],
    ( with_s2a_matcher(Engine, call(Goal)) -> Out = Out0 ; Out = fail ).
