# RadarChart
RadarChart Mathematica Package
The *RadarChart* mathematica package incorporates Radar Charts (also known as Spider Charts, Web Charts and Star Plots) as a new set of visualization tools into the mathematica environment.

A detailed explanation on the use of radar charts can be found in the following [wikipedia page](https://en.wikipedia.org/wiki/Radar_chart).

##![doc image](http://i.stack.imgur.com/erf8e.png) Detailed Usage
    RadarChart[{y1,y2,y3,...}]
generates a radar plot (also known as web, star, spider, cobweb or kiviat diagram) corresponding to a list of values. This type of chart is suitable for showing commonality and outliers across different variables. 
     RadarChart[{list1,list2,...}]
generates a radar plot to compare several series. 

     RadarChart[association]
generates a radar plot to view the variable values in an association. 

     RadarChart[{association1,association2,...}]
generates a radar plot to compare several series. 

     RadarChart[dataset]
generates a radar plot to compare several series.

The following options can be given.
First Header | Second Header
------------ | -------------
Content from cell 1 | Content from cell 2
Content in the first column | Content in the second column


AxesType  "Star" or "Radar"  AxesType is an option for changing the style of the Axes. Star creates 


|              |                    |a Star Plot, while "Radar" a Radar Plot.                               |

|FrameTicks    | Automatic          |Frameticks can be defined by the user eg {0,2,4,6,8,10}                |
