namespace XmlAddins
{
	public class ValidationResult
	{
		#region Public Properties

		public string[] ErrorMessages { get; internal set; }

		public bool HasErrors{
			get { return ErrorMessages != null && ErrorMessages.Length > 0; }
		}

		public string[] WarningMessages { get; internal set; }

		public bool HasWarnings
		{
			get { return WarningMessages != null && WarningMessages.Length > 0; }
		}

		#endregion
	}
}
