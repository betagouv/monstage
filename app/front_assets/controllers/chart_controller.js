import { Controller } from "stimulus";
import * as d3 from "d3";

function formatDate(date) {
  return date.toLocaleString("fr", {
    month: "short",
    day: "numeric",
    year: "numeric",
    timeZone: "UTC",
  });
}


function serializeForGraph(data) {
  var result = [];
  var parseTime = d3.timeParse("%Y-%m-%d");
  $.each(data, function (index, element) {
    var prev = result[index - 1];
    var previousValue = prev ? prev.value : 0;
    result.push({
      date: parseTime(element.date),
      value: element.count + previousValue,
    });
  });
  return result;
}
export default class extends Controller {
  static targets = ["svg"];
  static values = {
    internshipOfferCreatedAtByMonth: Array,
    internshipApplicationAcceptedAtByMonth: Array,
  };

  drawCharts() {
    // set the dimensions and margins of the graph
    var margin = { top: 15, right: 80, bottom: 100, left: 80 },
      width = $(this.svgTarget).width() - margin.left - margin.right,
      height = 500 - margin.top - margin.bottom;

    //reformat data for ease of use
    var internshipOfferCreatedAtData = serializeForGraph(
      this.internshipOfferCreatedAtByMonthValue
    );
    var internshipApplicationAcceptedAtData = serializeForGraph(
      this.internshipApplicationAcceptedAtByMonthValue
    );

    // append the svg object to the body of the page
    var svg = d3
      .select(this.svgTarget)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

    this.makeGradient(svg);

    var allData = []
      .concat(internshipOfferCreatedAtData)
      .concat(internshipOfferCreatedAtData);

    // Determine the first and last dates in the data sets
    var x = d3
      .scaleTime()
      .domain(d3.extent(allData, (d) => d.date))
      .rangeRound([0, width]);
    // Determine the max value in the data sets
    var y = d3
      .scaleLinear()
      .domain([0, d3.max(allData, (d) => d.value)])
      .range([height, 0]);

    var xAxis = d3.axisBottom(x);
    var yAxis = d3.axisLeft(y).ticks(10);

    svg
      .append("g")
      .attr("transform", "translate(0," + height + ")")
      .call(xAxis);

    svg
      .append("g")
      .call(yAxis)
      .append("text")
      .attr("fill", "#000")
      .attr("transform", "rotate(-90)")
      .attr("y", 6)
      .attr("dy", "0.71em")
      .style("text-anchor", "end")

    this.drawInternshipOfferCreatedAtChart(
      x,
      y,
      internshipOfferCreatedAtData,
      svg
    );
    this.drawInternshipApplicationAcceptedAtChart(
      x,
      y,
      internshipApplicationAcceptedAtData,
      svg
    );
    this.drawToolTip(
      x,
      y,
      internshipOfferCreatedAtData,
      internshipApplicationAcceptedAtData,
      svg
    );
    this.makeSvgFilter(svg);
  }

  drawInternshipOfferCreatedAtChart(x, y, internshipOfferCreatedAtData, svg) {
    var curve = d3.curveBumpX;
    var area = d3
      .area()
      .curve(curve)
      .x((d) => x(d.date))
      .y0(y(0))
      .y1((d) => y(d.value));

    svg
      .append("path")
      .datum(internshipOfferCreatedAtData)
      .attr("class", "area")
      .attr("d", area)
      .style("fill", "#f6c4c5");
  }

