#!/apps/util/ActivePerl-5.8/bin/perl
# =============================================================================

=pod

=head2 MakeDiffSQL.pl

=head2 ScriptName

	MakeDiffSQL.pl

=head2 Version

	1.0.1.0

=head2 Author

	Data Architecture - Patrick W. O'Brien

=head2 Script Created

	08/15/2006

=head2 Script Updated

	11/13/2007 V 1.0.1.1

		Enhanced SQLSERVER support for Integrated Security=SSPI.
		When the userid and password are specified as "NONE", integrated security is used.

		Enhanced to support field types of LOB and RAW as quoted fields with lengths of up to
		1 mb (1048576 bytes). This is a ALPHA release which needs to be tested on both ORACLE
		and SQLSERVER for this support.  Use at your own risk!

	10/02/2007 V 1.0.1.0

		Corrected bug in FilterColumns where loop max was less then and should have been less
		then or equal to.

	09/12/2007 V 1.0.0.9

		Modified BuildDeleteSQL for Oracle section to correct bug in building delete statement.
		This was caused by changes made in V 1.0.0.8.

	09/04/2007 V 1.0.0.8

		Modified for SQLServer:

			Added ALTER TABLE [TABLENAME] NOCHECK CONSTRAINT ALL before processing tables.

			Added ALTER TABLE [TABLENAME] CHECK CONSTRAINT ALL after processing tables.

			Added SET IDENTITY_INSERT [TABLENAME] ON before processing the table if the
			table has an identity column.

			Added SET IDENTITY_INSERT [TABLENAME] OFF after processing the table if the
			table has an identity column.

			References to the table names and column names in SQL statements executed and
			produced were changed to have the table name and column names enclosed by braces
			to avoid problems with using reserved names.

	08/27/2007

		Modified to prefix a single quote with a quote in char fields.

	02/09/2007

		Modified to correct a bug in the generation of the update sql where clause.

	01/02/2007

		Modified to print an information line if no tables qualified for processing.

	11/1/2006

		Modified to support include and exclude column names.

	10/18/2006

		Modified to support SQLServer.  This has still not been tested.  Use at your own risk.

	10/09/2006

		Modified to fix a bug in the BuildUpdateSQL where the target index was not set properly.

	08/31/2006

		Modified to change the documentation around the source and target meanings.

=head3 Description

	This script will compare the table data between two schemas, the target and the source,
	and generate the DDL that may be used to update the target schema table data to match the
	source schema table data.

	The DDL generated is written to the MakeDiffSQL.SQL file.

	The summary report is written to the MakeDiffSQL.rpt file.

	The rules for the process are

=over *

=item 1

	The target and source schemas must be identical.  This is not enforced by this
	process but is a requirement. If the schemas are not identical, the results
	are unpredictable, unsupported and will probably cause the program to terminate.

	To confirm that the schemas are identical, have your DBA compare them or use a
	tool like Toad.

=item 2

	To qualify for inclusion, a table must have a primary key. If a table does not have a primary key,
	it is excluded from processing and reported in the summary report.

=item 3

	To qualify for inclusion, a table must not have any CLOB,BLOB or LONG fields. If a table has any of
	these datatypes, it is excluded from processing and reported in the summary report.

=back

=head3 Command line parameters

=over *

=item -p : configuration parameter file

	The parameter filename.

	The full path to the file should be specified if it is not in the current directory.

	This is a mandatory parameter.

=back

