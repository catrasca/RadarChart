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

The following table lists some of the most important options available.

Options | Values |Description
------------ | ------------- | -------------
AxesType | "Star" or "Radar" | AxesType is an option for changing the style of the Axes. Star creates a Star Plot, while "Radar" a Radar Plot
FrameTicks    | Automatic          |Frameticks can be defined by the user. Example Frameticks->{0,2,4,6,8,10} 
PlotStyle | Automatic | PlotStyle is an option for plotting and related functions that specifies styles in which objects are to be drawn. 
Filling | None | defines what filling to add below lines.
ChartLegends | None or Automatic or list | ChartLegends is an option for charting functions that specifies what legends should be used for chart elements.
AxesLabel | None or Automatic or list | AxesLabel is an option for graphics functions that specifies labels for axes. 
PlotLabel | None | Defines the title of the plot.
Epilog | {} | Epilog is an option for graphics functions that gives a list of graphics primitives to be rendered after the main part of the graphics is rendered.  

##Examples
    Needs["RadarChart`"]
    RadarChart[{1, 2, 4, 5, 3}, 
    ChartLegends -> {"Private Label Strawberry Juice"}, 
    AxesLabel -> {"Ripe", "Green", "Candy", "Juicy", "Sulphur"}, 
    PlotLabel -> Style["Sensory Map Strawberry Juice", Bold, Large], 
    ImageSize -> Medium]
    
![Basic Example](http://i.stack.imgur.com/Opnwp.png)    
