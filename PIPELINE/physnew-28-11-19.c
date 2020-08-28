// plant mitochondrial simulation v0.7

// merger of simulation and network analysis and physical analysis code

// some debugging since 0.6: mem leak in "useless" trajectories fixed, endless loop for pair avoidance removed, command-line options added to allow single simulation (outputting trajectories, summary stats, and network structures) or long inference run
// looks like there's still a memory leak somewhere, and periodicity in random number output. latter problem may have been fixed by save+restore of random number seed

// a population of mitochondria (mitos) in a model cell are simulated undergoing stochastic motion
// motion can be influenced by linear cytoskeletal strands which scale and direct motion
// motion can be influence by interactions between mitos which scale motion
// mitos are constrained by reflecting edge of cell, and in an edge zone can be removed and respawned elsewhere in edge zone
// mitochondria now repel each other and may have hydrodynamic influence over others
// we now run the simulation for an initial equilibration period before outputting, to lose memory of the initial conditions
// command-line parameters specify physical dynamics
// output is structured to match trajectories from ImageJ's Mosaic Particle Tracker and consists of frame-by-frame mito co-ordinates with unique "trajectory" label for each mito

// adding to the above extraction, we'll now attempt to use the igraph library to compute summary statistics for each adjacency matrix
// the igraph library comes from here https://igraph.org/c/#ctut and has a libxml2-dev dependency
// on IGJ's machine this needs -I/usr/local/include/igraph -L/usr/local/lib/ -ligraph
// on JMC'c machine this is gcc physnew-28-11-19.c -I/usr/local/include/igraph -L/usr/local/lib/ -ligraph -lm -o physnew-28-11-19.ce

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <igraph.h>
#include <string.h>

#define _VERBOSE 0
#define _FULLRSEED 107

#define PI 3.1415927
#define RND drand48()

// definitions for program structure/memory allocation
#define MAXCYT 100
#define MAXMITO 1000
#define MAXT 202

// maximum number of trajectories
#define MAXM 100000
#define MAXE 1000000

// structure describing physical parameters
typedef struct tagParams
{
  int NCYT;         // number of cytoskeletal strands
  int NMITO;        // number of mitos
  int STEPTYPE;     // gaussian vs levy dynamics
  double STEPPARAM; // parameter for motion
  double CYTDIST;   // attachment distance for cytoskeleton
  double CYTATTACH; // attachment rate for cytoskeleton
  double CYTDETACH; // detachment rate for cytoskeleton
  double MITDIST;   // interaction range for mito pairs
  double MITSPEED;  // motion scaling for mito-mito interaction
  double CYTSPEED;  // motion scaling for cytoskeletal interaction
  double EDGELOSS;  // rate of mito loss from edge zone
  double HYDRO;     // strength of hydrodynamic interaction
  int RSEED;        // random number seed -- TO BE DISCUSSED
} Params;

// structure describing network summary statistics
typedef struct tagStatistics
{
  int numedges[MAXT];
  int numvertices[MAXT];
  double meandegree[MAXT];
  int maxdegree[MAXT];
  double meanbc[MAXT];
  double maxbc[MAXT];
  int nccs[MAXT];
  int maxccsize[MAXT];
  int singletoncount[MAXT];
  double meancolocalisation[MAXT];
  double sdcolocalisation[MAXT];
} Statistics;

// structure describing physical summary statistics
typedef struct tagPhysicalStatistics
{
  double meanspeed[MAXT];
  double sdspeed[MAXT];
  double meanangle[MAXT];
  double sdangle[MAXT];
  double meanhull[MAXT]; // not yet implemented
  double sdhull[MAXT];   // not yet implemented
} PhysicalStatistics;

// these parameters aren't (yet) set via the command line; they just reflect physical aspects of the model
int CELLX = 30;       // cell x dimension
int CELLY = 100;      // cell y dimension
double EDGEBOUND = 4; // width of the cellular edge zone
double REPEL = 1;     // repulsive core of a mito
int EQUIL = 1000;     // equilibration period

// which frames shall we compute stats for?
int frames_to_record[MAXT];

// structure for cytoskeletal strands (linear representations)
typedef struct tagCytoset
{
  int n;
  double m[MAXCYT], c[MAXCYT];
  int dirn[MAXCYT];
} Cytoset;

// structure for mitochondrial population
typedef struct tagMitoset
{
  int n;
  double x[MAXMITO], y[MAXMITO];
  int trajlabel[MAXMITO];
  int trajlength[MAXMITO];
  int cytinteract[MAXMITO];
} Mitoset;

// housekeeping function used to remove pointer set for connected graph components
void free_complist(igraph_vector_ptr_t *complist)
{
  long int i;
  for (i = 0; i < igraph_vector_ptr_size(complist); i++)
  {
    igraph_destroy(VECTOR(*complist)[i]);
    free(VECTOR(*complist)[i]);
  }
}

// generate a gaussian variate, taken from GSL
double gsl_ran_gaussian(const double sigma)
{
  double x, y, r2;

  do
  {
    /* choose x,y in uniform square (-1,-1) to (+1,+1) */

    x = -1 + 2 * RND;
    y = -1 + 2 * RND;

    /* see if it is in the unit circle */
    r2 = x * x + y * y;
  } while (r2 > 1.0 || r2 == 0);

  /* Box-Muller transform */
  return sigma * y * sqrt(-2.0 * log(r2) / r2);
}

// generate the displacement vector (dx, dy) for a step from the given regime
void GetStep(double *dx, double *dy, int steptype, double stepparam)
{
  double f, theta;

  if (steptype == 0)
  {
    // gaussian step
    *dx = gsl_ran_gaussian(stepparam);
    *dy = gsl_ran_gaussian(stepparam);
  }
  else
  {
    // levy step
    theta = RND * 2 * 3.14159;
    f = pow(RND, -1. / stepparam);
    *dx = f * cos(theta);
    *dy = f * sin(theta);
  }
}

