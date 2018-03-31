[string] $global:SaveIniFile = ""
#region Script Settings
#<ScriptSettings xmlns="http://tempuri.org/ScriptSettings.xsd">
#  <ScriptPackager>
#    <process>powershell.exe</process>
#    <arguments />
#    <extractdir>%TEMP%</extractdir>
#    <files />
#    <usedefaulticon>true</usedefaulticon>
#    <showinsystray>false</showinsystray>
#    <altcreds>false</altcreds>
#    <efs>true</efs>
#    <ntfs>true</ntfs>
#    <local>false</local>
#    <abortonfail>true</abortonfail>
#    <product />
#    <version>1.0.0.1</version>
#    <versionstring />
#    <comments />
#    <company />
#    <includeinterpreter>false</includeinterpreter>
#    <forcecomregistration>false</forcecomregistration>
#    <consolemode>false</consolemode>
#    <EnableChangelog>false</EnableChangelog>
#    <AutoBackup>false</AutoBackup>
#    <snapinforce>false</snapinforce>
#    <snapinshowprogress>false</snapinshowprogress>
#    <snapinautoadd>2</snapinautoadd>
#    <snapinpermanentpath />
#    <cpumode>2</cpumode>
#    <hidepsconsole>false</hidepsconsole>
#  </ScriptPackager>
#</ScriptSettings>
#endregion

#region ScriptForm Designer

#region Constructor

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

#endregion

#region Post-Constructor Custom Code

#endregion

#region Form Creation
#Warning: It is recommended that changes inside this region be handled using the ScriptForm Designer.
#When working with the ScriptForm designer this region and any changes within may be overwritten.
#~~< form1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$form1 = New-Object System.Windows.Forms.Form
$form1.ClientSize = New-Object System.Drawing.Size(638, 501)
$form1.Text = "Manage Log Ship INI File"
#~~< StatusBar1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$StatusBar1 = New-Object System.Windows.Forms.StatusBar
$StatusBar1.Dock = [System.Windows.Forms.DockStyle]::Bottom
$StatusBar1.Location = New-Object System.Drawing.Point(0, 479)
$StatusBar1.Size = New-Object System.Drawing.Size(638, 22)
$StatusBar1.TabIndex = 27
$StatusBar1.Text = "Status: "
#~~< MainMenu1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$MainMenu1 = New-Object System.Windows.Forms.MenuStrip
$MainMenu1.Location = New-Object System.Drawing.Point(0, 0)
$MainMenu1.Size = New-Object System.Drawing.Size(638, 24)
$MainMenu1.TabIndex = 6
$MainMenu1.Text = "MainMenu1"
#~~< FileToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FileToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$FileToolStripMenuItem.Size = New-Object System.Drawing.Size(37, 20)
$FileToolStripMenuItem.Text = "&File"
#~~< NewToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$NewToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$NewToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$NewToolStripMenuItem.Text = "&New"
#region$NewToolStripMenuItem.Image = ([System.Drawing.Image](...)
$NewToolStripMenuItem.Image = ([System.Drawing.Image]([System.Drawing.Image]::FromStream((New-Object System.IO.MemoryStream(($$ = [System.Convert]::FromBase64String(
"iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx"+
                                 "jwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAERSURBVDhPrZDbSgJRGIXnpewd6jXsjSQvIrwo"+
                                 "I0RQMChU0iiDPCGiE3ZCRkvR8VzTeBhnyR5/ccaZNnPhB4t9sdf6Ln5hb8QeathNJFVFKF5C8DqL"+
                                 "4ksDVHWGDf7jLHyPg6NjviSaFqlu5yQYR+KpupaIkrMknCxT3Y7v/NYYb0ITK1c3BarbWWhLQ7IR"+
                                 "0cTKReyZ6lZ0XYeiztHpK4bAc+h1FgQijzSxMptrGIxVSO0xX3AaStFki7bUMVFmaMm/eJMGfIH/"+
                                 "MkGzLep0AXn4h/r3CJV3mS9gn2bY4UY/UzQ7E9TqfeTFtnuB+XAfzSHKr11kSl/uBebDiZ89ZCst"+
                                 "3OUkdwL28sIVsE83ock+EIQV2Mz2wxeg6/UAAAAASUVORK5CYII=")),0,$$.Length)))))
