$file = 'C:\Demos\BimlBeginner.biml'

# Initialize the BIML file and set its properties
$biml = New-Object System.Xml.XmlTextWriter($file,$null)
$biml.Formatting = 'Indented'
$biml.Indentation = 1
$biml.IndentChar = "`t"
$biml.WriteStartElement('Biml')
$biml.WriteAttributeString('xmlns',"http://schemas.varigence.com/biml.xsd")

$biml.WriteStartElement('Packages')

$biml.WriteStartElement('Package')
$biml.WriteAttributeString('Name','BimlBeginner')
$biml.WriteAttributeString('ConstraintMode','Parallel')
$biml.WriteEndElement()			# End Package

$biml.WriteEndElement()			# End Packages
$biml.WriteEndElement()			# End Biml
$biml.Flush()
$biml.Close()