// check if "label"th mito is within interaction range of a cytoskeletal strand
// return the index for that strand if so
int InteractCyto(Mitoset M, Cytoset C, Params P, int label)
{
  int i;
  double mindist;
  int minref;
  double dist;
  double x0, y0, x1, y1, x2, y2;

  // distance (x0, y0) from ax + by + c = 0 is
  // | a x0 + b y0 + c | / sqrt(a^2 + b^2)
  // we have b -> 1, a -> -m, c -> -c
  // | - m x0 + y0 - c | / sqrt(m^2 + 1)

  mindist = -1;
  minref = 0;
  for (i = 1; i < C.n; i++)
  {
    x0 = M.x[label];
    y0 = M.y[label];
    x1 = 0;
    y1 = C.c[i];
    x2 = 1;
    y2 = C.m[i] + C.c[i];

    dist = fabs((y2 - y1) * x0 - (x2 - x1) * y0 + x2 * y1 - y2 * x1) / sqrt((y2 - y1) * (y2 - y1) + (x2 - x1) * (x2 - x1));

    if (mindist == -1 || dist < mindist)
    {
      mindist = dist;
      minref = i;
    }
  }
  if (mindist != -1 && mindist < P.CYTDIST)
    return minref;
  return 0;
}

// check if the "label"th mito is within interaction range of another mito
// return shortest distance to another mito
double InteractMito(Mitoset M, Cytoset C, int label)
{
  int i;
  double mindist;
  int minref;
  double dist;

  mindist = -1;
  minref = -1;
  for (i = 0; i < M.n; i++)
  {
    if (i != label)
    {
      dist = (M.x[i] - M.x[label]) * (M.x[i] - M.x[label]) + (M.y[i] - M.y[label]) * (M.y[i] - M.y[label]);
      if (mindist == -1 || dist < mindist)
      {
        mindist = dist;
        minref = i;
      }
    }
  }
  return mindist;
}

// use igraph library to get network statistics for a given set of trajectories
// stores them in structure S

//Jo notes: *fp is the file input
//			 *mset is the set of mitos
//			 *n is I think the current trajectory
//			 *xset is the cordinate of the mit at the current x position in the list
//			 *yset is the cordinate of the mit at the current y position in the list
//			 *nframe is total number of frames

