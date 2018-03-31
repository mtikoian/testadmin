using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Xml;
using System.Xml.Schema;

namespace XmlAddins
{
	public class XmlValidator
	{
		#region Fields

		private static IList<string> errors;
		private static IList<string> warnings;
		#endregion

		#region Public Methods

		public static ValidationResult ValidateXmlAgainstXsd(string xmlFilePath, string xsdFilePath)
		{
			if (!File.Exists(xmlFilePath))
			{
				throw new Exception("Xml file" + xmlFilePath + " could not be loaded");
			}

			if (!File.Exists(xsdFilePath))
			{
				throw new Exception("Xsd file" + xsdFilePath + " could not be loaded");
			}

			warnings = new List<string>();
			errors = new List<string>();
			var readerSettings = new XmlReaderSettings();
			readerSettings.Schemas.Add("", xsdFilePath);
			readerSettings.ValidationType = ValidationType.Schema;
			readerSettings.ValidationEventHandler += ValidationEventHandler;

			XmlReader xmlReader = XmlReader.Create(xmlFilePath, readerSettings);

			while (xmlReader.Read()) { }

			xmlReader.Close();

			var validationResult = new ValidationResult
			{
				ErrorMessages = errors.ToArray(),
				WarningMessages = warnings.ToArray()
			};

			return validationResult;
		}

		#endregion


		#region Private Methods

		private static void ValidationEventHandler(object sender, ValidationEventArgs eventArgs)
		{
			var info = sender as IXmlLineInfo;
			string lineNumber = string.Empty;

			if (info != null)
			{
				lineNumber = string.Format("Line No - {0}: ", info.LineNumber);
			}

			switch (eventArgs.Severity)
			{
				case XmlSeverityType.Warning:
					warnings.Add(lineNumber + eventArgs.Message + Environment.NewLine);
					break;
				case XmlSeverityType.Error:
					errors.Add(lineNumber + eventArgs.Message + Environment.NewLine);
					break;
			}
		}

		#endregion
	}
}
