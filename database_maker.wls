#!/usr/bin/env wolframscript

(* one command line arg: the shot number *)
shotnum=Part[$ScriptCommandLine,2]

scriptPath = ExpandFileName[First[$ScriptCommandLine]];
scriptDirectory = DirectoryName[scriptPath];
filename=FileNameJoin[{scriptDirectory,"data.h5"}];

npoints=10;
nsteps=RandomInteger[{15,25}];
dt=0.05;

(* for taking a random walk in constructing source terms *)
nextPt[pt_,r_]:=Block[{nxt=pt+r RandomReal[{-1,1}]},
				If[nxt<0,Return[0],
				If[nxt>1,Return[1],
				Return[nxt]]]];

(*Preset possible starting values for T*)
T0Generator[x_,\[Alpha]_,\[Beta]_]:=\[Alpha] (1-x^\[Beta]);
(*Preset possible deposition profiles based on time-dependent "beam powers" a and b *)
(* Deposition[t_,x_,T_]:=a[t]*PDF[NormalDistribution[0.8,1],x]+b[t]*PDF[NormalDistribution[0.1,.3*(1+T)],x]; *)
Deposition[t_,x_,T_]:=a[t]*PDF[NormalDistribution[0.8,0.3],x]+b[t]*PDF[NormalDistribution[0.2,0.3],x];

(* Model power source parameters a and b *)
aDiscrete=NestList[nextPt[#,0.2]&,RandomReal[{0,1}],nsteps];
bDiscrete=NestList[nextPt[#,0.2]&,RandomReal[{0,1}],nsteps];
a=ListInterpolation[aDiscrete,{{0,dt*nsteps}}];
b=ListInterpolation[bDiscrete,{{0,dt*nsteps}}];
T0=T0Generator[#,RandomReal[{0.1,2}],RandomReal[{0.5,2}]]&;

vars={T[t,x],t,{x}};
pars=<|"MassDensity"->1,"SpecificHeatCapacity"->1|>;
(* Preset deposition function *)
pars["HeatSource"]=Deposition[t,x,T[t,x]];
(* For now keep it simple with constant thermal conductivity *)
pars["ThermalConductivity"]=1;
(* Use ~boundary conditions for actual tokamaks:
   0 derivative at core, 0 value at edge *)
pde={HeatTransferPDEComponent[vars,pars]==NeumannValue[0,x==0],DirichletCondition[T[t,x]==0,x==1],T[0,x]==T0[x]};
	Tfun=NDSolveValue[pde,T,{t,0,dt*nsteps},
	x\[Element]Line[{{0},{1}}]];

TfunDiscrete=Array[Tfun[#1,#2]&,{nsteps,npoints},{{0,dt*nsteps},{0,1}}];
depositionDiscrete=Array[pars["HeatSource"]/.{t->#1,x->#2,T->Tfun}&,{nsteps,npoints},{{0,dt*nsteps},{0,1}}];

Export[filename,{"Datasets"->FileNameJoin[{shotnum,"aDiscrete"}]->aDiscrete},"Rules",OverwriteTarget->"Append"];
Export[filename,{"Datasets"->FileNameJoin[{shotnum,"bDiscrete"}]->bDiscrete},"Rules",OverwriteTarget->"Append"];
Export[filename,{"Datasets"->FileNameJoin[{shotnum,"deposition"}]->depositionDiscrete},"Rules",OverwriteTarget->"Append"];
Export[filename,{"Datasets"->FileNameJoin[{shotnum,"T"}]->TfunDiscrete},"Rules",OverwriteTarget->"Append"];