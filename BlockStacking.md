# Block Stacking for Perl (v 1.1.0)

This is a Perl port of the [Python version I wrote a little while back](https://github.com/SleepyJay/PlaycodePython/tree/master/BlockStacking). It was run with Perl v5.24.2 (which is what I have last brewed on my laptop). Because I'm using `Modern::Perl '2016'`, you need to be at least that current. Sorry. 

(TODO: maybe remove a lot of this explaination and defer to the Python readme...?)

## Basic Rules

The idea is that you have blocks of certain widths, size 3 and 4.5 (cm, both 1 cm height). With these blocks you want to count how many walls you can build of given dimensions. For each layer of blocks that you stack, they must overlap all seams on the lower layer--where by "seams", I mean the places where the edges of two blocks meet.

The other point was to make this do it efficiently. My first approach ("build walls") was to brute-force my way through by actually making walls. This got very slow, very fast. With a few iterations, I changed techniques (to "count walls") and it became a lot faster (few seconds vs minutes or much worse).
 
## Running
There are a few dependencies required in the cpanfile, so make sure you `cpanm --installdeps .`. 

There are two unit tests, of which, the `t/ut_engine_runs.t` is the more interesting one. That test will run a variety of wall-sizes, count the walls, and time each run.

There is also `run.pl` for doing a single wall size, with timing broken down between the layer creation and wall counting. Also you can print more stuff by option.

## Design Notes
Given the two block sizes, we can can create a set of layers of a certain length. Each of these layers can be combined with each other such that they can or cannot be stacked (by the rule of all "seams" have to be covered). This is a simple matter of comparing the length of paritally built structures: if they ever have the same partial-lengths, then they must overlap (of course, the final length should be the same).

Once you have what can stack on what, you can easily build walls. However, building all of the walls in memory takes a lot of resources. So instead, I start from the top and count all possible stackings as I move down the height. This becomes **significantly** more efficient.

## Comments on Performance

### General Algorithm
Even with some pruning, the brute force approach (where all walls were built as as it runs) only got me as far as 48x4 (before I got bored of waiting). To get to 48x10 and beyond, required improving the code by orders of magnitude. 

Where L is number of possible layers and H is height of walls:

* Layer creation is now ```O(L^2)```, pruned
* Wall counting is now ```O(L^2 * H)```

(I keep the H around in the big-O above, since a thin, REALLY TALL wall might make the height parameter significant.)

### Perl vs Python
In the Python version, ALL of these run in around 4-7 seconds (on my computer). The bulk of the time is still in testing stacking.

```
* 48x2:                   37,120 walls
* 48x4:               10,178,548 walls
* 48x6:            3,919,649,942 walls
* 48x8:        1,722,438,038,790 walls
* 48x10:     806,844,323,190,414 walls
* 48x12: 392,312,088,153,557,198 walls
```

In the Perl code at version 1.0 the layer stacking at 48-width was taking 18-20 seconds. I removed Moose and simplified the width-compare code to avoid hash-look ups. This got it down to about 11 seconds (v1.0.1). 

This was a huge disappointment. I would have expected pretty much any code to be faster in Perl. But, Python's `set` and `in` are apparently much faster than `exists` on a Perl hash. 

Then in v1.1.0, I used a search tree strategy that takes under 1 second. Finally, Perl is redeemed... although to be fair, I wonder what Python's runtime would be with a similar tree-strategy...hmm.
 
Wall counting is still blazing fast (sub-second). 

  
## Version Notes

### Version 1.1.0:
* FINALLY... blazing speed. 48x12 in 0.45 seconds! Take that Python!

### Version 1.0.1:
* Speed up layer stacking by removing Moose and some hash lookups. Still slower than Python.

### Version 1.0:
* Pretty much a direct port from the Python code
* Layer creation at the 48-width is painfully slow (like ~20 seconds).
