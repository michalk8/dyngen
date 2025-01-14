#' Initial settings for simulating a dyngen dataset
#' 
#' @param backbone The gene module configuration that determines the type of dynamic 
#'   process being simulated. See [list_backbones()] for a full list of different backbones 
#'   available in this package.
#' @param num_cells The number of cells to sample.
#' @param num_tfs The number of transcription factors (TFs) to generate. TFs are the
#'   main drivers of the changes that occur in a cell. TFs are regulated only by other 
#'   TFs.
#' @param num_targets The number of target genes to generate. Target genes are 
#'   regulated by TFs and sometimes by other target genes.
#' @param num_hks The number of housekeeping genes (HKs) to generate. HKs are 
#'   typically highly expressed, and are not regulated by the TFs or targets.
#' @param distance_metric The distance metric to be used to calculate the distance
#'   between cells. See [dynutils::calculate_distance()] for a list of possible
#'   distance metrics.
#' @param tf_network_params Settings for generating the TF network with 
#'   [generate_tf_network()], see [tf_network_default()]. 
#' @param feature_network_params Settings for generating the feature network with 
#'   [generate_feature_network()], see [feature_network_default()].
#' @param kinetics_params Settings for determining the kinetics of the feature network 
#'   with [generate_kinetics()], see [kinetics_default()].
#' @param gold_standard_params Settings pertaining simulating the gold standard with 
#'   [generate_gold_standard()], see [gold_standard_default()].
#' @param simulation_params Settings pertaining the simulation itself with [generate_cells()],
#'   see [simulation_default()].
#' @param experiment_params Settings related to how the experiment is simulated with 
#'   [generate_experiment()], see [experiment_snapshot()] or [experiment_synchronised()].
#' @param verbose Whether or not to print messages during the simulation.
#' @param download_cache_dir If not `NULL`, temporary downloaded files will be 
#'   cached in this directory.
#' @param num_cores Parallellisation parameter for various steps in the pipeline. 
#'   
#' @export
initialise_model <- function(
  backbone,
  num_cells = 1000,
  num_tfs = 100,
  num_targets = 500,
  num_hks = 400,
  distance_metric = "pearson",
  tf_network_params = tf_network_default(),
  feature_network_params = feature_network_default(),
  kinetics_params = kinetics_default(),
  gold_standard_params = gold_standard_default(),
  simulation_params = simulation_default(),
  experiment_params = experiment_snapshot(),
  verbose = TRUE,
  download_cache_dir = NULL,
  num_cores = 1
) {
  distance_metric <- match.arg(distance_metric)
  
  lst(
    backbone,
    numbers = lst(
      num_cells,
      num_tfs,
      num_targets,
      num_hks,
      num_features = num_tfs + num_targets + num_hks,
      num_modules = nrow(backbone$module_info)
    ),
    distance_metric,
    tf_network_params,
    feature_network_params,
    kinetics_params,
    gold_standard_params,
    simulation_params,
    experiment_params,
    verbose,
    download_cache_dir,
    num_cores
  )
}
formals(initialise_model)$distance_metric <- dynutils::list_distance_methods()