// Latching control of point absorber with internal mass.
// Enrico Anderlini, University of Edinburgh, E.Anderlini@ed.ac.uk
//
// Adapted from code by
// Gordon Parker
// Michigan Technological University
// Mechanical Engineering - Engineering Mechanics Dept.
// Houghton, MI
//
// Created : 6 March 2017
//
// Version : 1.0

#define S_FUNCTION_NAME wecLatch
#define S_FUNCTION_LEVEL 2

#include "simstruc.h"
#include "math.h"     // fabs

#define IS_PARAM_DOUBLE(pVal) (mxIsNumeric(pVal) && !mxIsLogical(pVal) &&\
!mxIsEmpty(pVal) && !mxIsSparse(pVal) && !mxIsComplex(pVal) && mxIsDouble(pVal))

#define MYPI 3.14159265358979

#define YES 1
#define NO  0

//
// Manage the size of all the inputs, outputs, states and work vectors
// using the #define statements below. This off-loads the need for
// maintaining sizes in multiple spots below. EA
//
// Parameters
#define P_L   0  // latched mode duration (s)
#define P_A   1  // state matrix
#define P_B   2  // input matrix
#define P_I   3  // initial conditions
#define P_N   4  // number of elements in input
   
// continuous state indices
#define C_X1  0 // (m)
#define C_X2  1 // (m)
#define C_X1D 2 // (m/s)
#define C_X2D 3 // (m/s)
#define C_XSS 4 // start of radiation approximation
#define C_N   8 //

// real work vector indices
#define RW_A13  0 // non-zero componenets of the A-matrix
#define RW_A24  1
#define RW_A31  2
#define RW_A32  3
#define RW_A34  4
#define RW_A35  5
#define RW_A36  6
#define RW_A41  7
#define RW_A42  8
#define RW_A44  9
#define RW_A45 10
#define RW_A46 11
#define RW_A55 12
#define RW_A56 13
#define RW_A63 14
#define RW_A65 15
#define RW_A66 16
#define RW_A67 17
#define RW_A68 18
#define RW_A77 19
#define RW_A78 20
#define RW_A83 21
#define RW_A87 22
#define RW_A88 23
#define RW_B31 24 // non-zero components of the B-matrix
#define RW_B32 25
#define RW_B41 26
#define RW_B42 27
#define RW_F   28 // PTO force
#define RW_N   29 // size of real work vector

// integer work vector indices
#define IW_N   0 // size of integer work vector

// input indices
#define I_F    0    // wave force input port #
#define   I_FSIZE 1 // wave force (N)
#define I_N    1    // # of input ports

// output indices
#define O_ST   0         // state output port #
#define   O_STSIZE C_N   // states (m and m/s)
#define O_LON  1         // latch state port #
#define   O_LONSIZE  1   // latch state (on/off)
#define O_FPTO 2         // PTO force port
#define   O_FPTOSIZE 1   // PTO force (N)
#define O_N    3         // # of output ports

// ************************************************************************
// mdlCheckParameters: Method for checking parameter data types and sizes.
// Not required, but highly recommended to use it.
// ************************************************************************
#define MDL_CHECKPARAMETERS
#if defined(MDL_CHECKPARAMETERS)
static void mdlCheckParameters(SimStruct *S)
{
// Check 1st parameter: P_L
  {
    if (mxGetNumberOfElements(ssGetSFcnParam(S,P_L)) != 1 || 
            !IS_PARAM_DOUBLE(ssGetSFcnParam(S,P_L)) ) {
      ssSetErrorStatus(S,"1st parameter, P_L, to S-function "
                       "\"Response Parameters\" are not dimensioned "
                       "correctly or of type double");
      return; } }
// Check 2nd parameter: P_A
  {
    if (mxGetNumberOfElements(ssGetSFcnParam(S,P_A)) != C_N*C_N || 
            !IS_PARAM_DOUBLE(ssGetSFcnParam(S,P_A)) ) {
      ssSetErrorStatus(S,"2nd parameter, P_A, to S-function "
                       "\"Response Parameters\" are not dimensioned "
                       "correctly or of type double");
      return; } }
// Check 3rd parameter: P_B
  {
    if (mxGetNumberOfElements(ssGetSFcnParam(S,P_B)) != C_N*2 || 
            !IS_PARAM_DOUBLE(ssGetSFcnParam(S,P_B)) ) {
      ssSetErrorStatus(S,"3rd parameter, P_B, to S-function "
                       "\"Response Parameters\" are not dimensioned "
                       "correctly or of type double");
      return; } }
// Check 4th parameter: P_I
  {
    if (mxGetNumberOfElements(ssGetSFcnParam(S,P_I)) != C_N || 
            !IS_PARAM_DOUBLE(ssGetSFcnParam(S,P_I)) ) {
      ssSetErrorStatus(S,"4th parameter, P_I, to S-function "
                       "\"Response Parameters\" are not dimensioned "
                       "correctly or of type double");
      return; } }
}
#endif
 
