function Split-Path2 
{
	param
	(
		[string]$path
	)
	
	[string]$strFinalPath = "";
	
	#Split the path by the "\" character
	$arrPathSplit = $path.Split("\");
	
	#Join all but the last item in the array (assumed to be the filename)
	for ($i = 0; $i -le $arrPathSplit.Count - 2; $i ++)
	{
		$strFinalPath += $arrPathSplit[$i] + "\";
	}
	
	$strFinalPath = $strFinalPath.TrimEnd("\");
	
	return $strFinalPath;
}
