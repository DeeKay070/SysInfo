using System;
using System.Management; // For WMI queries

namespace SysInfo
{
    class Program
    {
        static void Main(string[] args)
        {
            // Display Operating System info using built-in property
            Console.WriteLine("Operating System: " + Environment.OSVersion);

            // Retrieve CPU details using WMI
            try
            {
                ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT Name, ProcessorId FROM Win32_Processor");
                foreach (ManagementObject obj in searcher.Get())
                {
                    Console.WriteLine("Processor Name: " + obj["Name"]);
                    Console.WriteLine("Processor ID: " + obj["ProcessorId"]);
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error retrieving CPU info: " + ex.Message);
            }

            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }
    }
}