// ************************************************************************
// mdlInitializeSize: Setup i/o and state sizes
// ************************************************************************
static void mdlInitializeSizes(SimStruct *S)
{
  //-----------------------------------------------------------------------      
  //           *** P A R A M E T E R    S E T U P ***
  //-----------------------------------------------------------------------  
  //   #  Description                                Units      Dim
  //-----------------------------------------------------------------------      
  //   0. Fill this in later....

  ssSetNumSFcnParams(S, P_N); // total number of parameters
  
  // Catch error made by user in giving parameter list to Simulink block
  // To make the mdlCheckParameters method active, it must be called as
  // shown below. This feature is not allowable in real-time, coder use,
  // so it is conditional on the MATLAB_MEX_FILE attribute. 
  #if defined(MATLAB_MEX_FILE)
  if( ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S) )
  {
      mdlCheckParameters(S);
      if(ssGetErrorStatus(S) != NULL) return;
  }
  else return; // parameter mismatch error
  #endif

  //-----------------------------------------------------------------------        
  //         *** C O N T I N U O U S    S T A T E    S E T U P ***
  //-----------------------------------------------------------------------    
  //   #                Description                 Units       Dim
  //-----------------------------------------------------------------------  
  //   0.               fill these in later...
  
  ssSetNumContStates(S,C_N);  // total number of continuous states           

  ssSetNumDiscStates(S,0); // total number of discrete states

  // set number of input ports
  if (!ssSetNumInputPorts(S,I_N)) return;  
  
  // set input port widths
  ssSetInputPortWidth(S, I_F, I_FSIZE);

  // If you add new inputs, you must add an element to the list below to
  // indicate if the input is used directly to compute an output.  
  ssSetInputPortDirectFeedThrough(S, I_F, NO);
  
  // specify number of output ports
  if (!ssSetNumOutputPorts(S,O_N)) return; 
  
  // specify output port widths
  ssSetOutputPortWidth(S, O_ST , O_STSIZE) ; 
  ssSetOutputPortWidth(S, O_LON, O_LONSIZE);   
  ssSetOutputPortWidth(S, O_FPTO, O_FPTOSIZE); 
  
  // setup work vectors
  // EA
  // If you need more work vectors, then you must modify this section
  // as needed, perhaps by adding some new #define statement earlier.
  // If you need several arrays or 2D arrays of work vectors, then use
  // DWork.
  ssSetNumRWork(S, RW_N); 
  ssSetNumIWork(S, IW_N);
  ssSetNumPWork(S, 0);
  ssSetNumModes(S, 0);
  ssSetNumDWork(S, 0);    
  
  // setup sample times
  ssSetNumSampleTimes(  S, 1);
  ssSetNumNonsampledZCs(S, 0);

  ssSetOptions(S, SS_OPTION_RUNTIME_EXCEPTION_FREE_CODE);
}

// ************************************************************************
// mdlInitializeSampleTimes: Set sample times for this s-fn. Modify this
// if you want to have the S-Fn called at interesting times. Lots of 
// documentation at MathWorks regarding how to manage this. 
// ************************************************************************
static void mdlInitializeSampleTimes(SimStruct *S)
{
  ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
  ssSetOffsetTime(S, 0, 0.0);
}

