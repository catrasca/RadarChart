(* Wolfram Language Package *)

(* Created by the Wolfram Workbench Dec 13, 2015 *)
(* :Title: RadarChart *)
(* :Context: RadarChart` *)
(* :Author: Diego Zviovich*)
(* :Date: 2015-12-13 *)

(* :Package Version: 0.1 *)
(* :Mathematica Version: *)
(* :Copyright: (c) 2015 Diego Zviovich *)
(* :Keywords: *)
(* :Discussion: *)
(* :Summary: *)

BeginPackage["RadarChart`"]
(* Exported symbols added here with SymbolName::usage *) 

RadarChart::usage = "RadarChart[{y1,y2,y3,...}] generates a radar plot (also known as web, star, spider, cobweb or kiviat diagram) corresponding to a list of values.\
 This type of chart is suitable for showing commonality and outliers across different variables.
RadarChart[{list1,list2,...}] generates a radar plot to compare several series.
RadarChart[association] generates a radar plot to view the variable values in an association.
RadarChart[{association1,association2...}] generates a radar plot to compare several series.
RadarChart[dataset] generates a radar plot to compare several series."
 
Begin["`Private`"]
(* Implementation of the package *)

(*** Auxiliary Functions ***)

(*
rearragePoints is used to convert the Real values into the plane coordinate system 
*)

rearrangePoints::badDim = "All variables should have the same length."

rearrangePoints[list:{_?NumericQ,_?NumericQ,__?NumericQ}] :=
    Module[ {nMax = Length@list,l},
        l = (N@list[[#]]{Cos[(((#-1)2/nMax)+1/2) Pi],Sin[(((#-1)2/nMax)+1/2) Pi]})&/@Range@nMax;
        Append[l,First@l]
    ]
    
rearrangePoints[list:{{_?NumericQ,_?NumericQ,__?NumericQ}...}] :=
    rearrangePoints[#]&/@list

(*spacing is used to automate the Axis Scaling *)

spacing[value_] :=
    Module[ {log,mod,int},
        log = N@Log[10,value];
        mod = Mod[log,1];
        int = Floor[log];
        Which[mod==0,10.^(int-1),mod>0&&mod<=Log[10,2],2.*10^(int-1),mod<Log[10,5],5*10.^(int-1),True,10.^(int)]
    ]

(*CycleValues is used to cycle values to a certain length*)
CycleValues[{},_] :=
    {}

CycleValues[list_List,n_Integer] :=
    Module[ {hold = list},
        While[Length[hold]<n,hold = Join[hold,hold]];
        Take[hold,n]/.None->{}
    ]

CycleValues[item_,n_] :=
    CycleValues[{item},n]

(*Convert Dataset to Sequence for RadarChart*)
Options[dsToSequence] = {
    ChartLegends->Automatic,
    AxesLabel->Automatic    
}

dsToSequence[ds_Dataset/;Length@Dimensions@ds==2,opts:OptionsPattern[]] :=
    Module[ {keys = ds[1, Keys] // Normal,
    posString = Position[Head /@ ds[1, Values] // Normal, String],
    posNumber = 
    Position[Head /@ ds[1, Values] // Normal, Real | Integer], 
    keyString, keyValues, values,
    chartLegends = OptionValue[ChartLegends],
    axesLabel = OptionValue[AxesLabel]},
        keyString = concatenate[ds[All, Extract[keys, posString]][Values] // Normal];
        keyValues = Extract[keys, posNumber] // Normal;
        values = ds[All, Extract[keys, posNumber]] // Values // Normal;
        dmzList[values, 
            If[ chartLegends===Automatic,
                ChartLegends -> keyString,
                ChartLegends->None
            ], 
          If[ axesLabel===Automatic,
              AxesLabel -> keyValues,
              AxesLabel->None
          ]] /. dmzList -> Sequence
    ]
    
dsToSequence[ds_Dataset /; Length@Dimensions@ds == 1,opts:OptionsPattern[]] :=
    Module[ {keys = ds[Keys] // Normal, 
      posString = Position[Head /@ ds[Values] // Normal, String], 
      posNumber = Position[Head /@ ds[Values] // Normal, Real | Integer],
      chartLegends = OptionValue[ChartLegends],
      axesLabel = OptionValue[AxesLabel],
       keyString, keyValues, values},
        If[ Length@posString==0,
            keyString = None;
            keyValues = keys;
            values = Extract[ds[Values],posNumber];,
            keyString = 
                 concatenate[ds[ Extract[keys, posString]][Values] // Normal];
            keyValues = Extract[keys, posNumber] // Normal;
            values = ds[ Extract[keys, posNumber]] // Values // Normal;
        ];
        dmzList[values, If[ chartLegends===Automatic,
                            ChartLegends -> keyString,
                            ChartLegends->None
                        ], 
          If[ axesLabel===Automatic,
              AxesLabel -> keyValues,
              AxesLabel->None
          ]] /. dmzList -> Sequence
    ]
        
dsToSequence[ds_Dataset /; Length@Dimensions@ds == 3,opts:OptionsPattern[]] :=
    Module[ {keyValues = ds[1, Keys] // Normal // First, 
       keyString = ds[Keys]//Normal, values,
       chartLegends = OptionValue[ChartLegends],
          axesLabel = OptionValue[AxesLabel]},
        values = Flatten[ds[Values][Values] // Normal, 1];
        dmzList[values,If[ chartLegends===Automatic,
                           ChartLegends -> keyString,
                           ChartLegends->None
                       ], 
          If[ axesLabel===Automatic,
              AxesLabel -> keyValues,
              AxesLabel->None
          ]] /. dmzList -> Sequence
    ]
    
(*concatenate - Group String Fields Together *)
concatenate[{a_String}] :=
    a
concatenate[{a_String, b_String, c__}] :=
    concatenate[Flatten[{StringJoin[a, ", ", b], c}]]
concatenate[{a_String, b_String}] :=
    Style[StringJoin[a, ", ", b]]
concatenate[list : {_List ..}] :=
    concatenate[#] & /@ list
(*User Defined Option Rules *)

(*RadarChart Function*)
RadarChart::badDim = "All Series need to have the same length."

Options[RadarChart] = {PlotStyle->Automatic,
    Filling->None,
    ChartLegends->Automatic,
    AxesLabel->Automatic,
    AxesType->"Radar"
    }~Join~Developer`GraphicsOptions[];

RadarChart[list:{{_?NumericQ,_?NumericQ,__?NumericQ}...},opts:OptionsPattern[]] :=
    Module[ {min,max,length,vars,nbrVars,axes,ticks,tickLabels,steps,colors,polys,maxAxis,labelCoeff,
                gOpts = FilterRules[{opts},Options[Graphics]],
                plotStyle = OptionValue[PlotStyle],
                filling = OptionValue[Filling],
                chartLegends = OptionValue[ChartLegends],
                axesLabel = OptionValue[AxesLabel],
                plotRange = OptionValue[PlotRange],
                frameTicks = OptionValue[FrameTicks],
                axesType = OptionValue[AxesType]
                },
        If[ Length@Dimensions@list!=2,
            Message[RadarChart::badDim];
            Abort[]
        ];
        length = Length@First@list;
        nbrVars = Length@list;
        vars = rearrangePoints[list];
        filling = If[ filling===None,
                      Transparent,
                      Opacity[0.3]
                  ];
        labelCoeff = If[ axesType=="Star",
                         1.18,
                         1.05
                     ];
        If[ plotStyle===Automatic,
            colors = ColorData[1][#]&/@Range@nbrVars;
            polys = Transpose[{{FaceForm[{#,filling}],EdgeForm[{Thick,#}]}&/@colors
            ,
             Polygon[#]&/@vars}],
            plotStyle = CycleValues[plotStyle,nbrVars];
            polys = Join[{filling},Transpose[{plotStyle,Polygon[#]&/@vars}],{Opacity[1],Thick},Transpose[{plotStyle,Line[#]&/@vars}]];
            colors = CycleValues[plotStyle,nbrVars];
        ];
        If[ plotRange===All,
            min = 0;
            max = Max@list;,
            {min,max} = plotRange;
        ];
        Which[frameTicks===Automatic,
            steps = spacing[max];
            maxAxis = Ceiling[max,steps];
            ticks = Range[min,maxAxis,steps];
            If[ axesType=="Star",
                axes = {GrayLevel[0.5],Arrow[Transpose[{ConstantArray[{0,0},length],
                    Most@rearrangePoints[ConstantArray[1.15 maxAxis,length]]}]]};,
                axes = {Transparent,EdgeForm[{Thin,GrayLevel[0.5]}],RegularPolygon[{#,Pi/2},length]&/@Rest[ticks]};
            ];
            tickLabels = Inset[Style[ToString[#]],{-maxAxis/25,#},Alignment->Right]&/@Rest@ticks;
         , Head@frameTicks===List,
            ticks = frameTicks;
            maxAxis = Max@frameTicks;
            If[ axesType=="Star",
                axes = {GrayLevel[0.5],Arrow[Transpose[{ConstantArray[{0,0},length],
                    Most@rearrangePoints[ConstantArray[1.15 maxAxis,length]]}]]};,
                axes = {Transparent,EdgeForm[{Thin,GrayLevel[0.5]}],RegularPolygon[{#,Pi/2},length]&/@ticks};
            ];
            tickLabels = Inset[Style[ToString[#]],{-maxAxis/25,#},Alignment->Right]&/@ticks;    
        , True,
            steps = spacing[max];
            maxAxis = Ceiling[max,steps];
            ticks = Range[min,maxAxis,steps];
            If[ axesType=="Star",
                axes = {GrayLevel[0.5],Arrow[Transpose[{ConstantArray[{0,0},length],
                    Most@rearrangePoints[ConstantArray[1.15 maxAxis,length]]}]]};,
                axes = {Transparent,EdgeForm[{Thin,GrayLevel[0.5]}],RegularPolygon[{#,Pi/2},length]&/@Rest[ticks]};
            ];
            tickLabels = Sequence[];
        ];
              
              (*Define Chart Legends*)
        Which[ 
            chartLegends === Automatic,
                chartLegends = StringJoin["Series ",ToString[#]]&/@Range@nbrVars;
                  ,
                  Head@chartLegends===List,
                      If[ First[Head/@chartLegends]==String,
                          chartLegends = Style/@chartLegends
                      ];
                      chartLegends = PadRight[chartLegends,nbrVars,""];
                  ,
                  Head@chartLegends===String,
                  chartLegends = {Style[chartLegends]};
                  chartLegends = PadRight[chartLegends,nbrVars,""];
                  ,
                  Head@chartLegends===Placed,
                      chartLegends;
              ];
              (*Define Axes Labels*)
        Which[ 
            axesLabel === Automatic,
            axesLabel = MapThread[ Text[Style[#1],labelCoeff #2, -labelCoeff #2/Norm[#2]] &, {StringJoin["Dim ",ToString[#]]&/@Range@length, 
                Most@rearrangePoints[ConstantArray[maxAxis, length]]}];
              
                  ,
                  Fold[Or,False,SameQ[axesLabel,#]&/@{None,Off,False}],
                      axesLabel = Sequence[];
                  ,
                  True,
                      axesLabel = MapThread[ Text[Style[#1], labelCoeff #2, -labelCoeff #2/Norm[#2]] &, {PadRight[axesLabel,length,""], 
                      Most@rearrangePoints[ConstantArray[maxAxis, length]]}];
              ];
              
              (*Actual Graph*)
        If[ Fold[Or,False,SameQ[chartLegends,#]&/@{None,Off,False}],
            Graphics[Flatten@Join[polys,axes,{GrayLevel[0.4],Opacity[1],tickLabels,axesLabel}],PlotRange->All,PlotRangePadding->Round[maxAxis/6],gOpts],
            Legended[
                Graphics[Flatten@Join[polys,axes,{GrayLevel[0.4],Opacity[1],tickLabels,axesLabel}],PlotRange->All,PlotRangePadding->Round[maxAxis/6],gOpts]
                ,
                Placed[LineLegend[Directive/@colors,chartLegends,LegendLayout->"Row"],{Center,Below}]]
        ]
    ]
RadarChart[list:{_?NumericQ,_?NumericQ,__?NumericQ},opts:OptionsPattern[]] :=
    RadarChart[{list},opts]
RadarChart[ds_Dataset,opts:OptionsPattern[]] :=
    Module[ {
        override = FilterRules[{opts},Options[dsToSequence]],
        otherOpts},
        otherOpts = Complement[{opts},override];
        RadarChart[dsToSequence[ds,override],otherOpts]
    ];
RadarChart[assn_Association,opts:OptionsPattern[]] :=
    RadarChart[Dataset[{assn}],opts];
RadarChart[assn:{_Association...},opts:OptionsPattern[]] :=
    RadarChart[Dataset[assn],opts];

End[]  
EndPackage[]