#endregion
$NewToolStripMenuItem.ImageTransparentColor = [System.Drawing.Color]::Magenta
$NewToolStripMenuItem.add_Click({NewINIFile($NewToolStripMenuItem)})
#~~< OpenToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OpenToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$OpenToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$OpenToolStripMenuItem.Text = "&Open"
#region$OpenToolStripMenuItem.Image = ([System.Drawing.Image](...)
$OpenToolStripMenuItem.Image = ([System.Drawing.Image]([System.Drawing.Image]::FromStream((New-Object System.IO.MemoryStream(($$ = [System.Convert]::FromBase64String(
"iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx"+
                                 "jwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAJHSURBVDhPxZBdSNNhFMb/F110ZZEVhVBgeeHN"+
                                 "ICiiuggpolAUyyxI0oSaH1QYC3N+tKnp5ubm1JUua5uuqdNKMwr7kApFItTUkWZqVhSVYmao5Nev"+
                                 "vy7UoYR3HXh44XCe33nOKyy3lAY7l9RWMo0O/raWXxEyo5spVYTNvOGyfIRPfW+ptOkXqaPl6T83"+
                                 "hcRmExSdgzAz3NVmYWyoYla/B+1M9JtxWLPpaH22JORIjI6gKAMB0jyEimIdo4OlbuaprwVMOOMo"+
                                 "vammpDADc34qppwUrmnl5Kni3aFlFg2j3y1z5mnRTJccnNIltQhwq0jFry+mOXNtpWZWDx1Z1NhV"+
                                 "3C3JwGFOw25SYjVe5oYhiUKdHKMmwQUrMWUw/CF3NnZvvYKqUh1TvUroS3fXe7HXkwidMngTS2t5"+
                                 "KLbregSzMY2f3Wr4qKW6LJvGR1rX0MLor8OhKYTJBn/GHvvxrliCTBrsOqXIoOBHh5K+hmSq7Fqm"+
                                 "exTQHuUytkaKxuNMNgYyVneA4Qd7GKjchjLaRzxH7gIU6JIZaEvgtk1D8wsxSWecCDgNzWFMvwxm"+
                                 "/PkhRmr3Mli1nW9lvjRdWc0Jf+/5jzRmyWmvS+GOLQu6U6BFjPvqKOP1AYw88WOoZif9DgmfLVtx"+
                                 "aj1RSLdwNvrkPCA3M54KqxrnvRia9MKcGrUrqFOt5H7qKsqT1mGO9+Lqhc2ELdw+U/r0i+gVZ8hM"+
                                 "iCDx3DHORwZyKnQ/hw/uYt9uCTskPvh6e7Fp41rWr/Fgg6eHO+A/lyD8ARfG3mk9fv1YAAAAAElF"+
                                 "TkSuQmCC")),0,$$.Length)))))