int GetNetworkStats(int *mset, int *n, double *xset, double *yset, int nframe, double cutoff, Statistics *S, int FILEOUT, char *fstr)
{
  FILE *fp;
  int i, j, k, l, m;
  int ref, mref;
  char str[2000];
  int nmito;
  int *am;
  double d;
  int nam = 0;
  int ci, found;
  int *singletons;
  int *thisframe, *colocalisation, *bestcolocalisation;
  int tmp;
  double meanc, sdc;

  printf("*mset is %i\n", *mset);
  printf("*n is %i\n", *n);
  printf("*xset is %f\n", *xset);
  printf("*yset is %f\n", *yset);
  printf("nframe is %i\n", nframe);

  if (FILEOUT)
  {
    fp = fopen(fstr, "w");
  }

  // allocate memory for arrays
  am = (int *)malloc(sizeof(int) * MAXE * 2);
  singletons = (int *)malloc(sizeof(int) * MAXM);
  thisframe = (int *)malloc(sizeof(int) * MAXE);
  colocalisation = (int *)malloc(sizeof(int) * MAXE);
  bestcolocalisation = (int *)malloc(sizeof(int) * MAXE);

  // now we do the processing

  nam = 0;

  // initialise singletons list
  for (i = 0; i < MAXM; i++)
    singletons[i] = 0;

  // loop through frames
  for (i = 0; i < nframe - 1; i++)
  {
    if (_VERBOSE)
      printf("Processing frame %i ", i);

    // reset colocalisation tracker for this frame
    for (l = 0; l < nam; l++)
    {
      thisframe[l] = 0;
    }

    // register mitos that come into view in this frame as singletons
    for (l = 0; l < n[i]; l++)
    {
      if (singletons[mset[MAXM * i + l]] == 0)
        singletons[mset[MAXM * i + l]] = 1;
    }

    // loop through pairs of mitos in this frame
    // here, the label of the lth mito in frame i is mset[MAXM*i+l]. because we build up the social network progressively through time, all labels up to the current highest label will be nodes in the social network (although some labels will correspond to mitos that have disappeared from the system).
    for (l = 0; l < n[i]; l++)
    {
      for (m = l + 1; m < n[i]; m++)
      {
        j = mset[MAXM * i + l];
        k = mset[MAXM * i + m];
        if (j > k)
        {
          tmp = k;
          k = j;
          j = tmp;
        }

        // compute separation
        d = (xset[MAXM * i + l] - xset[MAXM * i + m]) * (xset[MAXM * i + l] - xset[MAXM * i + m]) + (yset[MAXM * i + l] - yset[MAXM * i + m]) * (yset[MAXM * i + l] - yset[MAXM * i + m]);
        d = sqrt(d);

        // if we're close...
        if (d < cutoff)
        {
          // see if we already have this pair, if not, add to historical adjacency matrix
          found = 0;
          for (ci = 0; ci < nam && found == 0; ci++)
          {
            if ((am[(ci * 2) + 0] == j && am[(ci * 2) + 1] == k)) // || (am[(ci * 2) + 0] == k && am[(ci * 2) + 1] == j)) // commented as we now insist the lower trajectory label comes first
            {
              found = 1;
              thisframe[ci] = 1;
              break;
            }
          }
          if (found == 0)
          {
            am[(nam * 2) + 0] = j;
            am[(nam * 2) + 1] = k;
            thisframe[nam] = 1;
            colocalisation[nam] = bestcolocalisation[nam] = 0;
            singletons[j] = singletons[k] = 2;
            nam++;
          }
        }
      }
    }

    for (l = 0; l < nam; l++)
    {
      // if this pair of mitos is (still) interacting in this frame, increment colocalisation counter, and best colocalisation score if it's exceeded
      if (thisframe[l] == 1)
      {
        colocalisation[l]++;
        if (colocalisation[l] > bestcolocalisation[l])
          bestcolocalisation[l] = colocalisation[l];
      }
      else
      {
        // otherwise reset counter for this pair
        colocalisation[l] = 0;
      }
    }

    // previously we would just output these adjacency matrices to a file
    // now let's try and use them in igraph

    if (!frames_to_record[i])
    {
      S->numedges[i] = S->numvertices[i] = S->meandegree[i] = S->maxdegree[i] = S->meanbc[i] = S->maxbc[i] = S->nccs[i] = S->maxccsize[i] = S->singletoncount[i] = S->meancolocalisation[i] = S->sdcolocalisation[i] = -1;
    }
    else
    {
      igraph_t graph;
      igraph_vector_t v;
      igraph_vector_t result;
      igraph_vector_t toremove;
      igraph_real_t edges[nam * 2];
      igraph_vector_ptr_t complist;
      igraph_vs_t toselectremove;

      int featuredset[MAXM];
      int singleton_count;
      int max;
      int max_cc_size;

      // initialise max label tracker and singleton identifier
      max = 0;
      for (j = 0; j < MAXM; j++)
        featuredset[i] = 0;

      // loop through edges in historical adjacency matrix. if a node features in an edge, mark it in "featuredset", the complement of which contains singletons
      for (j = 0; j < nam * 2; j++)
      {
        edges[j] = am[j];
        featuredset[am[j]] = 1;
        if (am[j] > max)
          max = am[j];
      }

      // initialise a vector to remove singletons, and store node labels therein
      igraph_vector_init(&toremove, 0);
      for (j = 0; j < max; j++)
      {
        if (featuredset[j] == 0)
          igraph_vector_push_back(&toremove, j);
      }
      igraph_vs_vector(&toselectremove, &toremove);

      // create graph, remove singletons
      igraph_vector_view(&v, edges, nam * 2);
      igraph_create(&graph, &v, 0, IGRAPH_UNDIRECTED);
      igraph_delete_vertices(&graph, toselectremove);
      igraph_vector_init(&result, 0);

      // the following lines add igraph stats to the summary statistics structure
      igraph_degree(&graph, &result, igraph_vss_all(), IGRAPH_ALL, IGRAPH_LOOPS);
      S->numedges[i] = (int)igraph_ecount(&graph);
      S->numvertices[i] = (int)igraph_vcount(&graph);
      S->meandegree[i] = (double)igraph_vector_sum(&result) / igraph_vector_size(&result);
      S->maxdegree[i] = (int)igraph_vector_max(&result);

      if (_VERBOSE)
        printf("edges: %i vertices: %i\n", S->numedges[i], S->numvertices[i]);

      igraph_betweenness(&graph, &result, igraph_vss_all(), IGRAPH_UNDIRECTED, 0, 1);
      S->meanbc[i] = (double)igraph_vector_sum(&result) / igraph_vector_size(&result);
      S->maxbc[i] = (double)igraph_vector_max(&result);

      // connected component statistics
      igraph_vector_ptr_init(&complist, 0);
      igraph_decompose(&graph, &complist, IGRAPH_WEAK, -1, 0);

      max_cc_size = 0;
      S->nccs[i] = (int)igraph_vector_ptr_size(&complist);
      for (j = 0; j < igraph_vector_ptr_size(&complist); j++)
      {
        if (((int)igraph_vcount(VECTOR(complist)[j])) > max_cc_size)
          max_cc_size = (int)igraph_vcount(VECTOR(complist)[j]);
      }
      free_complist(&complist);
      S->maxccsize[i] = max_cc_size;

      igraph_destroy(&graph);
      igraph_vector_destroy(&result);
      igraph_vector_destroy(&toremove);

      // singleton count
      singleton_count = 0;
      for (j = 0; j < MAXM; j++)
      {
        if (singletons[j] == 1)
          singleton_count++;
      }
      S->singletoncount[i] = singleton_count;

      // record colocalisation statistics
      meanc = sdc = 0;
      for (j = 0; j < nam; j++)
      {
        meanc += bestcolocalisation[j];
      }
      meanc /= nam;
      for (j = 0; j < nam; j++)
      {
        sdc += (bestcolocalisation[j] - meanc) * (bestcolocalisation[j] - meanc);
      }
      sdc = sqrt(sdc / (nam - 1));

      S->meancolocalisation[i] = meanc;
      S->sdcolocalisation[i] = sdc;
    }

    if (FILEOUT)
    {
      for (j = 0; j < MAXM; j++)
      {
        if (singletons[j] == 1)
          fprintf(fp, "%i %i -1\n", i, j);
      }

      for (ci = 0; ci < nam; ci++)
      {
        fprintf(fp, "%i %i %i\n", i, am[(ci * 2) + 0], am[(ci * 2) + 1]);
      }
    }
  }

  free(am);
  free(singletons);
  free(thisframe);
  free(colocalisation);
  free(bestcolocalisation);

  if (FILEOUT)
  {
    fclose(fp);
  }
}

