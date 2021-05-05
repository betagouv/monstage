import { Controller } from 'stimulus';
import * as d3 from 'd3'
function formatDate(date) {
  return date.toLocaleString("en", {
    month: "short",
    day: "numeric",
    year: "numeric",
    timeZone: "UTC"
  });
}
function formatValue(value) {
  return value.toString();
}

export default class extends Controller {

  static targets = ['svg']
  static values = {
    internshipOfferCreatedAtSerie: Array,
    internshipApplicationAcceptedAtSerie: Array,
  };

  drawCharts() {
    // set the dimensions and margins of the graph
    var margin = {top: 0, right: 40, bottom: 20, left: 40},
        width = $(this.svgTarget).width() - margin.left - margin.right,
        height = 400 - margin.top - margin.bottom;

    //reformat data for ease of use
    var internshipOfferCreatedAtData = this.makeInternshipOfferCreatedAtData();
    var internshipApplicationAcceptedAtData = this.makeInternshipApplicationAcceptedAtSerie();
    var allData = [].concat(internshipOfferCreatedAtData)
                    .concat(internshipOfferCreatedAtData)

  // append the svg object to the body of the page
  var svg = d3.select(this.svgTarget)
    .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
    .append("g")
      .attr("transform",
            "translate(" + margin.left + "," + margin.top + ")");

  this.makeGradient(svg)

   // Determine the first and last dates in the data sets
   var x = d3.scaleTime()
             .domain(d3.extent(allData, (d) => d.date))
             .rangeRound([0, width]);
   // Determine the max value in the data sets
   var y = d3.scaleLinear()
             .domain([0, d3.max(allData, (d) => d.value )])
             .range([height, 0]);

   var xAxis = d3.axisBottom(x);
   var yAxis = d3.axisLeft(y).ticks(10);

   svg.append("g")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

   svg.append("g")
      .call(yAxis)
      .append("text")
      .attr("fill", "#000")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", "0.71em")
      .style("text-anchor", "end")
      .text("Number of events");

    this.drawInternshipOfferCreatedAtChart(x, y, internshipOfferCreatedAtData, svg);
    this.drawInternshipApplicationAcceptedAtChart(x, y, internshipApplicationAcceptedAtData, svg);
    this.drawToolTip(x,y,internshipOfferCreatedAtData, internshipApplicationAcceptedAtData, svg);

  }


  drawInternshipOfferCreatedAtChart(x, y, internshipOfferCreatedAtData, svg) {
    var curve = d3.curveBumpX
    var area = d3.area()
                  .curve(curve)
                  .x((d) => x(d.date))
                  .y0(y(0))
                  .y1(d => y(d.value))

    svg.append("path")
        .datum(internshipOfferCreatedAtData)
        .attr("class", "area")
        .attr("d", area)
        .style("fill", "#f6c4c5")

  }