// ************************************************************************
// mdlInitializeConditions: Assign state ics, and other one-off actions.
// ************************************************************************
#define MDL_INITIALIZE_CONDITIONS
#if defined(MDL_INITIALIZE_CONDITIONS)
static void mdlInitializeConditions(SimStruct *S)
{
  // set a pointer to the continuous state vector
  real_T *x  = ssGetContStates(S);
  
  // set a pointer to the real work vector
  real_T *rw = ssGetRWork(S);
  
  // set pointers to the parameter arrays that are needed
  const real_T *ics = mxGetPr(ssGetSFcnParam(S,P_I));  

  int_T i; // counter
  
  // insert initial conditions  
  for(i=0;i<C_N;i++) x[i] = ics[i]; 
  
  //snatch and map all the needed parameters  
  const real_T *A1D = mxGetPr(ssGetSFcnParam(S,P_A));  
  const real_T *B1D = mxGetPr(ssGetSFcnParam(S,P_B)); 
  
  //snatch and map all the needed parameters   
  real_T A[C_N][C_N], B[C_N][2];
  memcpy(A,A1D,C_N*C_N*sizeof(real_T));
  memcpy(B,B1D,C_N*2*sizeof(real_T)); 
  
  // create the elements of A & B that you need, avoid all the 0 elements:
  rw[RW_A13] = A[0][2];
  rw[RW_A24] = A[1][3];
  rw[RW_A31] = A[2][0];
  rw[RW_A32] = A[2][1];
  rw[RW_A34] = A[2][3];
  rw[RW_A35] = A[2][4];
  rw[RW_A36] = A[2][5];
  rw[RW_A41] = A[3][0];
  rw[RW_A42] = A[3][1];
  rw[RW_A44] = A[3][3];
  rw[RW_A45] = A[3][4];
  rw[RW_A46] = A[3][5];
  rw[RW_A55] = A[4][4];
  rw[RW_A56] = A[4][5];
  rw[RW_A63] = A[5][2];
  rw[RW_A65] = A[5][4];
  rw[RW_A66] = A[5][5];
  rw[RW_A67] = A[5][6];
  rw[RW_A68] = A[5][7];
  rw[RW_A77] = A[6][6];
  rw[RW_A78] = A[6][7];
  rw[RW_A83] = A[7][2];
  rw[RW_A87] = A[7][6];
  rw[RW_A88] = A[7][7];
  rw[RW_B31] = B[2][0];
  rw[RW_B32] = B[2][1];
  rw[RW_B41] = B[3][0];
  rw[RW_B42] = B[3][1];
  rw[RW_F] = 0;
  
  ssSetSimStateCompliance(S,USE_DEFAULT_SIM_STATE);
}
#endif

// ************************************************************************
// mdlOutputs: Calc outputs at the start of each major integration step
// ************************************************************************
static void mdlOutputs(SimStruct *S, int_T tid)
{
  // set a pointers to the outputs
  real_T *ySt   = ssGetOutputPortSignal(S,O_ST );  // states
  real_T *yLOn  = ssGetOutputPortSignal(S,O_LON);  // latch state (on/off)
  real_T *yF    = ssGetOutputPortSignal(S,O_FPTO); // PTO force (N)
  
  // set a point to the 'next latch time' parameter
  const real_T *dltc = mxGetPr(ssGetSFcnParam(S,P_L)); 
  
  // set a pointer to the continous state vector
  real_T *x  = ssGetContStates(S);
  
  // set a pointer to the real work vector
  real_T *rw = ssGetRWork(S);
  
  int_T i; // counter
    
  // toss continuous states to the output port
  for(i=0;i<C_N;i++) ySt[i] = x[i];
  
  // toss the latch state to the output port, as a real_T
  *yLOn = (real_T)(ssGetT(S) < *dltc); 
  
  // toss the PTO force to the output port
  *yF = rw[RW_F];
}

