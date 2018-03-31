$Script:incrementVersionNumberGroupName = "minor"

$SharedConfigData = [PsCustomObject] @{
    #Version Number
        MajorVersionDigitCount = 2
        MinorVersionDigitCount = 4
        BuildVersionDigitCount = 6
        RevisionVersionDigitCount = 1

        IncrementVersionNumberGroupName = $Script:incrementVersionNumberGroupName

        #Must include named groups for major, minor, build and revision
        VersionNumberRegex = "(?<major>\d+)\.(?<$Script:incrementVersionNumberGroupName>\d+)\.(?<build>\d+)\.(?<revision>\d+)"
    #endregion
}