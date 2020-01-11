<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.regex.Matcher" %>
<%@ page import="java.util.regex.Pattern" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
  <head>
    <title>Lemmafier</title>

    <%
      Object requestString = request.getAttribute("request");
      Object results = request.getAttribute("results");
      Object conflictToken = request.getAttribute("conflictToken");
      Object conflictChoices = request.getAttribute("conflictChoices");

      Object metadata = request.getAttribute("metadata");
    %>

    <link href="bootstrap.min.css" rel="stylesheet">
    <link href="bootstrap-grid.min.css" rel="stylesheet">

  </head>
  <body class="container">

    <form action="${pageContext.request.contextPath}/request" method="GET" class="form-inline row my-5">
      <input  class="form-control form-control-lg col-lg-8 col-12 mt-1"
              placeholder="Entrez votre requête..."
              type="text"

              name="q"
              value=<% out.print("\"" + (requestString != null ? requestString : "") + "\""); %>
      />
      <button type="submit" class="btn btn-lg btn-success offset-lg-1 col-lg-2 col-12 mt-1">C'est parti !</button>
    </form>

    <div id="conflict">
      <%
        if (conflictToken != null && conflictChoices != null && requestString != null) {
          out.println("<hr><h3>Conflit pour \"<i>" + conflictToken + "</i>\":</h3>");

          for (String choice : (List<String>) conflictChoices) {
            String newRequest = ((String) requestString).replaceFirst((String) conflictToken, choice);
            out.println("<a href=/request?q="+ newRequest.replaceAll(" ", "+") +">" + newRequest.replaceFirst(choice, "<b>$0</b>") + "</a></br>");
          }
        }
      %>
    </div>

    <div class="row">

      <div id="metadata" class="col-6 bg-light">
        <%
          if (metadata != null) {
            out.println("<h3>Métadonnées</h3>");
            out.println(metadata.toString().replaceAll("(.*) => (.*)", "<p><div class=\"text-capitalize\">$1</div><code>$2</code></p>"));
          }
        %>
      </div>

      <div id="results" class="col-6 bg-light">
        <%
          if (results != null) {
            out.println("<h3>Résultats</h3>");
            out.println("<pre><code>");

            for (String result : (List<String>) results) {
              out.println(result
                      .replaceAll("(\\d+\\.htm)", "<a target=\"_blank\" href=http://www4.utc.fr/~lo17/TELECHARGE/BULLETINS_LO17/$1>$1</a>")
                      .replaceAll("(\\S+@\\S+)", "<a target=\"_blank\" href=mailto:$1>$1</a>"));
            }

            out.println("</pre></code>");
          }
        %>
      </div>

    </div>

  </body>
</html>
