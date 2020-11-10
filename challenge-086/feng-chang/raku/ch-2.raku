#!/bin/env raku

constant @rows-index =
	0..8,    9..17, 18..26,
	27..35, 36..44, 45..53,
	54..62, 63..71, 72..80;
constant @cols-index =
	[0,9,18,27,36,45,54,63,72],
	[1,10,19,28,37,46,55,64,73],
	[2,11,20,29,38,47,56,65,74],
	[3,12,21,30,39,48,57,66,75],
	[4,13,22,31,40,49,58,67,76],
	[5,14,23,32,41,50,59,68,77],
	[6,15,24,33,42,51,60,69,78],
	[7,16,25,34,43,52,61,70,79],
	[8,17,26,35,44,53,62,71,80];
constant @squares-index =
	[0,1,2, 9,10,11, 18,19,20], 
	[3,4,5, 12,13,14, 21,22,23], 
	[6,7,8, 15,16,17, 24,25,26], 
	[27,28,29, 36,37,38, 45,46,47], 
	[30,31,32, 39,40,41, 48,49,50], 
	[33,34,35, 42,43,44, 51,52,53], 
	[54,55,56, 63,64,65, 72,73,74], 
	[57,58,59, 66,67,68, 75,76,77], 
	[60,61,62, 69,70,71, 78,79,80];

sub is-done(@cells where *.elems == 9 --> Bool) {
    @cells.sort eqv (1...9);
}

sub is-complete(@sdk where *.elems == 81 --> Bool) {
    ([and] (0..8)».&{ is-done(@sdk[@rows-index[$_]]) })   and
    ([and] (0..8)».&{ is-done(@sdk[@cols-index[$_]]) })   and
    ([and] (0..8)».&{ is-done(@sdk[@squares-index[$_]]) });
}

sub is-wrong(@cells where *.elems == 9 --> Bool) {
    my @c = @cells.grep(* > 0);
    @c.unique.elems != @c.elems;
}

sub contradict(@sdk where *.elems == 81 --> Bool) {
    ([or] (0..8)».&{ is-wrong(@sdk[@rows-index[$_]]) })   or
    ([or] (0..8)».&{ is-wrong(@sdk[@cols-index[$_]]) })   or
    ([or] (0..8)».&{ is-wrong(@sdk[@squares-index[$_]]) });
}

sub show-solution(@sdk where *.elems == 81) {
    put '=' x 17;
    put @sdk[@rows-index[$_]] for 0..8;
}

my @is-uncertain;

sub solve(@sdk is copy, UInt:D $pos) {
    if is-complete(@sdk) {
        show-solution(@sdk);
        return;
    }
    
    return if contradict(@sdk);

    if @is-uncertain[$pos] {
        for 1..9 -> $i {
            @sdk[$pos] = $i;
            solve(@sdk, $pos + 1);
        }
    } else {
        solve(@sdk, $pos + 1);
    }
}

multi MAIN($data-file) {
    my @puzzle = $data-file.IO.words;
    for 0..80 -> $i {
        if @puzzle[$i] eq '_' {
            @puzzle[$i] = 0;
            @is-uncertain[$i] = True;
        } else {
            @puzzle[$i] .= Int;
            @is-uncertain[$i] = False;
        }
    }

    solve(@puzzle, 0);
}

multi MAIN('test') {
    my @puzzle = 'data.txt'.IO.words;
    for 0..80 -> $i {
        if @puzzle[$i] eq '_' {
            @puzzle[$i] = 0;
        } else {
            @puzzle[$i] .= Int;
        }
    }

    use Test;
    plan 7;

    is contradict(@puzzle), False, 'the initial puzzle has no contradiction';

    @puzzle[0] = 1;
    is is-wrong([1, 0, 0, 2, 6, 0, 7, 0, 1]), True, "two 1's in a row";
    is is-wrong(@puzzle[@rows-index[0]]), True, 'row 1 has contradiction';
    is ([or] (0..8)».&{ is-wrong(@puzzle[@rows-index[$_]]) }), True, 'puzzle has contradiction';
    is contradict(@puzzle), True, '1 at up-left produces contradiction';

    @puzzle[0] = 2;
    is contradict(@puzzle), True, '2 at up-left produces contradiction';

    @puzzle[0] = 3;
    is contradict(@puzzle), False, '3 at up-left has no contradiction';

    done-testing;
}