#endregion
$OpenToolStripMenuItem.ImageTransparentColor = [System.Drawing.Color]::Magenta
$OpenToolStripMenuItem.add_Click({Openfile($OpenToolStripMenuItem)})
#~~< toolStripSeparator >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$toolStripSeparator = New-Object System.Windows.Forms.ToolStripSeparator
$toolStripSeparator.Size = New-Object System.Drawing.Size(149, 6)
#~~< SaveToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SaveToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$SaveToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$SaveToolStripMenuItem.Text = "&Save"
#region$SaveToolStripMenuItem.Image = ([System.Drawing.Image](...)
$SaveToolStripMenuItem.Image = ([System.Drawing.Image]([System.Drawing.Image]::FromStream((New-Object System.IO.MemoryStream(($$ = [System.Convert]::FromBase64String(
"iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACx"+
                                 "jwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAIySURBVDhPrZLfS5NRGMfff6H7boIuuq2pMZyL"+
                                 "1eAt11CWDcOKsB9vpFmaLtNExco0av6CbIVLJ61Wk3BSkT/AFCkRZSpZmrmiJQ41xSaCwdfznL15"+
                                 "XEUX0Reem5f38znnec4j/Zc8fxYGla91CS3eRTx0z6OpMYS7jmnU1X6B/VYA18snUVoyjsKCt8jL"+
                                 "HcH5c36ouCQR2NUJ1Nas4G9ZXlmFKbULh1Kf8lJxSfI+WeCCyopv6q+/h+DQ/DJ2WV5Ao1FgPegR"+
                                 "AveDOS4oLfmq/h6dn/DH4AJizD4UXJrCAUuzEDgbZrjgou2DiohshIcnQtgme5GTPYbkJKcQ1N8O"+
                                 "ckHW2REVi+RXuM8fxGaDG4oyALPZIQQ11Z+5QDk1oKJ/hjv7P2FTfCMOH3mFxMQ6IbhROYWOdrCn"+
                                 "BI4dfwPr0V4+bRoY9UzXppMjcDdSrC8hy3YhuFI2gTYf2A4Aza4f7N2/o/zaLB8qDYx6zszwr8P7"+
                                 "k1thNFYIweXCMXgeAfedq2xxwjClZUeVJd2GtDNFETiJwfs8MBjKhMCWN8pgoLoqzE8miH1GjE7G"+
                                 "4PsZjE7OQsm9ij2mFg7rdrug1xcJAa2l4w7Wr00Cgk/n38S7wBwC04u4UGxHrMHF4CbEJtyDLj5f"+
                                 "CDIzhljfSxzeavRgyw4Zj9t64GvvQ0d3P3pfD2Kv2QqNvgFxDN6urYdWmyMElJMnevh60obRktA7"+
                                 "01PRtGlg1DOdSkXwzrisaMG/RZLWAE60OMW5fNhvAAAAAElFTkSuQmCC")),0,$$.Length)))))
