<%@ WebHandler Language="C#" Class="Raplet" %>

using System;
using System.Data;
using System.Web;
using MacAdvWeb;

/// <summary>
/// REST web service for returning simple Advancement snippets as a Rapportive.com Rapportlet
/// http://code.rapportive.com/raplet-docs/index.html#overview
/// 
/// This Raportlet is provided with no warranty or suggestion it will work on your system.
/// Tweak it, wrap it, do what you will with it, even send feedback to cledwyn@gmail.com.  Why not.  :)
/// Let me know if it works for you.
/// </summary>
public class Raportlet : IHttpHandler {
    //CallBack must be prepended to the JSON response
    private string _callback = "";

    public void ProcessRequest(HttpContext context)
    {
        context.Response.ContentType = "text/html";

        string ans = "";
        _callback = context.Request.QueryString["callback"];
        string email = context.Request.QueryString["email"];
        if (email == null) { email = ""; }

        //Per the Rapportlet API, if there is a ?show=metadata request, show the app info
        string show = context.Request.QueryString["show"];
        if (show == "metadata")
        {
            ShowMetadata(context);
            return;
        }

        // PER this fine tutorial http://blog.rutwick.com/raplets-tutorial-part-1-hello-world
        // and some tinkering (try returning Request.QueryString to the output, and you see what is available to work with

        // CALL SOME DATA.
        string sql = "select distinct name, namesuffix, id_number from V_EMAIL_LOOKUP t where t.email_address = :email or t.work_email = :email or t.alt_email = :email";
        //This is my hand rolled method to return a standard .NET data object via Oracle, and a view defined above.
        OracleRS.Command aCmd = new OracleRS.Command(sql, "event", System.Data.CommandType.Text);
        aCmd.AddParameterWithValue(":email", email);
        DataTable dt = aCmd.GetDataTable(false);

        if (dt.Rows.Count == 0)
        {
            ans += "<h1 class=\"error\">No matching email in our system.</h1>";
        }
        foreach (DataRow row in dt.Rows)
        {
            ans += "<strong>" + row["namesuffix"].ToString() + "</strong><br />" + row["id_number"].ToString();
        }


        // Build the JSON response.
        string strJSON = "\"html\":\"" + ans + "\"";
        strJSON += ",\"css\":\"p{margin:0; padding:0; color:#444; font-size: 13px; }\"";
        strJSON += ",\"status\":200";
        // Prepend the _callback
        strJSON = _callback + "({" + strJSON + "})";
        context.Response.Write(strJSON);
    }

    
    /// <summary>
    /// Return a JSON response of Application info, icons, validation point, etc.
    /// http://code.rapportive.com/raplet-docs/index.html#metadata_and_configuration
    /// </summary>
    /// <param name="context"></param>
    public void ShowMetadata(HttpContext context)
    {

        string strJSON = "";
        strJSON += "\"name\":\"Macalester Matrix Data\"";
        strJSON += ",\"description\":\"Gmail API to allow matrix data to be returned in the context of the GMail Client.\"";
        strJSON += ",\"welcome_text\":\"This will allow you to view a small snippet of associated Advance Data for any records pulled.\"";
        strJSON += ",\"icon_url\":\"https://advancement.macalester.edu/M/img/RaportiveIcon.png\"";
        strJSON += ",\"preview_url\":\"https://advancement.macalester.edu/M/img/RaportivePreview.png\"";
        strJSON += ",\"provider_name\":\"Macalester College Advancement Office\"";
        strJSON += ",\"provider_url\":\"http://advancement.macalester.edu\"";
        strJSON += ",\"config_url\":\"https://advancement.macalester.edu/M/PrivateServices/RaportiveConfig.ashx\"";
        strJSON += ",\"name\":\"Macalester Matrix Data\"";
        strJSON += ",\"css\":\"p{margin:0; padding:0; color:#444; font-size: 13px; }\"";
        strJSON += ",\"status\":200";
        strJSON = _callback + "({" + strJSON + "})";
        context.Response.Write(strJSON);

    }

    public bool IsReusable
    {
        get
        {
            return false;
        }
    }

}