// get physical summary statistics for a given set of trajectories
// store them in structure PS
int GetPhysicalStats(int *mset, int *n, double *xset, double *yset, int nframe, PhysicalStatistics *PS)
{
  int i, j, k, l;
  int nspeed, ntheta;
  double meanspeed, sdspeed, meantheta, sdtheta;
  double x2, y2, x1, y1, x0, y0;
  int thislabel;
  double dotprod, norm, theta[MAXM];
  double speed[MAXM];
  double tmp;

  // loop through frames
  for (i = 0; i < nframe - 1; i++)
  {
    if (_VERBOSE)
      printf("Processing frame %i\n", i);

    nspeed = ntheta = 0;
    // loop through mitos in this frame
    for (l = 0; l < n[i]; l++)
    {
      thislabel = mset[MAXM * i + l];
      x2 = xset[MAXM * i + l];
      y2 = yset[MAXM * i + l];

      // search for appearances in previous two frames
      x1 = y1 = x0 = y0 = -1;
      if (i > 0)
      {
        for (j = 0; j < n[i - 1]; j++)
        {
          if (mset[MAXM * (i - 1) + j] == thislabel)
          {
            x1 = xset[MAXM * (i - 1) + j];
            y1 = yset[MAXM * (i - 1) + j];
          }
        }
      }
      if (i > 1)
      {
        for (j = 0; j < n[i - 2]; j++)
        {
          if (mset[MAXM * (i - 2) + j] == thislabel)
          {
            x0 = xset[MAXM * (i - 2) + j];
            y0 = yset[MAXM * (i - 2) + j];
          }
        }
      }

      // if we found a position in the previous frame, we can compute a speed
      if (x1 != -1)
      {
        speed[nspeed++] = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
      }

      // if we found a position in the previous two frames, we can compute an angle
      if (x0 != -1 && x1 != -1)
      {
        dotprod = (x2 - x1) * (x1 - x0) + (y2 - y1) * (y1 - y0);
        norm = sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1)) * sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0));

        tmp = acos(dotprod / norm) * 180 / PI;
        if (!isnan(tmp))
          theta[ntheta++] = tmp;
      }
    }

    // take averages of speeds and angles for this frame
    // averaging angles is of course a bit funny
    meanspeed = sdspeed = meantheta = sdtheta = 0;
    for (l = 0; l < nspeed; l++)
      meanspeed += speed[l];
    meanspeed /= nspeed;
    for (l = 0; l < ntheta; l++)
      meantheta += theta[l];

    // some checks here to make sure we're computing angles. if mitos aren't moving, we get NaNs creeping in here
    if (ntheta == 0 && i > 2)
      printf("no angles\n");
    meantheta /= ntheta;
    //       if(isnan(meantheta))
    //	  printf("wtf l457\n");

    // SDs of physical statistics -- again SD of angle is a bit odd
    for (l = 0; l < nspeed; l++)
      sdspeed += (speed[l] - meanspeed) * (speed[l] - meanspeed);
    sdspeed = sqrt(sdspeed / (nspeed - 1));
    for (l = 0; l < ntheta; l++)
      sdtheta += (theta[l] - meantheta) * (theta[l] - meantheta);
    sdtheta = sqrt(sdtheta / (ntheta - 1));

    PS->meanspeed[i] = meanspeed;
    PS->sdspeed[i] = sdspeed;
    PS->meanangle[i] = meantheta;
    PS->sdangle[i] = sdtheta;
  }
}
// SIMULATE SIMULATE SIMULATE SIMULATE SIMULATE 
// simulate the behaviour of parameterisation P
// store resulting trajectories and also output to file
// we run the simulation for 1000 equilibration timesteps then for a further number of frames
int Simulate(Params P, int *data_mset, int *data_n, double *data_xset, double *data_yset, int FILEOUT)
{
  Cytoset C;
  Mitoset M, newM;
  int cyt, mit;
  double dx, dy;
  int i, j;
  double s;
  int t;
  int steptype;
  double stepparam;
  FILE *fp;
  char fstr[1000];
  int maxtrajlabel;
  int ref = 0;
  int newedge;
  int change;
  double angle;
  double dist, thisdx, thisdy;
  int output;
  int fref;
  int debugout = 0;

  srand48(P.RSEED);
  printf("PARAS ARE %i  %i  %.3f  %.3f  %.3f  %.3f  %.3f  %.3f  %.3f  %i  %.3f  %.3f  %i\n", P.NCYT, P.NMITO, P.EDGELOSS, P.CYTDIST, P.CYTATTACH, P.CYTDETACH, P.CYTSPEED, P.MITDIST, P.MITSPEED, P.STEPTYPE, P.STEPPARAM, P.HYDRO, P.RSEED);
  printf("P.RSEED is %i\n", P.RSEED);
  // construct random cytoskeletal strands
  // i here changed to 0 from 1 on 2/4/20, was bugging to make mitos jump to infinity as cyto 0 wasn't initialising.
  C.n = P.NCYT;
  for (i = 0; i < P.NCYT; i++)
  {
    C.m[i] = tan(RND * 2 * PI);
    C.c[i] = RND * CELLY;
    C.dirn[i] = (RND < 0.5 ? -1 : 1);
  }

  // output strands to file
  if (FILEOUT)
  {
    sprintf(fstr, "simoutput-%i-%i-%.3f-%.3f-%.3f-%.3f-%.3f-%.3f-%.3f-%i-%.3f-%.3f-%i.cyt.txt", P.NCYT, P.NMITO, P.EDGELOSS, P.CYTDIST, P.CYTATTACH, P.CYTDETACH, P.CYTSPEED, P.MITDIST, P.MITSPEED, P.STEPTYPE, P.STEPPARAM, P.HYDRO, P.RSEED);
    fp = fopen(fstr, "w");
    for (i = 0; i < CELLX; i++)
    {
      for (j = 0; j < P.NCYT; j++)
        fprintf(fp, "%i %f\n", i, C.m[j] * i + C.c[j]);
    }
    fclose(fp);
  }

  // initialise output file for mito trajectories
  if (FILEOUT)
  {
    sprintf(fstr, "simoutput-%i-%i-%.3f-%.3f-%.3f-%.3f-%.3f-%.3f-%.3f-%i-%.3f-%.3f-%i.txt", P.NCYT, P.NMITO, P.EDGELOSS, P.CYTDIST, P.CYTATTACH, P.CYTDETACH, P.CYTSPEED, P.MITDIST, P.MITSPEED, P.STEPTYPE, P.STEPPARAM, P.HYDRO, P.RSEED);
    fp = fopen(fstr, "w");
    fprintf(fp, "Obs_index\tTrajectory\tFrame\tx\ty\tz\tm0\tm1\tm2\tm3\tm4\tNPscore\n");
  }

  // initialise population with random positions
  ref = 0;

  M.n = P.NMITO;
  for (i = 0; i < M.n; i++)
  {
    M.x[i] = RND * CELLX;
    M.y[i] = RND * CELLY;
    M.cytinteract[i] = 0;
    M.trajlabel[i] = i;
    M.trajlength[i] = 0;
  }
  maxtrajlabel = i;

  steptype = P.STEPTYPE;
  stepparam = P.STEPPARAM;

  output = 0;
  // loop through simulation time
  for (t = 0; t < EQUIL + MAXT; t++)
  {
    if (_VERBOSE)
      printf("Time is %i . Maxtrajlabel is %i . P.NMITO is %i\n", t, maxtrajlabel, P.NMITO);
    // if we're done with the equilibration period, reset labels so we can start outputting
    if (t > EQUIL && output == 0)
    {
      output = 1;
      for (i = 0; i < M.n; i++)
      {
        M.trajlabel[i] = i;
        M.trajlength[i] = 0;
      }
      maxtrajlabel = i;
    }

    if (output == 1)
    {
      fref = t - EQUIL - 1;
      data_n[fref] = 0;
    }

    newM = M;

    // loop through mitos

    for (i = 0; i < P.NMITO; i++)
    {
      debugout=0;
      if (output == 1 && fref == 57 && M.trajlabel[i] == 10) debugout = 1;
      // decide whether to detach from cytoskeleton
      if (M.cytinteract[i] && RND < P.CYTDETACH)
        newM.cytinteract[i] = 0;
      // decide whether to attach to cytoskeleton (strand index "cyt")
      cyt = InteractCyto(M, C, P, i);
      if (cyt)
      {
        if (RND < P.CYTATTACH)
          newM.cytinteract[i] = cyt;
      }
      // check if interacting with other mitos
      mit = InteractMito(M, C, i);

      // get a step for this mito
      GetStep(&dx, &dy, steptype, stepparam);

      if(debugout == 1) {
        printf("1st print is dx is %f dy is %f\n", dx, dy);
      } 

      if (mit < P.MITDIST) // scale step because we're interacting
      {
        dx *= P.MITSPEED;
        dy *= P.MITSPEED;
      }

      if(debugout == 1) {
        printf("2nd print is dx is %f dy is %f\n", dx, dy);
      } 

      if (newM.cytinteract[i] == 0) // no cytoskeletal interaction: apply step
      {
        thisdx = dx;
        thisdy = dy;

        if(debugout == 1) {
          printf("IF::: thisdx is %f thisdy is %f\n", thisdx, thisdy);
        } 
      }
      else // bound to cytoskeletal strand: scale step and align with strand
      {
        s = sqrt(dx * dx + dy * dy) * P.CYTSPEED;
        thisdx = s * (1. / sqrt(C.m[M.cytinteract[i]] * C.m[M.cytinteract[i]] + 1)) * C.dirn[M.cytinteract[i]];
        thisdy = s * (1. / sqrt(C.m[M.cytinteract[i]] * C.m[M.cytinteract[i]] + 1)) * C.dirn[M.cytinteract[i]] * C.m[M.cytinteract[i]];

        if(debugout == 1) {
          printf("ELSE::: thisdx is %f thisdy is %f , strand %i m is %f dirn is %d s is %f\n", thisdx, thisdy, M.cytinteract[i], C.m[M.cytinteract[i]], C.dirn[M.cytinteract[i]], s);
        }
      
        // s^2 = x^2 + y^2
        // y = m x
        // s^2 = x^2 + m^2 x^2
        // x^2 = s^2 / (1 + m^2)
      }
      newM.x[i] += thisdx;
      newM.y[i] += thisdy;
      //	  if(!(newM.x[i] >= 0 && newM.x[i] <= CELLX) || !(newM.y[i] >= 0 && newM.y[i] <= CELLY))
      //	    printf("wtf l605 %f %f\n", newM.x[i], newM.y[i]);

      // apply hydrodynamic interactions to nearby mitos
      for (j = 0; j < P.NMITO; j++)
      {
        if (i != j)
        {
          dist = sqrt((M.x[i] - M.x[j]) * (M.x[i] - M.x[j]) + (M.y[i] - M.y[j]) * (M.y[i] - M.y[j]));
          if (dist <= REPEL)
            dist = REPEL;
          if (dist < 0.001)
            printf("wtf l634\n");
          newM.x[j] += thisdx * P.HYDRO / dist;
          newM.y[j] += thisdy * P.HYDRO / dist;
          if (isnan(newM.x[j]) || isnan(newM.y[j]))
            printf("wtf l613 %f %f %f %f %f\n", newM.x[i], newM.y[i], newM.x[j], newM.y[j], dist);
        }
      }
    }

    // this section tries to get rid of overlapping mito pairs by moving overlappin mitos away from each other
    // in practise for some parameterisations this may never stabilise -- i.e. moving a mito out of one overlap will cause it to experience another
    // we don't have a full physical resolution of this, but instead just allow one move per timeframe to avoid a neverending situation
    //      change = 1;
    //while(change == 1)
    {
      change = 0;
      for (i = 0; i < P.NMITO; i++)
      {
        for (j = i + 1; j < P.NMITO; j++)
        {
          dist = sqrt((M.x[i] - M.x[j]) * (M.x[i] - M.x[j]) + (M.y[i] - M.y[j]) * (M.y[i] - M.y[j]));
          if (dist < REPEL)
          {
            change = 1;
            angle = RND * 2. * PI;
            thisdx = 1.5 * dist * cos(angle);
            thisdy = 1.5 * dist * sin(angle);
            newM.x[i] -= thisdx;
            newM.y[i] -= thisdy;
            newM.x[j] += thisdx;
            newM.y[j] += thisdy;
          }
        }
      }
    }

    M = newM;

    for (i = 0; i < P.NMITO; i++)
    {
      if (i > MAXMITO)
        printf("wtf l647\n");

      // reflecting boundary conditions
      if (M.x[i] > CELLX)
        M.x[i] = CELLX;
      if (M.y[i] > CELLY)
        M.y[i] = CELLY;
      if (M.x[i] < 0)
        M.x[i] = 0;
      if (M.y[i] < 0)
        M.y[i] = 0;

      // if we're in the cell edge zone, we may die and respawn
      if ((CELLX - M.x[i] < EDGEBOUND) || (M.x[i] - 0 < EDGEBOUND) || (CELLY - M.y[i] < EDGEBOUND) || (M.y[i] - 0 < EDGEBOUND))
      {
        if (RND < P.EDGELOSS) // die and respawn
        {
          // pick respawn position
          if (RND < (double)CELLX / (CELLX + CELLY))
            newedge = (RND < 0.5 ? 0 : 2);
          else
            newedge = (RND < 0.5 ? 1 : 3);

          switch (newedge)
          {
          case 0:
            M.y[i] = CELLY;
            M.x[i] = RND * CELLX;
            break;
          case 1:
            M.y[i] = RND * CELLY;
            M.x[i] = CELLX;
            break;
          case 2:
            M.y[i] = 0;
            M.x[i] = RND * CELLX;
            break;
          case 3:
            M.y[i] = RND * CELLY;
            M.x[i] = 0;
            break;
          }

          // reinitialise new trajectory
          M.cytinteract[i] = 0;
          M.trajlabel[i] = maxtrajlabel++;
          M.trajlength[i] = 0;
        }
      }
      M.trajlength[i]++;

      if (output == 1)
      {
        data_mset[fref * MAXM + data_n[fref]] = M.trajlabel[i];
        data_xset[fref * MAXM + data_n[fref]] = M.x[i];
        data_yset[fref * MAXM + data_n[fref]] = M.y[i];
        if (FILEOUT)
        {
          //Print simout from 0 (new way to match --analyse)
          fprintf(fp, "%i\t%i\t%i\t%f\t%f\t0\t0\t0\t0\t0\t0\t0\n", ref++, M.trajlabel[i], t - EQUIL - 1, M.x[i], M.y[i]);
          //Print simout from 1 (old way)
          //fprintf(fp, "%i\t%i\t%i\t%f\t%f\t0\t0\t0\t0\t0\t0\t0\n", ref++, M.trajlabel[i], t - EQUIL, M.x[i], M.y[i]);
        }
        data_n[fref]++;
      }
      if(debugout == 1) exit(0);
    }
  }
  if (FILEOUT)
  {
    fclose(fp);
  }
}

