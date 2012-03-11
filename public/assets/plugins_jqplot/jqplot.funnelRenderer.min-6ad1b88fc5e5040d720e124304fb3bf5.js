/**
 * jqPlot
 * Pure JavaScript plotting plugin using jQuery
 *
 * Version: 1.0.0b2_r1012
 *
 * Copyright (c) 2009-2011 Chris Leonello
 * jqPlot is currently available for use in all personal or commercial projects 
 * under both the MIT (http://www.opensource.org/licenses/mit-license.php) and GPL 
 * version 2.0 (http://www.gnu.org/licenses/gpl-2.0.html) licenses. This means that you can 
 * choose the license that best suits your project and use it accordingly. 
 *
 * Although not required, the author would appreciate an email letting him 
 * know of any substantial use of jqPlot.  You can reach the author at: 
 * chris at jqplot dot com or see http://www.jqplot.com/info.php .
 *
 * If you are feeling kind and generous, consider supporting the project by
 * making a donation at: http://www.jqplot.com/donate.php .
 *
 * sprintf functions contained in jqplot.sprintf.js by Ash Searle:
 *
 *     version 2007.04.27
 *     author Ash Searle
 *     http://hexmen.com/blog/2007/03/printf-sprintf/
 *     http://hexmen.com/js/sprintf.js
 *     The author (Ash Searle) has placed this code in the public domain:
 *     "This code is unrestricted: you are free to use it however you like."
 *
 * included jsDate library by Chris Leonello:
 *
 * Copyright (c) 2010-2011 Chris Leonello
 *
 * jsDate is currently available for use in all personal or commercial projects 
 * under both the MIT and GPL version 2.0 licenses. This means that you can 
 * choose the license that best suits your project and use it accordingly.
 *
 * jsDate borrows many concepts and ideas from the Date Instance 
 * Methods by Ken Snyder along with some parts of Ken's actual code.
 * 
 * Ken's origianl Date Instance Methods and copyright notice:
 * 
 * Ken Snyder (ken d snyder at gmail dot com)
 * 2008-09-10
 * version 2.0.2 (http://kendsnyder.com/sandbox/date/)     
 * Creative Commons Attribution License 3.0 (http://creativecommons.org/licenses/by/3.0/)
 *
 * jqplotToImage function based on Larry Siden's export-jqplot-to-png.js.
 * Larry has generously given permission to adapt his code for inclusion
 * into jqPlot.
 *
 * Larry's original code can be found here:
 *
 * https://github.com/lsiden/export-jqplot-to-png
 * 
 * 
 */
