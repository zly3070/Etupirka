using Etupirka.Properties;
using Microsoft.Shell;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Threading;
using System.Windows;
namespace Etupirka
{
	/// <summary>
	/// Interaction logic for App.xaml
	/// </summary>
	public partial class App : Application, Microsoft.Shell.ISingleInstanceApp // 入口类继承 Application
	{
		private const string Unique = "15ea85f4e7c301a460d4fc862c9895ca4ff1dffe";

		[STAThread] // 指示为单线程进程，用于应用程序的入口方法
		public static void Main()
		{
			if (SingleInstance<App>.InitializeAsFirstInstance(Unique))
			{
				ApplyLanguage();
				string[] args = Environment.GetCommandLineArgs(); //返回当前进程的命令行字符串
				if (args.Count() > 1 && args[1].Equals("-min")) // 命令的第“1”个参数是最小化则最小化启动
				{
					Settings.Default.Do_minimize = true;

				}
				var application = new App();
				application.InitializeComponent();
				application.Run();


				// Allow single instance code to perform cleanup operations
				SingleInstance<App>.Cleanup();
			}
		}

		private static void ApplyLanguage()
		{
			string language = Settings.Default.language;
			if (language != "zh-CN" && language != "ja-JP")
			{
				language = "en";
			}

			Thread.CurrentThread.CurrentUICulture = CultureInfo.GetCultureInfo(language);
		}

		#region ISingleInstanceApp Members
		public bool SignalExternalCommandLineArgs(IList<string> args)
		{
			// Handle command line arguments of second instance
			return true;
		}
		#endregion



	}

}