#endregion
$SaveToolStripMenuItem.ImageTransparentColor = [System.Drawing.Color]::Magenta
$SaveToolStripMenuItem.add_Click({SaveFile($SaveToolStripMenuItem)})
#~~< SaveAsToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SaveAsToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$SaveAsToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$SaveAsToolStripMenuItem.Text = "Save &As"
$SaveAsToolStripMenuItem.add_Click({SaveFileAs($SaveAsToolStripMenuItem)})
#~~< toolStripSeparator1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$toolStripSeparator1 = New-Object System.Windows.Forms.ToolStripSeparator
$toolStripSeparator1.Size = New-Object System.Drawing.Size(149, 6)
#~~< toolStripSeparator2 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$toolStripSeparator2 = New-Object System.Windows.Forms.ToolStripSeparator
$toolStripSeparator2.Size = New-Object System.Drawing.Size(149, 6)
#~~< ExitToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ExitToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$ExitToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$ExitToolStripMenuItem.Text = "E&xit"
$ExitToolStripMenuItem.add_Click({ExitForm($ExitToolStripMenuItem)})
$FileToolStripMenuItem.DropDownItems.AddRange([System.Windows.Forms.ToolStripItem[]](@($NewToolStripMenuItem, $OpenToolStripMenuItem, $toolStripSeparator, $SaveToolStripMenuItem, $SaveAsToolStripMenuItem, $toolStripSeparator1, $toolStripSeparator2, $ExitToolStripMenuItem)))
#~~< HelpToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$HelpToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$HelpToolStripMenuItem.Size = New-Object System.Drawing.Size(44, 20)
$HelpToolStripMenuItem.Text = "&Help"
#~~< ContentsToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ContentsToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$ContentsToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$ContentsToolStripMenuItem.Text = "&Contents"
#~~< IndexToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$IndexToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$IndexToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$IndexToolStripMenuItem.Text = "&Index"
#~~< SearchToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SearchToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$SearchToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$SearchToolStripMenuItem.Text = "&Search"
#~~< toolStripSeparator5 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$toolStripSeparator5 = New-Object System.Windows.Forms.ToolStripSeparator
$toolStripSeparator5.Size = New-Object System.Drawing.Size(149, 6)
#~~< AboutToolStripMenuItem >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$AboutToolStripMenuItem = New-Object System.Windows.Forms.ToolStripMenuItem
$AboutToolStripMenuItem.Size = New-Object System.Drawing.Size(152, 22)
$AboutToolStripMenuItem.Text = "&About..."
$HelpToolStripMenuItem.DropDownItems.AddRange([System.Windows.Forms.ToolStripItem[]](@($ContentsToolStripMenuItem, $IndexToolStripMenuItem, $SearchToolStripMenuItem, $toolStripSeparator5, $AboutToolStripMenuItem)))
$MainMenu1.Items.AddRange([System.Windows.Forms.ToolStripItem[]](@($FileToolStripMenuItem, $HelpToolStripMenuItem)))
#~~< GroupBox1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$GroupBox1 = New-Object System.Windows.Forms.GroupBox
$GroupBox1.Location = New-Object System.Drawing.Point(29, 44)
$GroupBox1.Size = New-Object System.Drawing.Size(578, 416)
$GroupBox1.TabIndex = 26
$GroupBox1.TabStop = $false
$GroupBox1.Text = "Log Ship Properties"
$GroupBox1.Visible = $false
#~~< Label11 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label11 = New-Object System.Windows.Forms.Label
$Label11.Location = New-Object System.Drawing.Point(50, 311)
$Label11.Size = New-Object System.Drawing.Size(100, 23)
$Label11.TabIndex = 15
$Label11.Text = "DBs to Log Ship"
$Label11.add_Click({Label11Click($Label11)})
#~~< TextBox10 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox10 = New-Object System.Windows.Forms.TextBox
$TextBox10.Location = New-Object System.Drawing.Point(217, 308)
$TextBox10.Multiline = $true
$TextBox10.Size = New-Object System.Drawing.Size(322, 95)
$TextBox10.TabIndex = 24
$TextBox10.Text = ""
#~~< ComboBox1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ComboBox1 = New-Object System.Windows.Forms.ComboBox
$ComboBox1.FormattingEnabled = $true
$ComboBox1.Location = New-Object System.Drawing.Point(217, 227)
$ComboBox1.Size = New-Object System.Drawing.Size(121, 21)
$ComboBox1.TabIndex = 25
$ComboBox1.Text = ""
$ComboBox1.Items.AddRange([System.Object[]](@("Primary", "Secondary")))
$ComboBox1.SelectedIndex = -1
#~~< TextBox9 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox9 = New-Object System.Windows.Forms.TextBox
$TextBox9.Location = New-Object System.Drawing.Point(217, 282)
$TextBox9.Size = New-Object System.Drawing.Size(236, 20)
$TextBox9.TabIndex = 23
$TextBox9.Text = ""
#~~< Label10 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label10 = New-Object System.Windows.Forms.Label
$Label10.Location = New-Object System.Drawing.Point(50, 285)
$Label10.Size = New-Object System.Drawing.Size(100, 23)
$Label10.TabIndex = 14
$Label10.Text = "Dest TLog Folder"
$Label10.add_Click({Label10Click($Label10)})
#~~< Label1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Location = New-Object System.Drawing.Point(49, 41)
$Label1.Size = New-Object System.Drawing.Size(100, 23)
$Label1.TabIndex = 0
$Label1.Text = "Programs Root"
$Label1.add_Click({Label1Click($Label1)})
#~~< TextBox8 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox8 = New-Object System.Windows.Forms.TextBox
$TextBox8.Location = New-Object System.Drawing.Point(217, 255)
$TextBox8.Size = New-Object System.Drawing.Size(236, 20)
$TextBox8.TabIndex = 22
$TextBox8.Text = ""
#~~< TextBox1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox1 = New-Object System.Windows.Forms.TextBox
$TextBox1.Location = New-Object System.Drawing.Point(217, 38)
$TextBox1.Size = New-Object System.Drawing.Size(138, 20)
$TextBox1.TabIndex = 2
$TextBox1.Text = ""
$TextBox1.add_TextChanged({TextBox1TextChanged($TextBox1)})
#~~< Label9 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label9 = New-Object System.Windows.Forms.Label
$Label9.Location = New-Object System.Drawing.Point(50, 258)
$Label9.Size = New-Object System.Drawing.Size(125, 23)
$Label9.TabIndex = 13
$Label9.Text = "Dest Data Folder"
#~~< Label2 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label2 = New-Object System.Windows.Forms.Label
$Label2.Location = New-Object System.Drawing.Point(49, 68)
$Label2.Size = New-Object System.Drawing.Size(126, 23)
$Label2.TabIndex = 1
$Label2.Text = "Primary SQL Server"
$Label2.add_Click({Label2Click($Label2)})
#~~< TextBox2 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox2 = New-Object System.Windows.Forms.TextBox
$TextBox2.Location = New-Object System.Drawing.Point(217, 65)
$TextBox2.Size = New-Object System.Drawing.Size(138, 20)
$TextBox2.TabIndex = 3
$TextBox2.Text = ""
$TextBox2.add_TextChanged({TextBox2TextChanged($TextBox2)})
#~~< TextBox7 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox7 = New-Object System.Windows.Forms.TextBox
$TextBox7.Location = New-Object System.Drawing.Point(217, 200)
$TextBox7.Size = New-Object System.Drawing.Size(188, 20)
$TextBox7.TabIndex = 20
$TextBox7.Text = ""
#~~< Label8 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label8 = New-Object System.Windows.Forms.Label
$Label8.Location = New-Object System.Drawing.Point(49, 230)
$Label8.Size = New-Object System.Drawing.Size(125, 23)
$Label8.TabIndex = 12
$Label8.Text = "Server Log Ship Role"
$Label8.add_Click({Label8Click($Label8)})
#~~< TextBox3 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox3 = New-Object System.Windows.Forms.TextBox
$TextBox3.Location = New-Object System.Drawing.Point(217, 92)
$TextBox3.Size = New-Object System.Drawing.Size(138, 20)
$TextBox3.TabIndex = 16
$TextBox3.Text = ""
#~~< TextBox6 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox6 = New-Object System.Windows.Forms.TextBox
$TextBox6.Location = New-Object System.Drawing.Point(217, 173)
$TextBox6.Size = New-Object System.Drawing.Size(188, 20)
$TextBox6.TabIndex = 19
$TextBox6.Text = ""
#~~< Label3 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label3 = New-Object System.Windows.Forms.Label
$Label3.Location = New-Object System.Drawing.Point(49, 95)
$Label3.Size = New-Object System.Drawing.Size(125, 23)
$Label3.TabIndex = 7
$Label3.Text = "Primary Server Name"
$Label3.add_Click({Label3Click($Label3)})
#~~< Label7 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label7 = New-Object System.Windows.Forms.Label
$Label7.Location = New-Object System.Drawing.Point(48, 203)
$Label7.Size = New-Object System.Drawing.Size(140, 23)
$Label7.TabIndex = 11
$Label7.Text = "TLog Backup Share Name "
$Label7.add_Click({Label7Click($Label7)})
#~~< TextBox5 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox5 = New-Object System.Windows.Forms.TextBox
$TextBox5.Location = New-Object System.Drawing.Point(217, 146)
$TextBox5.Size = New-Object System.Drawing.Size(188, 20)
$TextBox5.TabIndex = 18
$TextBox5.Text = ""
#~~< TextBox4 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$TextBox4 = New-Object System.Windows.Forms.TextBox
$TextBox4.Location = New-Object System.Drawing.Point(217, 119)
$TextBox4.Size = New-Object System.Drawing.Size(138, 20)
$TextBox4.TabIndex = 17
$TextBox4.Text = ""
#~~< Label4 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label4 = New-Object System.Windows.Forms.Label
$Label4.Location = New-Object System.Drawing.Point(49, 122)
$Label4.Size = New-Object System.Drawing.Size(125, 23)
$Label4.TabIndex = 8
$Label4.Text = "Mirrored SQL Server"
$Label4.add_Click({Label4Click($Label4)})
#~~< Label6 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label6 = New-Object System.Windows.Forms.Label
$Label6.Location = New-Object System.Drawing.Point(48, 176)
$Label6.Size = New-Object System.Drawing.Size(140, 23)
$Label6.TabIndex = 10
$Label6.Text = "DB Local Backup Folder"
$Label6.add_Click({Label6Click($Label6)})
#~~< Label5 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label5 = New-Object System.Windows.Forms.Label
$Label5.Location = New-Object System.Drawing.Point(48, 149)
$Label5.Size = New-Object System.Drawing.Size(140, 23)
$Label5.TabIndex = 9
$Label5.Text = "DB Backup Share Name"
$Label5.add_Click({Label5Click($Label5)})
$GroupBox1.Controls.Add($Label11)
$GroupBox1.Controls.Add($TextBox10)
$GroupBox1.Controls.Add($ComboBox1)
$GroupBox1.Controls.Add($TextBox9)
$GroupBox1.Controls.Add($Label10)
$GroupBox1.Controls.Add($Label1)
$GroupBox1.Controls.Add($TextBox8)
$GroupBox1.Controls.Add($TextBox1)
$GroupBox1.Controls.Add($Label9)
$GroupBox1.Controls.Add($Label2)
$GroupBox1.Controls.Add($TextBox2)
$GroupBox1.Controls.Add($TextBox7)
$GroupBox1.Controls.Add($Label8)
$GroupBox1.Controls.Add($TextBox3)
$GroupBox1.Controls.Add($TextBox6)
$GroupBox1.Controls.Add($Label3)
$GroupBox1.Controls.Add($Label7)
$GroupBox1.Controls.Add($TextBox5)
$GroupBox1.Controls.Add($TextBox4)
$GroupBox1.Controls.Add($Label4)
$GroupBox1.Controls.Add($Label6)
$GroupBox1.Controls.Add($Label5)
$form1.Controls.Add($StatusBar1)
$form1.Controls.Add($MainMenu1)
$form1.Controls.Add($GroupBox1)
$form1.add_Load({Form1Load($form1)})
#~~< SaveFileDialog1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$SaveFileDialog1 = New-Object System.Windows.Forms.SaveFileDialog
$SaveFileDialog1.FileName = "LogShipping_MSSQLServer.ini"
$SaveFileDialog1.Filter = "All File (*.*)|*.*"
$SaveFileDialog1.InitialDirectory = "c:\sqlrds"
$SaveFileDialog1.ShowHelp = $true
#~~< OpenFileDialog1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OpenFileDialog1 = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog1.Filter = "All files (*.*)|*.*|INI Files|*.ini"
$OpenFileDialog1.InitialDirectory = "c:\sqlrds"
$OpenFileDialog1.ShowHelp = $true