(function(a){function b(b,c,d){d=d||{},d.axesDefaults=d.axesDefaults||{},d.legend=d.legend||{},d.seriesDefaults=d.seriesDefaults||{};var e=!1;if(d.seriesDefaults.renderer==a.jqplot.FunnelRenderer)e=!0;else if(d.series)for(var f=0;f<d.series.length;f++)d.series[f].renderer==a.jqplot.FunnelRenderer&&(e=!0);e&&(d.axesDefaults.renderer=a.jqplot.FunnelAxisRenderer,d.legend.renderer=a.jqplot.FunnelLegendRenderer,d.legend.preDraw=!0,d.sortData=!1,d.seriesDefaults.pointLabels={show:!1})}function c(b,c,d){for(var e=0;e<this.series.length;e++)this.series[e].renderer.constructor==a.jqplot.FunnelRenderer&&this.series[e].highlightMouseOver&&(this.series[e].highlightMouseDown=!1)}function d(b){for(var c=0;c<this.series.length;c++)this.series[c].seriesColors=this.seriesColors,this.series[c].colorGenerator=a.jqplot.colorGenerator}function e(a,b,c){var d=a.series[b],e=a.plugins.funnelRenderer.highlightCanvas;e._ctx.clearRect(0,0,e._ctx.canvas.width,e._ctx.canvas.height),d._highlightedPoint=c,a.plugins.funnelRenderer.highlightedSeriesIndex=b,d.renderer.drawSection.call(d,e._ctx,d._vertices[c],d.highlightColors[c],!1)}function f(a){var b=a.plugins.funnelRenderer.highlightCanvas;b._ctx.clearRect(0,0,b._ctx.canvas.width,b._ctx.canvas.height);for(var c=0;c<a.series.length;c++)a.series[c]._highlightedPoint=null;a.plugins.funnelRenderer.highlightedSeriesIndex=null,a.target.trigger("jqplotDataUnhighlight")}function g(a,b,c,d,g){if(d){var h=[d.seriesIndex,d.pointIndex,d.data],i=jQuery.Event("jqplotDataMouseOver");i.pageX=a.pageX,i.pageY=a.pageY,g.target.trigger(i,h);if(g.series[h[0]].highlightMouseOver&&(h[0]!=g.plugins.funnelRenderer.highlightedSeriesIndex||h[1]!=g.series[h[0]]._highlightedPoint)){var j=jQuery.Event("jqplotDataHighlight");j.pageX=a.pageX,j.pageY=a.pageY,g.target.trigger(j,h),e(g,h[0],h[1])}}else d==null&&f(g)}function h(a,b,c,d,g){if(d){var h=[d.seriesIndex,d.pointIndex,d.data];if(g.series[h[0]].highlightMouseDown&&(h[0]!=g.plugins.funnelRenderer.highlightedSeriesIndex||h[1]!=g.series[h[0]]._highlightedPoint)){var i=jQuery.Event("jqplotDataHighlight");i.pageX=a.pageX,i.pageY=a.pageY,g.target.trigger(i,h),e(g,h[0],h[1])}}else d==null&&f(g)}function i(a,b,c,d,e){var g=e.plugins.funnelRenderer.highlightedSeriesIndex;g!=null&&e.series[g].highlightMouseDown&&f(e)}function j(a,b,c,d,e){if(d){var f=[d.seriesIndex,d.pointIndex,d.data],g=jQuery.Event("jqplotDataClick");g.pageX=a.pageX,g.pageY=a.pageY,e.target.trigger(g,f)}}function k(a,b,c,d,e){if(d){var g=[d.seriesIndex,d.pointIndex,d.data],h=e.plugins.funnelRenderer.highlightedSeriesIndex;h!=null&&e.series[h].highlightMouseDown&&f(e);var i=jQuery.Event("jqplotDataRightClick");i.pageX=a.pageX,i.pageY=a.pageY,e.target.trigger(i,g)}}function l(){this.plugins.funnelRenderer&&this.plugins.funnelRenderer.highlightCanvas&&(this.plugins.funnelRenderer.highlightCanvas.resetCanvas(),this.plugins.funnelRenderer.highlightCanvas=null),this.plugins.funnelRenderer={},this.plugins.funnelRenderer.highlightCanvas=new a.jqplot.GenericCanvas;var b=a(this.targetId+" .jqplot-data-label");b.length?a(b[0]).before(this.plugins.funnelRenderer.highlightCanvas.createElement(this._gridPadding,"jqplot-funnelRenderer-highlight-canvas",this._plotDimensions,this)):this.eventCanvas._elem.before(this.plugins.funnelRenderer.highlightCanvas.createElement(this._gridPadding,"jqplot-funnelRenderer-highlight-canvas",this._plotDimensions,this));var c=this.plugins.funnelRenderer.highlightCanvas.setContext();this.eventCanvas._elem.bind("mouseleave",{plot:this},function(a){f(a.data.plot)})}a.jqplot.FunnelRenderer=function(){a.jqplot.LineRenderer.call(this)},a.jqplot.FunnelRenderer.prototype=new a.jqplot.LineRenderer,a.jqplot.FunnelRenderer.prototype.constructor=a.jqplot.FunnelRenderer,a.jqplot.FunnelRenderer.prototype.init=function(b,e){this.padding={top:20,right:20,bottom:20,left:20},this.sectionMargin=6,this.fill=!0,this.shadowOffset=2,this.shadowAlpha=.07,this.shadowDepth=5,this.highlightMouseOver=!0,this.highlightMouseDown=!1,this.highlightColors=[],this.widthRatio=.2,this.lineWidth=2,this.dataLabels="percent",this.showDataLabels=!1,this.dataLabelFormatString=null,this.dataLabelThreshold=3,this._type="funnel",this.tickRenderer=a.jqplot.FunnelTickRenderer,b.highlightMouseDown&&b.highlightMouseOver==null&&(b.highlightMouseOver=!1),a.extend(!0,this,b),this._highlightedPoint=null,this._bases=[],this._atot,this._areas=[],this._lengths=[],this._angle,this._dataIndices=[],this._unorderedData=a.extend(!0,[],this.data);var f=a.extend(!0,[],this.data);for(var m=0;m<f.length;m++)f[m].push(m);this.data.sort(function(a,b){return b[1]-a[1]}),f.sort(function(a,b){return b[1]-a[1]});for(var m=0;m<f.length;m++)this._dataIndices.push(f[m][2]);if(this.highlightColors.length==0)for(var m=0;m<this.seriesColors.length;m++){var n=a.jqplot.getColorComponents(this.seriesColors[m]),o=[n[0],n[1],n[2]],p=o[0]+o[1]+o[2];for(var q=0;q<3;q++)o[q]=p>570?o[q]*.8:o[q]+.4*(255-o[q]),o[q]=parseInt(o[q],10);this.highlightColors.push("rgb("+o[0]+","+o[1]+","+o[2]+")")}e.postParseOptionsHooks.addOnce(d),e.postInitHooks.addOnce(c),e.eventListenerHooks.addOnce("jqplotMouseMove",g),e.eventListenerHooks.addOnce("jqplotMouseDown",h),e.eventListenerHooks.addOnce("jqplotMouseUp",i),e.eventListenerHooks.addOnce("jqplotClick",j),e.eventListenerHooks.addOnce("jqplotRightClick",k),e.postDrawHooks.addOnce(l)},a.jqplot.FunnelRenderer.prototype.setGridData=function(a){var b=0,c=[];for(var d=0;d<this.data.length;d++)b+=this.data[d][1],c.push([this.data[d][0],this.data[d][1]]);for(var d=0;d<c.length;d++)c[d][1]=c[d][1]/b;this._bases=new Array(c.length+1),this._lengths=new Array(c.length),this.gridData=c},a.jqplot.FunnelRenderer.prototype.makeGridData=function(a,b){var c=0,d=[];for(var e=0;e<this.data.length;e++)c+=this.data[e][1],d.push([this.data[e][0],this.data[e][1]]);for(var e=0;e<d.length;e++)d[e][1]=d[e][1]/c;return this._bases=new Array(d.length+1),this._lengths=new Array(d.length),d},a.jqplot.FunnelRenderer.prototype.drawSection=function(a,b,c,d){function h(){a.beginPath(),a.fillStyle=c,a.strokeStyle=c,a.lineWidth=f,a.moveTo(b[0][0],b[0][1]);for(var d=1;d<4;d++)a.lineTo(b[d][0],b[d][1]);a.closePath(),e?a.fill():a.stroke()}var e=this.fill,f=this.lineWidth;a.save();if(d)for(var g=0;g<this.shadowDepth;g++)a.save(),a.translate(this.shadowOffset*Math.cos(this.shadowAngle/180*Math.PI),this.shadowOffset*Math.sin(this.shadowAngle/180*Math.PI)),h();else h();if(d)for(var g=0;g<this.shadowDepth;g++)a.restore();a.restore()},a.jqplot.FunnelRenderer.prototype.draw=function(b,c,d,e){function F(a){var b=(B[1]-D[1])/(B[0]-D[0]),c=B[1]-b*B[0],d=a+B[1];return[(d-c)/b,d]}function G(a){var b=(C[1]-E[1])/(C[0]-E[0]),c=C[1]-b*C[0],d=a+C[1];return[(d-c)/b,d]}var f,g=d!=undefined?d:{},h=0,i=0,j=1;this._areas=[];if(d.legendInfo&&d.legendInfo.placement=="insideGrid"){var k=d.legendInfo;switch(k.location){case"nw":h=k.width+k.xoffset;break;case"w":h=k.width+k.xoffset;break;case"sw":h=k.width+k.xoffset;break;case"ne":h=k.width+k.xoffset,j=-1;break;case"e":h=k.width+k.xoffset,j=-1;break;case"se":h=k.width+k.xoffset,j=-1;break;case"n":i=k.height+k.yoffset;break;case"s":i=k.height+k.yoffset,j=-1;break;default:}}var l=j==1?this.padding.left+h:this.padding.left,m=j==1?this.padding.top+i:this.padding.top,n=j==-1?this.padding.right+h:this.padding.right,o=j==-1?this.padding.bottom+i:this.padding.bottom,p=g.shadow!=undefined?g.shadow:this.shadow,q=g.showLine!=undefined?g.showLine:this.showLine,r=g.fill!=undefined?g.fill:this.fill,s=b.canvas.width,t=b.canvas.height;this._bases[0]=s-l-n;var u=this._length=t-m-o,v=this._bases[0]*this.widthRatio;this._atot=u/2*(this._bases[0]+this._bases[0]*this.widthRatio),this._angle=Math.atan((this._bases[0]-v)/2/u);for(f=0;f<c.length;f++)this._areas.push(c[f][1]*this._atot);var w,x,y,z=0,A=1e-4;for(f=0;f<this._areas.length;f++){w=this._areas[f]/this._bases[f],x=999999,this._lengths[f]=w,y=0;while(x>this._lengths[f]*A&&y<100)this._lengths[f]=this._areas[f]/(this._bases[f]-this._lengths[f]*Math.tan(this._angle)),x=Math.abs(this._lengths[f]-w),this._bases[f+1]=this._bases[f]-2*this._lengths[f]*Math.tan(this._angle),w=this._lengths[f],y++;z+=this._lengths[f]}this._vertices=new Array(c.length);var B=[l,m],C=[l+this._bases[0],m],D=[l+(this._bases[0]-this._bases[this._bases.length-1])/2,m+this._length],E=[D[0]+this._bases[this._bases.length-1],D[1]],H=h,I=i,J=0,K=0;for(f=0;f<c.length;f++){this._vertices[f]=new Array;var L=this._vertices[f],M=this.sectionMargin;f==0&&(K=0),f==1?K=M/3:f>0&&f<c.length-1?K=M/2:f==c.length-1&&(K=2*M/3),L.push(F(J+K)),L.push(G(J+K)),J+=this._lengths[f],f==0?K=-2*M/3:f>0&&f<c.length-1?K=-M/2:f==c.length-1&&(K=0),L.push(G(J+K)),L.push(F(J+K))}if(this.shadow){var N="rgba(0,0,0,"+this.shadowAlpha+")";for(var f=0;f<c.length;f++)this.renderer.drawSection.call(this,b,this._vertices[f],N,!0)}for(var f=0;f<c.length;f++){var L=this._vertices[f];this.renderer.drawSection.call(this,b,L,this.seriesColors[f]);if(this.showDataLabels&&c[f][1]*100>=this.dataLabelThreshold){var O,P;this.dataLabels=="label"?(O=this.dataLabelFormatString||"%s",P=a.jqplot.sprintf(O,c[f][0])):this.dataLabels=="value"?(O=this.dataLabelFormatString||"%d",P=a.jqplot.sprintf(O,this.data[f][1])):this.dataLabels=="percent"?(O=this.dataLabelFormatString||"%d%%",P=a.jqplot.sprintf(O,c[f][1]*100)):this.dataLabels.constructor==Array&&(O=this.dataLabelFormatString||"%s",P=a.jqplot.sprintf(O,this.dataLabels[this._dataIndices[f]]));var Q=this._radius*this.dataLabelPositionFactor+this.sliceMargin+this.dataLabelNudge,H=(L[0][0]+L[1][0])/2+this.canvas._offsets.left,I=(L[1][1]+L[2][1])/2+this.canvas._offsets.top,R=a('<span class="jqplot-funnel-series jqplot-data-label" style="position:absolute;">'+P+"</span>").insertBefore(e.eventCanvas._elem);H-=R.width()/2,I-=R.height()/2,H=Math.round(H),I=Math.round(I),R.css({left:H,top:I})}}},a.jqplot.FunnelAxisRenderer=function(){a.jqplot.LinearAxisRenderer.call(this)},a.jqplot.FunnelAxisRenderer.prototype=new a.jqplot.LinearAxisRenderer,a.jqplot.FunnelAxisRenderer.prototype.constructor=a.jqplot.FunnelAxisRenderer,a.jqplot.FunnelAxisRenderer.prototype.init=function(b){this.tickRenderer=a.jqplot.FunnelTickRenderer,a.extend(!0,this,b),this._dataBounds={min:0,max:100},this.min=0,this.max=100,this.showTicks=!1,this.ticks=[],this.showMark=!1,this.show=!1},a.jqplot.FunnelLegendRenderer=function(){a.jqplot.TableLegendRenderer.call(this)},a.jqplot.FunnelLegendRenderer.prototype=new a.jqplot.TableLegendRenderer,a.jqplot.FunnelLegendRenderer.prototype.constructor=a.jqplot.FunnelLegendRenderer,a.jqplot.FunnelLegendRenderer.prototype.init=function(b){this.numberRows=null,this.numberColumns=null,a.extend(!0,this,b)},a.jqplot.FunnelLegendRenderer.prototype.draw=function(){var b=this;if(this.show){var c=this._series,d="position:absolute;";d+=this.background?"background:"+this.background+";":"",d+=this.border?"border:"+this.border+";":"",d+=this.fontSize?"font-size:"+this.fontSize+";":"",d+=this.fontFamily?"font-family:"+this.fontFamily+";":"",d+=this.textColor?"color:"+this.textColor+";":"",d+=this.marginTop!=null?"margin-top:"+this.marginTop+";":"",d+=this.marginBottom!=null?"margin-bottom:"+this.marginBottom+";":"",d+=this.marginLeft!=null?"margin-left:"+this.marginLeft+";":"",d+=this.marginRight!=null?"margin-right:"+this.marginRight+";":"",this._elem=a('<table class="jqplot-table-legend" style="'+d+'"></table>');var e=!1,f=!1,g,h,i=c[0],j=new a.jqplot.ColorGenerator(i.seriesColors);if(i.show){var k=i.data;this.numberRows?(g=this.numberRows,this.numberColumns?h=this.numberColumns:h=Math.ceil(k.length/g)):this.numberColumns?(h=this.numberColumns,g=Math.ceil(k.length/this.numberColumns)):(g=k.length,h=1);var l,m,n,o,p,q,r,s,t=0;for(l=0;l<g;l++){f?n=a('<tr class="jqplot-table-legend"></tr>').prependTo(this._elem):n=a('<tr class="jqplot-table-legend"></tr>').appendTo(this._elem);for(m=0;m<h;m++)t<k.length&&(q=this.labels[t]||k[t][0].toString(),s=j.next(),f?l==g-1?e=!1:e=!0:l>0?e=!0:e=!1,r=e?this.rowSpacing:"0",o=a('<td class="jqplot-table-legend" style="text-align:center;padding-top:'+r+';"><div><div class="jqplot-table-legend-swatch" style="border-color:'+s+';"></div></div></td>'),p=a('<td class="jqplot-table-legend" style="padding-top:'+r+';"></td>'),this.escapeHtml?p.text(q):p.html(q),f?(p.prependTo(n),o.prependTo(n)):(o.appendTo(n),p.appendTo(n)),e=!0),t++}}}return this._elem},a.jqplot.preInitHooks.push(b),a.jqplot.FunnelTickRenderer=function(){a.jqplot.AxisTickRenderer.call(this)},a.jqplot.FunnelTickRenderer.prototype=new a.jqplot.AxisTickRenderer,a.jqplot.FunnelTickRenderer.prototype.constructor=a.jqplot.FunnelTickRenderer})(jQuery)