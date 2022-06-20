using System;
using HtmlToCsvHurtownie;
using RestSharp;

namespace DownloadPageRestSharp
{
    class Program
    {
        static void Main(string[] args)
        {
            StringManager stringManager = new StringManager();
            string[] urls = new string[3]
            {
                "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv?fbclid=IwAR2_Z53cesn7zTvRNLT3WdB9sWptVxE21JnzSg6WA-SE2hB-3AiEZI6ED88",
                "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv?fbclid=IwAR1H2c9pyPlurwh8o7l6ZGkx63SDxBq89o80xdlDx481Xsf1GQZ_sNf0brY",
                "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv?fbclid=IwAR0ABoM80Ms-tfcv6OpwF6BlDVn2ZNaEzu3XVX0uVEXWl8p57Bi7HMTF6S0"
            };

            SaveToCSV(stringManager.DeleteComa(GetContentFromUrl(urls[0])),"time_series_covid19_confirmed_global");
            SaveToCSV(stringManager.DeleteComa(GetContentFromUrl(urls[1])),"time_series_covid19_recovered_global");
            SaveToCSV(stringManager.DeleteComa(GetContentFromUrl(urls[2])),"time_series_covid19_deaths_global");
        }

        static string GetContentFromUrl(string url)
        {
            var client = new RestClient(url);
            var request = new RestRequest("", Method.GET);
            var response = client.Get(request);
            return response.Content;
        }

        static void SaveToCSV(string text, string filename)
        {
            System.IO.File.WriteAllText("F:/Projects/CovidDW/Data/Source/" + filename + ".csv", text);
        }
    }
}