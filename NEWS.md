# dyngen 0.2.2 (unreleased)

* MINOR CHANGES: Fix module naming of backbones derived from `backbone_branching()`.

* MINOR CHANGES: Allow to plot labels in `plot_simulation_expression()`.

* FIX: Implement fix for double positives in `bblego` backbones.

* FIX: Fix graph plotting mixup of interaction effects (up/down).

* MINOR CHANGES: Improve `backbone_disconnected()` and `backbone_converging()`.

# dyngen 0.2.1 (2019-07-17)

* MAJOR CHANGES: Custom backbones can be defined using backbone lego pieces. See `?bblego` for more information.

* MAJOR CHANGES: Splicing reactions have been reworked to better reflect biology.

# dyngen 0.2.0 (2019-07-12)

Complete rewrite from `dyngen` from the bottom up.
 
* OPTIMISATION: All aspects of the pipeline have been optimised towards execution time and end-user usability.

* OPTIMISATION: `dyngen` 0.2.0 uses `gillespie` 0.2.0, which has also been rewritten entirely in `Rcpp`,
  thereby improving the speed significantly.
  
* OPTIMISATION: The transcription factor propensity functions have been refactored to make it much more 
  computationally efficient.
  
* OPTIMISATION: Mapping a simulation to the gold standard is more automised and less error-prone.

* FEATURE: A splicing step has been added to the chain of reaction events.

# dyngen 0.1.0 (2017-04-27)

 * INITIAL RELEASE: a package for generating synthetic single-cell data from regulatory networks.
   Key features are:
   
   - The cells undergo a dynamic process throughout the simulation.
   - Many different trajectory types are supported.
   - `dyngen` 0.1.0 uses `gillespie` 0.1.0, a clone of `GillespieSSA` that is much less
     error-prone and more efficient than `GillespieSSA`.

# dyngen 0.0.1 (2016-04-04)

 * Just a bunch of scripts on a repository, which creates random networks using `igraph` and 
   generates simple single-cell expression data using `GillespieSSA`.