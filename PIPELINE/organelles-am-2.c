// plant mitochondrial simulation v0.3
// output trajectories from simulation code are parsed to collect adjacency matrices describing colocalisation events
// we first read in a file containing full histories
// then go through frame-by-frame, constructing sets of colocalisations both historically (i.e. up to and including this frame) and specifically (i.e. just this frame)
// edited to add output of singletons

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

// maximum number of trajectories
#define MAXM 200000
#define MAXE 2000000

// maximum number of frames
#define MAXF 502

int main(int argc, char *argv[])
{
  FILE *fp;
  int i, j, k, l, m;
  int ref, mref, fref;
  double tx, ty, tmp1, tmp2, tmp3, tmp4, tmp5, tmp6, tmp7;
  char str[2000];
  int nmito, nframe;
  int *mset, *fset, *n;
  double *xset, *yset;
  int *am, *frameam;
  double d;
  double cutoff;
  int nam = 0, nframeam = 0;
  int ci, found;
  int *singletons;
  
  // allocate memory for arrays
  mset = (int*)malloc(sizeof(int)*MAXM*MAXF);
  n = (int*)malloc(sizeof(int)*MAXF);
  xset = (double*)malloc(sizeof(double)*MAXM*MAXF);  
  yset = (double*)malloc(sizeof(double)*MAXM*MAXF);
  am = (int*)malloc(sizeof(int)*MAXE*2);
  frameam = (int*)malloc(sizeof(int)*MAXE*2);
  singletons = (int*)malloc(sizeof(int)*MAXM);
					       
  // process arguments: file name and colocalisation distance
  if(argc != 3)
    {
      printf("Need a file and a colocalisation distance!\n");
      return 0;
    }
  fp = fopen(argv[1], "r");
  if(fp == NULL)
    {
      printf("Couldn't find file %s\n", argv[1]);
      return 0;
    }
  cutoff = atof(argv[2]);
  printf("Cutoff is %f\n", cutoff);

  // read and omit first line of file (column headers)
  fgets(str, 2000, fp);

  // reset frame-by-frame mito counts 
  for(i = 0; i < MAXF; i++)
    {
      n[i] = 0;
    }
  nmito = nframe = 0;

  // first part just gets data from file: population of adjacency matrix is done subsequently
  
  // loop through entries in file
  while(!feof(fp))
    {
      // read entry
      fscanf(fp, "%i\t%i\t%i\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf\t%lf", &ref, &mref, &fref, &tx, &ty, &tmp1, &tmp2, &tmp3, &tmp4, &tmp5, &tmp6, &tmp7);

      // pop trajectory label and x,y coords into appropriate arrays, indexed by frame
      if(!feof(fp))
	{
	  mset[fref*MAXM+n[fref]] = mref;
	  xset[fref*MAXM+n[fref]] = tx;
	  yset[fref*MAXM+n[fref]] = ty;
	  n[fref]++;
	}
      else break;

      // keep track of how many trajs and frames we've counted
      if(mref >= MAXM)
	{
	  printf("Too many mitos!\n");
	  return 0;
	}
      if(mref > nmito)
	nmito = mref;
      if(fref > nframe)
	nframe = fref;
      if(fref >= MAXF-2)
	{
	  printf("Too many entries -- truncating at %i\n", ref);
	  break;
	}
    }
  fclose(fp);

  printf("Read %i entries\n", ref);

  // now we do the processing
  
  nam = 0;

  // initialise singletons list
  for(i = 0; i < MAXM; i++)
    singletons[i] = 0;

  // loop through frames
  for(i = 0; i < nframe; i++)
    {
      nframeam = 0;

      // register mitos that come into view in this frame as singletons
      // also output to file
      sprintf(str, "%s-%.1f-%i-single-new.txt", argv[1], cutoff, i);
      fp = fopen(str, "w");

        for(l = 0; l < n[i]; l++)
	  {
	    if(singletons[mset[MAXM*i+l]] == 0)
	      {
	        singletons[mset[MAXM*i+l]] = 1;
		fprintf(fp, "%i\n", l);
	      }
	  }
	fclose(fp);

      // loop through pairs of mitos in this frame
      for(l = 0; l < n[i]; l++)
	{
	  for(m = l+1; m < n[i]; m++)
	    {
	      j = mset[MAXM*i+l]; k = mset[MAXM*i+m];

	      // compute separation
	      d = (xset[MAXM*i+l]-xset[MAXM*i+m])*(xset[MAXM*i+l]-xset[MAXM*i+m]) + (yset[MAXM*i+l]-yset[MAXM*i+m])*(yset[MAXM*i+l]-yset[MAXM*i+m]);
	      d = sqrt(d);
	      
	      // if we're close...
	      if(d < cutoff)
		{
		  // see if we already have this pair, if not, add to historical adjacency matrix
		  found = 0;
		  for(ci = 0; ci < nam && found == 0; ci++)
		    {
		      if((am[(ci*2)+0] == j && am[(ci*2)+1] == k) || (am[(ci*2)+0] == k && am[(ci*2)+1] == j)) 
			{
			  found = 1;
			  break;
			}
		    }
		  if(found == 0)
		    {
		      am[(nam*2)+0] = j;
		      am[(nam*2)+1] = k;
		      singletons[j] = singletons[k] = 2;
		      nam++;
		    }

		  // see if we already have this pair, if not, add to frame-specific adjacency matrix
		  found = 0;
		  for(ci = 0; ci < nframeam && found == 0; ci++)
		    {
		      if((frameam[(ci*2)+0] == j && frameam[(ci*2)+1] == k) || (frameam[(ci*2)+0] == k && frameam[(ci*2)+1] == j)) 
			{
			  found = 1;
			  break;
			}
		    }
		  if(found == 0)
		    {
		      frameam[(nframeam*2)+0] = j;
		      frameam[(nframeam*2)+1] = k;
		      singletons[j] = singletons[k] = 2;
		      nframeam++;
		    }

		}
	    }
	}

      // output this frame's historical adjacency matrix
      sprintf(str, "%s-%.1f-%i.txt", argv[1], cutoff, i);
      fp = fopen(str, "w");
      for(j = 0; j < nam; j++)
	{
	  if(am[(2*j)+0] > am[(2*j)+1])
	    fprintf(fp, "%i %i\n", am[(2*j)+1], am[(2*j)+0]);
	  else
	    fprintf(fp, "%i %i\n", am[(2*j)+0], am[(2*j)+1]);
	}
      fclose(fp);

      // output this frame's specific adjacency matrix
      sprintf(str, "%s-%.1f-%i-spec.txt", argv[1], cutoff, i);
      fp = fopen(str, "w");
      for(j = 0; j < nframeam; j++)
	{
	  if(frameam[(2*j)+0] > frameam[(2*j)+1])
	    fprintf(fp, "%i %i\n", frameam[(2*j)+1], frameam[(2*j)+0]);
	  else
	    fprintf(fp, "%i %i\n", frameam[(2*j)+0], frameam[(2*j)+1]);
	}
      fclose(fp);

      // output this frame's historic set of singletons (frame-specific singleton set is not as meaningful?)
      sprintf(str, "%s-%.1f-%i-single.txt", argv[1], cutoff, i);
      fp = fopen(str, "w");
      for(j = 0; j < MAXM; j++)
	{
	  if(singletons[j] == 1)
	    fprintf(fp, "%i\n", j);
	}
      fclose(fp);
    }

  return 0;
}