  drawToolTip(
    x,
    y,
    internshipOfferCreatedAtData,
    internshipApplicationAcceptedAtData,
    svg
  ) {
    var callout = (g, value) => {
      if (!value) return g.style("display", "none");

      g.style("display", null)
        .style("pointer-events", "none")
        // .style("font", "10px sans-serif");

      const path = g
        .selectAll("path")
        .data([null])
        .join("path")
        .attr("fill", "#333333");
      const text = g
        .selectAll("text")
        .data([null])
        .join("text")
        .call((text) =>
          text
            .selectAll("tspan")
            .data((value + "").split(/\n/))
            .join("tspan")
            .attr("x", 0)
            .attr("y", (d, i) => `${i * 1.5}em`)
            .attr("fill", "#ffffff")
            .style("text-anchor", "middle")
            .style("font-weight", (_, i) => (i ? null : "bold"))
            .style("font-size", "11px")
            .text((d) => d)
        );

      const { x, y, width: w, height: h } = text.node().getBBox();

      text.attr("transform", `translate(0,${15 - y})`);
      path.attr(
        "d",
        `M${-w / 2 - 10},5H-5l5,-5l5,5H${w / 2 + 10}v${h + 20}h-${w + 20}z`
      );
    };

    svg.on("mousemove touchmove", function (event) {
      const bisectInternshipOfferCreatedAtData = (mx) => {
        const bis = d3.bisector((d) => d.date).left;
        const date = x.invert(mx);
        const index = bis(internshipOfferCreatedAtData, date, 1);
        const a = internshipOfferCreatedAtData[index - 1];
        const b = internshipOfferCreatedAtData[index];
        return b && date - a.date > b.date - date ? b : a;
      };
      const { date, value: createdValue } = bisectInternshipOfferCreatedAtData(
        d3.pointer(event, this)[0]
      );
      const bisectInternshipApplicationAcceptedAtData = (mx) => {
        const bis = d3.bisector((d) => d.date).left;
        const date = x.invert(mx);
        const index = bis(internshipApplicationAcceptedAtData, date, 1);
        const a = internshipApplicationAcceptedAtData[index - 1];
        const b = internshipApplicationAcceptedAtData[index];
        return b && date - a.date > b.date - date ? b : a;
      };
      const {
        date: _,
        value: approvedValue,
      } = bisectInternshipApplicationAcceptedAtData(d3.pointer(event, this)[0]);

      icon
        .style("display", null)
        .attr("transform", `translate(${x(date) - 12},${y(createdValue) - 12})`)
      tooltip
        .attr("transform", `translate(${x(date)},${y(createdValue) + 12})`)
        .call(
          callout,
          `${createdValue} offres proposées
${approvedValue} candidatures acceptées
au ${formatDate(date)}`
        );
    });

    svg.on("touchend mouseleave", () => {
      tooltip.call(callout, null)
      icon.style("display", "none")
    });

    // create a tooltip
    const tooltip = svg.append("g");
    const icon = this.drawIcon(svg);

  }

  drawInternshipApplicationAcceptedAtChart(
    x,
    y,
    internshipApplicationAcceptedAtData,
    svg
  ) {
    var curve = d3.curveBumpX;
    var area = d3
      .area()
      .curve(curve)
      .x((d) => x(d.date))
      .y0(y(0))
      .y1((d) => y(d.value));

    svg
      .append("path")
      .datum(internshipApplicationAcceptedAtData)
      .attr("class", "area")
      .attr("d", area)
      .style("fill", "url(#mygrad)");
  }

  drawIcon(svg){
    var icon = svg.append("g")
    icon.style("display", "none")
          .attr("transform","translate(15 15)")
          .append("g")
          .attr("style", "filter: url(#a)")
          .attr("transform","matrix(1, 0, 0, 1, -15, -15)")
            .append("path")
            .attr("transform", "translate(2236.09 -2540.68)")
            .attr("fill", "#ffffff")
            .attr("d", "M-2209.085,2579.677a11.921,11.921,0,0,1-8.485-3.515,11.922,11.922,0,0,1-3.515-8.486,11.922,11.922,0,0,1,3.515-8.485,11.921,11.921,0,0,1,8.485-3.515,11.923,11.923,0,0,1,8.486,3.515,11.921,11.921,0,0,1,3.515,8.485,11.923,11.923,0,0,1-3.515,8.486A11.923,11.923,0,0,1-2209.085,2579.677Zm0-16a4,4,0,0,0-4,4,4,4,0,0,0,4,4,4.005,4.005,0,0,0,4-4A4,4,0,0,0-2209.085,2563.677Z")
    return icon;
  }

  makeGradient(svg) {
    var lg = svg
      .append("defs")
      .append("linearGradient")
      .attr("id", "mygrad") //id of the gradient
      .attr("x1", "0%")
      .attr("x2", "0%")
      .attr("y1", "0%")
      .attr("y2", "100%"); //since its a vertical linear gradient
    lg.append("stop")
      .attr("offset", "0%")
      .style("stop-color", "#E24647") //start in blue
      .style("stop-opacity", 1);

    lg.append("stop")
      .attr("offset", "100%")
      .style("stop-color", "#FF8D8E") //end in red
      .style("stop-opacity", 1);
  }


  makeSvgFilter(svg) {
    var def = svg.selectAll("defs")
    var filter = def.append("filter")
    filter.attr('id', "a")
    filter.attr('x', "0")
    filter.attr('y', "0")
    filter.attr('width', "54")
    filter.attr('height', "54")
    filter.attr('filterUnits', "userSpaceOnUse")
    filter.append("feOffset").attr("input", "SourceAlpha")
    filter.append("feGaussianBlur").attr("stdDeviation","5").attr("result", "b")
    filter.append("feFlood").attr("flood-opacity","0.161")
    filter.append("feComposite").attr("operator","in").attr("in2", "b")
    filter.append("feComposite").attr("in", "SourceGraphic")
  }


  connect() {
    this.drawCharts();
  }
}

