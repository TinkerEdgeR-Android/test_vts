<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<html>
  <head>
    <title>VTS Table</title>
    <link rel="icon" href="//www.gstatic.com/images/branding/googleg/1x/googleg_standard_color_32dp.png" sizes="32x32">
    <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons">
    <link rel="stylesheet" href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700">
    <link rel="stylesheet" href="https://www.gstatic.com/external_hosted/materialize/all_styles-bundle.css">
    <link type="text/css" href="/css/navbar.css" rel="stylesheet">
    <link type="text/css" href="/css/show_table.css" rel="stylesheet">
    <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"></script>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <script src="https://www.gstatic.com/external_hosted/materialize/materialize.min.js"></script>
    <script src="http://www.gstatic.com/external_hosted/moment/min/moment-with-locales.min.js"></script>
    <script type="text/javascript">
      google.charts.load('current', {'packages':['table', 'corechart']});
      google.charts.setOnLoadCallback(drawGridTable);
      google.charts.setOnLoadCallback(drawProfilingTable);
      google.charts.setOnLoadCallback(drawLegendTable);
      google.charts.setOnLoadCallback(drawPieChart);
      google.charts.setOnLoadCallback(function() {
          $(".gradient").removeClass("gradient");
      });

      // table for profiling data
      function drawProfilingTable() {
          errorMessage = ${errorJson} || "";
          if (errorMessage.length > 0) {
              return;
          }
          var data = new google.visualization.DataTable();

          // add columns
          data.addColumn('string', 'Profiling Point Names');

          // add rows
          var profilingPointNameArray = ${profilingPointNameJson};
          var rowArray = new Array(profilingPointNameArray.length);

          for (var i = 0; i < rowArray.length; i++) {
              var row = new Array(1);
              row[0] = profilingPointNameArray[i];
              rowArray[i] = row;
          }
          data.addRows(rowArray);

          var table = new google.visualization.Table(
              document.getElementById('profiling_table_div'));

          var options = {
              showRowNumber: false,
              alternatingRowStyle : true,
              width: '100%',
              sortColumn: 0,
              sortAscending: true
          };
          table.draw(data, options);

          google.visualization.events.addListener(table, 'select', selectHandler);

          function selectHandler(e) {
              var ctx = "${pageContext.request.contextPath}";
              var link = ctx + "/show_graph?profilingPoint=" +
                  data.getValue(table.getSelection()[0].row, 0) +
                  "&testName=${testName}" +
                  "&startTime=" + ${startTime} +
                  "&endTime=" + ${endTime};
              window.open(link,"_self");
          }
      }

      // to draw pie chart
      function drawPieChart() {
          var pieChartArray = ${pieChartArrayJson};
          if (pieChartArray.length < 1) {
              return;
          }
          for (var i = 1; i < pieChartArray.length; i++) {
              pieChartArray[i][1] = parseInt(pieChartArray[i][1]);
          }

          var data = google.visualization.arrayToDataTable(pieChartArray);
          var topBuild = ${topBuildJson};
          var colName = topBuild.substring(0, topBuild.lastIndexOf("."));
          var title = 'Test Result Status for build ID : ' + colName;
          var options = {
            title: title,
            is3D: false,
            colors: ['#FFFFFF', '#7FFF00', '#ff4d4d', '#A8A8A8', '#000000', '9900CC'],
            fontName: 'Roboto',
            fontSize: '14px',
            legend: { position: 'bottom', alignment: 'center' },
            tooltip: {showColorCode: true, ignoreBounds: true}
          };

          var chart = new google.visualization.PieChart(document.getElementById('pie_chart_div'));
          chart.draw(data, options);
      }
      // table for legend
      function drawLegendTable() {
          var data = new google.visualization.DataTable();

          var columns = new Array('Unknown', 'Pass', 'Fail', 'Skipped', 'Exception', 'Timeout');
          // add columns
          data.addColumn('string', 'Result');
          for (var i = 0; i < columns.length; i++) {
              data.addColumn('string', columns[i]);
          }

          var row = new Array('Color Code', ' ', ' ', ' ', ' ', ' ', ' ');
          var rows = new  Array(1);
          rows[0] = row;
          data.addRows(rows);

          // add colors
          for (var row = 0; row < rows.length; row++) {
              for (var column = 1; column < rows[0].length; column++) {
                  var result = column - 1;
                  switch(result) {
                      case 0 : // case : unknown
                          data.setValue(row, column, ' ');
                          break;
                      case 1 : // Case: pass - green
                          data.setProperty(row, column, 'style',
                              'background-color: #7FFF00;');
                          break;
                      case 2 : // Case : fail - red
                          data.setProperty(row, column, 'style',
                              'background-color: #ff4d4d;');
                          break;
                      case 3 : // case : skip : grey
                          data.setProperty(row, column, 'style',
                              'background-color: #A8A8A8;');
                          data.setValue(row, column, ' ');
                          break;
                      case 4: // Case: Exception - black
                          data.setProperty(row, column, 'style',
                              'background-color: #000000;');
                          break;
                      case 5: // Case: Timeout - purple
                          data.setProperty(row, column, 'style',
                              'background-color: #9900CC;');
                          break;
                  }
              }
          }

          var table = new google.visualization.Table(document.getElementById('legend_table_div'));
          table.draw(data, {showRowNumber: false, alternatingRowStyle : true, 'allowHtml': true,
                            frozenColumns: 1});
      }

      // table for grid data
      function drawGridTable() {
          var data = new google.visualization.DataTable();

          // add columns
          data.addColumn('string', 'Stats Type  \\ Device Build ID'); // blank column for first
          var deviceBuildIdArray = ${deviceBuildIdArrayJson};
          for (var i = 0; i < deviceBuildIdArray.length; i++) {
              data.addColumn('string', deviceBuildIdArray[i]);
          }

          // add rows
          var deviceGrid = ${deviceGrid};
          var timeGrid = ${timeGrid};
          var summaryGrid = ${summaryGrid};
          var resultsGrid = ${resultsGrid};

          timeGrid = timeGrid.map(function(row) {
              return row.map(function(cell, j) {
                  if (j == 0) return cell;
                  else return moment(cell/1000).format("M/D/YY H:mmZZ");
              });
          });

          // add rows to the data.
          data.addRows(deviceGrid);
          data.addRows(timeGrid);
          data.addRows(summaryGrid);
          data.addRows(resultsGrid);

          var table = new google.visualization.Table(document.getElementById('grid_table_div'));
          var classNames = {
              headerRow : 'table-header'
          };
          table.draw(data, {showRowNumber: false, alternatingRowStyle : true, 'allowHtml': true,
                            frozenColumns: 1, cssClassNames: classNames});
      }
    </script>

    <nav id="navbar">
      <div class="nav-wrapper">
        <div class="col s12">
          <a href="${pageContext.request.contextPath}/" class="breadcrumb">VTS Dashboard Home</a>
          <a href="#!" class="breadcrumb">${testName}</a>
        </div>
      </div>
    </nav>
  </head>

  <body>
    <div class="container">
      <div class="row">
        <div class="col s6">
          <div id="profiling_container" class="col s12 card">
            <c:choose>
              <c:when test="${not empty error}">
                <div id="error_div" class="center-align"><h5>${error}</h5></div>
              </c:when>
              <c:otherwise>
                <!-- Profiling Table -->
                <div id="profiling_table_div" class="center-align"></div>
              </c:otherwise>
            </c:choose>
          </div>
        </div>
        <div class="col s6 valign-wrapper">
          <!-- pie chart -->
          <div id="pie_chart_div" class="valign center-align card"></div>
        </div>
      </div>
      <div class="row">
        <div id = "legend_table_div"></div>
      </div>
      <div class="row">
      </div>
      <div class="row">
        <div id="chart_holder" class="col s12 card">
          <!-- Grid tables-->
          <div id="grid_table_div"></div>

          <div id="buttons" class="col s12">
            <a id="newer_button" class="btn-floating waves-effect waves-light red"><i class="material-icons">keyboard_arrow_left</i></a>
            <a id="older_button" class="btn-floating waves-effect waves-light red right"><i class="material-icons">keyboard_arrow_right</i></a>
          </div>
        </div>
      </div>
    </div>
    <footer class="page-footer">
      <div class="footer-copyright">
          <div class="container">© 2016 - The Android Open Source Project
          </div>
      </div>
    </footer>

    <script type="text/javascript">
        // disable buttons on load
        if (!${hasNewer}) {
          $("#newer_button").toggleClass("disabled");
        }
        if (!${hasOlder}) {
          $("#older_button").toggleClass("disabled");
        }
        $("#newer_button").click(prev);
        $("#older_button").click(next);

        // for navigating grid table through previous and next buttons
        function next() {
            var endTime = ${startTime};
            var link = "${pageContext.request.contextPath}" +
              "/show_table?testName=${testName}&endTime=" + endTime;
            window.open(link,"_self");
        }

        function prev() {
            var startTime = ${endTime};
            var link = "${pageContext.request.contextPath}" +
              "/show_table?testName=${testName}&startTime=" + startTime;
            window.open(link,"_self");
        }
    </script>
  </body>
</html>