#endregion

#region Custom Code

#endregion

#region Event Loop

function Main{
	[System.Windows.Forms.Application]::EnableVisualStyles()
	[System.Windows.Forms.Application]::Run($Form1)
	
}

#endregion

#endregion

#region Event Handlers



function Openfile($object)
{
	$OpenFileDialog1.ShowDialog()
	$global:SaveIniFile = $OpenFileDialog1.filename
	PopulateTextBoxes $global:SaveIniFile
	$GroupBox1.Visible = $true
	$StatusBar1.Text = "Opened File $global:SaveIniFile"
}
						
#####################################################################################
## This function reads ini file and creates hash table key=value pairs

# Get-Settings Reads an ini file into a hash table
# Each line of the .ini File will be processed through the pipe.
# The splitted lines fill a hastable. Empty lines and lines beginning with
# '[' or ';' are ignored. $ht returns the results as a hashtable.
function ReadIniFile( )
{
	begin
	{
		$ht = @{ }
	}
	process
	{
		[string[]]$key = [regex]::split($_, '=')
		if ( ($key[0].CompareTo("") -ne 0) `
			-and ($key[0].StartsWith("[") -ne $True) `
		-and ($key[0].StartsWith(";") -ne $True) )
		{
			$IniName = $key[0].trim()
			if ($key[1]) { $IniValue = $key[1].trim() } else { $IniValue = $key[1] }
			$ht.Add($IniName, $IniValue)
		}
	}
	end
	{
		return $ht
	}
}
						