// compute a normalised difference between two stats
double myabs(double x1, double x2)
{
  if ((x1 - x2) < 0)
    return (x2 - x1) / (x1 + x2);
  return (x1 - x2) / (x1 + x2);
}

// get the distance between two sets of (network + physical) summary statistics, to use in ABC
double GetDistance(Statistics S1, Statistics S2, PhysicalStatistics PS1, PhysicalStatistics PS2)
{
  int i;
  double dist = 0;

  for (i = 0; i < MAXT; i++)
  {
    if (frames_to_record[i])
    {
      dist += myabs(PS1.meanspeed[i], PS2.meanspeed[i]);
      dist += myabs(PS1.sdspeed[i], PS2.sdspeed[i]);
      dist += myabs(PS1.meanangle[i], PS2.meanangle[i]);
      dist += myabs(PS1.sdangle[i], PS2.sdangle[i]);
      dist += myabs(S1.numedges[i], S2.numedges[i]);
      dist += myabs(S1.numvertices[i], S2.numvertices[i]);
      dist += myabs(S1.meandegree[i], S2.meandegree[i]);
      dist += myabs(S1.maxdegree[i], S2.maxdegree[i]);
      dist += myabs(S1.meanbc[i], S2.meanbc[i]);
      dist += myabs(S1.maxbc[i], S2.maxbc[i]);
      dist += myabs(S1.nccs[i], S2.nccs[i]);
      dist += myabs(S1.maxccsize[i], S2.maxccsize[i]);
      dist += myabs(S1.singletoncount[i], S2.singletoncount[i]);
      dist += myabs(S1.meancolocalisation[i], S2.meancolocalisation[i]);
      dist += myabs(S1.sdcolocalisation[i], S2.sdcolocalisation[i]);
      if (isnan(dist))
        printf("wtf l730\n");
    }
  }

  return dist;
}

