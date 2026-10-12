using System;
using System.Diagnostics;
using System.IO;
using System.Reflection;
using System.Windows.Forms;

[assembly: AssemblyTitle("NOVRAM Patcher")]
[assembly: AssemblyDescription("NOVRAM patcher launcher for eFootball")]
[assembly: AssemblyProduct("NOVRAM Patcher")]
[assembly: AssemblyVersion("1.0.0.0")]
[assembly: AssemblyFileVersion("1.0.0.0")]

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        try
        {
            string exePath = Assembly.GetExecutingAssembly().Location;
            string dir = Path.GetDirectoryName(exePath);
            string cmdPath = Path.Combine(dir, "NOVRAM Patcher.cmd");

            if (!File.Exists(cmdPath))
            {
                MessageBox.Show(
                    "NOVRAM Patcher.cmd was not found next to NOVRAM Patcher.exe.",
                    "NOVRAM Patcher",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            var psi = new ProcessStartInfo();
            psi.FileName = "cmd.exe";
            psi.Arguments = "/c \"\"" + cmdPath + "\"\"";
            psi.WorkingDirectory = dir;
            psi.UseShellExecute = false;
            Process.Start(psi);
        }
        catch (Exception ex)
        {
            MessageBox.Show(ex.Message, "NOVRAM Patcher", MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