function PopulateTextBoxes([string]$IniFile)
{
		  
	[object]$IniHashtable = (Get-Content $IniFile | ReadIniFile)
	$TextBox1.text = $IniHashtable.item("SQLInstallLogRootDir")
	$TextBox2.text = $IniHashtable.item("SQLServer")	
	$TextBox3.text = $IniHashtable.item("PrimaryServer")
	$TextBox4.text = $IniHashtable.item("MirrorSQLServer")		
	$TextBox5.text = $IniHashtable.item("BackupDirShareName")	
	$TextBox6.text = $IniHashtable.item("BackupDir")	
	$TextBox7.text = $IniHashtable.item("TlogBackupDirShareName")	
	$ComboBox1.text = $IniHashtable.item("LogShipRole") 
	$TextBox8.text = $IniHashtable.item("SQLDataRoot")	
	$TextBox9.text = $IniHashtable.item("SQLTLogRoot")	
	$TextBox10.text = $IniHashtable.item("CreateDbs")
	$StatusBar1.Text = ""
				
}
			





function Label11Click( $object ){

}

function Label10Click( $object ){

}

function Label8Click( $object ){

}

function Label7Click( $object ){

}

function Label6Click( $object ){

}

function Label5Click( $object ){

}

function Label4Click( $object ){

}