// produce a new parameter set, sampled from priors
// priors for some params are spike-and-slab to test the effect of removing that effect
void InitParams(Params *P)
{
  if (RND < 0.5)
    P->NCYT = 0;
  else
    P->NCYT = RND * 20;
  P->NMITO = RND * 200;

  if (RND < 0.5)
    P->EDGELOSS = 0.05;
  else
   P->EDGELOSS = RND * 0.1;
  //P->EDGELOSS = 0;

  P->CYTDIST = RND * 10;

  if (RND < 0.5)
    P->CYTATTACH = 0;
  else
    P->CYTATTACH = RND;

  if (RND < 0.5)
    P->CYTDETACH = 0;
  else
    P->CYTDETACH = RND;

  if (RND < 0.5)
    P->CYTSPEED = 1;
  else
    P->CYTSPEED = RND * 10;

  P->MITDIST = RND * 10;

  P->MITSPEED = RND;

  P->STEPTYPE = 0; //(RND < 0.5);
  P->STEPPARAM = RND;

  if (RND < 0.5)
    P->HYDRO = 0;
  else
    P->HYDRO = RND;
}

// reads a set of trajectories from a file, either output from previous versions of simulation code or (untested) from Mosaic particle tracker
void ReadTrajFromFile(char *fname, int *mset, int *n, double *xset, double *yset)
{
  FILE *fp;
  char str[2000];
  double tx, ty, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
  int ref, mref, fref;
  int nmito, nframe;
  int i;

  fp = fopen(fname, "r");
  if (fp == NULL)
  {
    printf("Couldn't find file %s\n", fname);
    exit(0);
  }

  // read and omit first line of file (column headers)
  fgets(str, 2000, fp);

  // reset frame-by-frame mito counts
  for (i = 0; i < MAXT; i++)
  {
    n[i] = 0;
  }
  nmito = nframe = 0;

  // first part just gets data from file: population of adjacency matrix is done subsequently

  // loop through entries in file
  while (!feof(fp))
  {
    // read entry
    fscanf(fp, "%i\t%i\t%i\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf", &ref, &mref, &fref, &tx, &ty, &tmp1, &tmp2, &tmp3, &tmp4, &tmp5, &tmp6, &tmp7);

    // pop trajectory label and x,y coords into appropriate arrays, indexed by frame
    if (!feof(fp))
    {
      mset[fref * MAXM + n[fref]] = mref;
      xset[fref * MAXM + n[fref]] = tx;
      yset[fref * MAXM + n[fref]] = ty;
      n[fref]++;
    }
    else
      break;

    // keep track of how many trajs and frames we've counted
    if (mref >= MAXM)
    {
      printf("Too many mitos!\n");
      exit(0);
    }
    if (mref > nmito)
      nmito = mref;
    if (fref > nframe)
      nframe = fref;
    if (fref >= MAXT - 2)
    {
      printf("Too many entries -- truncating at %i\n", ref);
      break;
    }
  }
  fclose(fp);

  printf("Read %i entries over %i frames\n", ref, fref);
}