  drawToolTip(x,y,internshipOfferCreatedAtData, internshipApplicationAcceptedAtData, svg) {
    var callout = (g, value) => {
      if (!value) return g.style("display", "none");

      g.style("display", null)
          .style("pointer-events", "none")
          .style("font", "10px sans-serif");

      const path = g.selectAll("path")
        .data([null])
        .join("path")
          .attr("fill", "#333333");

      const text = g.selectAll("text")
        .data([null])
        .join("text")
        .call(text => text
          .selectAll("tspan")
          .data((value + "").split(/\n/))
          .join("tspan")
            .attr("x", 0)
            .attr("y", (d, i) => `${i * 1.1}em`)
            .attr("fill", "#ffffff")
            .style("text-anchor", "middle")

            .style("font-weight", (_, i) => i ? null : "bold")
            .text(d => d));

      const {x, y, width: w, height: h} = text.node().getBBox();

      text.attr("transform", `translate(0,${15 - y})`);
      path.attr("d", `M${-w / 2 - 10},5H-5l5,-5l5,5H${w / 2 + 10}v${h + 20}h-${w + 20}z`);
    }

    svg.on("mousemove touchmove", function(event) {
          const bisectInternshipOfferCreatedAtData = mx => {
            const bis = d3.bisector(d => d.date).left;
            const date = x.invert(mx);
            const index = bis(internshipOfferCreatedAtData, date, 1);
            const a = internshipOfferCreatedAtData[index - 1];
            const b = internshipOfferCreatedAtData[index];
            return b && (date - a.date > b.date - date) ? b : a;
          }
          const {date, value: createdValue} = bisectInternshipOfferCreatedAtData(d3.pointer(event, this)[0]);
          const bisectInternshipApplicationAcceptedAtData = mx => {
            const bis = d3.bisector(d => d.date).left;
            const date = x.invert(mx);
            const index = bis(internshipApplicationAcceptedAtData, date, 1);
            const a = internshipApplicationAcceptedAtData[index - 1];
            const b = internshipApplicationAcceptedAtData[index];
            return b && (date - a.date > b.date - date) ? b : a;
          }
          const {date: _, value: approvedValue} = bisectInternshipApplicationAcceptedAtData(d3.pointer(event, this)[0]);
          tooltip
              .attr("transform", `translate(${x(date)},${y(createdValue)})`)
              .call(callout, `${formatValue(createdValue)} offres proposées
${formatValue(approvedValue)} candidatures acceptés
au ${formatDate(date)}`);
        })

      svg.on("touchend mouseleave", () => tooltip.call(callout, null));

      // create a tooltip
      const tooltip = svg.append("g");
  }

  drawInternshipApplicationAcceptedAtChart(x, y, internshipApplicationAcceptedAtData, svg) {
  var curve = d3.curveBumpX
  var area = d3.area()
                .curve(curve)
                .x((d) => x(d.date))
                .y0(y(0))
                .y1(d => y(d.value))

  svg.append("path")
      .datum(internshipApplicationAcceptedAtData)
      .attr("class", "area")
      .attr("d", area)
      .style("fill", "url(#mygrad)")


  }

  makeInternshipOfferCreatedAtData() {
    var data = []
    var parseTime = d3.timeParse("%Y-%m-%dT%H:%M:%S.%LZ");

    $.each(this.internshipOfferCreatedAtSerieValue, function (index, element) {
      var prev = data[index - 1]
      var previousValue = prev ? prev.value : 0
      data.push({
          'date': parseTime(element.created_at_to_month),
          'value': element.count + previousValue
      })
    });
    return data;
  }
  makeInternshipApplicationAcceptedAtSerie() {
    var data = []
    var parseTime = d3.timeParse("%Y-%m-%dT%H:%M:%S.%LZ");
    $.each(this.internshipApplicationAcceptedAtSerieValue, function (index, element) {
      var prev = data[index - 1]
      var previousValue = prev ? prev.value : 0
      data.push({
          'date': parseTime(element.approved_at_to_month),
          'value': element.count + previousValue
      })
    });
    return data;
  }

  makeGradient(svg) {
    var lg = svg.append("defs").append("linearGradient")
                .attr("id", "mygrad")//id of the gradient
                .attr("x1", "0%")
                .attr("x2", "0%")
                .attr("y1", "0%")
                .attr("y2", "100%")//since its a vertical linear gradient
                ;
    lg.append("stop")
    .attr("offset", "0%")
    .style("stop-color", "#E24647")//start in blue
    .style("stop-opacity", 1)

    lg.append("stop")
    .attr("offset", "100%")
    .style("stop-color", "#FF8D8E")//end in red
    .style("stop-opacity", 1)
  }


  connect() {
    console.log('internshipOfferCreatedAtSerieValue', this.internshipOfferCreatedAtSerieValue);
    console.log('internshipApplicationAcceptedAtSerie', this.internshipApplicationAcceptedAtSerieValue);

    this.drawCharts()
  }
}
