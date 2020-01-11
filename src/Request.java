import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;
import java.util.stream.Collectors;

@WebServlet("/request")
public class Request extends javax.servlet.http.HttpServlet {
    private Analyzer analyzer;

    @Override
    public void init() throws ServletException {
        Properties properties = new Properties();

        System.out.println(System.getProperty("LEMMIFIER_PROPERTIES_PATH"));

        try (InputStream configFile = new FileInputStream(System.getProperty("LEMMIFIER_PROPERTIES_PATH"))) {
            properties.load(configFile);
        } catch (IOException e) {
            e.printStackTrace();
        }

        SQLManager sqlManager = new SQLManager(
                properties.getProperty("psqlUrl"),
                properties.getProperty("psqlUsername"),
                properties.getProperty("psqlPassword"),
                properties.getProperty("psqlDatabase")
        );

        analyzer = new Analyzer(
                sqlManager,
                properties.getProperty("wordsByLemmaPath"),
                properties.getProperty("structurePath"),
                properties.getProperty("stopListPath")
        );
    }

    protected void doGet(javax.servlet.http.HttpServletRequest request, javax.servlet.http.HttpServletResponse response) throws javax.servlet.ServletException, IOException {
        response.setContentType("text/plain;charset=UTF-8");

        String requestString = request.getParameter("q");

        if (requestString == null || requestString.isEmpty()) {
            request.getRequestDispatcher("/").forward(request, response);
            return;
        }

        response.setCharacterEncoding("UTF-8");

        Response analyzerResponse = analyzer.run(requestString);

        request.setAttribute("request", requestString);
        request.setAttribute("metadata", analyzerResponse.getMetadata());

        if (analyzerResponse.success()) {
            request.setAttribute("results", analyzerResponse.getResults().stream().map(line -> line.replaceAll(";", "\t")).collect(Collectors.toList()));
        } else {
            request.setAttribute("conflictToken", analyzerResponse.getConflict().getToken());
            request.setAttribute("conflictChoices", analyzerResponse.getConflict().getChoices());
        }

        request.getRequestDispatcher("/").forward(request, response);

    }
}