int main(int argc, char *argv[])
{
  Params P, newP;
  int *data_mset, *data_n;
  double *data_xset, *data_yset;
  int nframe;
  Statistics S, newS;
  PhysicalStatistics PS, newPS;
  int i = 40;
  int j;
  double dist;
  int it;
  int acc = 0, rej = 0;
  double cutoff, threshold;
  char fname[1000];
  FILE *fp;
  int refframe;
  int expt_type;
  int seed;

  // frames_to_record is used by GetNetworkStats (which frames to compute network stats for) and GetDistance (which frames to use in distance calculation)
  // if element i is 1 then we use that frame, if 0 then we don't
  for (j = 0; j < MAXT; j++)
  {
    //frames_to_record[j] = (j % 20 == 0 ? 1 : 0);
    frames_to_record[j] = (j == 1 || j == 20 || j == 50 || j == 80 || j == 110 || j == 117 || j == 118 ? 1 : 0);
  }
  // refframe is the frame used for the single-line onscreen summary outputs
  refframe = 110;

  // make sure we've got the correct command-line arguments
  if (argc < 2 || (strcmp(argv[1], "--simulation\0") != 0 && strcmp(argv[1], "--inference\0") != 0 && strcmp(argv[1], "--analyse\0") != 0))
  {
    printf("Usage:\n\n--simulation NCYT NMITO EDGELOSS CYTDIST CYTATTACH CYTDETACH CYTSPEED MITDIST MITSPEED STEPTYPE STEPPARAM HYDRO RSEED DISTANCE\n\t: Simulate a given parameterisation once and produce output file\n\n--inference SOURCE_FILE DISTANCE THRESHOLD\n\t: Perform ABC inference using data in SOURCE_FILE\n\n--analyse SOURCE_FILE DISTANCE\n\t: Compute summary statistics using data in SOURCE_FILE\n");
    exit(0);
  }
  if (strcmp(argv[1], "--simulation\0") == 0)
  {
    expt_type = 0;
    if (argc != 16)
    {
      printf("Need parameters NCYT NMITO EDGELOSS CYTDIST CYTATTACH CYTDETACH CYTSPEED MITDIST MITSPEED STEPTYPE STEPPARAM HYDRO RSEED DISTANCE.\nUsing default parameterisation instead.\n");
      P.NCYT = 10;
      P.NMITO = 100;
      P.EDGELOSS = 0.01;
      P.CYTDIST = 4;
      P.CYTATTACH = 0.1;
      P.CYTDETACH = 0.1;
      P.CYTSPEED = 5;
      P.MITDIST = 4;
      P.MITSPEED = 0.2;
      P.STEPTYPE = 0;
      P.STEPPARAM = 0.3;
      P.HYDRO = 0.1;
      P.RSEED = 321;
      cutoff = 1.6;
    }
    else
    {
      P.NCYT = atoi(argv[2]);
      P.NMITO = atoi(argv[3]);
      P.EDGELOSS = atof(argv[4]);
      P.CYTDIST = atof(argv[5]);
      P.CYTATTACH = atof(argv[6]);
      P.CYTDETACH = atof(argv[7]);
      P.CYTSPEED = atof(argv[8]);
      P.MITDIST = atof(argv[9]);
      P.MITSPEED = atof(argv[10]);
      P.STEPTYPE = atoi(argv[11]);
      P.STEPPARAM = atof(argv[12]);
      P.HYDRO = atof(argv[13]);
      P.RSEED = atoi(argv[14]);
      cutoff = atof(argv[15]);
    }
  }
  if (strcmp(argv[1], "--inference\0") == 0)
  {
    if (argc != 5)
    {
      printf("Need source file, distance cutoff, ABC threshold.\ne.g. output-10-100-0.010-4.000-0.100-0.100-5.000-4.000-0.200-0-0.300-0.100-123.txt 1.6 12\n");
      exit(0);
    }
    expt_type = 1;
    sprintf(fname, "posterior-%s-%.4f-%.4f.txt", argv[2], cutoff, threshold);
    cutoff = atof(argv[3]);
    threshold = atof(argv[4]);
  }
  if (strcmp(argv[1], "--analyse\0") == 0)
  {
    if (argc != 4)
    {
      printf("Need source file, distance cutoff\ne.g. test-1.txt 1.6\n");
      exit(0);
    }
    expt_type = 2;
    cutoff = atof(argv[3]);
  }

  // allocate memory for trajectories
  data_mset = (int *)malloc(sizeof(int) * MAXM * MAXT);
  data_n = (int *)malloc(sizeof(int) * MAXT);
  data_xset = (double *)malloc(sizeof(double) * MAXM * MAXT);
  data_yset = (double *)malloc(sizeof(double) * MAXM * MAXT);

  // if we're just doing a simple simulation:
  if (expt_type == 0)
  {
    Simulate(P, data_mset, data_n, data_xset, data_yset, 1);

    sprintf(fname, "networks-%i-%i-%.3f-%.3f-%.3f-%.3f-%.3f-%.3f-%.3f-%i-%.3f-%.3f-%i-%.3f.txt", P.NCYT, P.NMITO, P.EDGELOSS, P.CYTDIST, P.CYTATTACH, P.CYTDETACH, P.CYTSPEED, P.MITDIST, P.MITSPEED, P.STEPTYPE, P.STEPPARAM, P.HYDRO, P.RSEED, cutoff);

    GetNetworkStats(data_mset, data_n, data_xset, data_yset, MAXT, cutoff, &newS, 1, fname);
    GetPhysicalStats(data_mset, data_n, data_xset, data_yset, MAXT, &newPS);
    //first arg=target, second=content of the target, 3rd= paras to fill in that content (filename) with
    sprintf(fname, "simstats-%i-%i-%.3f-%.3f-%.3f-%.3f-%.3f-%.3f-%.3f-%i-%.3f-%.3f-%i-%.3f.txt", P.NCYT, P.NMITO, P.EDGELOSS, P.CYTDIST, P.CYTATTACH, P.CYTDETACH, P.CYTSPEED, P.MITDIST, P.MITSPEED, P.STEPTYPE, P.STEPPARAM, P.HYDRO, P.RSEED, cutoff);
    //Opens a file under fname from above- it then loops through the frames, filling up the stats file as it goes.
    fp = fopen(fname, "w");
    for (i = 0; i < MAXT; i++)
    {
      fprintf(fp, "%i %i %i %f %i %f %f %i %i %i %f %f %f %f %f %f\n", i, newS.numedges[i], newS.numvertices[i], newS.meandegree[i], newS.maxdegree[i], newS.meanbc[i], newS.maxbc[i], newS.nccs[i], newS.maxccsize[i], newS.singletoncount[i], newS.meancolocalisation[i], newS.sdcolocalisation[i], newPS.meanspeed[i], newPS.sdspeed[i], newPS.meanangle[i], newPS.sdangle[i]);
    }
    fclose(fp);
    exit(0);
  }

  // if we're just analysing a data file
  if (expt_type == 2)
  {
    printf("Reading file...\n");
    ReadTrajFromFile(argv[2], data_mset, data_n, data_xset, data_yset);
    sprintf(fname, "networks-%s-%.3f.txt", argv[2], cutoff);
    GetNetworkStats(data_mset, data_n, data_xset, data_yset, MAXT, cutoff, &newS, 1, fname);
    GetPhysicalStats(data_mset, data_n, data_xset, data_yset, MAXT, &newPS);
    sprintf(fname, "simstats-%s-%.3f.txt", argv[2], cutoff);
    fp = fopen(fname, "w");
    for (i = 0; i < MAXT; i++)
    {
      fprintf(fp, "%i %i %i %f %i %f %f %i %i %i %f %f %f %f %f %f\n", i, newS.numedges[i], newS.numvertices[i], newS.meandegree[i], newS.maxdegree[i], newS.meanbc[i], newS.maxbc[i], newS.nccs[i], newS.maxccsize[i], newS.singletoncount[i], newS.meancolocalisation[i], newS.sdcolocalisation[i], newPS.meanspeed[i], newPS.sdspeed[i], newPS.meanangle[i], newPS.sdangle[i]);
    }
    fclose(fp);
    exit(0);
  }

  // otherwise we're doing a full inference run
  //srand48(_FULLRSEED);

  fp = fopen(fname, "w");
  fclose(fp);

  printf("Testing data read and summarise:\n");
  ReadTrajFromFile(argv[2], data_mset, data_n, data_xset, data_yset);
  GetNetworkStats(data_mset, data_n, data_xset, data_yset, MAXT, cutoff, &S, 0, NULL);
  GetPhysicalStats(data_mset, data_n, data_xset, data_yset, MAXT, &PS);

  printf("numedges numvertices meandegree maxdegree meanbc maxbc nccs maxccsize singletoncount meancolocal sdcolocal meanspeed sdspeed meanangle sdangle\n");
  printf("-> %i %i %f %i %f %f %i %i %i %f %f %f %f %f %f\n\n", S.numedges[refframe], S.numvertices[refframe], S.meandegree[refframe], S.maxdegree[refframe], S.meanbc[refframe], S.maxbc[refframe], S.nccs[refframe], S.maxccsize[refframe], S.singletoncount[refframe], S.meancolocalisation[refframe], S.sdcolocalisation[refframe], PS.meanspeed[refframe], PS.sdspeed[refframe], PS.meanangle[refframe], PS.sdangle[refframe]);

  // loop through iterations
  for (it = 0; it < 5000; it++)
  {
    // randomly sample a new parameterisation
    InitParams(&newP);
    printf("%i %i %f %f %f %f %f %f %f %i %f %f %i\n", newP.NCYT, newP.NMITO, newP.EDGELOSS, newP.CYTDIST, newP.CYTATTACH, newP.CYTDETACH, newP.CYTSPEED, newP.MITDIST, newP.MITSPEED, newP.STEPTYPE, newP.STEPPARAM, newP.HYDRO, newP.RSEED);
    //printf("This is newP.RSEED %i\n",newP.RSEED);
    // Simulate() sets the random number seed for a simulation. to avoid locking in to a loop, we store a current random number and use it to reinitialise the generator after the simulation function
    seed = RND * 1000000;
    //printf("The seed is %i",seed);
    printf("The iteration is %i", it);
    Simulate(newP, data_mset, data_n, data_xset, data_yset, 0);
    // srand48(seed);

    // get statistics for these trajectories
    GetNetworkStats(data_mset, data_n, data_xset, data_yset, MAXT, cutoff, &newS, 0, NULL);
    GetPhysicalStats(data_mset, data_n, data_xset, data_yset, MAXT, &newPS);
    printf("-> %i %i %f %i %f %f %i %i %i %f %f %f %f %f %f\n", newS.numedges[refframe], newS.numvertices[refframe], newS.meandegree[refframe], newS.maxdegree[refframe], newS.meanbc[refframe], newS.maxbc[refframe], newS.nccs[refframe], newS.maxccsize[refframe], newS.singletoncount[refframe], newS.meancolocalisation[refframe], newS.sdcolocalisation[refframe], newPS.meanspeed[refframe], newPS.sdspeed[refframe], newPS.meanangle[refframe], newPS.sdangle[refframe]);

    // compute distance
    dist = GetDistance(S, newS, PS, newPS);

    // apply ABC
    printf("Distance from first set %f\n", dist);
    if (dist < threshold)
    {
      printf("Accepted\n\n");
      fp = fopen(fname, "a");
      fprintf(fp, "%i %i %f %f %f %f %f %f %f %i %f %f %i %f\n", newP.NCYT, newP.NMITO, newP.EDGELOSS, newP.CYTDIST, newP.CYTATTACH, newP.CYTDETACH, newP.CYTSPEED, newP.MITDIST, newP.MITSPEED, newP.STEPTYPE, newP.STEPPARAM, newP.HYDRO, newP.RSEED, dist);
      fclose(fp);
    }
    else
    {
      printf("Rejected\n\n");
    }
  }

  return 0;
}