=head3 Configuration file parameters

	These are specified in the format of name=value pairs.

	Blank lines and lines starting with a pound sign (#) are ignored.

=over *

=item RDBMSType : Type of RDBMS

	The supported types are ORACLE and SQLSERVER

=item TargetConnectionString : Connection string

	This is the connection string for the target instance in the format of
	userid/password@instance

=item TargetSchema : target schema name

	This is the target schema name in the target instance

=item SourceSchema : source schema name

	This is the source schema name in the instance. See DBLinkName.

=item DBLinkName : Database link name in the target Oracle instance for the source schema.

	The database linkname should be used if the source schema resides in a different Oracle instance
	then the target	schema

		or

	the source schema is in the target Oracle instance but the target userid and password does not have access
	to the source schema.

	Optional parameter based on RDBMSType, source location and access.

=item IncludeTablenames : Include table names

	A comma separated list of the table names to be included for processing. No specification of
	include table names means all tables will be processed except those specified in the ExcludeTablenames.

	The table names are case sensitive in Oracle so check them!

=item ExcludeTablenames : Exclude table names

	A comma separated list of table names to be excluded from processing.

	The table names are case sensitive in Oracle so check them!

=item IncludeColumns

	The columns to include comma delimited.  Supports the * wild card.
	If this is not specified, all columns will be included.
	See additional notes.

	This is an optional parameter.

=item ExcludeColumns

	The columns to exclude comma delimited.  Supports the * wild card.
	See additional notes.

	This is an optional parameter.

=item TestOnly : Test flag

	If this flag is set to one (1), then the generation of the insert, update and delete SQL is skipped.

	Optional parameter.

=back

=head3 Returns

	None

=head3 Examples of Usage

	MakeDiffSQL.pl -p <ParameterFilename>

	MakeDiffSQL.exe -p <ParameterFilename>

	The parameter file supports the following name=value pairs

		RDBMSType=ORACLE
		TargetConnectionString=userid/password@instance
		TargetSchema=TEST1
		SourceSchema=TEST2
		DBLinkName=GWMPXX
		IncludeTablenames=
		ExcludeTablenames=
		IncludeColumns=
		ExcludeColumns=
		TestOnly=0

=head3 Examples of program output

	The command

		MakeDiffSQL.pl -p MakeDiffSQL.cfg

	The output

		MakeDiffSQL.pl v1.0.0.5 start  Wed Oct 18 12:15:03 2006
		   Processing RELATIONSHIP_BACKBONE
		   Processing RELATIONSHIP_UNIVERSE
		MakeDiffSQL.pl v1.0.0.5 finish Wed Oct 18 12:20:44 2006

=head3 Examples of summary report output

	Created Datetime Wed Oct 18 12:47:14 2006
	Target Instance: GWMPSD1  Target Schema: CM_EDB
	Source Schema: BV1_EDB
	DBLinkName: GWMPBV1
	                                                                    Table Exclusions
																		        BLOB/CLOB/
	Table name                               Inserts  Updates  Deletes PK Error LONG Error
	--------------------------------------- -------- -------- -------- -------- ----------
	RPT_TEMPLATE                                   0        0        0
	BUSINESS_ASSET_PORTFOLIO                       0        0        0
	CORRESPONDENCE_MATRIX                          0        0        0
	RECONGWMPPMERR_MSG                             0        0        0      Yes
	CORRESPONDENCE_RECIPIENT                       0        0        0
	ALLOWABLE_CURRENCY                             8        0        0
	RPT_TEMPLATE_MESSAGE_MAP                       0        0        0 
	ALLOWABLE_RPT_PACKAGE_L                        0        0        0
	USER_REL_BUSINESS_PROC_SYS                     0        0        0
	STATIC_MAPPING                                 0        0        0
	ALLOWABLE_RELATIONSHIP                         0      315        0

=head2 Additional Notes

=over *

=item Include and Exclude parameters

	It should be noted that you may specify include and exclude parameters and essentially eliminate
	all tablenames or columns to be compared.  Nothing prevents this condition but if it occurs, a
	message will be generated indicating that there are no tables or columns by which to perform the
	comparison.

=item Tablename and Column Include and Exclude Parameters

	These parameters support a comma delimited list of names that are to
	be processed.  These parameters also except the wild card symbol (*). The *
	wild card is interpreted to mean any number of non blank alphanumeric characters. As an
	example, let us assume that there are three (3) tables in a schema

		TABLE_A_ACCOUNT
		TABLE_B_POSITION
		TABLE_C_TAXLOT

	Given these table names, if we specified the IncludeTablenames parameter as

		IncludeTablenames=*A*

	all tables will qualify as any number of non blank characters match before "A" and
	any number of non blank characters match after "A". If we specified the IncludeTablenames
	parameter as

		IncludeTablenames=TABLE*

	again all the tables would match.  If we specified the IncludeTablenames parameter as

		IncludeTablenames=*ACCOUNT

	only the table TABLE_A_ACCOUNT would match.  If we specified the IncludeTablenames
	parameter as

		IncludeTablenames=TABLE_B_POSITION,*T

	all table names would match.

	It should be noted that if the table names specified in the IncludeTablenames parameter
	cause duplicate table names to qualify, the duplicates are eliminated. For example,
	if we specified the IncludeTablenames parameter as

		IncludeTablenames=*T,TABLE_A_ACCOUNT,TABLE_C_TAXLOT

	all tables ending in T would qualify as well as the explicitly specified table names. The result
	would be TABLE_A_ACCOUNT and TABLE_C_TAXLOT qualifying only once.

	See the TestOnly parameter.

=item Temp Space

	You should have temp space at least equal to your largest table to be compared times three (3).

=item Dependancies for running this program

	This is a Perl program. To execute it as a perl program you will need the following:

		ActivePerl 5.8 or above.
		Perl module DBI 1.52 or above.
		Perl module DBD:Oracle 1.16 or above.
		Perl module DBD:ADO 2.95 or above
		Perl module Getopt 2.35 or above.
		Perl module Carp.
		Perl module Tie::IxHash 1.21 or above.
		Perl module English.
		SQLServer client and DMO ...
		Oracle 10g client or above.

		Some of the above modules will also require a C or C++ compiler to make the modules.

		ActivePerl 5.8 may be retrieved from www.activestate.com

		All the other modules may be retrieved from www.cpan.org.

	The other option is to use the executable version of this program under Windows XP SP2 or later, MakeDiffSQL.exe.
	This requires

		Oracle 10g client or above.
		SQLServer client and DMO ...

	This option is not available under UNIX.

=back

=cut

# Perl modules
use strict;
use warnings;
use Carp qw(confess cluck);    # Used for warnings and errors
use Getopt::Long;              # Command line options parser
use DBI;                       # Database independant interface
use Tie::IxHash;               # Insertion order hash
use English;                   # English names for Perlish ugly symbols
use XML::Simple;

# Smart::Comments is an optional module.  It is only needed for debugging.
# Comments denoted with three (3) ### are used by this module and just treated
# as normal comments if the module is not included.

#use Smart::Comments;

# Global variables
my %ConfigOptions;             # Global hash for the configuration options.
my $VERSION = "1.0.1.1  *** ALPHA RELEASE ***";       # Version number of program
my $MAX_LOB_SIZE = 1048576;    # DBI long read length for LOB fields.

sub Help
{
    print <<EOH;

Makediffsql

usage: perl Makediffsql.pl -p <parameterfile> or Makediffsql.exe -p <parameterfile>

Parameter file required parameters:

	RDBMSType=xxx				<ORACLE> or <SQLSERVER>
	TargetConnectionString=xxx		<userid>/<password><\@instance>
	TargetSchema=xxx			<Schema Name>
	SourceSchema=xxx			<Schema Name>

Optional parameters:
	
	DBLinkName=				<Database link name>
	IncludeTablenames=			[Comma delimited list of tables to include.  Blank for all.]
	ExcludeTablenames=			[Comma delimited list of tables to exclude.]
	IncludeColumns=				[Comma delimited list of columns to include. Blank for all.]
	ExcludeColumns=				[Comma delimited list of columns to exclude.]
	TestOnly=				[blank or 0 for false | 1 for true]

EOH
}

# ======================================================================================================================

=pod

=head2 LoadConfigurationOptions

=head3 Description

	This routine will read the configuration parameter file and store the
	configuration options in the %ConfigOptions hash. Any configurations parameters
	that are required and are not supplied will be flagged as missing and processing
	will be terminated.

=head3 Parameters

	None

=head3 Returns

	Hash of configuration options

=cut

# ======================================================================================================================
sub LoadConfigurationOptions
{

	# Local declarations
	my $FileName;
	my @Lines;
	my $Flag;
	my $rc;

	# Initialize the configuration options in the hash
	$ConfigOptions{"RDBMSType"}              = "";
	$ConfigOptions{"TargetConnectionString"} = "";
	$ConfigOptions{"TargetInstance"}         = "";
	$ConfigOptions{"TargetSchema"}           = "";
	$ConfigOptions{"TargetUserID"}           = "";
	$ConfigOptions{"TargetPassword"}         = "";
	$ConfigOptions{"SourceSchema"}           = "";
	$ConfigOptions{"DBLinkName"}             = "";
	$ConfigOptions{"IncludeTablenames"}      = "";
	$ConfigOptions{"ExcludeTablenames"}      = "";
	$ConfigOptions{"IncludeColumns"}         = "";
	$ConfigOptions{"ExcludeColumns"}         = "";
	$ConfigOptions{"TestOnly"}               = "0";

	if ($#ARGV < 1)
	{
		Help;
		exit;
	}

	# Get the parameter filename option
	$rc = GetOptions( 'p=s' => \$FileName );
	if ( $rc != 1 )
	{
		confess "Unable to get parameter option -p for the configuration filename\n";
	}

	# Read the config file into an array.
	if ( -e $FileName )
	{
		open( FH, "<$FileName" );
		@Lines = <FH>;
		close(FH);
	}
	else
	{
		confess "Unable to open the configuration options file $FileName for input";
	}

	# Process the lines in the file.
	foreach my $line (@Lines)
	{

		# Skip comments.  First character is a # sign.
		next if ( $line =~ m{^#} );

		# Trim leading and trailing blanks
		$line =~ s{^\s+}{};
		$line =~ s{\s+$}{};

		# Remove carriage returns and line feeds.
		$line =~ s{\n}{};
		$line =~ s{\r}{};

		# Skip the line if it is blank
		next if length($line) < 1;

		# Parse out the name=value pair
		my ( $Option, $Value ) = $line =~ m{(\w+) # a word
				   \s* # 0 or more blanks
				   = # an equal sign
				   \s* # 0 or more blanks
				   (.*?) # 0 or more characters
				   \s*$ # 0 or more blanks to end of string
				   }x;

		# Make sure the key is defined in the configuration hash
		if ( !defined $ConfigOptions{$Option} )
		{
			confess "Unknown key value in parameter file.  Key=$Option   Value=$Value\n";
		}

		# If the option is the target connection string, handle it differently as we need to parse out the instance,
		# userid and password.
		if ( $Option =~ /TargetConnectionString/i )
		{
			my ( $UserID, $Password, $Instance ) = $Value =~ m{(\S+) # Non blank string
															  \/ # a forward slash
															  (\S+) # non blank string
															  @ # an asterik
															  (\S+) # non blank string
															  }x;
			$ConfigOptions{"TargetConnectionString"} = $Value;
			$ConfigOptions{"TargetUserID"}           = $UserID;
			$ConfigOptions{"TargetPassword"}         = $Password;
			$ConfigOptions{"TargetInstance"}         = $Instance;

		}

		# Otherwise just set the options value.
		else
		{
			$ConfigOptions{$Option} = $Value;
		}
	}

	# Validate that the config options were specified.
	$Flag = 0;
	foreach my $Option ( keys %ConfigOptions )
	{
		if ( $ConfigOptions{$Option} eq "" )
		{
			if ( $Option =~ /DBLinkName|IncludeTablenames|ExcludeTablenames|IncludeColumns|ExcludeColumns|TestOnly/i )
			{
			}
			else
			{
				cluck "Configuration option $Option was not set.\n";
				$Flag = 1;
			}
		}
	}

	if ( $Flag == 1 )
	{
		confess "Unable to continue since configuration options were not set\n";
	}
	
	# Finished
	return;
}

sub LoadXMLConfigurationOptions
{
	my $rc;
	my $FileName;
	my $XML;
	my $XMLRef;
	my $Temp;
	my $Ary;

	# Initialize the configuration options in the hash
	$ConfigOptions{"RDBMSType"}              = "";
	$ConfigOptions{"TargetConnectionString"} = "";
	$ConfigOptions{"TargetInstance"}         = "";
	$ConfigOptions{"TargetSchema"}           = "";
	$ConfigOptions{"TargetUserID"}           = "";
	$ConfigOptions{"TargetPassword"}         = "";
	$ConfigOptions{"SourceSchema"}           = "";
	$ConfigOptions{"DBLinkName"}             = "";
	$ConfigOptions{"IncludeTablenames"}      = "";
	$ConfigOptions{"ExcludeTablenames"}      = "";
	$ConfigOptions{"IncludeColumns"}         = "";
	$ConfigOptions{"ExcludeColumns"}         = "";
	$ConfigOptions{"TestOnly"}               = "0";
	
	if ($#ARGV < 1)
	{
		Help;
		exit;
	}

	# Get the parameter filename option
	$rc = GetOptions( 'p=s' => \$FileName );
	if ( $rc != 1 )
	{
		confess "Unable to get parameter option -p for the configuration filename\n";
	}

	# Read the config file into an array.
	if (! -e $FileName )
	{
		confess "Unable to open the configuration options file $FileName for input";
	}

	$XML    = XML::Simple->new();
	$XMLRef = $XML->XMLin("$FileName");
	
	if (defined $XMLRef->{RDBMSType})
	{
		$ConfigOptions{"RDBMSType"} = $XMLRef->{RDBMSType};
	}
	
	if (defined $XMLRef->{TargetConnectionString})
	{
		$ConfigOptions{"TargetConnectionString"} = $XMLRef->{TargetConnectionString};
	}
	
	if (defined $XMLRef->{TargetInstance})
	{
		$ConfigOptions{"TargetInstance"} = $XMLRef->{TargetInstance};
	}
	
	if (defined $XMLRef->{TargetSchema})
	{
		$ConfigOptions{"TargetSchema"} = $XMLRef->{TargetSchema};
	}
	
	if (defined $XMLRef->{TargetUserID})
	{
		$ConfigOptions{"TargetUserID"} = $XMLRef->{TargetUserID};
	}
	
	if (defined $XMLRef->{TargetPassword})
	{
		$ConfigOptions{"TargetPassword"} = $XMLRef->{TargetPassword};
	}
	
	if (defined $XMLRef->{SourceSchema})
	{
		$ConfigOptions{"SourceSchema"} = $XMLRef->{SourceSchema};
	}
	
	if (defined $XMLRef->{DBLinkName})
	{
		$ConfigOptions{"DBLinkName"} = $XMLRef->{DBLinkName};
	}
	
	$Ary = $XMLRef->{IncludeTablename};
	if (ref $Ary eq 'HASH')
	{
		$Ary = ();
	} elsif ($Ary eq 'SCALAR')
	{
		$Ary = ( $Ary );
	}
	$Temp = "";
	for my $TableName ( @$Ary )
	{
		$Temp .= $TableName . ",";
	}
	chop($Temp);
	$ConfigOptions{"IncludeTablenames"} = $Temp;
	
	$Ary = $XMLRef->{ExcludeTablename};
	if (ref $Ary eq 'HASH')
	{
		$Ary = ();
	} elsif ($Ary eq 'SCALAR')
	{
		$Ary = ( $Ary );
	}
	$Temp = "";
	for my $TableName ( @$Ary )
	{
		$Temp .= $TableName . ",";
	}
	chop($Temp);
	$ConfigOptions{"ExcludeTablenames"} = $Temp;
	
	$Ary = $XMLRef->{IncludeColumn};
	if (ref $Ary eq 'HASH')
	{
		$Ary = ();
	} elsif ($Ary eq 'SCALAR')
	{
		$Ary = ( $Ary );
	}
	$Temp = "";
	for my $Column ( @$Ary ) 
	{
		$Temp .= $Column . ",";
	}
	chop($Temp);
	$ConfigOptions{"IncludeColumns"} = $Temp;
	
	$Ary = $XMLRef->{ExcludeColumn};
	
	my $Crap = ref $Ary; 
	
	if (ref $Ary eq 'HASH')
	{
		$Ary = ();
	} elsif ($Ary eq 'SCALAR')
	{
		$Ary = ( $Ary );
	}
	$Temp = "";
	for my $Column ( $Ary )
	{
		$Temp .= $Column . ",";
	}
	chop($Temp);
	$ConfigOptions{"ExcludeColumns"} = $Temp;
	
	if (defined $XMLRef->{TestOnly})
	{
		$ConfigOptions{"TestOnly"} = $XMLRef->{TestOnly};
	}
	
	return 0;
}

# ======================================================================================================================

=pod

=head2 GetTablesToCompare

=head3 Description

	This routine will get the table names to compare and return the table names
	in a hash. The hash is keyed by the table name and the data is an include/exclude
	flag, 1 for include, 0 for exclude.

=head3 Parameters

	$TRGDBH - Target DBI database handle
	$RDBMSType  - Type of RDBMS
	$Schema - Schema name from which to get the table names

=head3 Returns

	Hash of table names

=cut

# ======================================================================================================================
sub GetTablesToCompare($$$)
{

	# Get the arguments
	my ( $TRGDBH, $RDBMSType, $Schema ) = @_;

	# Local declarations
	my %Tables;
	my $SELECT_TABLENAMES_SQL;
	my $SQL;
	my $DBLink;
	my $STH;
	my @Data;

	# For the target schema, get all the tablenames
	# ---------------------------------------------

	# Construct the SQL to get all the tablenames from target
	if ( $RDBMSType eq "ORACLE" )
	{
		$SQL
			= "select at.table_name from sys.all_tables at where at.owner = '$Schema' and at.temporary = 'N' order by at.table_name";
	}
	elsif ( $RDBMSType eq "SQLSERVER" )
	{
		$SQL = "select so.name from sysobjects so where so.type = 'U' order by so.name";
	}

	# Prepare the statement.
	$STH = $TRGDBH->prepare($SQL) or confess "Couldn't prepare statement $SQL : $TRGDBH->errstr";

	# Get the table names in schema
	$STH->execute() or confess "Couldn't execute statement $SQL : $STH->errstr";
	while ( @Data = $STH->fetchrow_array() )
	{
		if ( $TRGDBH->err )
		{
			confess "Unable to fetchrow_array for table names\n";
		}

		# Add the table name to the hash. Index 2 is the table name.
		$Tables{ $Data[0] } = 1;
	}

	# Close the statement handle.
	$STH->finish or confess "Couldn't execute finish: $SQL : $STH->errstr";

	# Handle tables specified to be included.
	if ( length( $ConfigOptions{"IncludeTablenames"} ) > 0 )
	{
		my @IncludeTables = split( /,/, $ConfigOptions{"IncludeTablenames"} );
		foreach my $Table ( keys %Tables )
		{
			$Tables{$Table} = 0;
		}
		foreach my $Table (@IncludeTables)
		{
			if ( exists $Tables{$Table} )
			{
				$Tables{$Table} = 1;
			}
			else
			{
				confess "IncludeTable $Table is not a table in the schema. This entry has been ignored\n";
			}
		}
	}

	# Handle tables specified to be excluded.
	if ( length( $ConfigOptions{"ExcludeTablenames"} ) > 0 )
	{
		my @ExcludeTables = split( /,/, $ConfigOptions{"ExcludeTablenames"} );
		foreach my $Table (@ExcludeTables)
		{
			if ( exists $Tables{$Table} )
			{
				$Tables{$Table} = 0;
			}
			else
			{
				confess "ExcludeTable $Table is not a table in the schema. This entry has been ignored\n";
			}
		}
	}

	# Return the hash of tables to process.
	return %Tables;
}

# ======================================================================================================================

=pod

=head2 GetTableColumns

=head3 Description

	This routine will get the column names for the received table and return them
	in a hash. The hash is keyed by the column name and the data is an flag indicating
	the column must be handle as a quoted field, 1 for quoted, 0 for unquoted.

=head3 Parameters

	$TRGDBH - Target DBI database handle
	$RDBMSType  - Type of RDBMS
	$Schema - Target schema name in the target instance
	$Table  - Table name in $Schema
	$Error  - Error flag. Initialized to zero (0). Set to one (1) if the table has CLOB/BLOB/LONG fields

=head3 Returns

	Hash of Column names.

=cut

# ======================================================================================================================
sub GetTableColumns($$$$$)
{

	# Get the arguments
	my ( $TRGDBH, $RDBMSType, $Schema, $Table, $Error ) = @_;

	# Local declarations
	my %Columns;
	tie %Columns, "Tie::IxHash";    # Keep insertion order
	my $STH;
	my @Data;

	# Initialized the error flag
	$$Error = 0;

	# Get the column information
	if ( $RDBMSType eq "ORACLE" )
	{
		$STH = $TRGDBH->column_info( undef, $Schema, $Table, undef );
	}
	elsif ( $RDBMSType eq "SQLSERVER" )
	{
		$STH = $TRGDBH->column_info( $Schema, undef, $Table, undef );
	}
	if ( $TRGDBH->err )
	{
		confess "Unable to get column_info\n";
	}

	# Process the column information
	while ( @Data = $STH->fetchrow_array() )
	{
		if ( $TRGDBH->err )
		{
			confess "Unable to fetchrow_array for column information\n";
		}

		# If the column should be included...
		# If the column is a LOB or LONG data type, flag the table as in error
		#if ( $Data[5] =~ /CLOB|BLOB|LONG/i )
		#{
		#	$$Error = 1;
		#	last;
		#}

		# Create the hash entry for the column with the data being 1 if the field should be quoted on an insert, update
		# or delete, otherwise a 0.
		#if ( $Data[5] =~ /char|date|time/i )
		if ( $Data[5] =~ /char|date|time|lob|raw/i )
		{
			$Columns{ $Data[3] } = 1;
		}
		else
		{
			$Columns{ $Data[3] } = 0;
		}
	}

	# Return the hash
	return %Columns;
}

# ======================================================================================================================

=pod

=head2 IndexOfField

=head3 Description

	This routine will return the index of the Column name in the hash or undef

=head3 Parameters

	$Columns  - Hash of the tables columns
	$Column   - Name of column of which to find the index

=head3 Returns

	Index of column or undef

=cut

# ======================================================================================================================
sub IndexOfField(%$)
{
	my ( $Columns, $Column ) = @_;

	my $IntIdx = -1;

	foreach my $Col ( keys %$Columns )
	{
		$IntIdx++;

		if ( $Col eq $Column )
		{
			return ($IntIdx);
		}
	}

	return (undef);
}

# ======================================================================================================================

=pod

=head2 FilterColumns

=head3 Description

	This routine will filter the tables columns hash based on the users include and exclude of columns.

=head3 Parameters

	$Columns  - Hash of the tables columns

=head3 Returns

	Hash of tables columns subset.

=cut

# ======================================================================================================================
sub FilterColumns(%)
{
	my ($Columns) = @_;

	my %ColumnsSubset;
	tie %ColumnsSubset, "Tie::IxHash";    # Keep insertion order
	my @IncludeColumns;
	my @ExcludeColumns;
	my @TempColumns;

	# Split the $IncludeColumns and $ExcludeColumns up by commas
	@IncludeColumns = split( m{,}, $ConfigOptions{"IncludeColumns"} );
	@ExcludeColumns = split( m{,}, $ConfigOptions{"ExcludeColumns"} );

	# Process the include columns trimming spaces, linefeeds and carriage returns, and construct a regular expression
	# replacing an asterik with the regular expression \S*
	foreach my $IncCol (@IncludeColumns)
	{

		# Trim leading and trailing blanks
		$IncCol =~ s{^\s+}{};
		$IncCol =~ s{\s+$}{};

		# Remove carriage returns and line feeds.
		$IncCol =~ s{\n}{};
		$IncCol =~ s{\r}{};

		# Escape the * with a backslash to set it up for usage as a regular expression.
		if ( $IncCol =~ m{\*} )
		{
			$IncCol =~ s{\*}{\\S*}g;
		}
		else
		{

			# Match it exactly
			$IncCol = "\\A" . $IncCol . "\\Z";
		}
	}

	# Process the exclude columns trimming spaces, linefeeds and carriage returns, and construct a regular expression
	# replacing an asterik with the regular expression \S*
	foreach my $ExCol (@ExcludeColumns)
	{

		# Trim leading and trailing blanks
		$ExCol =~ s{^\s+}{};
		$ExCol =~ s{\s+$}{};

		# Remove carriage returns and line feeds.
		$ExCol =~ s{\n}{};
		$ExCol =~ s{\r}{};

		# Escape the * with a backslash to set it up for
		# usage as a regular expression.
		if ( $ExCol =~ m{\*} )
		{
			$ExCol =~ s{\*}{\\S*}g;
		}
		else
		{

			# Match it exactly
			$ExCol = "\\A" . $ExCol . "\\Z";
		}
	}

	# If the user specified specific columns to include ...
	if ( length( $ConfigOptions{"IncludeColumns"} ) > 0 )
	{

		# Build an array of the columns to include
		foreach my $Col ( keys %$Columns )
		{
			for ( my $intCol = 0 ; $intCol < $#IncludeColumns ; $intCol++ )
			{
				if ( $Col =~ $IncludeColumns[$intCol] )
				{
					push @TempColumns, $Col;
				}
			}
		}
	}

	# Otherwise build the array with all columns
	else
	{
		foreach my $Col ( keys %$Columns )
		{
			push @TempColumns, $Col;
		}
	}

	# If the user specified columns to exclude ...
	if ( length( $ConfigOptions{"ExcludeColumns"} ) > 0 )
	{

		# Iterate over the columns and blank the column name in the array if it is excluded
		for ( my $intCol = 0 ; $intCol <= $#TempColumns ; $intCol++ )
		{
			for ( my $intEx = 0 ; $intEx <= scalar(@ExcludeColumns) - 1 ; $intEx++ )
			{
				if ( $TempColumns[$intCol] =~ $ExcludeColumns[$intEx] )
				{
					$TempColumns[$intCol] = "";
				}
			}
		}
	}

	# Now build the new hash for the columns subset.
	for ( my $intCol = 0 ; $intCol <= $#TempColumns ; $intCol++ )
	{
		if ( $TempColumns[$intCol] ne "" )
		{
			$ColumnsSubset{ $TempColumns[$intCol] } = $$Columns{ $TempColumns[$intCol] };
		}
	}

	# Return the hash
	return %ColumnsSubset;
}

# ======================================================================================================================

=pod

=head2 QuoteFieldIfNeeded

=head3 Description

	This routine will quote the data value received based on the %Columns hash column
	quote flag.

=head3 Parameters

	$Columns - Hash of column names
	$Column  - The column name
	$Value   - The data value of the Column

=head3 Returns

	The quoted or unquoted value.

=cut

# ======================================================================================================================
sub QuoteFieldIfNeeded(%$$)
{

	# Get the arguments
	my ( $Columns, $Column, $Value ) = @_;

	# If the column was flagged as quoted data, quote the data
	if ( $$Columns{$Column} == 1 )
	{

		# First change any embedded quote to be quoted.
		$Value =~ s/'/''/g;

		return "'" . $Value . "'";
	}

	# Otherwise return what we received.
	else
	{
		return $Value;
	}
}

# ======================================================================================================================

=pod

=head2 BuildDeleteSQL

=head3 Description

	This routine will compare the data in the specified table between the schemas and generate
	the DDL delete statements for rows present in the target schema table but not in the source schema table.

=head3 Parameters

	$SQLFILE    - File handle for the SQL output file
	$TRGDBH     - Target DBI database handle
	$RDBMSType  - Type of RDBMS
	$Statistics - Hash keyed by table name for statistics
	$Table      - Table name in target schema
	$PKColumns  - Array of primary key column names
	$Columns    - Hash of column names

=head3 Returns

	None

=cut

# ======================================================================================================================
sub BuildDeleteSQL($$%$@%)
{

	# Get the arguments
	my ( $SQLFILE, $TRGDBH, $RDBMSType, $Statistics, $Table, $PKColumns, $Columns ) = @_;

	# Local declarations
	my $DBLink;
	my $SourceSchema;
	my $TargetSchema;
	my $DeleteCount;
	my $SQLDelimeter;
	my $SQL;
	my $STH;
	my @Data;
	my $Temp;
	my $Col;
	my $Val;
	my $IntIdx;

	# Get configuration information.
	$DBLink       = $ConfigOptions{"DBLinkName"};
	$TargetSchema = $ConfigOptions{"TargetSchema"};
	$SourceSchema = $ConfigOptions{"SourceSchema"};

	# ORACLE
	if ( $RDBMSType eq "ORACLE" )
	{
		$SQLDelimeter = "/";

		# Construct the columns used for the minus command.
		# These are the primary key columns.
		$Temp = "";
		foreach my $Column (@$PKColumns)
		{
			$Temp = $Temp . $Column . ",";
		}
		chop($Temp);

		$SQL = "Select $Temp From ${TargetSchema}.$Table Minus Select $Temp From ${SourceSchema}.$Table";
		if ( length($DBLink) > 0 )
		{
			$SQL = $SQL . "\@${DBLink}";
		}
	}

	# SQLSERVER
	elsif ( $RDBMSType eq "SQLSERVER" )
	{
		$SQLDelimeter = ";";

		$SQL = "Select ";
		foreach my $Column (@$PKColumns)
		{
			$SQL = $SQL . "t.[${Column}],";
		}
		chop($SQL);

		$SQL = $SQL . " From ${TargetSchema}.dbo.$Table t Where not exists (Select null from ${SourceSchema}.dbo.$Table s Where ";

		foreach my $Column (@$PKColumns)
		{
			$SQL = $SQL . " t.[${Column}] = s.[${Column}] and ";
		}
		$SQL = substr( $SQL, 0, length($SQL) - 5 );
		$SQL = $SQL . ")";
	}

	# Count of delete statements created
	$DeleteCount = 0;

	# Prepare the statement
	$STH = $TRGDBH->prepare($SQL) or confess "Couldn't prepare statement $SQL : $TRGDBH->errstr";

	# Execute the statement.
	$STH->execute() or confess "Couldn't execute statement $SQL : $STH->errstr";

	# For each of the rows found in the target schema but not the source schema, construct the delete for the row.
	while ( @Data = $STH->fetchrow_array() )
	{
		if ( $TRGDBH->err )
		{
			confess "Unable to fetchrow_array for delete DDL\n";
		}

		# Construct the Delete clause
		if ($RDBMSType eq "SQLSERVER")
		{
			$SQL = "Delete from [dbo].[$Table] Where ";
		}
		elsif ($RDBMSType eq "ORACLE")
		{
			$SQL = "Delete from $Table Where ";
		}

		# Construct the Where clause
		for ( $IntIdx = 0 ; $IntIdx <= $#{$PKColumns} ; $IntIdx++ )
		{
			$Col = @$PKColumns[$IntIdx];
			$Val = QuoteFieldIfNeeded( $Columns, $Col, $Data[$IntIdx] );

			if ( $RDBMSType eq "SQLSERVER" )
			{
				$SQL = $SQL . "[" . @$PKColumns[$IntIdx] . "] = " . $Val;
			}
			elsif ( $RDBMSType eq "ORACLE" )
			{
				$SQL = $SQL . @$PKColumns[$IntIdx] . " = " . $Val;
			}

			if ( $IntIdx < $#{$PKColumns} )
			{
				$SQL = $SQL . " And ";
			}
		}

		# Write the SQL to the file
		print $SQLFILE "$SQL\n$SQLDelimeter\n";

		# Increment count of delete statements
		$DeleteCount++;
	}

	# Finished with the hande.
	$STH->finish;
	
	# Store the delete count
	$$Statistics{"$Table"}{"Deletes"} = $DeleteCount;

	# Finished
	return;
}

# ======================================================================================================================

=pod

=head2 BuildInsertSQL

=head3 Description

	This routine will compare the data in the specified table between the schemas and generate
	the DDL insert statements for rows present in the source schema table but not in the target schema table.

=head3 Parameters

	$SQLFILE    - File handle for the SQL output file
	$TRGDBH     - Target DBI database handle
	$RDBMSType  - Type of RDBMS
	$Statistics - Hash keyed by table name for statistics
	$Table      - Table name in target schema
	$PKColumns  - Array of primary key column names
	$Columns    - Hash of column names

=head3 Returns

	None

=cut

# ======================================================================================================================
sub BuildInsertSQL($$%$@%)
{

	# Get the arguments
	my ( $SQLFILE, $TRGDBH, $RDBMSType, $Statistics, $Table, $PKColumns, $Columns ) = @_;

	# Local declarations
	my $DBLink;
	my $SourceSchema;
	my $TargetSchema;
	my $InsertCount;
	my $SQL;
	my $SQLDelimiter;
	my $STH;
	my $STH_SELECT_ROW_BY_PK;
	my @Data;
	my $Temp;
	my $IntIdx;
	my $Col;
	my $Val;
	my @RowData;

	# Get configuration information.
	$DBLink       = $ConfigOptions{"DBLinkName"};
	$TargetSchema = $ConfigOptions{"TargetSchema"};
	$SourceSchema = $ConfigOptions{"SourceSchema"};

	# Prepare a select statement for this table to retrieve all the fields for a row by primary key fields.

	# Oracle
	if ( $RDBMSType eq "ORACLE" )
	{

		# Construct the Select clause
		$SQLDelimiter = "/";
		$SQL          = "Select ";
		foreach my $Col ( keys %$Columns )
		{
			$SQL = $SQL . $Col . ",";
		}

		# Get rid of the last comma
		chop($SQL);

		# Construct the From clause
		$SQL = $SQL . " From ${SourceSchema}.${Table}";
		if ( length($DBLink) > 0 )
		{
			$SQL = $SQL . "\@${DBLink} ";
		}

		# Construct the Where clause
		$SQL = $SQL . " Where ";
		for ( $IntIdx = 0 ; $IntIdx <= $#{$PKColumns} ; $IntIdx++ )
		{
			$Col = @$PKColumns[$IntIdx];
			$SQL = $SQL . @$PKColumns[$IntIdx] . " = ?";
			if ( $IntIdx < $#{$PKColumns} )
			{
				$SQL = $SQL . " And ";
			}
		}

		# Now prepare the statement and cache it.
		$STH_SELECT_ROW_BY_PK = $TRGDBH->prepare_cached($SQL) or confess "Couldn't prepare statement $SQL : $TRGDBH->errstr";
	}

	# SQLSERVER
	elsif ( $RDBMSType eq "SQLSERVER" )
	{

		# Construct the Select clause
		$SQLDelimiter = ";";
		$SQL          = "Select ";
		foreach my $Col ( keys %$Columns )
		{
			$SQL = $SQL . "[" . $Col . "],";
		}

		# Get rid of the last comma
		chop($SQL);

		# Construct the from clause
		$SQL = $SQL . " From ${SourceSchema}.dbo.$Table";

		# Construct the Where clause
		$SQL = $SQL . " Where ";
		for ( $IntIdx = 0 ; $IntIdx <= $#{$PKColumns} ; $IntIdx++ )
		{
			$Col = @$PKColumns[$IntIdx];
			$SQL = $SQL . "[" . @$PKColumns[$IntIdx] . "] = ?";
			if ( $IntIdx < $#{$PKColumns} )
			{
				$SQL = $SQL . " And ";
			}
		}

		# Now prepare the statement.
		$STH_SELECT_ROW_BY_PK = $TRGDBH->prepare_cached( $SQL, { ado_cursortype => 'adOpenStatic' } )
			or confess "Couldn't prepare statement $SQL : $TRGDBH->errstr";
	}

	# Oracle
	if ( $RDBMSType eq "ORACLE" )
	{

		# Construct the columns used for the minus command. These are the primary key columns.
		$Temp = "";
		foreach my $Column (@$PKColumns)
		{
			$Temp = $Temp . $Column . ",";
		}
		chop($Temp);

		# Construct the Select minus Select SQL.
		$SQL = "Select $Temp From ${SourceSchema}.$Table";
		if ( length($DBLink) > 0 )
		{
			$SQL = $SQL . "\@${DBLink} ";
		}
		$SQL = $SQL . " Minus Select $Temp From ${TargetSchema}.$Table";
	}

	# SQLServer
	elsif ( $RDBMSType eq "SQLSERVER" )
	{

		# Construct the select from the source by primary key
		$SQL = "Select ";
		foreach my $Column (@$PKColumns)
		{
			$SQL = $SQL . "s.[${Column}],";
		}
		chop($SQL);

		# Construct the From clause from the source schema
		$SQL = $SQL . " From ${SourceSchema}.dbo.$Table s ";

		# Construct the Where clause where the PK is not found in the target.
		$SQL = $SQL . "Where not exists (Select null from ${TargetSchema}.dbo.$Table t Where ";
		foreach my $Column (@$PKColumns)
		{
			$SQL = $SQL . " t.[${Column}] = s.[${Column}] and ";
		}
		$SQL = substr( $SQL, 0, length($SQL) - 5 );
		$SQL = $SQL . ")";
	}

	# Prepare the statement
	if ( $RDBMSType eq "ORACLE" )
	{
		$STH = $TRGDBH->prepare($SQL) or confess "Couldn't prepare statement $SQL : $TRGDBH->errstr";
	}
	elsif ( $RDBMSType eq "SQLSERVER" )
	{
		$STH = $TRGDBH->prepare( $SQL, { ado_cursortype => 'adOpenStatic' } )
			or confess "Couldn't prepare statement $SQL : $TRGDBH->errstr";
	}

	# Execute the statement.
	$STH->execute() or confess "Couldn't execute statement $SQL : $STH->errstr";

	# Count of insert statements created.
	$InsertCount = 0;

	# For each of the rows found in the source schema but not the target schema, construct the insert for the row.
	while ( @Data = $STH->fetchrow_array() )
	{
		if ( $TRGDBH->err )
		{
			confess "Unable to fetchrow_array for insert DDL\n";
		}

		# We need to select the corresponding row of data. Execute the statement with the primary key fields as the
		# parameter data.
		$STH_SELECT_ROW_BY_PK->execute(@Data) or confess "Couldn't execute statement $SQL : $STH->errstr";

		# Get the row of data.
		@RowData = $STH_SELECT_ROW_BY_PK->fetchrow_array();

		# Construct the insert statement up to the values clause.
		if ( $RDBMSType eq "SQLSERVER" )
		{
			$SQL  = "Insert Into [dbo].[$Table] (";
		}
		elsif ( $RDBMSType eq "ORACLE")
		{
			$SQL  = "Insert Into $Table (";
		}
		
		$Temp = "";
		foreach my $Col ( keys %$Columns )
		{
			if ( $RDBMSType eq "SQLSERVER" )
			{
				$Temp = $Temp . "[" . $Col . "],";
			}
			elsif ( $RDBMSType eq "ORACLE")
			{
				$Temp = $Temp . $Col . ",";
			}
		}
		chop($Temp);
		$SQL = $SQL . $Temp . ") Values (";

		# Now we need the values for the insert.
		$IntIdx = 0;
		foreach my $Col ( keys %$Columns )
		{
			if ( defined $RowData[$IntIdx] )
			{
				$SQL = $SQL . QuoteFieldIfNeeded( $Columns, $Col, $RowData[$IntIdx] ) . ",";
			}
			else
			{
				$SQL = $SQL . "NULL,";
			}
			$IntIdx = $IntIdx + 1;
		}

		# Get rid of the last comma
		chop($SQL);

		# Add the trailing paren
		$SQL = $SQL . ")";

		# Write the SQL to the file
		print $SQLFILE "$SQL\n$SQLDelimiter\n";

		# Increment the count of Insert statements
		$InsertCount++;
	}

	# Finished with the statement handles
	$STH->finish;
	$STH_SELECT_ROW_BY_PK->finish;
	
	# Store the insert count
	$$Statistics{"$Table"}{"Inserts"} = $InsertCount;

	# Finished
	return;
}

# ======================================================================================================================

=pod

=head2 BuildUpdateSQL

=head3 Description

	This routine will compare the data in the specified table between the schemas and generate the DDL update statements
	for rows present in both schemas but with differing data element values. Only the fields that are different are
	included in the update DDL statement. The columns by which we compare the rows are those that are specified by the
	user via the Include or Exclude columns parameters. If neither of these are specified, all columns are used.

=head3 Parameters

	$SQLFILE    - File handle for the SQL output file
	$TRGDBH     - Target DBI database handle
	$RDBMSType  - Type of RDBMS
	$Statistics - Hash keyed by table name for statistics
	$Table      - Table name in target schema
	$PKColumns  - Array of primary key column names
	$Columns    - Hash of column names

=head3 Returns

	None

=cut

# ======================================================================================================================
sub BuildUpdateSQL($$%$@%)
{

	# Get the arguments
	my ( $SQLFILE, $TRGDBH, $RDBMSType, $Statistics, $Table, $PKColumns, $Columns ) = @_;

	# Local declarations
	my %ColumnsSubset;
	tie %ColumnsSubset, "Tie::IxHash";    # Keep insertion order
	my $SQLDelimiter;
	my $DBLink;
	my $SourceSchema;
	my $TargetSchema;
	my $SQL;
	my $STH;
	my @Data;
	my $UpdateCount;
	my $IntIdx;
	my $SrcIdx;
	my $TrgIdx;
	my $MaxCols;
	my $Col;
	my $Val;
	my @RowData;

	# Get configuration information.
	$DBLink       = $ConfigOptions{"DBLinkName"};
	$TargetSchema = $ConfigOptions{"TargetSchema"};
	$SourceSchema = $ConfigOptions{"SourceSchema"};

	# For the update we want to filter the columns to whatever the user specified as Include and Exclude columns.
	%ColumnsSubset = FilterColumns( \%$Columns );

        $IntIdx = 0;
        foreach my $Col (keys %ColumnsSubset)
        {
            $IntIdx++;
        }
        if ($IntIdx < 1)
        {
            # Store the update count
            $$Statistics{"$Table"}{"Updates"} = 0;
    
            # Finished
            return;
        }


	# Prepare a select statement for this table to retrieve all the fields for both the target and source row by primary
	# key fields.
	if ( $RDBMSType eq "ORACLE" )
	{
		$SQLDelimiter = "/";

		# Construct the Select clause
		$SQL = "Select ";
		foreach my $Col ( keys %ColumnsSubset )
		{
			$SQL = $SQL . "t1." . $Col . ",";
		}
		foreach my $Col ( keys %ColumnsSubset )
		{
			$SQL = $SQL . "t2." . $Col . ",";
		}

		# Remote trailing comma
		chop($SQL);

		# Add the From clause
		$SQL = $SQL . " From ${TargetSchema}.${Table} t1, ${SourceSchema}.${Table}";
		if ( length($DBLink) > 0 )
		{
			$SQL = $SQL . "\@${DBLink} ";
		}
		$SQL = $SQL . " t2 ";

		# Add the Where clause
		$SQL = $SQL . " Where ";

		for ( $IntIdx = 0 ; $IntIdx <= $#{$PKColumns} ; $IntIdx++ )
		{
			$Col = @$PKColumns[$IntIdx];
			$SQL = $SQL . "t1." . @$PKColumns[$IntIdx] . " = " . "t2." . @$PKColumns[$IntIdx];
			if ( $IntIdx < $#{$PKColumns} )
			{
				$SQL = $SQL . " And ";
			}
		}
	}
	elsif ( $RDBMSType eq "SQLSERVER" )
	{
		$SQLDelimiter = ";";

		# Construct the Select clause
		$SQL = "Select ";
		foreach my $Col ( keys %ColumnsSubset )
		{
			$SQL = $SQL . "t1.[" . $Col . "],";
		}
		foreach my $Col ( keys %ColumnsSubset )
		{
			$SQL = $SQL . "t2.[" . $Col . "],";
		}

		# Remote trailing comma
		chop($SQL);

		# Add the From clause
		$SQL = $SQL . " From ${TargetSchema}.[dbo].[${Table}] t1, ${SourceSchema}.[dbo].[${Table}] t2 ";

		# Add the Where clause
		$SQL = $SQL . " Where ";

		for ( $IntIdx = 0 ; $IntIdx <= $#{$PKColumns} ; $IntIdx++ )
		{
			$Col = @$PKColumns[$IntIdx];
			$SQL = $SQL . "t1.[" . @$PKColumns[$IntIdx] . "] = " . "t2.[" . @$PKColumns[$IntIdx] . "]";
			if ( $IntIdx < $#{$PKColumns} )
			{
				$SQL = $SQL . " And ";
			}
		}
	}
           
	# Prepare the statement
	$STH = $TRGDBH->prepare($SQL) or confess "Couldn't prepare statement $SQL : $TRGDBH->errstr";

	# Execute the statement.
	$STH->execute() or confess "Couldn't execute statement $SQL : $STH->errstr";

	# Get the number of columns in a single tables row
	$MaxCols = scalar( keys %ColumnsSubset );

	# Count of updates created for this table
	$UpdateCount = 0;

	# For each of the rows found, we need to compare the target fields to the source fields and construct the update
	# statement for only the fields that are different using the source fields as the update data. The where clause for
	# the update uses the primary key fields which are the same in the target and the source.
	while ( @Data = $STH->fetchrow_array() )
	{
		if ( $TRGDBH->err )
		{
			confess "Unable to fetchrow_array for update DDL\n";
		}

		# Set any undefined (null) field to the literal NULL in the data array
		foreach (@Data) { $_ = 'NULL' unless defined }

		# Initialize fields for the rows data comparison
		$SQL    = "";
		$TrgIdx = 0;

		# Loop thru the columns
		foreach $Col ( keys %ColumnsSubset )
		{

			# TrgIdx is the index to the target data column. SrcIdx is the index to the source data column. Calculate
			# the offset to the source field data.
			$SrcIdx = $TrgIdx + $MaxCols;

			# If both columns are null, skip this field
			if ( $Data[$TrgIdx] eq "NULL" and $Data[$SrcIdx] eq "NULL" )
			{
			}
			else
			{

				# Construct the update of the column data
				if ( $Data[$TrgIdx] ne $Data[$SrcIdx] )
				{
					if ( $RDBMSType eq "SQLSERVER" )
					{
						$SQL = $SQL . "[$Col] = " . QuoteFieldIfNeeded( \%ColumnsSubset, $Col, $Data[$SrcIdx] ) . ",";
					}
					elsif ( $RDBMSType eq "ORACLE" )
					{
						$SQL = $SQL . "$Col = " . QuoteFieldIfNeeded( \%ColumnsSubset, $Col, $Data[$SrcIdx] ) . ",";	
					}
				}
			}

			# Increment the source column index
			$TrgIdx++;
		}

		# If we found any updates for this row
		if ( length($SQL) > 0 )
		{

			# Get rid of the last character ( a comma )
			chop($SQL);

			# Construct the update statement
			if ( $RDBMSType eq "SQLSERVER" )
			{
				$SQL = "Update [dbo].[$Table] Set " . $SQL . " Where ";
			}
			elsif ( $RDBMSType eq "ORACLE" )
			{
				$SQL = "Update $Table Set " . $SQL . " Where ";
			}

			# Add the where clause
			for ( $IntIdx = 0 ; $IntIdx <= $#{$PKColumns} ; $IntIdx++ )
			{
				$Col = @$PKColumns[$IntIdx];

				$TrgIdx = IndexOfField( \%ColumnsSubset, $Col );
				$Val = QuoteFieldIfNeeded( \%ColumnsSubset, $Col, $Data[$TrgIdx] );

				if ( $RDBMSType eq "SQLSERVER" )
				{
					$SQL = $SQL . "[" . @$PKColumns[$IntIdx] . "] = " . $Val;
				}
				elsif ( $RDBMSType eq "ORACLE" )
				{
					$SQL = $SQL . @$PKColumns[$IntIdx] . " = " . $Val;
				}

				if ( $IntIdx < $#{$PKColumns} )
				{
					$SQL = $SQL . " And ";
				}
			}

			# Write the SQL to the file
			print $SQLFILE "$SQL\n$SQLDelimiter\n";

			# Increment the count of Update statements
			$UpdateCount++;
		}
	}

	# Finished with the statement handle
	$STH->finish;
	
	# Store the update count
	$$Statistics{"$Table"}{"Updates"} = $UpdateCount;

	# Finished
	return;
}

# ======================================================================================================================

=pod

=head2 ProcessTable

=head3 Description

	This routine will handle the comparison of a table between the target and source schema.

=head3 Parameters

	$SQLFILE    - File handle for the SQL output file
	$TRGDBH     - Target DBI database handle
	$RDBMSType  - Type of RDBMS
	$Statistics - Hash keyed by table name for statistics
	$Table      - Table name in target schema

=head3 Returns

	None

=cut

# ======================================================================================================================
sub ProcessTable($$$%$)
{

	# Get the arguments
	my ( $SQLFILE, $TRGDBH, $RDBMSType, $Statistics, $Table ) = @_;

	# Local declarations
	my %Columns;
	tie %Columns, "Tie::IxHash";    # Keep insertion order
	my @PKColumns;
	my $DBLink;
	my $SourceSchema;
	my $TargetSchema;
	my @Data;
	my $IdentityColumnFlag;
	my $Error;

	# Get configuration information.
	$DBLink       = $ConfigOptions{"DBLinkName"};
	$TargetSchema = $ConfigOptions{"TargetSchema"};
	$SourceSchema = $ConfigOptions{"SourceSchema"};

	# Initialize the statistics information for this table
	$$Statistics{"$Table"}{"Inserts"}  = 0;
	$$Statistics{"$Table"}{"Updates"}  = 0;
	$$Statistics{"$Table"}{"Deletes"}  = 0;
	$$Statistics{"$Table"}{"PKError"}  = 0;
	$$Statistics{"$Table"}{"LOBError"} = 0;

	# Get the columns for the table
	%Columns = GetTableColumns( $TRGDBH, $RDBMSType, $TargetSchema, $Table, \$Error );
	if ( $TRGDBH->err ) { confess "Unable to GetTableColumns\n"; }

	# If the table had columns that were CLOB's, BLOB's or LONG's, it should be excluded.
	if ( $Error == 1 )
	{
		$$Statistics{"$Table"}{"LOBError"} = 1;
		return;
	}

	# Get the primary key columns for the table.
	if ( $RDBMSType eq "ORACLE" )
	{
		@PKColumns = $TRGDBH->primary_key( undef, $TargetSchema, $Table );
	}
	elsif ( $RDBMSType eq "SQLSERVER" )
	{
		@PKColumns = $TRGDBH->primary_key( $TargetSchema, undef, $Table );
	}
	if ( $TRGDBH->err ) { confess "Unable to GetTableColumns\n"; }

	# If there is no primary key then the table should be excluded.
	if ( $#PKColumns == -1 )
	{
		$$Statistics{"$Table"}{"PKError"} = 1;
		return;
	}

	# Determine if the table has an identity column.
	$IdentityColumnFlag = TableHasIdentityColumn($TRGDBH, $RDBMSType, $Table);

	# If we are not just testing, build the SQL
	if ( $ConfigOptions{"TestOnly"} == "0" )
	{
	
		if ($RDBMSType eq "SQLSERVER")
		{
			if ($IdentityColumnFlag == 1)
			{
				print $SQLFILE "SET IDENTITY_INSERT [dbo].[$Table] ON\n";
			}
		}

		# Build the delete SQL
		BuildDeleteSQL( $SQLFILE, $TRGDBH, $RDBMSType, \%$Statistics, $Table, \@PKColumns, \%Columns );

		# Build the insert SQL
		BuildInsertSQL( $SQLFILE, $TRGDBH, $RDBMSType, \%$Statistics, $Table, \@PKColumns, \%Columns );

		# Build the update SQL
		BuildUpdateSQL( $SQLFILE, $TRGDBH, $RDBMSType, \%$Statistics, $Table, \@PKColumns, \%Columns );

		if ($RDBMSType eq "SQLSERVER")
		{
			if ($IdentityColumnFlag == 1)
			{
				print $SQLFILE "SET IDENTITY_INSERT [dbo].[$Table] OFF\n";
			}
		}
	}

	# Finish.
	return;
}

# ======================================================================================================================

=pod

=head2 TableHasIdentityColumn

=head3 Description

	This routine will determine if a table has a column which is an identity column.

=head3 Parameters

	$TRGDBH     - Target DBI database handle
	$RDBMSType  - Type of RDBMS
	$Table      - Table name in target schema

=head3 Returns

	0 false, 1 true.

=cut

# ======================================================================================================================
sub TableHasIdentityColumn($$$)
{
	my $STH;
	my @Data;
	my $SQL;

	# Get the parameters
	my ( $TRGDBH, $RDBMSType, $Table ) = @_;
	
	# This routine is only applicable for SQL Server
	if ($RDBMSType ne "SQLSERVER")
	{
		return 0;
	}
	
	# Construct the SQL to get the count of identity columns in the table.
	$SQL =
		"Select Count(*) from sysobjects o join syscolumns c " .
		"on o.id = c.id " .
		"where o.name = '$Table' " .
		"and   o.type = 'U' and COLUMNPROPERTY(o.id, c.name, 'IsIdentity') = 1 ";
	
	# Prepare the statement
	$STH = $TRGDBH->prepare($SQL) or confess "Couldn't prepare statement $SQL : $TRGDBH->errstr";

	# Execute the statement.
	$STH->execute() or confess "Couldn't execute statement $SQL : $STH->errstr";

	# Get the data.
	@Data = $STH->fetchrow_array();

	# Return the answer
	if ($Data[0] == 1)
	{
		return 1;
	}
	else
	{
		return 0;
	}
}

# ======================================================================================================================

=pod

=head2 CompareTables

=head3 Description

	This routine will handle the comparison the tables between the target and source schema.

=head3 Parameters

	$TRGDBH     - Target DBI database handle
	$RDBMSType  - Type of RDBMS
	$Statistics - Hash keyed by table name for statistics
	$Table      - Table name in target schema

=head3 Returns

	None

=cut

# ======================================================================================================================
sub CompareTables($$%%)
{

	# Get the arguments
	my ( $TRGDBH, $RDBMSType, $Statistics, %Tables ) = @_;

	# Local declarations
	my $SQLFILE;
	my $Filename;
	my $DateTime;
	my @Parts;

	# Open the sql output file
	$Filename = __FILE__;
	@Parts    = split( /\./, $Filename );
	$Filename = $Parts[0] . ".sql";
	open( $SQLFILE, ">$Filename" ) or die "Unable to create $Filename";

	# Write the sql file header
	$DateTime = localtime(time);
	print $SQLFILE "-- Created  Datetime $DateTime\n";
	print $SQLFILE "-- Target Instance: "
		. $ConfigOptions{"TargetInstance"}
		. "  Target Schema: "
		. $ConfigOptions{"TargetSchema"} . "\n";
	print $SQLFILE "-- Source Schema: " . $ConfigOptions{"SourceSchema"} . "\n";
	print $SQLFILE "-- DBLinkName: " . $ConfigOptions{"DBLinkName"} . "\n";
	print $SQLFILE "--\n";

	# Defer the constraints in the SQL to be created.
	if ( $RDBMSType eq "ORACLE" )
	{
		print $SQLFILE "\n";
		
		print $SQLFILE "ALTER SESSION SET CONSTRAINTS=DEFERRED\n";
		print $SQLFILE "/\n";

		print $SQLFILE "ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MON-RRRR HH:MI:SS AM'\n";
		print $SQLFILE "/\n";
		
		print $SQLFILE "ALTER SESSION SET NLS_TIME_FORMAT = 'HH.MI.SSXFF AM'\n";
		print $SQLFILE "/\n";
		
		print $SQLFILE "ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD-MON-RRRR HH.MI.SSXFF AM'\n";
		print $SQLFILE "/\n";
		
		print $SQLFILE "ALTER SESSION SET NLS_TIME_TZ_FORMAT = 'HH.MI.SSXFF AM TZR'\n";
		print $SQLFILE "/\n";
		
		print $SQLFILE "ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-RRRR HH.MI.SSXFF AM TZR'\n";
		print $SQLFILE "/\n";

		print $SQLFILE "\n";
	}
	elsif ( $RDBMSType eq "SQLSERVER" )
	{
		foreach my $Table ( sort keys %Tables )
		{
			# Make sure it should be included.
			next if ( $Tables{$Table} == 0 );
	
			print $SQLFILE "ALTER TABLE [dbo].[$Table] NOCHECK CONSTRAINT ALL\n";
		}
	}
	
	print $SQLFILE "--\n";

	# Process the tables
	foreach my $Table ( sort keys %Tables )
	{

		# Make sure it should be included.
		next if ( $Tables{$Table} == 0 );

		# Status user
		print "   Processing $Table\n";

		# Process the table
		ProcessTable( $SQLFILE, $TRGDBH, $RDBMSType, \%$Statistics, $Table );

	}

	print $SQLFILE "--\n";
	
	# Enable the constraints
	if ( $RDBMSType eq "SQLSERVER" )
	{
		foreach my $Table ( sort keys %Tables )
		{
			# Make sure it should be included.
			next if ( $Tables{$Table} == 0 );
	
			print $SQLFILE "ALTER TABLE [dbo].[$Table] CHECK CONSTRAINT ALL\n";
		}
	}
	
	# If no tables qualified just print a message to inform the user.
	if ( ( scalar keys %Tables ) < 1 )
	{
		print "   No tables qualify for inclusion\n";
	}

	# SQL file footer.
	$DateTime = localtime(time);
	print $SQLFILE "--\n";
	print $SQLFILE "-- Finished Datetime $DateTime\n";

	# Close the sql output file
	close($SQLFILE);

	# Finished.
	return;
}

# ======================================================================================================================

=pod

=head2 OracleSessionSettings

=head3 Description

	This routine will set the oracle session settings.

=head3 Parameters

	$TRGDBH - Target DBI Oracle database handle

=head3 Returns

	None

=cut

# ======================================================================================================================
sub OracleSessionSettings($)
{

	# Get the arguments
	my ($TRGDBH) = @_;

	# Set all the date time formats
	$TRGDBH->do("ALTER SESSION SET NLS_DATE_FORMAT         = 'DD-MON-RRRR HH:MI:SS AM'");
	if ( $TRGDBH->err ) { confess "Unable to set NLS_DATE_FORMAT\n"; }

	$TRGDBH->do("ALTER SESSION SET NLS_TIME_FORMAT         = 'HH.MI.SSXFF AM'");
	if ( $TRGDBH->err ) { confess "Unable to set NLS_TIME_FORMAT\n"; }

	$TRGDBH->do("ALTER SESSION SET NLS_TIMESTAMP_FORMAT    = 'DD-MON-RRRR HH.MI.SSXFF AM'");
	if ( $TRGDBH->err ) { confess "Unable to set NLS_TIMESTAMP_FORMAT\n"; }

	$TRGDBH->do("ALTER SESSION SET NLS_TIME_TZ_FORMAT      = 'HH.MI.SSXFF AM TZR'");
	if ( $TRGDBH->err ) { confess "Unable to set NLS_TIME_TZ_FORMAT\n"; }

	$TRGDBH->do("ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'DD-MON-RRRR HH.MI.SSXFF AM TZR'");
	if ( $TRGDBH->err ) { confess "Unable to set NLS_TIMESTAMP_TZ_FORMAT\n"; }

	# Finished.
	return;
}

# ======================================================================================================================

=pod

=head2 CommifyNumber

=head3 Description

	This routine will add commas to a number in string format.

=head3 Parameters

	The number in string format.

=head3 Returns

	The number in string format with commas added.

=cut

# ======================================================================================================================
sub CommifyNumber($)
{

	# Get the arguments
	my ($Number) = @_;

	# Reverse the field characters
	my $text = reverse $Number;

	# Add the commas
	$text =~ s/(\d\d\d)(?=\d)(?!\d*\.)/$1,/g;

	# Reverse it back and return it.
	return scalar reverse $text;
}

# ======================================================================================================================

=pod

=head2 GenerateReport

=head3 Description

	This routine will generate a summary report of the counts of inserts, updates and deletes
	for each table that was processed.  It will also report any table exclusions from lack of
	primary key or tables that have BLOB/CLOB/LONG columns.

=head3 Parameters

	$Statistics - Hash of statistics information

=head3 Returns

	None

=cut

# ======================================================================================================================
sub GenerateReport(%)
{

	# Get the arguments
	my ($Statistics) = @_;

	# Local declarations
	my $Table;
	my $Inserts;
	my $Updates;
	my $Deletes;
	my $PKError;
	my $LOBError;
	my $RPTFILE;
	my $Filename;
	my @Parts;
	my $DateTime;
	my $SAVEFILE;

	# Setup the top of page
	format RPTFILE_TOP =
                                                                    Table Exclusions
																	        BLOB/CLOB/
Table name                               Inserts  Updates  Deletes PK Error LONG Error
--------------------------------------- -------- -------- -------- -------- ----------
.

	# Setup the detail line
	format RPTFILE =
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< @>>>>>>> @>>>>>>> @>>>>>>> @>>>>>>> @>>>>>>>>>
$Table,$Inserts,$Updates,$Deletes,$PKError,$LOBError
.

	# Open the report file
	$Filename = __FILE__;
	@Parts    = split( /\./, $Filename );
	$Filename = $Parts[0] . ".rpt";
	open( $RPTFILE, ">$Filename" ) or die "Unable to create report filename $Filename";

	# Set the file handle for output to the report file and save the
	# current file handle.
	$SAVEFILE = select($RPTFILE);

	# Set the detail line and top of form formats for the report.
	$FORMAT_NAME     = "RPTFILE";
	$FORMAT_TOP_NAME = "RPTFILE_TOP";

	# Write the report file header
	$DateTime = localtime(time);
	print $RPTFILE "Created Datetime $DateTime\n";
	print $RPTFILE "Target Instance: "
		. $ConfigOptions{"TargetInstance"}
		. "  Target Schema: "
		. $ConfigOptions{"TargetSchema"} . "\n";
	print $RPTFILE "Source Schema: " . $ConfigOptions{"SourceSchema"} . "\n";
	print $RPTFILE "DBLinkName: " . $ConfigOptions{"DBLinkName"} . "\n";
	print $RPTFILE "\n";

	# Loop thru the tables
	foreach $Table ( sort keys %$Statistics )
	{

		# Get the statistics
		$Inserts = CommifyNumber( $$Statistics{"$Table"}{"Inserts"} );
		$Updates = CommifyNumber( $$Statistics{"$Table"}{"Updates"} );
		$Deletes = CommifyNumber( $$Statistics{"$Table"}{"Deletes"} );

		# Suppress the zero (0) printing in the summary report of the counts
		if ( $Inserts eq "0" ) { $Inserts = ""; }
		if ( $Updates eq "0" ) { $Updates = ""; }
		if ( $Deletes eq "0" ) { $Deletes = ""; }

		# Flag a table with a primary key error in the report
		if ( $$Statistics{"$Table"}{"PKError"} == 1 )
		{
			$PKError = "Yes";
		}
		else
		{
			$PKError = "";
		}

		# Flag a table with a LOB field error in the summary report
		if ( $$Statistics{"$Table"}{"LOBError"} == 1 )
		{
			$LOBError = "Yes";
		}
		else
		{
			$LOBError = "";
		}

		# Write the line
		write $RPTFILE;

	}

	# Close the report file
	close($RPTFILE);

	# Set the output file handle back to standard output.
	select($SAVEFILE);

	# Finished.
	return;
}

# ======================================================================================================================

=pod

=head2 CompareSchemas

=head3 Description

	This routine handles the establishing of a connection to the target instance,
	the comparision of the tables and report summary of comparison results.

=head3 Parameters

	None

=head3 Returns

	None

=cut

# ======================================================================================================================
sub CompareSchemas
{

	# Local declarations
	my $RDBMSType;
	my $TRGDBH;
	my $Instance;
	my $Schema;
	my $UserID;
	my $Password;
	my %TableNames;
	my %Statistics;

	# Establish a connection to the instance
	$RDBMSType = $ConfigOptions{"RDBMSType"};
	$Instance  = $ConfigOptions{"TargetInstance"};
	$Schema    = $ConfigOptions{"TargetSchema"};
	$UserID    = $ConfigOptions{"TargetUserID"};
	$Password  = $ConfigOptions{"TargetPassword"};

	if ( $RDBMSType eq "ORACLE" )
	{

		# Connect using userid and password
		$TRGDBH
			= DBI->connect( "dbi:Oracle:$Instance", "$UserID", "$Password", { RaiseError => 0, PrintError => 1, AutoCommit => 0 } );

		# Settings for Oracle
		OracleSessionSettings($TRGDBH);
	}
	elsif ( $RDBMSType eq "SQLSERVER" )
	{
		if (($UserID eq "NONE") and ($Password eq "NONE"))
		{
			# Connect using Integrated Security
			$TRGDBH = DBI->connect(
						 "dbi:ADO:Provider=SQLOLEDB.1;Data Source=$Instance;Initial Catalog=$Schema;Integrated Security=SSPI",
						 "", "", { RaiseError => 0, PrintError => 1, AutoCommit => 0 } );
		}
		else
		{
			# Connect using userid and password
			$TRGDBH = DBI->connect(
						 "dbi:ADO:Provider=SQLOLEDB.1;Data Source=$Instance;Initial Catalog=$Schema;User ID=$UserID;Password=$Password",
						 "", "", { RaiseError => 0, PrintError => 1, AutoCommit => 0 } );
		}
	}
	else
	{
		confess "RDBMSType $RDBMSType in invalid. Types are: ORACLE SQLSERVER";
	}

	if ( !defined($TRGDBH) )
	{
		confess "Unable to establish Target connection.  Please check the Target connection string specified.\n";
	}

	# Set the long read length for potential LOB like processing at 1mb
	$TRGDBH->{LongReadLen} = $MAX_LOB_SIZE;

	# Get the table names to be compared between the two schemas.
	%TableNames = GetTablesToCompare( $TRGDBH, $RDBMSType, $Schema );

	# Compare the tables in the schemas.
	CompareTables( $TRGDBH, $RDBMSType, \%Statistics, %TableNames );

	# Generate summary report
	GenerateReport( \%Statistics );

	# Disconnect from the instance
	$TRGDBH->disconnect();

	# Finished.
	return;
}

# ======================================================================================================================
# ======================================================================================================================
#                                                       M A I N
# ======================================================================================================================
# ======================================================================================================================

# Local declarations
my $DateTime;    # A date/time formatted

# Set autoflush of output to true.
$OUTPUT_AUTOFLUSH = 1;

# Status user with program name, version and current date and time
$DateTime = localtime(time);
print __FILE__, " v$VERSION start  $DateTime\n";

# Load the configuration options
#LoadXMLConfigurationOptions();
#exit 0;
LoadConfigurationOptions;

# Compare the schema data
CompareSchemas;

# Status user with program completion information
$DateTime = localtime(time);
print __FILE__, " v$VERSION finish $DateTime\n";

# Done
exit 0;