function Label3Click( $object ){

}

function TextBox2TextChanged( $object ){

}

function TextBox1TextChanged( $object ){

}

function Label2Click( $object ){

}

function Label1Click( $object ){

}

function Form1Load( $object ){
$StatusBar1.Text = ""
}

function SaveFile( $object ){
				
	if (!$global:SaveIniFile) 
	{ 
		$SaveFileDialog1.ShowDialog()
		$global:SaveIniFile = $SaveFileDialog1.filename 
	 
	}

	SaveIniFileDetail $global:SaveIniFile

}

function SaveFileAs($object)
{
				
	$SaveFileDialog1.ShowDialog()
	$global:SaveIniFile = $SaveFileDialog1.filename 
   SaveIniFileDetail $global:SaveIniFile
 
}
			
function SaveIniFileDetail($IniFileName)
{
  	Set-Content -path $IniFileName -value "SQLInstallLogRootDir = $( $TextBox1.text)"
	Add-Content -path $IniFileName -value "SQLServer = $( $TextBox2.text)"
	Add-Content -path $IniFileName -value "PrimaryServer = $( $TextBox3.text)"
	Add-Content -path $IniFileName -value "MirrorSQLServer = $( $TextBox4.text)"
	Add-Content -path $IniFileName -value "BackupDirShareName = $( $TextBox5.text)"
	Add-Content -path $IniFileName -value "BackupDir = $( $TextBox6.text)"
	Add-Content -path $IniFileName -value "TlogBackupDirShareName = $( $TextBox7.text)"
	Add-Content -path $IniFileName -value "LogShipRole = $( $ComboBox1.text)"
	Add-Content -path $IniFileName -value "SQLDataRoot = $( $TextBox8.text)"
	Add-Content -path $IniFileName -value "SQLTLogRoot = $( $TextBox9.text)"
	Add-Content -path $IniFileName -value "CreateDbs = $( $TextBox10.text)"								
	$StatusBar1.Text = "Saved File $global:SaveIniFile"
}
			
function NewINIFile( $object )
{
				$GroupBox1.Visible = $true
				$global:SaveIniFile = ""
				ResetFields
				$StatusBar1.Text = ""
}

function ExitForm( $object ){

$form1.Close()
}
			
function ResetFields( )
{
	$TextBox1.text = ""
	$TextBox2.text = ""	
	$TextBox3.text = ""
	$TextBox4.text = ""	
	$TextBox5.text = ""	
	$TextBox6.text = ""	
	$TextBox7.text = ""	
	$ComboBox1.text = "" 
	$TextBox8.text = ""
	$TextBox9.text = ""
	$TextBox10.text = ""
									
}

Main # This call must remain below all other event functions

#endregion

			
			
