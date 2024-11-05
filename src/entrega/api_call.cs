using System;
using System.Data.SqlTypes;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.SqlServer.Server;

public class CurrencyConverter
{
    [SqlFunction(IsDeterministic = true, IsPrecise = false)]
    public static SqlDouble ConvertUsdToArs(SqlDouble usdAmount)
    {
        using (HttpClient client = new HttpClient())
        {
            var response = client.GetStringAsync("https://api.exchangerate-api.com/v4/latest/USD").Result;
            var rate = /* Parse JSON response to get the ARS rate */;
            return usdAmount * rate;
        }
    }
}