// ************************************************************************
// mdlUpdate: Update the discrete states
// ************************************************************************
#undef MDL_UPDATE 
#if defined(MDL_UPDATE)
static void mdlUpdate(SimStruct *S, int_T tid){}
#endif

// ************************************************************************
// mdlDerivatives: Calc state derivatives for integration
// ************************************************************************
#define MDL_DERIVATIVES 
#if defined(MDL_DERIVATIVES)
static void mdlDerivatives(SimStruct *S)
{
  real_T *x  = ssGetContStates(S); // ptr to continous states
  real_T *dx = ssGetdX(S);         // ptr to right side of x' = f(x,u,t)
  real_T fPTO;  // PTO force
  
  int_T i,j; // counters
  
  // snatch and map the latching time
  const real_T *l = mxGetPr(ssGetSFcnParam(S,P_L)); 
  
  // set a pointer to the wave excitation
  InputRealPtrsType fEx = ssGetInputPortRealSignalPtrs(S,I_F); 
  
  fPTO = ((real_T)(ssGetT(S)<*l))*x[C_X2D];
  
//   // Neater, but slower solution:
//   //snatch and map all the needed parameters  
//   const real_T *A1D = mxGetPr(ssGetSFcnParam(S,P_A));  
//   const real_T *B1D = mxGetPr(ssGetSFcnParam(S,P_B)); 
//   
//   //snatch and map all the needed parameters  
//   real_T A[C_N][C_N], B[C_N][2];
//   memcpy(A,A1D,C_N*C_N*sizeof(real_T));
//   memcpy(B,B1D,C_N*2*sizeof(real_T));  
//   
//   // Initialize the right hand side:
//   for(i=0;i<C_N;i++) dx[i]=0;
//   // Calculate the solution to the state-space system:
//   for(i=0;i<C_N;i++) {
//     for(j=0;j<C_N;j++) {
//       dx[j]+= A[i][j]*x[j]; }
//     dx[i] += B[i][0]* *fEx[0] + B[i][1]*fPTO; }
  
  // Faster, but problem-specific solution:
  // set a pointer to the real work vector
  real_T *rw = ssGetRWork(S);
  
  dx[0] = rw[RW_A13]*x[2];
  dx[1] = rw[RW_A24]*x[3];
  dx[2] = rw[RW_A31]*x[0]+rw[RW_A32]*x[1]+rw[RW_A34]*x[3]+rw[RW_A35]*x[4]
          +rw[RW_A36]*x[5]+rw[RW_B31]* *fEx[0]+rw[RW_B32]*fPTO;
  dx[3] = rw[RW_A41]*x[0]+rw[RW_A42]*x[1]+rw[RW_A44]*x[3]+rw[RW_A45]*x[4]
          +rw[RW_A46]*x[5]+rw[RW_B41]* *fEx[0]+rw[RW_B42]*fPTO;
  dx[4] = rw[RW_A55]*x[4]+rw[RW_A56]*x[5];
  dx[5] = rw[RW_A63]*x[2]+rw[RW_A65]*x[4]+rw[RW_A66]*x[5]+rw[RW_A67]*x[6]
          +rw[RW_A68]*x[7];
  dx[6] = rw[RW_A77]*x[6]+rw[RW_A78]*x[7];
  dx[7] = rw[RW_A83]*x[2]+rw[RW_A87]*x[6]+rw[RW_A88]*x[7];
  
//   // process the latching control law
//   if (ssGetT(S) < *l)
//     dx[C_X2] = dx[C_X2D] = 0.0; // arrest relative motion of m2 
  
  // Update the PTO force:
  rw[RW_F] = fPTO;
}
#endif

// ************************************************************************
// mdlTerminate: Clean up anything that needs it
// ************************************************************************
static void mdlTerminate(SimStruct *S) { }

// Here's some stuff that is all S-Functions at the end.
#ifdef  MATLAB_MEX_FILE    // Is this file being compiled as a MEX-file?
#include "simulink.c"      // MEX-file interface mechanism 
#else
#include "cg_sfun.h"       // Code generation registration function
#endif